ITEMS:RegisterItem("Sulfur Ore", {
    Name = "Sulfur Ore",
    Info = "For smelting and crafting stuff",
    Category = "Extra",
    model = "materials/items/resources/sulfur_ore.png",
    Weapon = "",
    Count = 1,
    Stackable = true,
    StackSize = 150,
    Craft = function()
        return {
            {
                Time = 0,
                CanCraft = false,
                {
                    ITEM = "0",
                    AMOUNT = 0,
                },
            },
        }
    end,
}, "Extra")

ITEMS:RegisterItem("Metel Ore", {
    Name = "Metel Ore",
    Info = "For smelting and crafting stuff",
    Category = "Extra",
    model = "materials/items/resources/metal_ore.png",
    Weapon = "",
    Count = 1,
    Stackable = true,
    StackSize = 150,
    Craft = function()
        return {
            {
                Time = 0,
                CanCraft = false,
                {
                    ITEM = "0",
                    AMOUNT = 0,
                },
            },
        }
    end,
}, "Extra")

ITEMS:RegisterItem("Stone", {
    Name = "Stone",
    Info = "Used for upgrading your base!",
    Category = "Extra",
    model = "materials/items/resources/stone.png",
    Weapon = "",
    Count = 1,
    Stackable = true,
    StackSize = 150,
    Craft = function()
        return {
            {
                Time = 0,
                CanCraft = false,
                {
                    ITEM = "0",
                    AMOUNT = 0,
                },
            },
        }
    end,
}, "Extra")