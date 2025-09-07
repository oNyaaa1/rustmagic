print("Magic Loaded")
local meta = FindMetaTable("Player")
function meta:Charge(mana)
    self:SetNWFloat("Rust_Mana", mana or 0)
end

function meta:GetCharge(mana)
    return self:GetNWFloat("Rust_Mana", mana or 0)
end