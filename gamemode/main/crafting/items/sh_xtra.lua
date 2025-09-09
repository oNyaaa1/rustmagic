ITEMS:RegisterItem("Cloth", {
    Name = "Cloth",
    Info = "For bandages etc",
    Category = "Extra",
    model = "materials/items/resources/cloth.png",
    Weapon = "",
    Count = 1,
    Craft = function()
        return {
            {
                CanCraft = false,
                {
                    ITEM = "0",
                    AMOUNT = 0,
                    Time = 0,
                },
            },
        }
    end,
}, "Extra")