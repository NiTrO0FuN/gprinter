AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("g_printer_use")
util.AddNetworkString("g_printer_pause")
util.AddNetworkString("g_printer_take")
util.AddNetworkString("g_printer_destroyed")

local interval = 45 -- Time in sec between printing steps
local IncreaseAmount = 500 -- Amount of money to add at each printing step
local maxTTL = 4800 -- TTL in sec
local minTTL = 2200

function ENT:Initialize()
    self:SetModel("models/stromic/money_printer.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.nextSoundPlay = CurTime()
    self.interval = interval
    self.gold = false

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    self:SetActive(false)
    if math.random(1,20)==5 then
        self.gold = true
        self:SetpType(2)
        self.interval = self.interval / 3
        self:EmitSound("g/golden_printer.ogg")
        DarkRP.notify(self.spawnPlayer, 2, 3, DarkRP.getPhrase("printer.spawned_golden"))
    else
        self:SetpType(1)
    end

    -- make it stop :(
    self.TTL = math.random(minTTL,maxTTL)
    self.timeLived = 0
    
    
end

function ENT:Destruct()
    self:EmitSound("ambient/explosions/explode_4.wav",150)
    local effectdata = EffectData()
    effectdata:SetOrigin( self:GetPos() )
    util.Effect( "Explosion", effectdata )
    if IsValid(self.shooter) then
        local shooter = self.shooter
        if (shooter:Team() == TEAM_POLICE or shooter:Team() == TEAM_CHIEF or shooter:Team() == TEAM_MAYOR) and self:GetMoneyAmount() < IncreaseAmount*8 then
            shooter:addMoney(IncreaseAmount*8)
            DarkRP.notify(shooter, 3, 5, DarkRP.getPhrase("printer.cop_destroy"))
            hook.Run("gprinter_destroyed", self.gold, true, shooter, IncreaseAmount*8, self.spawnPlayerS64)
        elseif self:GetMoneyAmount()>0 then 
            DarkRP.createMoneyBag(self:GetPos(), self:GetMoneyAmount())
            hook.Run("gprinter_destroyed", self.gold, false, shooter, self:GetMoneyAmount(), self.spawnPlayerS64)
        end
    elseif self:GetMoneyAmount()>0 then DarkRP.createMoneyBag(self:GetPos(), self:GetMoneyAmount()) end
    
    net.Start("g_printer_destroyed")
        net.WriteEntity(self)
    net.Broadcast()
    if self:IsOnFire() then
        local Fire = ents.Create("fire")
        if IsValid(Fire) then
            Fire:SetPos( self:GetPos() )
            Fire:SetAngles( self:GetAngles() )
            Fire:Spawn()
        end
    end
    self:Remove()
end

function ENT:Think()
    if self:GetActive() then
        self:SetSkin(1)
        self:NextThink(CurTime())
        self:SetProgress(math.Clamp(self:GetProgress()+FrameTime()/self.interval,0,1))
        self.timeLived = self.timeLived + FrameTime()
        if self:GetProgress()>=1 then
            self:SetProgress(0)
            self:SetMoneyAmount(self:GetMoneyAmount()+IncreaseAmount) 
        end
        if CurTime() > self.nextSoundPlay then
            self:EmitSound("g/printer.ogg", 500, 100 , 0.6)
            self.nextSoundPlay=CurTime()+2+(math.random()*2) -- next sound in between 2 and 4 sec
        end
        if self.timeLived > self.TTL and not self.destroying then
            self.destroying=true
            self:Ignite(10.5, 10)
            timer.Simple(10, function() self:Destruct() end )
        end
        return true
    end
    self:SetSkin(0)
end

function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    if self.destroying then return end

    self.damage = (self.damage or 100) - dmg:GetDamage()
    if self.damage <= 0 then
        self.shooter = dmg:GetAttacker()
        self:Destruct()
    end
end

function ENT:Use(activator)
    if activator:Team() == TEAM_POLICE or activator:Team() == TEAM_CHIEF or activator:Team() == TEAM_MAYOR then 
        self:SetActive(false)
        return
    end
    net.Start("g_printer_use")
        net.WriteEntity(self)
    net.Send(activator)    
end

function ENT:takeMoney(ply)
    if not (self:GetMoneyAmount() > 0) then return end
    if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF or ply:Team() == TEAM_MAYOR then return end
    hook.Run("gprinter_take_money", self.gold, ply, self:GetMoneyAmount(), self.spawnPlayerS64)
    DarkRP.notify(ply, 0, 5, DarkRP.getPhrase("printer.took1") .. " " .. DarkRP.formatMoney(self:GetMoneyAmount()) .. " " .. DarkRP.getPhrase("printer.took2"))
    ply:addMoney(self:GetMoneyAmount())
    self:SetMoneyAmount(0)
    
end

hook.Add("PlayerButtonDown", "printerTake", function(ply, key)
    if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF or ply:Team() == TEAM_MAYOR then return end
    if key == KEY_R then
        local ent = ply:GetEyeTrace().Entity
        if IsValid(ent) then
            local distance = ply:GetPos():DistToSqr(ent:GetPos()) *0.01905*0.01905
            if ent:GetClass() == "g_printer" and distance < 4 then
                ent:takeMoney(ply)
            end
        end
    end
end)

net.Receive("g_printer_pause", function()
    local print_ent = net.ReadEntity()
    print_ent:SetActive(not print_ent:GetActive())
end)

net.Receive("g_printer_take", function(n, ply)
    local print_ent = net.ReadEntity()
    if not IsValid(print_ent) then return end
    print_ent:takeMoney(ply)
end)

