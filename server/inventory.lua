-- Clear Inventory
RegisterNetEvent('ps-adminmenu:server:ClearInventory', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local Player = ESX.GetPlayerFromId(player)

    if not Player then
        return TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
    end

    exports.ox_inventory:ClearInventory(Player.source)

    TriggerClientEvent('ox_lib:notify', src, {
        description = locale("invcleared", Player.getName()),
        type = 'success'
    })
end)

-- Clear Inventory Offline
RegisterNetEvent('ps-adminmenu:server:ClearInventoryOffline', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local src = source
    local citizenId = selectedData["Citizen ID"].value
    local Player = ESX.GetPlayerFromIdentifier(citizenId)

    if Player then
        if Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:ClearInventory(Player.source)
        else
            exports[Config.Inventory]:ClearInventory(Player.source, nil)
        end
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("invcleared", Player.getName()),
            type = 'success'
        })
    else
        MySQL.Async.fetchAll("SELECT inventory FROM users WHERE identifier = @identifier", { ['@identifier'] = citizenId },
            function(result)
                if result and result[1] then
                    MySQL.Async.execute("UPDATE users SET inventory = '[]' WHERE identifier = @identifier",
                        { ['@identifier'] = citizenId })

                    TriggerClientEvent('ox_lib:notify', src, {
                        description = 'Játékos inventory törölve!',
                        type = 'success'
                    })
                else
                    TriggerClientEvent('ox_lib:notify', src, {
                        description = locale("player_not_found"),
                        type = 'error'
                    })
                end
            end)
    end
end)

-- Open Inv [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenInv', function(data)
    exports.ox_inventory:forceOpenInventory(source, 'player', data)
end)

-- Open Stash [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenStash', function(data)
    exports.ox_inventory:forceOpenInventory(source, 'stash', data)
end)

-- Open Trunk [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenTrunk', function(data)
    exports.ox_inventory:forceOpenInventory(source, 'trunk', data)
end)

-- Give Item
RegisterNetEvent('ps-adminmenu:server:GiveItem', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local target = selectedData["Player"].value
    local item = selectedData["Item"].value
    local amount = selectedData["Amount"].value
    local Player = ESX.GetPlayerFromId(target)

    if not item or not amount then return end
    if not Player then
        return TriggerClientEvent('ox_lib:notify', source, {
            description = locale("not_online"),
            type = 'error'
        })
    end

    Player.addInventoryItem(item, amount)

    TriggerClientEvent('ox_lib:notify', source, {
        description = locale("give_item", tonumber(amount) .. " " .. item, Player.getName()),
        type = 'success'
    })
end)

-- Give Item to All
RegisterNetEvent('ps-adminmenu:server:GiveItemAll', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end

    local item = selectedData["Item"].value
    local amount = selectedData["Amount"].value
    local players = GetPlayers()

    if not item or not amount then return end

    for _, id in pairs(players) do
        local Player = ESX.GetPlayerFromId(id)
        Player.addInventoryItem(item, amount)
    end

    TriggerClientEvent('ox_lib:notify', source, {
        description = locale("give_item_all", amount .. " " .. item),
        type = 'success'
    })
end)
