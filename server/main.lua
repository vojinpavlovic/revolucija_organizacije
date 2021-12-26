--[[**************************]]--
--[[ Initialise organisations ]]--
--[[**************************]]--


local LoadOrganisations = function(data)
    local obj = {}
    -- Let's make job object first

    for k, v in pairs(Zurio.Poslovi) do
        obj[v.name] = {
            label = v.label,
            grades = {},
            members = {},
            skills = {},
            points = 0,
            money = 0,
            level = 1, 
            elo = 0
        }
    end

    -- Adding job grades to job object that we made
    for k, v in pairs(Zurio.Stepeni) do
        local job = v['job_name']

        if obj[job] then
            obj[job].grades[v.grade] = {
                name = v.name,
                label = v.label,
                salary = v.salary
            }
        end
    end

    -- Adding members to job object that we made
    if data.users then
        for k, v in pairs(data.users) do
            if obj[v.job] then
                obj[v.job].members[v.identifier] = {
                    firstname = v['firstname'],
                    lastname = v['lastname'],
                    birth = v['dateofbirth'],
                    sex = v['sex'],
                    height = v['height'],
                    phoneNumber = v['phone_number'],
                    grade = v['job_grade'],
                    grade_label = obj[v.job].grades[v['job_grade']].label
                }
            end
        end
    end

    --let's add skills, level and money and vehicle limit to the job object
    for k,v in pairs(data.organisations) do
        if obj[v.name] then
            obj[v.name].skills = json.decode(v.skills)
            obj[v.name].level = v.level
            obj[v.name].money = v.money
            obj[v.name].points = v.points
            obj[v.name].announces = json.decode(v.announces)
            obj[v.name].elo = v.elo
            Rev.rankList[v.name] = {elo = v.elo, label = obj[v.name].label}
        end
        
        if Config.Org.list[v.name] then
            obj[v.name].vehicle_limit = Config.Org.list[v.name].cars.vehicle_limit
        end
    end

    
    -- Creating organisation from class
    local counter = 0
    for k, v in pairs(obj) do
        counter = counter + 1
        Rev.org.jobs[k] = CreateOrganisation(k, v.grades, v.members, v.skills, v.points, v.money, v.level, v.vehicle_limit, v.announces, v.elo)
    end

    print('Loaded (' .. counter .. ') organisations')
    GlobalState.rankList = Rev.rankList
    -- Let's empty table as we do not need it anymore
    Zurio = nil
end

local insertMissingOrganisation = function(name)
    local DEFAULT = {}
    DEFAULT.skills = {
        members = 1, 
        safe = 1,
        teritory = 0,
        boat = 0
    }
    MySQL.Async.fetchAll('SELECT * FROM organisations WHERE name = @name', { ['@name'] = name }, function(result)
        if not result[1] then
            MySQL.Async.execute('INSERT INTO organisations (name, level, skills, money, points, announces) VALUES (@name, @level, @skills, @money, @points, @annonuces)',
            { 
                ['@name'] = name, 
                ['@level'] = 1, 
                ['@skills'] = json.encode(DEFAULT.skills), 
                ['@money'] = 0,
                ['@points'] = 0,
                ['@annonuces'] = json.encode({})
            }, function()
                print(string.format('Missing Organisation %s has successfully been added', name))
            end)        
        end
    end)

end

--[[***********************]]--
--[[ Initialise teritories ]]--
--[[***********************]]--

local LoadTeritories = function(data)
    if not data then
        error('Database is empty. If you dont want this error to show just comment this line')
        return
    end
    
    local counter = 0

    for k, v in pairs(data) do
        if v.name and v.owner and v.cooldown then
            Rev.teritories.instances[v.name] = CreateTeritory(v.name, v.owner, v.cooldown, 2000)
            counter = counter + 1
        else
            error('Check your database entries')
        end
    end

    print('Loaded (' .. counter .. ') teritories')

end

--[[On Database Ready]]--

MySQL.ready(function()
    for k, v in pairs(Zurio.Poslovi) do
        insertMissingOrganisation(v.name)
    end

    local data = {
        users = nil,
        organisations = nil
    }
    MySQL.Async.fetchAll('SELECT * FROM users', {}, function(result)
        data['users'] = result
        MySQL.Async.fetchAll('SELECT * FROM organisations', {}, function(result)
            data['organisations'] = result
            LoadOrganisations(data)
        end)
    end)

    MySQL.Async.fetchAll('SELECT * FROM teritories', {}, function(result) 
        LoadTeritories(result)
    end)
end)


--[[********]]--
--[[ Events ]]--
--[[********]]--
--organisation
RegisterNetEvent('revolucija_organizacije:getActiveMember')
RegisterNetEvent('revolucija_organizacije:takeVehicle')
RegisterNetEvent('revolucija_organizacije:storeVehicle')
--teritory
RegisterNetEvent('revolucija_organizacije:triggerAttack')
RegisterServerEvent('revolucija_organizacije:forceStopDefend')
--messages
RegisterServerEvent('revolucija_organizacije:sendAnnounce')
RegisterServerEvent('revolucija_organizacije:editAnnounce')
RegisterServerEvent('revolucija_organizacije:deleteAnnounce')
--money
RegisterNetEvent('revolucija_organizacije:donateMoney')

--[[ This Event is triggered when player has connected to server ]]--

AddEventHandler('revolucija_organizacije:getActiveMember', function(data)
    local org = Rev.org.func.getOrg(data)

    if org then
        org.addActiveMember(tostring(source))
    end
end)

--[[ This Event is triggered when the player has disconnected from the server ]]--

AddEventHandler('playerDropped', function()
    local player = ESX.GetPlayerFromId(source)

    if player then
        Rev.org.func.removeActiveMember(source, player.getJob().name)
    end
end)

--[[ This Event is triggered on resource start ]]--

AddEventHandler('onResourceStart', function()
    if (GetCurrentResourceName() ~= 'revolucija_organizacije2') then return end
end)

--[[ This Event is triggered on resource stop ]]--

AddEventHandler('onResourceStop', function()
    if (GetCurrentResourceName() ~= 'revolucija_organizacije2') then return end
    --Rev.Save()
end)

--[[ Organisation Events]]--

AddEventHandler('revolucija_organizacije:takeVehicle', function(identifier)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if xPlayer then
        Rev.org.func.takeVehicle(xPlayer.getJob().name, identifier)
    end
end)

AddEventHandler('revolucija_organizacije:storeVehicle', function(identifier)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if xPlayer then
        Rev.org.func.storeVehicle(xPlayer.getJob().name, identifier)
    end
end)

--[[ Teritory Events]]--

AddEventHandler('revolucija_organizacije:triggerAttack', function(teritory)
    local _source = source
    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    if #(coords - Config.Teritories.list[teritory].coords) <= 4.0 then
        Rev.teritories.func.trigger(teritory, _source)
    else
        DropPlayer(_source, 'Nice try kiddo')
    end
end)

AddEventHandler('revolucija_organizacije:forceStopDefend', function(teritory)
    local teritory = Rev.teritories.func.get(teritory)
    if teritory then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            teritory.forceStopDefend(current)
            Rev.org.func.announceMembers(xPlayer.getJob().name, 'Neuspesno odbranjena teritorija')            
        end
    end
end)

--[[ Announces ]]--
AddEventHandler('revolucija_organizacije:sendAnnounce', function(data) 
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local job = xPlayer.getJob()
        local org = Rev.org.func.getOrg(job.name)

        if org and Config.Org.list[job.name].announces.edit[job.grade_name] then
            org.insertAnnounce(data)
        end
    end
end)

AddEventHandler('revolucija_organizacije:editAnnounce', function(data) 
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local job = xPlayer.getJob()
        local org = Rev.org.func.getOrg(job.name)

        if org and Config.Org.list[job.name].announces.edit[job.grade_name] then
            org.editAnnounce(data)
        end
    end
end)


AddEventHandler('revolucija_organizacije:deleteAnnounce', function(data) 
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local job = xPlayer.getJob().name
        local org = Rev.org.func.getOrg(job.name)
        
        if org and Config.Org.list[job.name].announces.edit[job.grade_name] then
            org.removeAnnounce(data)
        end
    end
end)

--Money
AddEventHandler('revolucija_organizacije:donateMoney', function(data) 
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local job = xPlayer.getJob().name
        local org = Rev.org.func.getOrg(job)
        if org and xPlayer.getMoney() >= data.money then
            org.addMoney(data.money)
            xPlayer.removeMoney(data.money)
            TriggerClientEvent('revolucija_organizacije:setMoney', source, xPlayer.getMoney())
        end
    end
end)





--[[******]]--
--[[ Save ]]--
--[[******]]--

if Config.AutoSave.enabled then
    Rev.AutoSave(Config.AutoSave.interval)
end