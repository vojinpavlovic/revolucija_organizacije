--[[ Let's setup draw distance and enter marker distance ]]--
Config.DrawDistance = 20.0
Config.MarkerDistance = 2.0


--[[ We can add more type of markers here ]]--
Config.Org.markers = {
    panel = {
        type = 31,
        color = {r = 0, g = 0, b = 120},
        size = { x = 1.0, y = 1.0, z = 1.0},
        help = 'Pritisnite <span> E </span> da otvorite Mafija Panel'
     },
     safe = {
         type = 29,
         color = {r = 0, g = 0, b = 120},
         size = { x = 1.0, y = 1.0, z = 1.0},
         help = 'Pritisnite <span> E </span> da otvorite Sef'
     },
     vehicle_spawn = {
         type = 36,
         color = {r = 0, g = 0, b = 120},
         size = { x = 1.0, y = 1.0, z = 1.0},
         help = 'Pritisnite <span> E </span> da otvorite Meni vozila'
     },
     vehicle_delete = {
         type = 1,
         color = {r = 120, g = 0, b = 0},
         size = { x = 5.0, y = 5.0, z = 1.0},
         help = 'Pritisnite <span> E </span> da parkirate automobil'
     }
}

--[[ Organisation list ]]--
Config.Org.list['syndicate'] = {
    type = 'mafia',
    cars = {
        vehicle_limit = 4,
        list = {
            [1] = {
                label = 'Sultan', 
                value = 'sultan',
                upgrades = {
                    ['all'] = {
                        color = {primary = 42, secondary = 1}
                    },
                    ['boss'] = {
                        fullTune = true, 
                        bulletProof = true,
                        windowTint = true,
                        color = {primary = 10, secondary = 1},
                        plate = 'SogoLis',
                    }
                },
                access = {
                    boss = true,
                    savetnik = true
                }
            },
            [2] = {label = 'Infernus', value = 'infernus'}
        }
    },
    announces = {
        edit = {boss = true, savetnik = true},
        new = {boss = true},
    },
    coords = {
        panel = vector3(930.72, 72.09, 78.91),
        safe = vector3(943.2, 103.65, 79.91),
        vehicle_spawn =  vector3(950.53, 112.11, 80.6),
        vehicle_delete = vector3(951.51, 119.5, 79.84),
    }
}

Config.Org.list['gsf'] = {
    type = 'hood',
    cars = {
        vehicle_limit = 4,
        list = {
            [1] = {
                label = 'Sultan', 
                value = 'sultan',
                upgrades = {
                    ['all'] = {
                        color = {primary = 42, secondary = 1}
                    },
                    ['boss'] = {
                        fullTune = true, 
                        bulletProof = true,
                        windowTint = true,
                        color = {primary = 10, secondary = 1},
                        plate = 'SogoLis',
                    }
                },
                access = {
                    boss = true,
                    savetnik = true
                }
            },
            [2] = {label = 'Infernus', value = 'infernus'}
        }
    },
    announces = {
        edit = {boss = true, savetnik = true},
        new = {boss = true},
    },
    coords = {
        panel = vector3(930.72, 72.09, 78.91),
        safe = vector3(943.2, 103.65, 79.91),
        vehicle_spawn =  vector3(950.53, 112.11, 80.6),
        vehicle_delete = vector3(951.51, 119.5, 79.84),
    }
}
