-- Ban Player
RegisterNetEvent('ps-adminmenu:server:BanPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source

    local player = selectedData["Player"].value
    local reason = selectedData["Reason"].value or ""
    local time = tonumber(selectedData["Days"].value)

    if not tonumber(time) then
        return TriggerClientEvent('ox_lib:notify', src, {
            description = 'Érvénytelen a napok száma!',
            type = 'error'
        })
    end

    local xPlayer = ESX.GetPlayerFromId(player)
    if type(xPlayer) ~= 'table' then
        return TriggerClientEvent('ox_lib:notify', src, {
            description = 'Játékos nem található!',
            type = 'error'
        })
    end

    exports.fl_punishment:banPlayer(src, xPlayer.source, time, reason)

    TriggerClientEvent('ox_lib:notify', src, {
        description = 'Játékos kitiltva!',
        type = 'success'
    })
end)

RegisterNetEvent('ps-adminmenu:server:KickPlayer', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local target = ESX.GetPlayerFromId(selectedData["Player"].value)
    local reason = selectedData["Reason"].value

    if not target then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
        return
    end

    DropPlayer(target.source, locale("kicked") .. '\nAdmin: ' .. GetPlayerName(src) .. '\n' .. locale("reason") .. reason)
    TriggerClientEvent('ox_lib:notify', src, {
        description = 'Játékos kidobva',
        type = 'success'
    })
end)

-- Revive Player
RegisterNetEvent('ps-adminmenu:server:Revive', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local player = selectedData["Player"].value

    TriggerClientEvent('esx_ambulancejob:revive', player)
end)

-- Revive All
RegisterNetEvent('ps-adminmenu:server:ReviveAll', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    TriggerClientEvent('esx_ambulancejob:revive', -1)
end)

-- Revive Radius
RegisterNetEvent('ps-adminmenu:server:ReviveRadius', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local ped = GetPlayerPed(src)
    local pos = GetEntityCoords(ped)

    for _, v in pairs(GetPlayers()) do
        local target = GetPlayerPed(v)
        local targetPos = GetEntityCoords(target)
        local dist = #(pos - targetPos)

        if dist < 15.0 then
            TriggerClientEvent("hospital:client:Revive", v)
        end
    end
end)

-- Set RoutingBucket
RegisterNetEvent('ps-adminmenu:server:SetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local bucket = selectedData["Bucket"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    if bucket == currentBucket then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("target_same_bucket", player),
            type = 'error'
        })
        return
    end

    SetPlayerRoutingBucket(player, bucket)
    TriggerClientEvent('ox_lib:notify', src, {
        description = locale("bucket_set_for_target", player, bucket),
        type = 'success'
    })
end)

-- Get RoutingBucket
RegisterNetEvent('ps-adminmenu:server:GetBucket', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local currentBucket = GetPlayerRoutingBucket(player)

    TriggerClientEvent('ox_lib:notify', src, {
        description = locale("bucket_get", player, currentBucket),
        type = 'error'
    })
end)

-- Give Money
RegisterNetEvent('ps-adminmenu:server:GiveMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = ESX.GetPlayerFromId(tonumber(target))

    if Player == nil then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
        return
    end

    Player.addAccountMoney(tostring(moneyType), tonumber(amount))

    TriggerClientEvent('ox_lib:notify', src, {
        description = locale(
            (moneyType == "crypto" and "give_money_crypto" or "give_money"),
            tonumber(amount),
            Player.getName()
        ),
        type = 'success'
    })
end)

-- Give Money to all
RegisterNetEvent('ps-adminmenu:server:GiveMoneyAll', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local amount, moneyType = selectedData["Amount"].value, selectedData["Type"].value

    for _, v in pairs(GetPlayers()) do
        local Player = ESX.GetPlayerFromId(tonumber(v))
        Player.addAccountMoney(tostring(moneyType), tonumber(amount))
    end
    TriggerClientEvent('ox_lib:notify', src, {
        description = locale((moneyType == "crypto" and "give_money_all_crypto" or "give_money_all"), tonumber(amount)),
        type = 'success'
    })
end)

-- Take Money
RegisterNetEvent('ps-adminmenu:server:TakeMoney', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target, amount, moneyType = selectedData["Player"].value, selectedData["Amount"].value,
        selectedData["Type"].value
    local Player = ESX.GetPlayerFromId(tonumber(target))

    if Player == nil then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
        return
    end

    if Player.getAccountMoney(moneyType).money >= tonumber(amount) then
        Player.removeAccountMoney(moneyType, tonumber(amount))
    else
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_enough_money"),
            type = 'error'
        })
    end

    TriggerClientEvent('ox_lib:notify', src, {
        description = locale(
            (moneyType == "crypto" and "take_money_crypto" or "take_money"),
            tonumber(amount) .. "$",
            Player.getName()
        ),
        type = 'success'
    })
end)

-- Give Clothing Menu
RegisterNetEvent('ps-adminmenu:server:ClothingMenu', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local target = tonumber(selectedData["Player"].value)

    if target == nil then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
    end

    if target == src then
        TriggerClientEvent("ps-adminmenu:client:CloseUI", src)
    end

    TriggerClientEvent('fivem-appearance:skinCommand', target)
end)

-- Set Ped
RegisterNetEvent("ps-adminmenu:server:setPed", function(data, selectedData)
    local src = source
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("no_perms"),
            type = 'error'
        })
        return
    end

    local ped = selectedData["Ped Models"].label
    local tsrc = selectedData["Player"].value
    local Player = ESX.GetPlayerFromId(tsrc)

    if not Player then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
        return
    end

    TriggerClientEvent("ps-adminmenu:client:setPed", Player.source, ped)
end)
