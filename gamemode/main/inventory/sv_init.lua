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

function SaveSystem(ply, slot, displayName, oldSlot, NewSlot)
    oldSlot = oldSlot or -1
    NewSlot = NewSlot or -1
    if not file.IsDir("rust_slot", "DATA") then file.CreateDir("rust_slot") end
    ply.data = {}
    ply.data[slot] = {
        Slot = slot,
        model = "materials/items/tools/rock.png",
        Name = displayName,
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

function LoadData(ply)
    local sid = ply:SteamID64()
    return util.JSONToTable(file.Read("rust_slot/" .. sid .. ".txt", "DATA"))
end

local function DragNDrop(len, ply)
    local oldslot = net.ReadFloat()
    local newslot = net.ReadFloat()
    local displayName = net.ReadString()
    ply.data[oldslot] = nil
    ply.data[newslot] = {
        Slot = slot,
        model = "materials/items/tools/rock.png",
        Name = displayName,
    }

    SaveSystem(ply, newslot, displayName, oldslot, newslot)
end

net.Receive("DragNDropRust", DragNDrop)
local Inventory = FindMetaTable("Player")
-- Player metatable functions
function Inventory:AddItem(wep, name, slot, img)
    slot = slot or -1
    if not IsValid(self) then return end
    if not self:HasWeapon(wep) and wep ~= "" then self:Give(wep) end
    if slot == -1 then return end
    SaveSystem(self, slot, wep, slot, slot)
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
        ply:AddItem("tfa_rustalpha_rocktool", "Rock", 1, "materials/items/tools/rock.png")
        ply:AddItem("rust_hands", "Hands", -1, "")
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