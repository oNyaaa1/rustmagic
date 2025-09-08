print("Inventory Loaded")
util.AddNetworkString("gRust_COD")
util.AddNetworkString("SendSlots")
util.AddNetworkString("DragNDropRust")
resource.AddSingleFile("materials/tree/treemarker.png")
util.AddNetworkString("gRustWriteSlot")
hook.Add("InitPostEntity", "WipeStart", function()
    if game.GetMap() ~= "rust_highland_v1_3a" then --message pop up
        game.ConsoleCommand("changelevel rust_highland_v1_3a\n")
    end
end)

function LoadData(ply)
    local sid = ply:SteamID64()
    return util.JSONToTable(file.Read("rust_slot/" .. sid .. ".txt", "DATA"))
end

function FindFreeSlot(ply, slot, setslot)
    if setslot then return setslot end
    local slots = LoadData(ply)
    local freeSlot = 7
    local slotsFilled = {}
    for k, v in pairs(slots) do
        table.insert(slotsFilled, k)
    end

    for i = 1, 36 do
        if not slotsFilled[i] == i then freeSlot = i end
    end
    return freeSlot
end

function SaveSystem(ply, slot, item_Tbl, oldSlot, NewSlot, amount)
    print(item_Tbl.model)
    if item_Tbl.model == nil then return end
    oldSlot = oldSlot or -1
    NewSlot = NewSlot or -1
    if not file.IsDir("rust_slot", "DATA") then file.CreateDir("rust_slot") end
    ply.data = LoadData(ply)
    local slotz = FindFreeSlot(ply, slot)
    ply.data[slotz] = {
        Slot = slot,
        model = item_Tbl.Materials,
        Name = item_Tbl.Name,
        Amount = amount,
    }

    local sid = ply:SteamID64()
    -- Save to disk
    file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON(ply.data, true))
    -- Send updated slot table to client
    net.Start("gRust_COD")
    net.Send(ply)
    timer.Simple(0.1, function()
        net.Start("SendSlots")
        net.WriteTable(ply.data)
        net.WriteFloat(oldSlot)
        net.WriteFloat(NewSlot)
        net.Send(ply)
    end)
end

local meta = FindMetaTable("Player")
function meta:GiveItem(item, amount, setslot)
    if not IsValid(self) then return end
    local itemz = ITEMS:GetItem(item)
    local slotz = FindFreeSlot(self, slot, setslot)
    print(itemz, item, slotz)
    SaveSystem(self, slotz, itemz, 0, 0, amount)
end

local function DragNDrop(len, ply)
    local oldslot = net.ReadFloat()
    local newslot = net.ReadFloat()
    local displayName = net.ReadString()
    local itemz = ITEMS:GetItem(displayName)
    ply.data[oldslot] = nil
    ply.data[newslot] = {
        Slot = slot,
        model = itemz.model,
        Name = itemz.Name,
    }

    SaveSystem(ply, newslot, itemz, oldslot, newslot, 1)
end

net.Receive("DragNDropRust", DragNDrop)
-- Player metatable functions
function meta:AddItem(wep, setslot)
    self:GiveItem(wep, 1, setslot)
end

hook.Add("PlayerInitialSpawn", "SpawnMeRust", function(ply)
    if IsValid(ply) then
        net.Start("gRust_COD")
        net.Send(ply)
        timer.Simple(0.1, function()
            ply.data = LoadData(ply)
            net.Start("SendSlots")
            net.WriteTable(ply.data)
            net.WriteFloat(1)
            net.WriteFloat(1)
            net.Send(ply)
        end)
    end
end)

hook.Add("PlayerSpawn", "SpawnMeRust", function(ply)
    if IsValid(ply) then
        ply:AddItem("rust_rock", 1)
        ply:AddItem("rust_hands", 0)
        net.Start("gRust_COD")
        net.Send(ply)
        timer.Simple(0.1, function()
            ply.data = LoadData(ply)
            net.Start("SendSlots")
            net.WriteTable(ply.data)
            net.WriteFloat(1)
            net.WriteFloat(1)
            net.Send(ply)
        end)
    end
end)

net.Receive("gRustWriteSlot", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    -- Rate limiting
    if ply.cd == nil then ply.cd = 0 end
    if ply.cd >= CurTime() then return end
    ply.cd = CurTime() + 0.5
    local str = net.ReadString()
    if not isstring(str) or str == "" then return end
    -- Load player's saved slots
    local slots = LoadData(ply) or {}
    -- Check if player actually has this weapon in their inventory
    local hasWep = false
    if str == "rust_hands" then
        hasWep = true -- Always allow hands
    else
        for _, v in pairs(slots) do
            if istable(v) and (v.Name == str) then
                hasWep = true
                break
            end
        end
    end

    if not hasWep then return end
    -- Give and select the weapon
    if str == "rust_hands" then
        if not ply:HasWeapon("rust_hands") then ply:Give("rust_hands") end
        ply:SelectWeapon("rust_hands")
    else
        if not ply:HasWeapon(str) then ply:Give(str) end
        ply:SelectWeapon(str)
    end
end)

function GM:PlayerSetHandsModel(ply, ent) -- Choose the model for hands according to their player model.
    local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
    local info = player_manager.TranslatePlayerHands(simplemodel)
    if info then
        ent:SetModel(info.model)
        ent:SetSkin(info.skin)
        ent:SetBodyGroups(info.body)
    end
end

hook.Add("GetFallDamage", "CSSFallDamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)