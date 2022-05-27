-- kad igrac menja poslove koje postoje u skripti
-- kad igrac menja u posao koji ne postoji u skripti
-- kad posao koji ne postoji u skripti se dodaje u posao koji postoji u skripti
ESX.RegisterCommand('posao', 'superadmin', function(xPlayer, args, showError)
    if ESX.DoesJobExist(args.job, args.grade) then
        -- Removing player from old member job if exist in config
        if Config.Org.list[xPlayer.getJob().name] then
            Rev.org.func.removeMember(xPlayer.getJob().name, xPlayer.identifier)
            Rev.org.func.removeActiveMember(xPlayer.source, xPlayer.getJob().name)
        end

        -- Setting a new job to xPlayer job object
    
        args.playerId.setJob(args.job, args.grade)
TriggerEvent("revolucija_core:discordLog", 'posaocmd', "Posao CMD", GetPlayerName(xPlayer.source).. " je setovao posao igracu \nID TARGETA: "..args.playerId.source.."\nSteam targeta: "..GetPlayerName(args.playerId.source).."\nSetovan posao: "..args.job.."\nRank: ".. args.grade.."\nHex Targeta: "..args.playerId.identifier.."\nHex od "..GetPlayerName(xPlayer.source)..": "..xPlayer.identifier.."\nId od "..GetPlayerName(xPlayer.source)..": "..xPlayer.source)
        -- Adding player to new job member object if exist in config
        if Config.Org.list[args.job] then
            local personalData = xPlayer.getPersonalData()
            local playerData = {
                identifier = xPlayer.identifier,
                firstname = personalData.firstname,
                lastname = personalData.lastname,
                birth = personalData.dateofbirth,
                sex = personalData.sex,
                phone_number = xPlayer.GetPhoneNumber(),
                grade = xPlayer.getJob().grade
            }
            Rev.org.func.addMember(args.job, playerData)
            Rev.org.func.addActiveMember(xPlayer.source, args.job)
        end
	end
end, true, {help = 'Daj Posao', validate = true, arguments = {
	{name = 'playerId', help = 'ID', type = 'player'},
	{name = 'job', help = 'POSAO', type = 'string'},
	{name = 'grade', help = 'STEPEN', type = 'number'}
}})

RegisterCommand('pozivnica', function(source, args, rawCommand)    
    if not args[1] then
        TriggerClientEvent('esx:showNotification', source, Config.Strings['INVALID_INVITATION_COMMAND_SYNTAX'])
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if args[1] == 'prihvati' then
        local invitation = Rev.Invitations[xPlayer.identifier]
        if not invitation then TriggerClientEvent('esx:showNotification', source, Config.Strings['NO_INVITATION']) return end

        Rev.org.func.removeMember(xPlayer.getJob().name, xPlayer.identifier)
        Rev.org.func.removeActiveMember(xPlayer.source, xPlayer.getJob().name)

        Wait(500)

        Rev.org.func.removeMember(xPlayer.getJob().name, xPlayer.identifier)
        Rev.org.func.removeActiveMember(xPlayer.source, xPlayer.getJob().name)

        -- Setting a new job to xPlayer job object
        xPlayer.setJob(invitation.name, 0)
        
        -- Adding player to new job member object
        local personalData = xPlayer.getPersonalData()
        local playerData = {
            identifier = xPlayer.identifier,
            firstname = personalData.firstname,
            lastname = personalData.lastname,
            birth = personalData.dateofbirth,
            sex = personalData.sex,
            phone_number = xPlayer.GetPhoneNumber(),
            grade = xPlayer.getJob().grade
        }

        Rev.org.func.addMember(invitation.name, playerData)
        Rev.org.func.addActiveMember(xPlayer.source, invitation.name)
        Rev.Invitations[xPlayer.identifier] = nil
        xPlayer.showNotification(string.format(Config.Strings['NEW_JOB'], invitation.label))
    elseif args[1] == 'odbij' then
        local invitation = Rev.Invitations[xPlayer.identifier]
        if not invitation then TriggerClientEvent('esx:showNotification', source, 'Nemate pozivnicu') return end
        Rev.Invitations[xPlayer.identifier] = nil
        xPlayer.showNotification(string.format(Config.Strings['REJECTED_JOB'], invitation.label))
    else
        TriggerClientEvent('esx:showNotification', source, Config.Strings['INVALID_INVITATION_COMMAND_SYNTAX'])
    end

end)


rateLimit, maxRateLimit, rateReset = {}, 3, 10

function checkRateLimit(source)
    local _source = tostring(source)
    -- Let's check if source is in rateLimit table 
    if not rateLimit[_source] then
        rateLimit[_source] = {count = 1, lastQuery = os.time()}
        return true
    end

    if math.abs(os.difftime(rateLimit[_source].lastQuery, os.time())) >= rateReset then
        rateLimit[_source] = {count = 1, lastQuery = os.time()}
        return true
    end

    if rateLimit[_source].count >= maxRateLimit then
        return false
    end

    rateLimit[_source].count = rateLimit[_source].count + 1
    
    return true
end
