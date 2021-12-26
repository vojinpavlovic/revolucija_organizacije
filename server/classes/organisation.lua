function CreateOrganisation(name, grades, members, skills, points, money, level, vehicle_limit, announces, elo)
    local self = {}

    --[[ Props ]]--

    self.name = name
    self.grades = grades
    self.members = members
    self.skills = skills
    self.points = points
    self.money = money
    self.level = level
    self.vehicleLimit = {
        identifiers = {},
        limit = vehicle_limit or 3,
    }
    self.activeMembers = {}
    self.announces = announces or {}
    self.elo = elo

    --[[ ELO Teritory ranking ]]--
    self.removeELO = function(value)
        self.elo = self.elo - value
        self.updateGlobalElo()
    end

    self.addELO = function(value)
        self.elo = self.elo + value
        self.updateGlobalElo()
    end

    self.setELO = function(value)
        self.elo = value
        self.updateGlobalElo()
    end

    self.updateGlobalElo = function()
        Rev.rankList[self.name].elo = self.elo
        self.save({'elo'})
        GlobalState.rankList = Rev.rankList
    end

    --[[ Announces ]]--
    self.getAnnounces = function()
        return self.announces
    end

    self.insertAnnounce = function(data)
        table.insert(self.announces, data)
        self.updateGlobalState()
    end

    self.editAnnounce = function(data)
        for i=1, #self.announces, 1 do
            if self.announces[i][5] == data.uuid then
                self.announces[i][3] = data.message
                self.updateGlobalState()
                break
            end
        end
    end

    self.removeAnnounce = function(data)
        local found = false
        for i=1, #self.announces, 1 do
            if self.announces[i][5] == data.uuid then
                found = i
                break
            end
        end

        print("Nasao " .. found)

        if found then
            table.remove(self.announces, found)
            self.updateGlobalState()
        end
    end
    
    --[[ Members ]]--

    self.getMembers = function()
        return self.members
    end

    self.removeMember = function(identifier)
        Rev.table.removeKey(self.members, identifier)
    end

    self.addMember = function(player)
        self.members[player.identifier] = {
            firstname = player.firstname,
            lastname = player.lastname,
            birth = player.birth,
            sex = player.sex,
            height = player.height,
            phoneNumber = player.phone_number,
            grade = player.grade,
            grade_label = self.grades[player.grade].label
        }
    end

    self.addActiveMember = function(source)
        self.activeMembers[source] = source
        self.updateGlobalState()
    end

    self.removeActiveMember = function(source)
        Rev.table.removeKey(self.activeMembers, source)
        self.updateGlobalState()
    end

    self.getActiveMembers = function()        
        return self.activeMembers    
    end

    self.announceMembers = function(msg)
        for k, v in pairs(self.activeMembers) do
            TriggerClientEvent('esx:showNotification', tonumber(k), msg)
        end
    end

    self.appendAlert = function(teritory)
        for k, v in pairs(self.activeMembers) do
            TriggerClientEvent('revolucija_organizacije:alertZone', tonumber(k), teritory)
        end
    end

    self.destroyAlert = function()
        for k, v in pairs(self.activeMembers) do
            TriggerClientEvent('revolucija_organizacije:destroyAlertZone', tonumber(k))
        end
    end


    --[[ Money ]]--

    self.getMoney = function()
        return self.money
    end

    self.setMoney = function(value)
        self.money = value
        self.updateGlobalState()
    end

    self.addMoney = function(value)
        self.money = self.money + value
        self.updateGlobalState()
    end

    self.removeMoney = function(value)
        self.money = self.money - value
        self.updateGlobalState()
    end


    --[[ Points ]]--
    
    self.getPoints = function()
        return self.points
    end

    self.setPoints = function(value)
        self.points = value
        self.updateGlobalState()
    end

    self.removePoints = function(value)
        self.points = self.points - value
        self.updateGlobalState()
    end

    self.addPoints = function(value)
        self.points = self.points + value
        self.updateGlobalState()
    end


    self.buyPoint = function()
        if (self.points + 1) > Config.Org.levels[self.level].max then 
            return 
        end

        local price = Config.Points.price

        if self.money < price then 
            return 
        end

        self.addPoints(1)
        self.removeMoney(price)
        self.save({'points', 'money'})
    end

    
    --[[ Skills ]]--

    self.getSkills = function()
        return self.skills
    end

    self.setSkill = function(name, value)
        self.skills[name] = value
        self.updateGlobalState()
    end

    self.buySkill = function(name)
        local level = self.skills[name] + 1 
        if Config.Skills[name] and Config.Skills[name].levels[level] == nil then
            return
        end
        
        local points_needed = Config.Skills[name].levels[level].points_needed
        if self.points < points_needed then
            return
        end

        self.removePoints(points_needed)
        self.setSkill(name, level)
        self.save({'skills', 'points'})
    end


    --[[ Levels ]]--

    self.getLevel = function()
        return self.level
    end

    self.setLevel = function(value)
        self.level = value
    end

    self.levelUP = function()
        self.level = self.level + 1
    end

    self.buyLevel = function()
        local level = self.level + 1
        if Config.Org and Config.Org.levels[level] == nil then
            return
        end

        local money_needed = Config.Org.levels[level].price
        if self.money < money_needed then
            return
        end

        self.removeMoney(money_needed)
        self.levelUP()
        self.updateGlobalState()
        self.save({'level', 'money'})
    end

    --[[ Vehicle limit ]]--

    self.getVehicleLimit = function()
        return self.vehicleLimit.limit
    end

    self.getVehicleIdentifiers = function()
        return self.vehicleLimit.identifiers
    end

    self.takeVehicle = function(identifier)
        if self.vehicleLimit.limit == 0 then
            return
        end

        table.insert(self.vehicleLimit.identifiers, tostring(identifier))
        self.vehicleLimit.limit = self.vehicleLimit.limit - 1
        self.updateGlobalState()
    end

    self.storeVehicle = function(identifier)
        local found = nil
        
        for i=1, #self.vehicleLimit.identifiers, 1 do
            if self.vehicleLimit.identifiers[i] == tostring(identifier) then
                found = i
                break
            end
        end

        if found then
            table.remove(self.vehicleLimit.identifiers, found)
            self.vehicleLimit.limit = self.vehicleLimit.limit + 1
            self.updateGlobalState()
        end
    end


    --[[ Save ]]--

    self.save = function(variable)
        --Setting default query with empty body and data that we want to pass values in SQL
        local query = {
            head = 'UPDATE organisations SET ',
            body = '',
            tail = ' WHERE name = @name'
        }

        local body = {}
        body['@name'] = self.name

        --Let's check if variable exist and loop
        for i=1, #variable, 1 do
            if self[variable[i]] == nil then 
                error('Variable '.. variable[i] ..' is not found')
                return
            end

            if i ~= #variable then
                query.body = string.format('%s%s = @%s, ', query.body, variable[i], variable[i])
            else
                query.body = string.format('%s%s = @%s ', query.body, variable[i], variable[i])
            end

            if type(self[variable[i]]) == 'table' then
                body['@' .. variable[i]] = json.encode(self[variable[i]])
            else
                body['@' .. variable[i]] = self[variable[i]]
            end

        end
        
        -- If query.body and body is empty we will return and break from function
        if query.body == '' then return end
        if #body == 1 then return end

        query = string.format('%s%s%s', query.head, query.body, query.tail)

        MySQL.Async.execute(query, body, function(rowsChanged) end)
    end

    --[[ Global State update ]]--
    self.updateGlobalState = function()
        GlobalState[self.name] = {
            skills = self.skills,
            points = self.points,
            money = self.money,
            level = self.level,
            vehicleLimit = self.vehicleLimit,
            activeMembers = self.activeMembers,
            members = self.members,
            announces = self.announces
        }
    end

    self.updateGlobalState()

    return self
end