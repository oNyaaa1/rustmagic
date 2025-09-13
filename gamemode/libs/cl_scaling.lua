
RUST.Hud = RUST.Hud or {}
RUST.Hud.BaseWidth = 1920
RUST.Hud.BaseHeight = 1080

function RUST.Hud.Scale(value)
    local w = ScrW()
    local scaling = w / RUST.Hud.BaseWidth
    return math.Round(value * scaling)
end
