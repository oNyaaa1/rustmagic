AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- Ore types with their models and items
local OreTypes = {
    {
        model = "models/darky_m/rust/worldmodels/stone.mdl",
        item = "Stone",
        name = "Stone",
        amount = {15, 25}
    },
    {
        model = "models/darky_m/rust/worldmodels/sulfur_ore.mdl",
        item = "Sulfur Ore",
        name = "Sulfur Ore",
        amount = {10, 20}
    },
    {
        model = "models/darky_m/rust/worldmodels/metal_ore.mdl", -- Using stone model for metal as specified
        item = "Metal Ore",
        name = "Metal Ore",
        amount = {8, 15}
    }
}

function ENT:Initialize()
    -- Choose random ore type
    self.OreType = OreTypes[math.random(1, #OreTypes)]
    self:SetModel(self.OreType.model)
    self:SetModelScale(2.5) -- Make pickups 2.5 times larger
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.CanPickup = true
    self.MaxUses = 1
    self.CurrentUses = 0
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if self.CurrentUses >= self.MaxUses then return end
    if not self.OreType then return end
    local amount = math.random(self.OreType.amount[1], self.OreType.amount[2])
    activator:GiveItem(self.OreType.item, amount)
    activator:SendNotification(self.OreType.name, NOTIFICATION_PICKUP, "materials/icons/pickup.png", "+" .. amount)
    -- Map item names to available sound groups
    local soundMap = {
        ["Stone"] = "Stone",
        ["Sulfur Ore"] = "Sulfur Ore", -- Use stone sound for sulfur ore
        ["Metal Ore"] = "Metal Ore" -- Use metal sound for metal ore
    }

    activator:EmitSound("ui/items/pickup_stone_3.wav")
    LoggerPlayer(activator, "picked up " .. amount .. " " .. self.OreType.name .. ".")
    self.CurrentUses = self.CurrentUses + 1
    self:Remove()
end

function ENT:OnRemove()
    -- Clean up any timers if needed
end