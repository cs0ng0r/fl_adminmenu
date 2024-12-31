-- Freeze Player
local frozen = false
RegisterNetEvent('ps-adminmenu:server:FreezePlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source

    if type(selectedData['Player']) ~= 'table' then
        return
    end
    local target = selectedData["Player"].value

    local ped = GetPlayerPed(target)
    local Player = ESX.GetPlayerFromId(target)

    if not Player then
        return TriggerClientEvent('ox_lib:notify', src, {
            description = locale('not_online'),
            type = 'error'
        })
    end

    if not frozen then
        frozen = true
        FreezeEntityPosition(ped, true)

        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("Frozen", Player.getName() .. " | " .. Player.identifier),
            type = 'success'
        })
    else
        frozen = false
        FreezeEntityPosition(ped, false)
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("deFrozen", Player.getName() .. " | " .. Player.identifier),
            type = 'success'
        })
    end
end)

-- Drunk Player
RegisterNetEvent('ps-adminmenu:server:DrunkPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target = selectedData["Player"].value
    local Player = ESX.GetPlayerFromId(target)

    if not Player then
        return TriggerClientEvent('ox_lib:notify', src, {
            description = locale('not_online'),
            type = 'error'
        })
    end

    TriggerClientEvent('ps-adminmenu:client:InitiateDrunkEffect', target)
    TriggerClientEvent('ox_lib:notify', src, {
        description = locale("playerdrunk", Player.getName() .. " | " .. Player.identifier),
        type = 'success'
    })
end)
