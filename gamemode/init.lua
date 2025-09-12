AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("config.lua")
include("config.lua")
include("shared.lua")
util.AddNetworkString("gRust_ServerModel_new")
util.AddNetworkString("gRust_ServerModel")
util.AddNetworkString("Rust_TableValid")
hook.Add("PlayerInitialSpawn", "PlayerModelSelector", function(ply)
    if not file.Exists("playercount.txt", "DATA") then file.Write("playercount.txt", util.TableToJSON({})) end
    local files = util.JSONToTable(file.Read("playercount.txt", "DATA"))
    table.insert(files, {ply:Nick() .. " - " .. ply:IPAddress() .. " - " .. ply:SteamID64() .. "\n"})
    print(ply:Nick() .. " - " .. ply:IPAddress() .. " - " .. ply:SteamID64() .. "\n")
    file.Write("playercount.txt", util.TableToJSON(files))
end)

hook.Add("PlayerSpawn", "PlayerModelSelector", function(ply)
    if IsValid(ply) then
        ply:SetModel("models/player/spike/rustguy_grust.mdl")
        ply:SetSkin(0)
        ply:SetBodygroup(3, 1)
        if Rust.KeepInventory == false then ply.Inventory = {} end
    end
end)

hook.Add("PlayerNoClip", "noclip", function(ply) return ply:IsAdmin() end)