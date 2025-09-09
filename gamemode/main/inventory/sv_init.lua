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
-- Data loading/saving functions
function LoadData(ply)
    if not IsValid(ply) then return {} end
    if not file.IsDir("rust_slot", "DATA") then file.CreateDir("rust_slot") end
    local sid = ply:SteamID64()
    if not file.Exists("rust_slot/" .. sid .. ".txt", "DATA") then
        local emptyData = {}
        file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON(emptyData))
        return emptyData
    end

    local fileContent = file.Read("rust_slot/" .. sid .. ".txt", "DATA")
    if not fileContent or fileContent == "" then return {} end
    local data = util.JSONToTable(fileContent)
    return data or {}
end

function SaveData(ply, data)
    if not IsValid(ply) or not data then return end
    local sid = ply:SteamID64()
    file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON(data))
end

function FindFreeSlot(ply, startSlot, setslot)
    if setslot and setslot > 0 and setslot <= 36 then return setslot end
    local slots = LoadData(ply)
    local usedSlots = {}
    -- Mark all used slots
    for k, v in pairs(slots) do
        if istable(v) and v.Slot then usedSlots[v.Slot] = true end
    end

    -- Find first free slot starting from startSlot or 7 (inventory start)
    local start = startSlot or 7
    for i = start, 36 do
        if not usedSlots[i] then return i end
    end

    -- If no slot found in inventory, try hotbar
    for i = 1, 6 do
        if not usedSlots[i] then return i end
    end
    return nil -- No free slots
end

function CheckCorruptedData(ply)
    if not IsValid(ply) then return end
    local data = LoadData(ply)
    local isCorrupted = false
    for k, v in pairs(data) do
        if not istable(v) or not v.Slot or not v.model or not v.Name or not v.Class then
            isCorrupted = true
            break
        end
    end

    if isCorrupted then
        local sid = ply:SteamID64()
        file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON({}))
        print("Player " .. ply:Nick() .. "'s inventory data was corrupted and has been reset")
        ply.data = {}
    end
end

-- Stack management functions
local function FindItemByName(itemName, ply)
    local data = LoadData(ply)
    for k, v in pairs(data) do
        if istable(v) and v.Name == itemName then return k, v end
    end
    return nil, nil
end

local function UpdateItemAmount(itemKey, amount, ply)
    if not ply.data then ply.data = LoadData(ply) end
    if ply.data[itemKey] then
        ply.data[itemKey].Amount = amount
        SaveData(ply, ply.data)
    end
end

function SaveSystem(ply, slot, item_Tbl, oldSlot, newSlot, amount, isDragDrop)
    if not IsValid(ply) or not item_Tbl then return end
    CheckCorruptedData(ply)
    oldSlot = oldSlot or -1
    newSlot = newSlot or -1
    amount = amount or 1
    if not ply.data then ply.data = LoadData(ply) end
    local targetSlot = slot
    if not isDragDrop then
        targetSlot = FindFreeSlot(ply, slot)
        if not targetSlot then
            ply:ChatPrint("Inventory is full!")
            return
        end
    end

    -- Remove item from old slot if moving
    if oldSlot > 0 and ply.data[oldSlot] then ply.data[oldSlot] = nil end
    -- Check for stacking with existing items
    local existingKey, existingItem = FindItemByName(item_Tbl.Name, ply)
    if existingItem and item_Tbl.Stackable and existingKey ~= targetSlot then
        local maxStack = item_Tbl.StackSize or 64
        local newAmount = (existingItem.Amount or 1) + amount
        if newAmount <= maxStack then
            -- Stack with existing item
            UpdateItemAmount(existingKey, newAmount, ply)
        else
            -- Split stack
            UpdateItemAmount(existingKey, maxStack, ply)
            local remainder = newAmount - maxStack
            local freeSlot = FindFreeSlot(ply, 7)
            if freeSlot then
                ply.data[freeSlot] = {
                    Slot = freeSlot,
                    model = item_Tbl.model,
                    Name = item_Tbl.Name,
                    Amount = remainder,
                    Class = item_Tbl.Weapon or item_Tbl.Class
                }
            end
        end
    else
        -- Create new item entry
        ply.data[targetSlot] = {
            Slot = targetSlot,
            model = item_Tbl.model,
            Name = item_Tbl.Name,
            Amount = amount,
            Class = item_Tbl.Weapon or item_Tbl.Class
        }
    end

    -- Give weapon if applicable
    if item_Tbl.Weapon and item_Tbl.Weapon ~= "" then if not ply:HasWeapon(item_Tbl.Weapon) then ply:Give(item_Tbl.Weapon) end end
    -- Save data
    SaveData(ply, ply.data)
    if IsValid(ply) then
        net.Start("gRust_COD")
        net.Send(ply)
        net.Start("SendSlots")
        net.WriteTable(ply.data)
        net.WriteFloat(oldSlot)
        net.WriteFloat(newSlot)
        net.Send(ply)
    end
end

-- Player metatable functions
local meta = FindMetaTable("Player")
function meta:GiveItem(itemName, amount, setslot)
    if not IsValid(self) or not ITEMS then return end
    local itemData = ITEMS:GetItem(itemName)
    if not itemData then
        print("Warning: Item '" .. tostring(itemName) .. "' not found in ITEMS table")
        return
    end

    local targetSlot = FindFreeSlot(self, 7, setslot)
    if not targetSlot then
        self:ChatPrint("Inventory is full!")
        return
    end

    amount = amount or 1
    self:SetNWFloat(itemData.Name, amount)
    SaveSystem(self, targetSlot, itemData, -1, -1, amount, setslot ~= nil)
end

function meta:AddItem(itemName, setslot)
    self:GiveItem(itemName, 1, setslot)
end

function meta:RemoveItem(itemName, amount)
    if not IsValid(self) then return false end
    amount = amount or 1
    if not self.data then self.data = LoadData(self) end
    for k, v in pairs(self.data) do
        if istable(v) and v.Name == itemName then
            local currentAmount = v.Amount or 1
            if currentAmount > amount then
                v.Amount = currentAmount - amount
                SaveData(self, self.data)
                return true
            elseif currentAmount == amount then
                self.data[k] = nil
                SaveData(self, self.data)
                return true
            end
        end
    end
    return false
end

function meta:HasItem(itemName, amount)
    if not IsValid(self) then return false end
    amount = amount or 1
    if not self.data then self.data = LoadData(self) end
    local totalAmount = 0
    for k, v in pairs(self.data) do
        if istable(v) and v.Name == itemName then totalAmount = totalAmount + (v.Amount or 1) end
    end
    return totalAmount >= amount
end

-- Network receivers
local function DragNDrop(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local oldslot = net.ReadFloat()
    local newslot = net.ReadFloat()
    local displayName = net.ReadString()
    local className = net.ReadString()
    if not ply.data then ply.data = LoadData(ply) end
    -- Find the item being moved
    local itemData = nil
    for k, v in pairs(ply.data) do
        if istable(v) and v.Slot == oldslot then
            itemData = v
            break
        end
    end

    if not itemData then return end
    -- Check if target slot is occupied
    local targetOccupied = nil
    for k, v in pairs(ply.data) do
        if istable(v) and v.Slot == newslot then
            targetOccupied = v
            break
        end
    end

    if targetOccupied then
        -- Swap items
        for k, v in pairs(ply.data) do
            if istable(v) and v.Slot == oldslot then
                v.Slot = newslot
            elseif istable(v) and v.Slot == newslot then
                v.Slot = oldslot
            end
        end
    else
        -- Move item to empty slot
        for k, v in pairs(ply.data) do
            if istable(v) and v.Slot == oldslot then
                v.Slot = newslot
                break
            end
        end
    end

    SaveData(ply, ply.data)
    if IsValid(ply) then
        net.Start("SendSlots")
        net.WriteTable(ply.data)
        net.WriteFloat(oldslot)
        net.WriteFloat(newslot)
        net.Send(ply)
    end
end

net.Receive("DragNDropRust", DragNDrop)
net.Receive("gRustWriteSlot", function(len, ply)
    if not IsValid(ply) or not ply:Alive() then return end
    -- Rate limiting
    ply.weaponCooldown = ply.weaponCooldown or 0
    if ply.weaponCooldown > CurTime() then return end
    ply.weaponCooldown = CurTime() + 0.3
    local weaponClass = net.ReadString()
    if not isstring(weaponClass) or weaponClass == "" then return end
    -- Load player's inventory
    if not ply.data then ply.data = LoadData(ply) end
    -- Check if player has this weapon in inventory
    local hasWeapon = false
    if weaponClass == "rust_hands" then
        hasWeapon = true -- Always allow hands
    else
        for _, v in pairs(ply.data) do
            if istable(v) and v.Class == weaponClass then
                hasWeapon = true
                break
            end
        end
    end

    if not hasWeapon then
        ply:ChatPrint("You don't have that item!")
        return
    end

    -- Give and select weapon
    if not ply:HasWeapon(weaponClass) then ply:Give(weaponClass) end
    timer.Simple(0.1, function() if IsValid(ply) and ply:HasWeapon(weaponClass) then ply:SelectWeapon(weaponClass) end end)
end)

-- Player spawn hooks
hook.Add("PlayerInitialSpawn", "RustInventoryInit", function(ply)
    if not IsValid(ply) then return end
    timer.Simple(1, function()
        if IsValid(ply) then
            ply.data = LoadData(ply)
            -- Give starting items if inventory is empty
            local hasItems = false
            for k, v in pairs(ply.data) do
                if istable(v) then
                    hasItems = true
                    break
                end
            end

            if not hasItems then ply:AddItem("Rock", 1) end
            net.Start("gRust_COD")
            net.Send(ply)
            timer.Simple(0.2, function()
                if IsValid(ply) then
                    net.Start("SendSlots")
                    net.WriteTable(ply.data)
                    net.WriteFloat(-1)
                    net.WriteFloat(-1)
                    net.Send(ply)
                end
            end)
        end
    end)
end)

hook.Add("PlayerSpawn", "RustInventorySpawn", function(ply)
    if not IsValid(ply) then return end
    timer.Simple(1, function()
        if IsValid(ply) then
            ply.data = LoadData(ply)
            -- Give starting items if inventory is empty
            local hasItems = false
            for k, v in pairs(ply.data) do
                if istable(v) then
                    hasItems = true
                    break
                end
            end

            if not hasItems then ply:AddItem("Rock", 1) end
            net.Start("gRust_COD")
            net.Send(ply)
            timer.Simple(0.2, function()
                if IsValid(ply) then
                    net.Start("SendSlots")
                    net.WriteTable(ply.data)
                    net.WriteFloat(-1)
                    net.WriteFloat(-1)
                    net.Send(ply)
                end
            end)
        end
    end)
end)

hook.Add("PlayerDeath", "RustInventoryDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end
    -- Clear inventory on death
    local sid = victim:SteamID64()
    file.Write("rust_slot/" .. sid .. ".txt", util.TableToJSON({}))
    victim.data = {}
    net.Start("gRust_COD")
    net.Send(victim)
end)

hook.Add("PlayerDisconnected", "RustInventoryDisconnect", function(ply) if IsValid(ply) and ply.data then SaveData(ply, ply.data) end end)
-- Hands model hook
function GM:PlayerSetHandsModel(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
    local info = player_manager.TranslatePlayerHands(simplemodel)
    if info then
        ent:SetModel(info.model)
        ent:SetSkin(info.skin)
        ent:SetBodyGroups(info.body)
    end
end

-- Fall damage hook
hook.Add("GetFallDamage", "CSSFallDamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)