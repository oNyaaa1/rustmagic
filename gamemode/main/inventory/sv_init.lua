print("Inventory Loaded")
util.AddNetworkString("gRust_COD")
util.AddNetworkString("SendSlots")
util.AddNetworkString("DragNDropRust")
util.AddNetworkString("gRustWriteSlot")
resource.AddSingleFile("model/tree/treemarker.png")
hook.Add("InitPostEntity", "WipeStart", function() if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end end)
hook.Add("GetFallDamage", "CSSFallDamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)
function FindValidSlotBackWards(ply, select_Slot)
    if select_Slot then return select_Slot end
    local SlotByDefault = 1
    local FoundSlot = false
    for i = 1, 48 do
        if ply.tbl[i] == nil then
            ply.tbl[i] = {
                SlotFree = true
            }
        end
    end

    for i = 1, 7 do
        if ply.tbl[i] and ply.tbl[i].SlotFree == true then
            SlotByDefault = i
            FoundSlot = true
            break
        end
    end

    if FoundSlot == false then
        for i = 8, 48 do
            if ply.tbl[i].SlotFree == true then
                SlotByDefault = i
                FoundSlot = true
                break
            end
        end
    end
    return SlotByDefault
end

local FindSlot = function(ply, item)
    local itemz = ITEMS:GetItem(item)
    for k, v in pairs(ply.tbl) do
        if v.Img == itemz.model then return v end
    end
    return nil
end

function PickleAdillyEdit(ply, wep, amount)
    if ply.Slots == nil then ply.Slotz = {} end
    if ply.tbl == nil then
        ply.tbl = {
            SlotFree = true
        }
    end

    local itemz = ITEMS:GetItem(wep)
    local slot = FindSlot(ply, wep)
    if slot == nil then
        print("slot == nil")
        local sloto = FindValidSlotBackWards(ply)
        ply.tbl[sloto] = {
            Slotz = sloto,
            Weapon = wep,
            Img = itemz.model,
            Amount = 0,
        }

        net.Start("DragNDropRust")
        net.WriteTable(ply.tbl)
        net.Send(ply)
        return
    end

    local slotss = 0
    local adding = false
    local editmode = false
    local CurrentAmount = 0
    for k, v in pairs(ply.tbl) do
        if v.Weapon == itemz.Name then
            local amont = v.Amount or 0
            print(amont, v.Amount)
            if amont ~= nil and amont >= 1000 then
                adding = true
                slotss = k
                CurrentAmount = amont
            elseif v.Weapon == itemz.Name and amont < 1000 then
                editmode = true
                slotss = k
                CurrentAmount = amont
                break
            end
        end
    end

    if editmode == true and slotss ~= 0 then
        print("Editing")
        ply.tbl[slotss] = {
            Slotz = slotss,
            Weapon = wep,
            Img = itemz.model,
            Amount = math.Clamp(CurrentAmount + amount, 0, itemz.StackSize),
            SlotFree = false,
        }

        net.Start("DragNDropRust")
        net.WriteTable(ply.tbl)
        net.Send(ply)
        return
    end

    if adding then
        print("Adding")
        local sloto = FindValidSlotBackWards(ply)
        ply.tbl[sloto] = {
            Slotz = sloto,
            Weapon = wep,
            Img = itemz.model,
            Amount = 0,
            SlotFree = false,
        }

        net.Start("DragNDropRust")
        net.WriteTable(ply.tbl)
        net.Send(ply)
        return
    end

    if itemz.Weapon ~= "" then ply:Give(itemz.Weapon) end
end

local meta = FindMetaTable("Player")
function meta:GiveItem(item, amount)
    PickleAdillyEdit(self, item, amount)
end

function PickleAdilly(ply, wep)
    if ply.Slots == nil then ply.Slotz = {} end
    if ply.tbl == nil then ply.tbl = {} end
    local itemz = ITEMS:GetItem(wep)
    local slot = FindValidSlotBackWards(ply, 1)
    --table.insert(ply.Slots)
    ply.tbl[slot] = {
        Slotz = slot,
        Weapon = wep,
        Img = itemz.model,
        Amount = 0,
        SlotFree = false,
    }

    if itemz.Weapon ~= "" then ply:Give(itemz.Weapon) end
    net.Start("DragNDropRust")
    net.WriteTable(ply.tbl)
    net.Send(ply)
end

net.Receive("gRustWriteSlot", function(len, ply)
    local id = net.ReadFloat()
    local NewSlot = net.ReadFloat()
    local proxy_wep = net.ReadString()
    local proxy_id = net.ReadFloat()
    local itemz = ITEMS:GetItem(proxy_wep)
    if id ~= -1 then
        ply.tbl[id] = {
            Slotz = id,
            Weapon = itemz.Name,
            Img = itemz.model,
            Amount = ply.tbl[proxy_id].Amount,
            SlotFree = false,
        }

        ply.tbl[proxy_id] = nil
        net.Start("DragNDropRust")
        net.WriteTable(ply.tbl)
        net.Send(ply)
    elseif NewSlot ~= -1 then
        ply.tbl[NewSlot] = {
            Slotz = NewSlot,
            Weapon = itemz.Name,
            Img = itemz.model,
            Amount = ply.tbl[proxy_id].Amount,
        }

        ply.tbl[proxy_id] = nil
        net.Start("DragNDropRust")
        net.WriteTable(ply.tbl)
        net.Send(ply)
    end
end)

hook.Add("PlayerSpawn", "GiveITem", function(ply) PickleAdilly(ply, "Rock") end)
hook.Add("PlayerDeath", "GiveITem", function(vic, inf, attacker)
    table.Empty(vic.tbl)
    net.Start("DragNDropRust")
    net.WriteTable(vic.tbl)
    net.Send(vic)
end)