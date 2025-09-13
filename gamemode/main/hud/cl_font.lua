    for i = 1, 128 do
        surface.CreateFont("RUST."..i.."px", {
            font = "Roboto Condensed Bold",
            size = i,
            weight = 2000,
            antialias = true,
            shadow = false,
        })
    end