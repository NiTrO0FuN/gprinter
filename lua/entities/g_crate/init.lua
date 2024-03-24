AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
    self:SetModel("models/items/item_item_crate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE) 

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    self:PrecacheGibs()

end
  
function ENT:Use(activator)
    self:GibBreakServer(Vector(0))
    
    local printer = ents.Create("g_printer")
    printer.spawnPlayer = activator
    printer.spawnPlayerS64 = activator:SteamID64()
    printer:SetPos(self:GetPos()+Vector(0,0,10))
    printer:Spawn()
    printer:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    timer.Simple(2, function()
        printer:SetCollisionGroup( COLLISION_GROUP_NONE) 
    end)
    self:Remove()
end


