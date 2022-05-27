ESX = nil
Rev = {}
Rev.PlayerData = nil
Rev.func = {}
Rev.func.markers = {}
Rev.func.vehicle = {}
Rev.func.data = {}
Rev.CurrentAction = nil
Rev.CurrentData = nil
Rev.Defend = false
Rev.Scoreboard = false
Rev.lastAttack = {
    minutes = 12,
    defend = 5
}
Rev.Blips = {
    alert = {},
    markers = {}
}

CreateThread(function()
	while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 
        Wait(250) 
    end

	while ESX.GetPlayerData().job == nil do 
        Wait(250) 
    end

	Rev.PlayerData = ESX.GetPlayerData()

    Wait(8000)
    TriggerServerEvent('revolucija_organizacije:getActiveMember', Rev.PlayerData.job.name)

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    Rev.PlayerData = playerData
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	Rev.PlayerData.job = job
end)

RegisterNetEvent('revolucija_organizacije:setMoney', function(money)
    Rev.PlayerData.money = money
end)

AddEventHandler('onResourceStop', function()
	if (GetCurrentResourceName() ~= 'revolucija_organizacije2') then
	  return
	end
	SetNuiFocus(false, false)
end)

--[[NUI Callbacks]]
RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
    TriggerScreenblurFadeOut()
end)

RegisterNUICallback('sendAnnounce', function(data) 
    TriggerServerEvent('revolucija_organizacije:sendAnnounce', data)
end)

RegisterNUICallback('deleteAnnounce', function(data) 
    TriggerServerEvent('revolucija_organizacije:deleteAnnounce', data)
end)

RegisterNUICallback('editAnnounce', function(data)
    TriggerServerEvent('revolucija_organizacije:editAnnounce', data)
end)

RegisterNUICallback('donateMoney', function(data)
    TriggerServerEvent('revolucija_organizacije:donateMoney', data)
end)

local alert = {}
--[[Events]]--
RegisterNetEvent('revolucija_organizacije:alertZone')
AddEventHandler('revolucija_organizacije:alertZone', function(key)
    local teritory = Config.Teritories.list[key]
    Citizen.CreateThread(function()
            Rev.Blips.alert.zone = AddBlipForRadius(teritory.coords, 800.0)
            SetBlipSprite(Rev.Blips.alert.zone,103)
            SetBlipColour(Rev.Blips.alert.zone,49)
            SetBlipAlpha(Rev.Blips.alert.zone,100)
            
            Rev.Blips.alert.blip = AddBlipForCoord(teritory.coords)
            SetBlipSprite(Rev.Blips.alert.blip, 310)
            SetBlipDisplay(Rev.Blips.alert.blip, 4)
            SetBlipColour(Rev.Blips.alert.blip, 4)
            SetBlipAsShortRange(Rev.Blips.alert.blip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Teritorija pod napadom! Ne prilazite')
            EndTextCommandSetBlipName(Rev.Blips.alert.blip)
    end)
end)

RegisterNetEvent('revolucija_organizacije:destroyAlertZone', function(key) 
    RemoveBlip(Rev.Blips.alert.zone)
    RemoveBlip(Rev.Blips.alert.blip)
end)