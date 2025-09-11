AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.ShowHealth = true
function ENT:Initialize()
    if CLIENT then return end
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetHealth(100)
    self:SetMaxHealth(100)
end

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Health")
    self:NetworkVar("Float", 1, "MaxHealth")
    self:NetworkVar("String", 0, "CreatureType")
end

function ENT:GetDisplayName()
    return ""
end