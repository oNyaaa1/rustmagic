print("Crafting")
util.AddNetworkString("CraftingAbility")
concommand.Add("SpawnOre", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then return end
    local tr = ply:GetEyeTrace()
    local ent = ents.Create("rust_orepickup")
    ent:SetPos(tr.HitPos + tr.HitNormal * 32)
    ent:Spawn()
    ent:Activate()
end)

local meta = FindMetaTable("Player")
function meta:AddCraftingObject(item)
    self:GiveItem(item, 1)
end

net.Receive("CraftingAbility", function(len, ply)
    if ply.tblOfCraft == nil then ply.tblOfCraft = {} end
    ply.tblOfCraft = net.ReadTable()
    ply:GiveItem(ply.tblOfCraft[1], 1)
    --ply:AddCraftingObject(ply.tblOfCraft[1])
end)