ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Category = "G"

ENT.PrintName = "G Money Printer"
ENT.Author = "NiTrO_FuN"

ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "MoneyAmount")
    self:NetworkVar("Bool", 1, "Active")
    self:NetworkVar("Float",1, "Progress")
    self:NetworkVar("Int",2,"pType") -- 1: normal, 2: golden
end