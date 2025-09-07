RegisterItem("rust_rock", {
    Name = "Rock",
    Info = "Rock, Basic gathering tool.",
    Category = "Tools",
    Materials = "materials/items/tools/rock.png",
    Weapon = "rust_rock",
    Craft = function()
        return {
            ITEM = "Stone",
            AMOUNT = 10,
            Time = 5,
        }
    end,
})

RegisterItem("rust_rock", {
    Name = "Stone Hatchet",
    Info = "The Stone Hatchet - Basic for collecting Sheep cloths and tree gathering",
    Category = "Tools",
    Materials = "materials/items/tools/rock.png",
    Weapon = "rust_stonehatchet",
    Craft = function()
        return {
            ITEM = "Stone",
            AMOUNT = 10,
            Time = 5,
        }
    end,
})