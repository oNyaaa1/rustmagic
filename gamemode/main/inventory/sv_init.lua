print("Inventory Loaded")
-- Network strings
util.AddNetworkString("gRust_COD")
util.AddNetworkString("SendSlots")
util.AddNetworkString("DragNDropRust")
util.AddNetworkString("gRustWriteSlot")
-- Resource files
resource.AddSingleFile("model/tree/treemarker.png")
-- Map enforcement
hook.Add("InitPostEntity", "WipeStart", function() if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end end)

-- Fall damage hook
hook.Add("GetFallDamage", "CSSFallDamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)