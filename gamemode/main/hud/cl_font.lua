for k = 2, 128 do
    if k % 2 != 0 then continue end
         surface.CreateFont("RUST."..k.."px", {
             font = "Roboto Condensed Bold",
             size = k,
             weight = 2000,
             antialias = true,
             shadow = false,
         })
     end
