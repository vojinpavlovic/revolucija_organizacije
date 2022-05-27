--[[***************]]--
--[[ Organisations ]]--
--[[***************]]--

--\\ Members //--
Rev.org.func.getOrg = function(name)
    if Rev.org.jobs[name] == nil then
       error('No organisation is found ' .. name)
        return
    end
    return Rev.org.jobs[name]
end

Rev.org.func.getMembers = function(name)
    if Rev.org.jobs[name] == nil then
        error('No organisation is found')
        return
    end
    return Rev.org.jobs[name].members
end

Rev.org.func.addMember = function(name, data)
    local org = Rev.org.func.getOrg(name)

    if org then
        org.addMember(data)
    end
end

Rev.org.func.addActiveMember = function(src, name) 
    local org = Rev.org.func.getOrg(name)

    if org then
        org.addActiveMember(tostring(src))
    end
end

Rev.org.func.removeMember = function(name, identifier)
    local org = Rev.org.func.getOrg(name)

    if org then
        org.removeMember(identifier)
    end
end

Rev.org.func.removeActiveMember = function(src, data)
    local org = Rev.org.func.getOrg(data)

    if org then
        org.removeActiveMember(tostring(src))
    end
end

Rev.org.func.announceMembers = function(job, msg)
    local org = Rev.org.func.getOrg(job)

    if org then
        org.announceMembers(msg)
    end
end

--\\ Money //--
Rev.org.func.getMoney = function(name)
    local org = Rev.org.func.getOrg(name)
    
    if org then
        return org.getMoney()
    end
end

--\\ Points //--
Rev.org.func.buyPoint = function(name)
    local org = Rev.org.func.getOrg(name)
    
    if org then
        org.buyPoint()
    end
end


--\\ Skills //-
Rev.org.func.buySkill = function(name, skill)
    local org = Rev.org.func.getOrg(name)
    
    if org then 
        org.buySkill(skill)
    end
end


--\\ Levels //-
Rev.org.func.buyLevel = function()
    local org = Rev.org.func.getOrg(name)
    
    if org then 
        org.buyLevel() 
    end
end


--\\ Vehicle //-
Rev.org.func.getVehicleLimit = function(name)
    local org = Rev.org.func.getOrg(name)
    
    if org then 
        return org.getVehicleLimit() 
    end
end

Rev.org.func.takeVehicle = function(name, identifier)
    local org = Rev.org.func.getOrg(name)
    
    if org then 
        org.takeVehicle(identifier) 
    end
end

Rev.org.func.storeVehicle = function(name, identifier)
    local org = Rev.org.func.getOrg(name)
    
    if org then 
        org.storeVehicle(identifier)
    end
end

Rev.org.func.save = function(name, data)
    local org = Rev.org.func.getOrg(name)

    if org then
        org.save(data)
    end
end




--[[************]]--
--[[ Teritories ]]--
--[[************]]--

Rev.teritories.func.get = function(name)
    if Rev.teritories.instances[name] == nil then
       error('No teritory is found')
        return
    end
    return Rev.teritories.instances[name]
end

Rev.teritories.func.trigger = function(name, src)
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        local teritory = Rev.teritories.func.get(name)
        
        if teritory then
            teritory.trigger(xPlayer.getJob().name, xPlayer.source)
        end
    end
end

Rev.teritories.func.forceStopDefend = function(name)
    local teritory = Rev.teritories.func.get(name)
    
    if teritory then
        teritory.forceStopDefend()
    end
end

Rev.teritories.alert = function(type)
    print('ovde ide kad se osvoji teritorija neka animacija')
end

RegisterCommand('attack', function()
    local teritory = Rev.teritories.func.get('blackmarket')
    teritory.trigger('syndicate2')
end)

RegisterCommand('defend', function()
    local teritory = Rev.teritories.func.get('blackmarket')
    teritory.trigger('syndicate')
end)

RegisterCommand('dstop', function()
    local teritory = Rev.teritories.func.get('blackmarket')
    teritory.forceStopDefend()
end)

RegisterCommand('testglobal', function()
    local org = Rev.org.func.getOrg('syndicate')
    org.updateGlobalElo()
end)

--[[*****************]]--
--[[ Table functions ]]--
--[[*****************]]--

Rev.table.removeKey = function(table, key)
    local element = table[key] 
    table[key] = nil
    return element
end

Rev.table.print = function(table, encoded)
    for key, value in pairs(table) do
        if not encoded then
            print(string.format('\n[Key]: %s,\n[Value]: %s', tostring(key), value))
        else 
            print(string.format('\n[Key]: %s,\n[Value]: %s', tostring(key), json.encode(value)))
        end
    end
end


--[[******]]--
--[[ Save ]]--
--[[******]]--
Rev.Save = function()
    local counter = 0
    for k, v in pairs(Rev.org.jobs) do
        MySQL.Async.execute('UPDATE organisations SET money = @money, announces = @announces WHERE name = @name', {
            ['@name'] = v.name,
            ['@money'] = v.money,
            ['@announces'] = json.encode(v.announces)
        }, function(rowsChanged) 
        end)
        counter = counter + 1
    end
    print(('^6Revolucija ^9» ^7Sačuvano ^3%s ^7organizacija.'):format(counter))
end

Rev.AutoSave = function(interval)
	function saveData()
        Rev.Save()
        SetTimeout(interval, saveData)
	end

	SetTimeout(interval, saveData)
end

--[[**********************]]--
--[[ For Testing purposes ]]--
--[[**********************]]--

Rev.ShowNotification = function(src, msg)
    TriggerClientEvent('esx:showNotification', src, msg)
end





