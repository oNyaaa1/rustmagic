print("Crafting")

concommand.Add("SpawnOre", function(ply,cmd,args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then return end
    local tr = ply:GetEyeTrace()
    local ent = ents.Create("rust_orepickup")
    ent:SetPos(tr.HitPos + tr.HitNormal * 32)
    ent:Spawn()
    ent:Activate()
end)