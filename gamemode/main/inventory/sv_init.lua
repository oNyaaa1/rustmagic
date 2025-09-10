print("Inventory Loaded")
util.AddNetworkString("gRust_COD")
util.AddNetworkString("SendSlots")
util.AddNetworkString("DragNDropRust")
util.AddNetworkString("gRustWriteSlot")
resource.AddSingleFile("model/tree/treemarker.png")
hook.Add("InitPostEntity", "WipeStart", function() if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end end)
hook.Add("GetFallDamage", "CSSFallDamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)
function PickleAdilly(ply, wep)
    ply.tbl = {}
    local itemz = ITEMS:GetItem(wep)
    table.insert(ply.tbl, {
        Slotz = 1,
        Weapon = wep,
        Img = itemz.model,
    })

    if itemz.Weapon ~= "" then ply:Give(itemz.Weapon) end
    net.Start("DragNDropRust")
    net.WriteTable(ply.tbl)
    net.Send(ply)
end

hook.Add("PlayerSpawn", "GiveITem", function(ply) PickleAdilly(ply, "Rock") end)