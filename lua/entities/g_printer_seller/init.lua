AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local npcLifeTime = 300 --in sec

local Price = 8000
local WaitTime = 1800 -- in seconde

local hi_speech = {"vo/npc/male01/hi01.wav","vo/npc/male01/hi02.wav"}
local cancel_speech = {"vo/npc/male01/notthemanithought01.wav","vo/npc/male01/notthemanithought02.wav"}
local sell_speech = {"vo/npc/male01/fantastic01.wav","vo/npc/male01/fantastic02.wav"}

// Don't modify under there
util.AddNetworkString("g_printer_seller_open")
util.AddNetworkString("g_printer_buy")
util.AddNetworkString("g_printer_update")
util.AddNetworkString("g_printer")

local player_printers_count = {}

function ENT:Initialize()
    self:SetModel("models/gman_high.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:SetUseType(SIMPLE_USE)
    self:DropToFloor()
    self:SetMaxYawSpeed(90)

    self:SetPrice(Price)
    self:SetWaitTime(WaitTime)
end

function ENT:OnTakeDamage()
    return false
end

function ENT:Use(activator)
    self:EmitSound(hi_speech[math.random(#hi_speech)])
    if not player_printers_count[activator:SteamID64()] then
        player_printers_count[activator:SteamID64()] = {count = 2, lastTaken=CurTime(), waiting=false}
    end
    local act_info = player_printers_count[activator:SteamID64()]
    while act_info.count<2 and CurTime()-act_info.lastTaken>self:GetWaitTime() do
        act_info.count = act_info.count+1
        act_info.lastTaken = act_info.lastTaken + self:GetWaitTime()
    end
    if act_info.count == 2 then act_info.waiting = false end

    net.Start("g_printer_seller_open")
        net.WriteInt(act_info.count, 4)
        net.WriteFloat(act_info.lastTaken)
        net.WriteEntity(self)
    net.Send(activator)   
end

net.Receive("g_printer_buy", function(n, ply)
    local S64 = ply:SteamID64()
    local npc = net.ReadEntity()

    if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_CHIEF or ply:Team() == TEAM_MAYOR then 
        DarkRP.notify(ply, 1, 3, DarkRP.getPhrase("printer_seller.cannot_buy_as_police"))
        return 
    end

    if player_printers_count[S64].count == 0 then
        DarkRP.notify(ply, 1, 3, DarkRP.getPhrase("printer_seller.cannot_buy"))
        npc:EmitSound(cancel_speech[math.random(#cancel_speech)])
    else
        // Update
        while player_printers_count[S64].count<2 and CurTime()-player_printers_count[S64].lastTaken>npc:GetWaitTime() do
            player_printers_count[S64].count = player_printers_count[S64].count+1
            player_printers_count[S64].lastTaken = player_printers_count[S64].lastTaken + npc:GetWaitTime()
        end
        if not ply:canAfford(npc:GetPrice()) then
            DarkRP.notify(ply, 1, 3, DarkRP.getPhrase("printer_seller.not_enough_money"))
            return
        end
        ply:addMoney(-npc:GetPrice())
        player_printers_count[S64].count = player_printers_count[S64].count-1
        if not player_printers_count[S64].waiting then 
            player_printers_count[S64].lastTaken = CurTime() 
            player_printers_count[S64].waiting= true
        end
        local printer_crate = ents.Create("g_crate")
        printer_crate:SetPos(npc:GetForward()*25+npc:GetPos())
        printer_crate:Spawn()
        npc:EmitSound(sell_speech[math.random(#sell_speech)])
        net.Start("g_printer_update")
            net.WriteInt(player_printers_count[S64].count, 4)
            net.WriteFloat(player_printers_count[S64].lastTaken)
        net.Send(ply)
    end
end)