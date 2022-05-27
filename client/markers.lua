--[[
    Let's draw markers and setting current actions if in marker distance
]]--

DrawText = function(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

Citizen.CreateThread(function()
    local hasExited = false
    local scoreboard = false
    while true do
        local lastAttack = {
            attack = 12,
            defend = 5
        }
        Citizen.Wait(0)
        if Rev.PlayerData then
            --Some variables
            local ped = PlayerPedId()
            local org = Rev.PlayerData.job.name
            local coords = GetEntityCoords(ped)
            local isInMarker, letSleep = false, true

            --Markers
            if Config.Org.list[org] then
                for k,v in pairs(Config.Org.list[org].coords) do
                    local distance = #(coords - v)
                    if distance <= Config.DrawDistance then
                        letSleep = false
                        local markerTable = Config.Org.markers[k]
                        DrawMarker(markerTable.type, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerTable.size.x, markerTable.size.y, markerTable.size.z, markerTable.color.r, markerTable.color.g, markerTable.color.b, 100, false, true, 2, true, false, false, false)
                        if distance <= Config.MarkerDistance then
                            if not isInMarker then
                                Rev.func.markers.enter(k, Config.Org.markers[k].help)
                            end
                            hasExited, isInMarker = false, true
                        end
                    end
                end
            end


            if Config.Teritories.list then
                for k, v in pairs(Config.Teritories.list) do
                    local distance = #(coords - v.coords) 
                    
                    local state = GlobalState[k]

                    if distance <= 50.0 and Rev.func.isTeritoryUnderAttack(k) and Rev.func.isAttorDeff(k) then

                        if Rev.func.compareTeritoryMinutes(k) then
                            Rev.func.onScoreboardChange(k)
                            Rev.func.assignLastAttack(k)
                        end

                        if not Rev.Scoreboard then
                            Rev.func.assignLastAttack(k)
                            Rev.func.revealScoreboard()
                            Rev.Scoreboard = true
                        end

                    elseif distance > 50.0 and Rev.Scoreboard or not Rev.func.isTeritoryUnderAttack(k) then
                        Rev.Scoreboard = false
                        Rev.func.defaultLastAttack()                        
                        Rev.func.unrevealScoreboard()                  
                    end
                    
                    if distance <= Config.DrawDistance then
                        letSleep = false
                        local markerTable = v.marker
                        local state = GlobalState[k]
                        if state.owner ~= Rev.PlayerData.job.name and Rev.func.isTeritoryUnderAttack(k) then
                            markerTable.color = {r = 120, g = 0, b = 0}
                        elseif state.owner == Rev.PlayerData.job.name and Rev.func.isTeritoryUnderAttack(k) then
                            markerTable.color = {r = 0, g = 120, b = 0}
                        elseif state.owner == org and not Rev.func.isTeritoryUnderAttack(k) then
                            markerTable.color = {r = 0, g = 0, b = 120}
                        end

                        DrawMarker(markerTable.type, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerTable.size.x, markerTable.size.y, markerTable.size.z, markerTable.color.r, markerTable.color.g, markerTable.color.b, 100, false, true, 2, true, false, false, false)
                        if distance <= Config.MarkerDistance then
                            if not isInMarker and hasExited then
                                if state.owner == Rev.PlayerData.job.name and not Rev.func.isTeritoryUnderAttack(k) then
                                    Rev.func.markers.enter('teritory', Config.Teritories.list[k].help.neutral, k)
                                elseif state.owner == Rev.PlayerData.job.name and Rev.func.isTeritoryUnderAttack(k) then
                                    Rev.func.markers.enter('teritory', Config.Teritories.list[k].help.defend, k)
                                else
                                    Rev.func.markers.enter('teritory', Config.Teritories.list[k].help.attack, k)
                                end
                            end
                            hasExited, isInMarker = false, true
                        end
                    end
                end
            end

            if Rev.Defend then
                letSleep = false
                local x, y, z = table.unpack(Config.Teritories.list[Rev.CurrentData].coords)
                DrawMarker(1, x, y, z-2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 20.0, 20.0, 2.0, 255,0,0, 100, false, true, 2, true, false, false, false)
                
                if #(coords - Config.Teritories.list[Rev.CurrentData].coords) >= 10 then
                    TriggerServerEvent('revolucija_organizacije:forceStopDefend', Rev.CurrentData)
                    --ESX.ShowNotification('Odbrana je prekinuta, nastavlja se napad!')
                    Rev.Defend = false
                end
            end

            if not isInMarker and not hasExited then
                Rev.func.markers.exit()
                hasExited = true
            end

            if letSleep then
                Citizen.Wait(1000)
                HasAlreadyEnteredMarker = false
            end
        else 
            Citizen.Wait(1000)
        end
    end
end)

--[[
    Registering key mapping and their handlers
]]--

RegisterCommand('+current_action', function()
    if Rev.CurrentAction then
        if Rev.func.markers[Rev.CurrentAction] == nil then
            ESX.ShowNotification('Funkcija ne postoji kontaktirajte server')
        else
            Rev.func.markers[Rev.CurrentAction]()
        end
    end
end, false)

RegisterCommand('-current_action', function() end, false)
RegisterKeyMapping('+current_action', 'Trenutne akcije', 'keyboard', 'e')

AddEventHandler('esx:onPlayerDeath', function() 
    Rev.Defend = false
    ESX.ShowNotification('Odbrana je prekinuta, nastavlja se napad!')
    TriggerServerEvent('revolucija_organizacije:forceStopDefend', Rev.CurrentData)
end)