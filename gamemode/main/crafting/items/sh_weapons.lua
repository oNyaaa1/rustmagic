RegisterItem("rust_rock", {
    Name = "Rock",
    Info = "Rock, Basic gathering tool.",
    Category = "Tools",
    Materials = "materials/items/tools/rock.png",
    Weapon = "rust_rock",
    Craft = function()
        return {
            {
                ITEM = "Stone",
                AMOUNT = 10,
                Time = 5,
            },
        }
    end,
}, "Tools")

RegisterItem("rust_stonehatchet", {
    Name = "Stone Hatchet",
    Info = "The Stone Hatchet - Basic for collecting Sheep cloths and tree gathering",
    Category = "Tools",
    Materials = "materials/items/tools/stone_hatchet.png",
    Weapon = "rust_stonehatchet",
    Craft = function()
        return {
            {
                ITEM = "wood",
                AMOUNT = 200,
                Time = 5,
            },
            {
                ITEM = "Stone",
                AMOUNT = 100,
                Time = 5,
            }
        }
    end,
}, "Tools")