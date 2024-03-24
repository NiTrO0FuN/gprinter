ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Printer Seller"
ENT.Category = "G"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "WaitTime")
    self:NetworkVar("Int", 2, "Price")
end