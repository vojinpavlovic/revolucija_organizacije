--[[ Adding Global variables ]]--

ESX = nil
Rev = {}
Rev.table = {}
Rev.Save = {}
Rev.org = {
    jobs = {},
    func = {}
}
Rev.teritories = {
    rang = {},
    func = {},
    instances = {}
}

Rev.Invitations = {}

Rev.teritoryList = {}
Rev.rankList = {}
GlobalState.rankList = {}

--[[ Loading Framework ]]--

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('mtablet', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        
        if Config.Org.list[xPlayer.getJob().name] == nil then 
            xPlayer.showNotification('Nemate pristup mafija panelu!')
            return
        end

        if xPlayer.getInventoryItem('mtablet').count <= 0 then 
            xPlayer.showNotification('Nemate tablet!')
            return
        end
        
        TriggerClientEvent('revolucija_organizacije:openTablet', source)
    end
end)