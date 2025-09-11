local Hud = {}
local w, h = ScrW(), ScrH()


surface.CreateFont( "Mrust.20", {
   font = "Roboto Condensed Bold",
   size = 20,
   weight = 2000,
   antialias = true,
   shadow = false,
} )


Hud.Posx, Hud.Posy = w * 0.8, h * 0.86


local health = Material("icons/health.png", "smooth mips")
local water = Material("icons/cup.png", "smooth mips")
local food = Material("icons/food.png", "smooth mips")
local magic = Material("icons/circle.png", "smooth mips")




local function HudMrust(text,icon, x, y, anim, col)


   //draw.RoundedBox(0, Hud.Posx + x, Hud.Posy + y, w * 0.150, h * 0.0350, Color(65, 65 ,65 ,100))
   //draw.RoundedBox(0, w * 0.821 + x,  w * 0.821 + x, w * 0.120 , h * 0.030, col)
   surface.SetDrawColor(color.white)
   surface.DrawRect(Hud.Posx + x, Hud.Posy + y, w * 0.150, h * 0.0350)


   surface.SetDrawColor(col)
   surface.DrawRect(w * 0.82 + x, h * 0.862 + y, anim , h * 0.0300)

   x = x or 0
   y = y or 0
   surface.SetMaterial(icon)
   surface.SetDrawColor(color_white)
   surface.DrawTexturedRect(w * 0.804 + x, h * 0.865 + y , 24, 24)
   draw.SimpleText(text, "Mrust.20", w  * 0.829 + x, h * 0.866 + y, Color( 255, 255, 255, 255), 0)
end


hook.Add("HUDPaint", "MrRustHud", function()
    HudMrust(LocalPlayer():Health(), health, w * 0.04, h * 0.009, 230 * (LocalPlayer():Health() / 100), Color(135, 179, 60))
    HudMrust("water", water, w * 0.04, h * 0.05, 230 * (LocalPlayer():Health() / 100), Color(69, 150, 205))
    HudMrust("food", food, w * 0.04, h * 0.09, 230 * (LocalPlayer():Health() / 100), Color(192, 109, 51))
   //HudMrust(hp, magic, "Health: ", 1, 90, Color(204, 204, 255, 100))
end)


local hide = {
   ["CHudHealth"] = true,
   ["CHudAmmo"] = true,
   ["CHudWeaponSelection"] = true,
   ["CHudSecondaryAmmo"] = true,
   ["CHudCrosshair"] = true
}


hook.Add("HUDShouldDraw", "rustHide", function(name) if hide[name] then return false end end)
