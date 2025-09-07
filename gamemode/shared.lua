gRust = gRust or {}
if Rust.Dev then
    DeriveGamemode("sandbox")
else
    DeriveGamemode("base")
end

GM.Name = "gRust | Rust in Garry's Mod"
local IncludeDir = IncludeDir or {}

local meta = FindMetaTable("Player")
function meta:GetWood()
    return self:GetNWInt("Wood", 0)
end

function meta:GetHunger()
    return self:GetNWInt("Hunger", 0)
end

function meta:GetThirst()
    return self:GetNWInt("Thirst", 0)
end

function meta:SetHunger(amy)
    self:SetNWInt("Hunger", amy)
end

function meta:SetThirst(amy)
    self:SetNWInt("Thirst", amy)
end

local includes = function(f)
    if string.find(f, "sv_") then
        return SERVER and include(f)
    elseif string.find(f, "cl_") then
        return SERVER and AddCSLuaFile(f) or CLIENT and include(f)
    elseif string.find(f, "sh_") then
        if SERVER then
            AddCSLuaFile(f)
            return include(f)
        else
            return include(f)
        end
    end
end

IncludeDir = function(dir)
    local fol = dir .. '/'
    local files, folders = file.Find(fol .. '*', "LUA")
    for _, f in ipairs(files) do
        includes(fol .. f)
    end

    for _, f in ipairs(folders) do
        IncludeDir(dir .. '/' .. f)
    end
end

IncludeDir("rustmagic/gamemode/main")