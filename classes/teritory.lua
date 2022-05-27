function CreateTeritory(name, owner, cooldown, payday)
    local self = {}
    --[[ Props ]]--

    self.name = name
    self.owner = owner
    self.owner_label = Rev.org.jobs[self.owner].label
    self.cooldown = cooldown
    self.payday = payday
    self.session = { attack = false, defend = false }
    self.minutes = { attack = Config.Teritories.interval['attack'], defend = Config.Teritories.interval['defend'] }
    self.label = Config.Teritories.list[self.name].label
    self.attacker = nil
    self.attackerLabel = nil
    self.killdeath = {
        attacker = {k = 0, d = 0},
        defender = {k = 0, d = 0}
    }

    --[[ Owner ]]--

    self.getOwner = function()
        return self.owner
    end

    self.setOwner = function(owner)
        self.owner = owner
    end

    --[[ Kill Death ]]--
    self.incrementKD = function(state, type) 
        self.killdeath[state][type] = self.killdeath[state][type] + 1
        self.updateGlobalState()
    end

    self.resetKD = function() 
        self.killdeath = {
            attacker = {k = 0, d = 0},
            defender = {k = 0, d = 0}
        }    
        self.updateGlobalState()
    end

    --[[ Time and sessions ]]--

    self.setCooldown = function(cooldown)
        self.cooldown = cooldown
    end

    self.checkCooldown = function(src)
        local time = os.difftime(os.time(), self.cooldown)
        if time < Config.Teritories.cooldown then
            TriggerClientEvent('esx:showNotification', src, Config.Strings['TERITORY_UNDER_COOLDOWN'])
            return
        end

        return true
    end

    self.setMinutes = function()
        self.minutes = {
            attack = 12,
            defend = 5
        }    
    end

    self.setSession = function(type, bool)
        if type == 'all' then
            self.session.attack = bool
            self.session.defend = bool
        else
            self.session[type] = bool 
        end
        self.updateGlobalState()
    end

    --[[ Attack ]]--

    self.attack = function(name, src)

        if self.session.attack then 
            return
        end

        if self.checkCooldown(src) and not self.session.attack then
            self.setSession('attack', true)
            self.start(name)
        end
    end

    --[[ Defend ]]--

    self.defend = function(src)
        if not self.session.attack then
            return
        end

        if self.session.defend then
            return
        end

        self.setSession('defend', true)
    end

    self.forceStopDefend = function(src)
        self.setSession('defend', false)
    end

    --[[ Start of an Attack/Defend ]]--

    self.trigger = function(name, src)
        if self.owner == name then
            if src then
                return self.defend(src)
            end
        else
            return self.attack(name, src)
        end

        return
    end

    self.start = function(attacker)

        --Getting informations
        local winner = nil
        local newOwnerLabe = nil
        local attOrg = Rev.org.func.getOrg(attacker)
        local defOrg = Rev.org.func.getOrg(self.owner)

        --Let's set a attacker var
        self.attacker = attacker
        self.attackerLabel = attOrg.label

        --Appending blip radius for attacker
        attOrg.appendAlert(self.name)
        defOrg.appendAlert(self.name)

        --Announce both sides
        defOrg.announceMembers(string.format(Config.Strings['TERITORY_UNDER_ATTACK_DEF'], self.label))
        attOrg.announceMembers(string.format(Config.Strings['TERITORY_UNDER_ATTACK_ATT'], self.label))

        local function interval()
            if not self.session.defend then
                self.minutes.attack = self.minutes.attack - 1
            else
                self.minutes.defend = self.minutes.defend - 1
            end

            --print(self.name, json.encode(self.minutes))

            if self.minutes.attack == 0 then
                winner = attacker
                attOrg.announceMembers(string.format(Config.Strings['TERITORY_WINNER_ATT'], self.label))
                defOrg.announceMembers(string.format(Config.Strings['TERITORY_LOSER_DEF'], self.label))
                attOrg.addELO(40)
                defOrg.removeELO(30)
                ownerLabel = attOrg.label
            elseif self.minutes.defend == 0 then
                winner = self.owner
                defOrg.announceMembers(string.format(Config.Strings['TERITORY_WINNER_DEF'], self.label))
                attOrg.announceMembers(string.format(Config.Strings['TERITORY_LOSER_ATT'], self.label))
                defOrg.addELO(40)
                attOrg.removeELO(30)
                ownerLabel = defOrg.label
            end

            if winner then
                self.setCooldown(os.time())
                self.setMinutes()
                self.setSession('all', false)
                self.owner = winner
                self.owner_label = ownerLabel
                self.attacker = nil
                self.attackerLabel = nil
                self.resetKD()
                attOrg.destroyAlert()
                defOrg.destroyAlert()
                self.updateGlobalState()
                self.updateTeritoryList()
                self.save({'owner', 'cooldown'})
            end

            self.updateGlobalState()

            if not winner then 
                local data = GlobalState[self.name].minutes
                SetTimeout(Config.Teritories.interval.timer, interval)
            end
        end

        interval()
    end

    self.save = function(variable)
        --Setting default query with empty body and data that we want to pass values in SQL
        local query = {
            head = 'UPDATE teritories SET ',
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

    self.updateGlobalState = function()
        GlobalState[self.name] = {
            owner = self.owner,
            owner_label = self.owner_label,
            cooldown = self.cooldown,
            payday = self.payday,
            session = self.session,
            minutes = self.minutes,
            attacker = self.attacker,
            attacker_label = self.attackerLabel,
            killdeath = self.killdeath
        }
    end

    self.updateTeritoryList = function()
        Rev.teritoryList[self.name] = {owner = self.owner, ownerLabel = Rev.org.jobs[self.owner].label, cooldown = self.cooldown}
        GlobalState.TeritoryList = Rev.teritoryList
    end

    self.updateGlobalState()

    return self
end