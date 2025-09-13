ITEMS:RegisterItem("Cloth", {
    Name = "Cloth",
    Info = "For bandages etc",
    Category = "Extra",
    model = "materials/items/resources/cloth.png",
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

ITEMS:RegisterItem("Animal Fat", {
    Name = "Animal Fat",
    Info = "For bandages etc",
    Category = "Extra",
    model = "materials/items/resources/animal_fat.png",
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

ITEMS:RegisterItem("Wood", {
    Name = "Wood",
    Info = "For upgrading your base!",
    Category = "Extra",
    model = "materials/items/resources/wood.png",
    Weapon = "",
    Count = 1,
    Stackable = true,
    StackSize = 1000,
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

ITEMS:RegisterItem("Hands", {
    Name = "Hands",
    Info = "",
    Category = "Extra",
    model = "materials/tree/hands.png",
    Weapon = "rust_hands",
    Count = 1,
    Stackable = true,
    StackSize = 1000,
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