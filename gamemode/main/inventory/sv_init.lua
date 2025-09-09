print("Inventory Loaded")
util.AddNetworkString("gRust_COD")
util.AddNetworkString("SendSlots")
util.AddNetworkString("DragNDropRust")
resource.AddSingleFile("model/tree/treemarker.png")
util.AddNetworkString("gRustWriteSlot")
hook.Add("InitPostEntity", "WipeStart", function()
    if game.GetMap() ~= "rust_highland_v1_3a" then --message pop up
        game.ConsoleCommand("changelevel rust_highland_v1_3a\n")
    end
end)

function LoadData(ply)
    if not file.IsDir("rust_slot", "DATA") then file.CreateDir("rust_slot") end
    local sid = ply:SteamID64()
    if not file.Exists("rust_slot/" .. sid .. ".txt", "DATA") then
        file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON({}), true)
        return util.JSONToTable(file.Read("rust_slot/" .. sid .. ".txt", "DATA"))
    end
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
        if slotsFilled[i] ~= i then
            freeSlot = i
            break
        end
    end
    return freeSlot
end

function CheckCorruptedData(ply)
    local data = LoadData(ply)
    local datac = false
    for k, v in pairs(data) do
        if not v.Slot and not v.model and not v.Name and not v.Amount and not v.Class then datac = true end
    end

    if datac == false then return end
    local sid = ply:SteamID64()
    file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON({}, true))
    print("filed corrupted resetting")
end

local FindWood = function(item, ply)
    local data = LoadData(ply)
    for k, v in pairs(data) do
        if v.Name == "Wood" then return v end
    end
    return nil
end

local UpdateWood = function(amount, ply)
    local data = LoadData(ply)
    for k, v in pairs(data) do
        if v.Name == "Wood" then data[k].Amount = amount end
    end
end

function SaveSystem(ply, slot, item_Tbl, oldSlot, NewSlot, amount, dnd)
    CheckCorruptedData(ply)
    oldSlot = oldSlot or -1
    NewSlot = NewSlot or -1
    if not file.IsDir("rust_slot", "DATA") then file.CreateDir("rust_slot") end
    local slotz = 1
    if dnd then
        slotz = slot
    else
        slotz = FindFreeSlot(ply, slot)
    end

    if ply.data then table.remove(ply.data, oldSlot) end
    ply.data[slotz] = {
        Slot = slotz,
        model = item_Tbl.model,
        Name = item_Tbl.Name,
        Amount = amount,
        Class = item_Tbl.Weapon
    }

    local Wood = FindWood(item_Tbl.Name, ply)
    if Wood then
        print(item_Tbl.Stackable, amount, item_Tbl.StackSize, item_Tbl.Name, Wood.Name)
        table.remove(ply.data, slotz)
        if item_Tbl.Name == Wood.Name and item_Tbl.Stackable == true and amount >= item_Tbl.StackSize then
            UpdateWood(amount, ply)
            net.Start("gRust_COD")
            net.Send(ply)
            net.Start("SendSlots")
            net.WriteTable(ply.data)
            net.WriteFloat(oldSlot)
            net.WriteFloat(NewSlot)
            net.Send(ply)
        end
    end

    if item_Tbl.Weapon ~= "" then ply:Give(item_Tbl.Weapon) end
    local sid = ply:SteamID64()
    file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON(ply.data, true))
    timer.Simple(0.1, function()
        net.Start("gRust_COD")
        net.Send(ply)
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
    if itemz == nil then return end
    self:SetNWFloat(itemz.Name, amount)
    SaveSystem(self, slotz, itemz, 0, 0, amount, true)
end

local function DragNDrop(len, ply)
    local oldslot = net.ReadFloat()
    local newslot = net.ReadFloat()
    local displayName = net.ReadString()
    local dss = net.ReadString()
    local itemz = ITEMS:GetItem(displayName)
    ply.data[oldslot] = nil
    ply.data[newslot] = {
        Slot = slot,
        model = itemz.model,
        Name = itemz.Name,
        Class = itemz.Weapon
    }

    SaveSystem(ply, newslot, itemz, oldslot, newslot, 1, true)
end

net.Receive("DragNDropRust", DragNDrop)
-- Player metatable functions
function meta:AddItem(wep, setslot)
    self:GiveItem(wep, 1, setslot)
end

hook.Add("PlayerInitialSpawn", "SpawnMeRust", function(ply)
    if IsValid(ply) then
        ply:AddItem("rust_rock", 1)
        -- ply:AddItem("rust_hands", 0)
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
        ply:AddItem("Rock", 1)
        -- ply:AddItem("rust_hands", 0)
        net.Start("gRust_COD")
        net.Send(ply)
        timer.Simple(1, function()
            ply.data = LoadData(ply)
            --[[net.Start("SendSlots")
            net.WriteTable(ply.data)
            net.WriteFloat(1)
            net.WriteFloat(1)
            net.Send(ply)]]
        end)
    end
end)

hook.Add("PlayerDeath", "SpawnMeRust", function(ply)
    if IsValid(ply) then
        net.Start("gRust_COD")
        net.Send(ply)
        local sid = ply:SteamID64()
        file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON({}, true))
        ply.data = LoadData(ply)
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
            if istable(v) and (v.Class == str) then
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