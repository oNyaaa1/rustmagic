print("Inventory Loaded")
util.AddNetworkString("gRust_COD")
util.AddNetworkString("SendSlots")
util.AddNetworkString("DragNDropRust")
util.AddNetworkString("gRustWriteSlot")
resource.AddSingleFile("model/tree/treemarker.png")
hook.Add("InitPostEntity", "WipeStart", function() if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end end)
hook.Add("GetFallDamage", "CSSFallDamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)
function FindValidSlotBackWards(ply)
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

    local adding = false
    local slotz = slot.Slotz
    for k, v in pairs(ply.tbl) do
        if v.Weapon == itemz.Name then
            local amont = v.Amount or 0
            if amont ~= nil and amont >= 1000 then
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
                adding = true
            elseif v.Weapon == itemz.Name and amont < 1000 then
                print("editing", slotz, k, ply.tbl[k].Amount)
                ply.tbl[k] = {
                    Slotz = k,
                    Weapon = wep,
                    Img = itemz.model,
                    Amount = amont + amount,
                    SlotFree = false,
                }
            end
        end
    end

    if itemz.Weapon ~= "" then ply:Give(itemz.Weapon) end
    net.Start("DragNDropRust")
    net.WriteTable(ply.tbl)
    net.Send(ply)
end

function PickleAdilly(ply, wep)
    if ply.Slots == nil then ply.Slotz = {} end
    if ply.tbl == nil then ply.tbl = {} end
    local itemz = ITEMS:GetItem(wep)
    local slot = FindValidSlotBackWards(ply)
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
    ply.tbl[proxy_id] = nil
    if id ~= -1 then
        ply.tbl[id] = {
            Slotz = id,
            Weapon = itemz.Name,
            Img = itemz.model,
        }

        net.Start("DragNDropRust")
        net.WriteTable(ply.tbl)
        net.Send(ply)
    elseif NewSlot ~= -1 then
        ply.tbl[NewSlot] = {
            Slotz = NewSlot,
            Weapon = itemz.Name,
            Img = itemz.model,
        }

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