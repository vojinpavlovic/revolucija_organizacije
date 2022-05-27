ESX.RegisterCommand('posao', 'superadmin', function(xPlayer, args, showError)
    if ESX.DoesJobExist(args.job, args.grade) then
        -- Removing player from old member job
        
        Rev.org.func.removeMember(xPlayer.getJob().name, xPlayer.identifier)
        Rev.org.func.removeActiveMember(xPlayer.source, xPlayer.getJob().name)

        -- Setting a new job to xPlayer job object
        args.playerId.setJob(args.job, args.grade)
        
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

        Rev.org.func.addMember(args.job, playerData)
        Rev.org.func.addActiveMember(xPlayer.source, args.job)
	end
end, true, {help = 'Daj Posao', validate = true, arguments = {
	{name = 'playerId', help = 'ID', type = 'player'},
	{name = 'job', help = 'POSAO', type = 'string'},
	{name = 'grade', help = 'STEPEN', type = 'number'}
}})