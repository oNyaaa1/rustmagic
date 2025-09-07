local Hud = {}
local w, h = ScrW(), ScrH()
Hud.Posx, Hud.Posy = w * 0.8, h * 0.86
local health = Material("icons/health.png", "noclamp smooth")
local water = Material("icons/cup.png", "noclamp smooth")
local food = Material("icons/food.png", "noclamp smooth")
local magic = Material("icons/circle.png", "noclamp smooth")
local function zSetHealth(icon, name, x, y, col)
    draw.RoundedBox(4, Hud.Posx + x, Hud.Posy + y, 300, 26, col)
    x = x or 0
    y = y or 0
    surface.SetMaterial(icon)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(Hud.Posx + x, Hud.Posy + y, 24, 24)
end

hook.Add("HUDPaint", "MrRustHud", function()
    zSetHealth(health, "Health: ", 1, 1, Color(255, 0, 0, 100))
    zSetHealth(water, "Health: ", 1, 30, Color(24, 24, 255, 100))
    zSetHealth(food, "Health: ", 1, 60, Color(24, 255, 24, 100))
    zSetHealth(magic, "Health: ", 1, 90, Color(204, 204, 255, 100))
end)

local hide = {
    ["CHudHealth"] = true,
    ["CHudAmmo"] = true,
    ["CHudWeaponSelection"] = true
}

hook.Add("HUDShouldDraw", "rustHide", function(name) if hide[name] then return false end end)