    local Hud = {}

    local health = Material("icons/health.png", "smooth mips")
    local water = Material("icons/cup.png", "smooth mips")
    local food = Material("icons/food.png", "smooth mips")
    local magic = Material("icons/circle.png", "smooth mips")

    local function RUSTHud(text, icon, x, y, ratio, col)
        local w, h = ScrW(), ScrH()

        local HudH = RUST.Hud.Scale(38) * 4 + RUST.Hud.Scale(10)
        local MinBottom = RUST.Hud.Scale(20)
        local TBottom = h * 0.05

        local Bottom = math.max(MinBottom, math.min(TBottom, HudH + MinBottom))

        Hud.Posx, Hud.Posy = w * 0.8, h - Bottom

        local panelWidth = RUST.Hud.Scale(300)
        local panelHeight = RUST.Hud.Scale(35)
        local iconSize = RUST.Hud.Scale(24)

        surface.SetDrawColor(color.white)
        surface.DrawRect(math.Round(Hud.Posx + x), math.Round(Hud.Posy + y), panelWidth, panelHeight)

        surface.SetMaterial(icon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(math.Round(Hud.Posx + x + RUST.Hud.Scale(5)), math.Round(Hud.Posy + y + RUST.Hud.Scale(6)), iconSize, iconSize)

        local barOffset = RUST.Hud.Scale(38)
        local maxBarLength = panelWidth - barOffset - RUST.Hud.Scale(12)
        local barLength = math.Round(maxBarLength * ratio)

        surface.SetDrawColor(col)
        surface.DrawRect(math.Round(Hud.Posx + x + barOffset), math.Round(Hud.Posy + y + RUST.Hud.Scale(2)), barLength, RUST.Hud.Scale(30))

        local fontSize = math.Round(RUST.Hud.Scale(20) / 2) * 2
        local fontName = "RUST." .. fontSize .. "px"

        draw.SimpleText(text, fontName, math.Round(Hud.Posx + x + RUST.Hud.Scale(42)), math.Round(Hud.Posy + y + RUST.Hud.Scale(8)), Color(255, 255, 255, 255), 0)
    end

    hook.Add("HUDPaint", "RUSTHud", function()
        local pl = LocalPlayer()
        local hp = pl:Health() / 100
        local hunger = pl:GetHunger() / 100
        local charge = pl:GetCharge() / 100
        local thirst = pl:GetThirst() / 100

        local w, h = ScrW(), ScrH()

        local startY = RUST.Hud.Scale(-110)
        local spacing = RUST.Hud.Scale(38)

        RUSTHud(math.Round(hp * 100), health, w * 0.04, startY + spacing * 0, hp, Color(135, 179, 60))
        RUSTHud(math.Round(thirst * 100), water, w * 0.04, startY + spacing * 1, thirst, Color(69, 150, 205))
        RUSTHud(math.Round(hunger * 100), food, w * 0.04, startY + spacing * 2, hunger, Color(192, 109, 51))
        RUSTHud(math.Round(charge * 100), magic, w * 0.04, startY + spacing * 3, charge, Color(204, 204, 255, 100))
    end)

    local hide = {
        ["CHudHealth"] = true,
        ["CHudAmmo"] = true,
        ["CHudWeaponSelection"] = true,
        ["CHudSecondaryAmmo"] = true,
        ["CHudCrosshair"] = true
    }

    hook.Add("HUDShouldDraw", "rustHide", function(name) if hide[name] then return false end end)
