function CreateTeritory(name, owner, cooldown, payday)
    self = {}

    --[[ Props ]]--

    self.name = name
    self.owner = owner
    self.cooldown = cooldown
    self.payday = payday
    self.session = {
        attack = false,
        defend = false
    }
    self.minutes = {
        attack = Config.Teritories.interval['attack'],
        defend = Config.Teritories.interval['defend']
    }
    self.label = Config.Teritories.list[self.name].label
    self.attacker = nil
    --[[ Owner ]]--
    
    self.getOwner = function()
        return self.owner
    end

    self.setOwner = function(owner)
        self.owner = owner
    end

    --[[ Time and sessions ]]--

    self.setCooldown = function(cooldown)
        self.cooldown = cooldown
    end

    self.checkCooldown = function()
        local time = os.difftime(os.time(), self.cooldown)
        if time < Config.Teritories.cooldown then
            print('cooldown')
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

    self.attack = function(name)

        if self.session.attack then 
            return
        end

        if self.checkCooldown(name) and not self.session.attack then
            self.setSession('attack', true)
            self.start(name)
        end
    end

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

    self.trigger = function(name, src)
        if self.owner == name then
            if src then
                return self.defend(src)
            end
        else
            return self.attack(name)
        end

        return
    end

    self.start = function(attacker)
        local winner = nil
        local attOrg = Rev.org.func.getOrg(attacker)
        local defOrg = Rev.org.func.getOrg(self.owner)
        self.attacker = attacker
        attOrg.appendAlert(self.name)
        defOrg.appendAlert(self.name)
        function interval()

            if not self.session.defend then
                self.minutes.attack = self.minutes.attack - 1
            else
                self.minutes.defend = self.minutes.defend - 1
            end

            if self.minutes.attack == 0 then
                winner = attacker
                attOrg.announceMembers('Teritorija ' .. self.label .. ' je pripala vama!')
                defOrg.announceMembers('Nazalost, vas odbrana na ' .. self.label .. ' je neuspesno')
                attOrg.addELO(40)
                defOrg.removeELO(30)
            elseif self.minutes.defend == 0 then
                winner = self.owner
                attOrg.announceMembers('Nazalost, vas napad na ' .. self.label .. ' je neuspesno')
                defOrg.announceMembers('Teritorija ' .. self.label .. ' je uspesno odbranjena!')
                defOrg.addELO(40)
                attOrg.removeELO(30)
            end

            if winner then
                self.setCooldown(os.time())
                self.setMinutes()
                self.setSession('all', false)
                self.owner = winner
                self.updateGlobalState()
                self.attacker = nil
                attOrg.destroyAlert()
                defOrg.destroyAlert()
                --self.save({'owner', 'cooldown'})
            end

            self.updateGlobalState()

            if not winner then 
                local data = GlobalState[self.name].minutes
                SetTimeout(20000, interval)
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
            cooldown = self.cooldown,
            payday = self.payday,
            session = self.session,
            minutes = self.minutes,
            attacker = self.attacker
        }
    end

    self.updateGlobalState()

    return self
end