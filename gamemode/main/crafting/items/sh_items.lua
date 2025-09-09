ITEMS:RegisterItem("Rock", {
    Name = "Rock",
    Info = "Rock, Basic gathering tool.",
    Category = "Tools",
    model = "materials/items/tools/rock.png",
    Weapon = "tfa_rustalpha_rocktool",
    Count = 1,
    Craft = function()
        return {
            {
                Time = 5,
                CanCraft = true,
                {
                    ITEM = "Stone",
                    AMOUNT = 10,
                },
            },
        }
    end,
}, "Tools")

ITEMS:RegisterItem("Stone Hatchet", {
    Name = "Stone Hatchet",
    Info = "The Stone Hatchet - Basic for collecting Sheep cloths and tree gathering",
    Category = "Tools",
    model = "materials/items/tools/stone_hatchet.png",
    Weapon = "rust_stonehatchet",
    Count = 1,
    Craft = function()
        return {
            {
                Time = 30,
                CanCraft = true,
                {
                    ITEM = "wood",
                    AMOUNT = 200,
                },
                {
                    ITEM = "Stone",
                    AMOUNT = 100,
                },
            },
        }
    end,
}, "Tools")

ITEMS:RegisterItem("Stone Pickaxe", {
    Name = "Stone Pickaxe",
    Info = "The Stone Pickaxe - Basic for collecting Ores",
    Category = "Tools",
    model = "materials/items/tools/stone_pickaxe.png",
    Weapon = "rust_stonepickaxe",
    Count = 1,
    Craft = function()
        return {
            {
                CanCraft = true,
                Time = 30,
                {
                    ITEM = "wood",
                    AMOUNT = 200,
                },
                {
                    ITEM = "Stone",
                    AMOUNT = 100,
                },
            },
        }
    end,
}, "Tools")

ITEMS:RegisterItem("Building Plan", {
    Name = "Building Plan",
    Info = "The Building Plan, For building",
    Category = "Tools",
    model = "materials/items/tools/building_plan.png",
    Weapon = "rust_buildingplan",
    Count = 1,
    Craft = function()
        return {
            {
                CanCraft = true,
                Time = 30,
                {
                    ITEM = "wood",
                    AMOUNT = 20,
                },
            },
        }
    end,
}, "Tools")

ITEMS:RegisterItem("Hammer", {
    Name = "Hammer",
    Info = "Hammer, Upgrading ur base!",
    Category = "Tools",
    model = "materials/items/tools/hammer.png",
    Weapon = "rust_hammer",
    Count = 1,
    Craft = function()
        return {
            {
                CanCraft = true,
                Time = 30,
                {
                    ITEM = "wood",
                    AMOUNT = 200,
                },
            },
        }
    end,
}, "Tools")

ITEMS:RegisterItem("Hatchet", {
    Name = "Hatchet",
    Info = "Hatchet, Gathering trees!",
    Category = "Tools",
    model = "materials/items/tools/hatchet.png",
    Weapon = "rust_hatchet",
    Count = 1,
    Craft = function()
        return {
            {
                CanCraft = true,
                Time = 30,
                {
                    ITEM = "wood",
                    AMOUNT = 400,
                },
                {
                    ITEM = "metal.fragments",
                    AMOUNT = 150
                }
            },
        }
    end,
}, "Tools")
