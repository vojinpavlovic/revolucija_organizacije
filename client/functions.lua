--[[ Markers functions ]]--
Rev.func.markers.enter = function(part, help, data)
    Rev.CurrentAction = part
    if data then Rev.CurrentData = data end
    if help then
        TriggerEvent('panama_notifikacije:sendFloatingText', help)
    end
end

Rev.func.markers.exit = function()
    Rev.CurrentAction = nil
    TriggerEvent('panama_notifikacije:sendFloatingText')
end

Rev.func.markers.panel = function()
    TriggerScreenblurFadeIn()
    SendNUIMessage({
        action = 'open', 
        info = Rev.func.data.getInfo(), 
        announces = Rev.func.data.getAnnounces(), 
        config = Rev.func.data.getConfig(), 
        rankList = Rev.func.data.getRankList()
    })
    SetNuiFocus(true, true)
end


Rev.func.markers.safe = function()
	TriggerEvent("revolucija_inventar:openStorageInventory", 'society_'..Rev.PlayerData.job.name)
end

Rev.func.markers.vehicle_spawn = function()
    if Config.Org.list[Rev.PlayerData.job.name] and Config.Org.list[Rev.PlayerData.job.name].cars == nil then
        ESX.ShowNotification('Ova organizacija nema vozila')
        return
    end

    Rev.func.vehicle.menu('cars')
end

Rev.func.markers.vehicle_delete = function()
    Rev.func.vehicle.delete()
end

Rev.func.markers.teritory = function()
    if Rev.CurrentData then
        local data = GlobalState[Rev.CurrentData]
        if data.owner == Rev.PlayerData.job.name and not data.session.attack then
            ESX.ShowNotification('Ovo je vasa teritorija')
        elseif data.owner == Rev.PlayerData.job.name and data.session.attack then
            Rev.Defend = true
            TriggerServerEvent('revolucija_organizacije:triggerAttack', Rev.CurrentData)
        else
            TriggerServerEvent('revolucija_organizacije:triggerAttack', Rev.CurrentData)
        end
    else
        ESX.ShowNotification('Marker za teritoriju ne postoji. Kontaktirajte server!')
    end
end

--[[ Cloakroom functions ]]--
Rev.func.cleanPed = function()
    local playerPed = PlayerPedId()

	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

--[[ Vehicle functions ]]--

Rev.func.vehicle.menu = function(type)
    local elements = {}
    local job = Rev.PlayerData.job.name
    local vehicleList = Config.Org.list[job][type].list
    local gradeName = Rev.PlayerData.job.grade_name
    local counter = 0
    local limit = GlobalState[job].vehicleLimit.limit

    for i=1, #vehicleList, 1 do
        counter = counter + 1
        if vehicleList[i].access then
            if vehicleList[i].access[gradeName] then
                table.insert(elements, {
                    label = vehicleList[i].label,
                    value = vehicleList[i].value,
                    index = counter
                })
            end
        else
            table.insert(elements, {
                label = vehicleList[i].label,
                value = vehicleList[i].value,
                index = counter
            })
        end
    end

	ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vozila_meni', {
		css      = 'mafia-vehicle-spawn',
		title    = 'Izaberi Vozilo | Limit ' .. limit,
		elements = elements
	}, function(data, menu)
        ESX.UI.Menu.CloseAll()

        if limit > 0 then
            Rev.func.vehicle.spawn(data.current.value, data.current.index)
        else
            ESX.ShowNotification('Ne mozete vaditi, prevrsili ste limit!')
        end

    end, function(data, menu)
		menu.close()
	end)
end

Rev.func.vehicle.spawn = function(model, index)
    local playerPed = PlayerPedId()
    local gradeName = Rev.PlayerData.job.grade_name

    ESX.Game.SpawnVehicle(model, GetEntityCoords(playerPed), GetEntityHeading(playerPed), function(vehicle)
		local veh_id = NetworkGetNetworkIdFromEntity(vehicle)
        local car = Config.Org.list[Rev.PlayerData.job.name].cars.list[tonumber(index)]    
        TriggerServerEvent('revolucija_organizacije:takeVehicle', veh_id)
        local data = {}

        if car.upgrades then
            if car.upgrades[gradeName] then
                data = car.upgrades[gradeName]
            elseif car.upgrades['all'] then
                data = car.upgrades['all']
            end

            for k, v in pairs(data) do
                if type(v) == 'boolean' and v == true then
                    Rev.func.vehicle[k](vehicle)
                elseif type(v) == 'string' or type(v) == 'table' or type(v) == 'number' then
                    Rev.func.vehicle[k](vehicle, v)
                end
            end
        end

        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleDirtLevel(vehicle, 0.0)
	end)
end

Rev.func.vehicle.delete = function()
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)
    if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        local veh_id = NetworkGetNetworkIdFromEntity(vehicle)
        local identifiers = GlobalState[Rev.PlayerData.job.name].vehicleLimit.identifiers
        local found = false
        
        for i=1, #identifiers do
            if identifiers[i] == tostring(veh_id) then
                found = true
            end
        end

        if found then
            ESX.Game.DeleteVehicle(vehicle)
            TriggerServerEvent('revolucija_organizacije:storeVehicle', veh_id)
            ESX.ShowNotification('Uspesno ste parkirali automobil')            
        else
            ESX.ShowNotification('Mozete samo vratiti vase vozilo!')
        end
    end
end

Rev.func.vehicle.windowTint = function(vehicle)
    ESX.Game.SetVehicleProperties(vehicle, {
        windowTint = 1, 
        wheelColor = 0, 
        plateIndex = 1
    })
end

Rev.func.vehicle.fullTune = function(vehicle)
    ESX.Game.SetVehicleProperties(vehicle, {
        modArmor        = 4,
        modXenon        = true,
        modEngine       = 3,
        modBrakes       = 2,
        modTransmission = 2,
        modSuspension   = 3,
        modTurbo        = true
    }) 
end

Rev.func.vehicle.plate = function(vehicle, plate)
    ESX.Game.SetVehicleProperties(vehicle, {plate = plate}) 
end

Rev.func.vehicle.bulletProof = function(vehicle)
    SetVehicleTyresCanBurst(vehicle, false)
end

Rev.func.vehicle.color = function(vehicle, data)
    if data and data.primary and data.secondary then
        SetVehicleColours(vehicle, data.primary, data.secondary)
    end
end

--[[ Teritories ]]--
Rev.func.revealScoreboard = function()
    SendNUIMessage({action = 'reveal-scoreboard'})
end

Rev.func.unrevealScoreboard = function()
    SendNUIMessage({action = 'unreveal-scoreboard'})
end

Rev.func.onScoreboardChange = function(teritory)
    local state = GlobalState[teritory]
    local session = 'NAPAD JE U TOKU'
    if state.session.attack and state.session.defend then
       session = 'ODBRANA JE U TOKU'
    end

    SendNUIMessage({action = 'onchange-scoreboard', minutes = state.minutes, session = session})
end

Rev.func.isTeritoryUnderAttack = function(teritory)
    local state = GlobalState[teritory]
    
    if state.session.attack or state.session.defend then
        return true
    end

    return false
end

Rev.func.isTeritoryOwner = function(teritory)
    local state = GlobalState[teritory]
    
    if state.owner == Rev.PlayerData.job.name then
        return true
    end

    return false
end

Rev.func.isAttorDeff = function(teritory)
    local state = GlobalState[teritory]
    
    if state.attacker == Rev.PlayerData.job.name or state.owner == Rev.PlayerData.job.name then
        return true
    end

    return false
end

Rev.func.defaultLastAttack = function()
    Rev.lastAttack = {
        attack = 12,
        defend = 5
    }
end

Rev.func.assignLastAttack = function(teritory)
    local state = GlobalState[teritory]

    Rev.lastAttack.attack = state.minutes.attack
    Rev.lastAttack.defend = state.minutes.defend
end

Rev.func.compareTeritoryMinutes = function(teritory)
    local state = GlobalState[teritory]

    if Rev.lastAttack.attack ~= state.minutes.attack or Rev.lastAttack.defend ~= state.minutes.defend then
        return true
    end

    return false
end


--[[ Data Getters and formatters ]]-- Definitely need cleaner version of code (wrote biggest shitcode here)
Rev.func.data.getUsedPoints = function(job)
    local skills = Config.Skills
    local states = GlobalState[job]

    local pointsUsedData = {
        members = skills.members.levels[states.skills.members].points_needed or 0,
        safe = skills.safe.levels[states.skills.safe].points_needed or 0,
        teritory = skills.teritory.levels[states.skills.teritory].points_needed or 0,
        boat = skills.boat.levels[states.skills.boat].points_needed or 0
    }

    local pointsUsed = 0

    for k, v in pairs(pointsUsedData) do
        pointsUsed = pointsUsed + v
    end

    return pointsUsed
end

Rev.func.data.getInfo = function()
    local job = Rev.PlayerData.job.name
    local counter = 0

    local states = GlobalState[job]

    for k, v in pairs(GlobalState[job].members) do
        counter = counter + 1
    end

    local data = {
        personal = {sidebar = false, result = Rev.PlayerData.personal},
        personalMoney = {sidebar = false, result = Rev.PlayerData.money},
        job_name = {sidebar = false, result = Rev.PlayerData.job.name},
        job_label = {sidebar = true, result = Rev.PlayerData.job.label},
        grade_name = {sidebar = false, result = Rev.PlayerData.job.grade_name},
        grade_label = {sidebar = true, result = Rev.PlayerData.job.grade_label},
        money = {sidebar = true, result = states.money},
        level = {sidebar = false, result = states.level},
        points_left = {sidebar = true, result = states.points},
        points_used = {sidebar = true, result = Rev.func.data.getUsedPoints(job)},
        points_max = {sidebar = true, result = Config.Org.levels[states.level].max},
        members_capacity = {sidebar = true, result = Config.Skills.members.levels[states.skills.members].limit},
        members_count = {sidebar = true, result = counter}
    }

    return data
end

Rev.func.data.getAnnounces = function()
    return GlobalState[Rev.PlayerData.job.name].announces
end

Rev.func.data.getConfig = function() 
    return Config
end

Rev.func.data.getRankList = function()
    return GlobalState.rankList
end

RegisterCommand('global', function()
    local org = Rev.PlayerData.job.name
    --local data = GlobalState.rankList
    --print(#GlobalState.rankList)
    --print(data)
    for k,v in pairs(GlobalState.rankList) do
        print(k .. ' ' .. v)
    end
end)