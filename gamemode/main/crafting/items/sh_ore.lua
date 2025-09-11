ITEMS:RegisterItem("Sulfur Ore", {
    Name = "Sulfur Ore",
    Info = "For bandages etc",
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