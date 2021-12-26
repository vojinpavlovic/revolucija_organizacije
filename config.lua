Config = {}

--[[
    Enable this feature if you want your data to be automaticly be saved in database after time interval passed
    - Set enable to true if you want it enabled
    - Set interval in miliseconds (1000ms = 1sec)
    Note: if autosave is disabled every data passed in Rev.Save will be automaticly be saved after modified
        In this version: Only params that are saved when modified is money
]]--

Config.AutoSave = {
    enabled = true,
    interval = 2000000
}


--[[
    This feature is for skill leveling, you can set limit if you don't want everything to be upgraded. To set max limit by organisation check structure in MySQL 'organisations' column 'points' and set your desired limit
    - If you don't want limit you can turn it off by setting it's value to false
    - You can put desired price for a point price
]]--

Config.Points = {
    limit = true,
    price = 500000,
}


--[[
    Let's make Organisation object in config.
    - Marker and organisation list setup is located in markerconf.lua
    - You can setup organisation upgrade levels and their price aswell maximum points you want them to have
]]--

Config.Org = {
    markers = {},
    list = {},
    levels = {}
}

Config.Org.levels = {
    [1] = {
        price = 0,
        max = 7
    },
    [2] = {
        price = 700000,
        max = 10
    },
    [3] = {
        price = 2000000,
        max = 14
    },
    [4] = {
        price = 7000000,
        max = 16
    }
}

--[[
    Let's make Skills object in config.
    - You can setup points needed to be unlocked and their variables to your desire
]]--

Config.Skills = {
    members = {},
    safe = {},
    teritory = {},
    boat = {}
}

Config.Skills.members = {
    levels = {
        [1] = {
            limit = 14,
            points_needed = 0
        },
        [2] = {
            limit = 16,
            points_needed = 1
        },
        [3] = {
            limit = 20,
            points_needed = 2
        },
        [4] = {
            limit = 30,
            points_needed = 2
        }
    }
}

Config.Skills.safe = {
    levels = {
        [1] = {
            limit = 100,
            points_needed = 0
        },
        [2] = {
            limit = 150,
            points_needed = 1
        },
        [3] = {
            limit = 200, 
            points_needed = 2
        },
        [4] = {
            limit = 250,
            points_needed = 2
        }
    }    
}

Config.Skills.teritory = {
    levels = {
        [0] = {
            points_needed = 0
        },
        [1] = {
            points_needed = 1,
        }
    }    
}

Config.Skills.boat = {
    levels = {
        [0] = {
            points_needed = 0
        },
        [1] = {
            points_needed = 3
        },
        [2] = {
            points_needed = 1
        },
        [3] = {
            points_needed = 1
        }
    }    
}

--[[
    Let's add teritories to Config objects
]]

Config.Teritories = {}

Config.Teritories.interval = {
    attack = 12,
    defend = 5
}

Config.Teritories.cooldown = 3

Config.Teritories.list = {}

--[[
    Teritories list
]]--

Config.Teritories.list['blackmarket'] = {
    label = 'Blackmarket',
    coords = vector3(920.07, 54.12, 80.9),
    marker = {
        type = 31,
        color = {r = 0, g = 0, b = 120},
        size = {x = 1.0, y = 1.0, z = 1.0}
    },
    help = {
        attack = 'Pritisnite <span>E</span> da osvojite teritoriju',
        defend = 'Pritisnite <span>E</span> da odbranite teritoriju',
        neutral = '<span>Blackmarket</span> Plata 2000$, -20% nize cene'
    }
}