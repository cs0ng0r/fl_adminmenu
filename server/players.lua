local function getVehicles(xPlayer)
    local result = MySQL.query.await(
        'SELECT vehicle, plate FROM owned_vehicles WHERE owner = ?', { xPlayer.identifier })
    local vehicles = {}

    for k, v in pairs(result) do
        local vehicleData = json.decode(v.vehicle)

        if vehicleData then
            vehicles[#vehicles + 1] = {
                id = k,
                cid = xPlayer.identifier,
                model = vehicleData.model,
                plate = v.plate,
                fuel = v.fuel,
                engine = v.engine,
                body = v.body
            }
        end
    end

    return vehicles
end

local function getPlayers()
    local players = {}

    for _, playerId in pairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local vehicles = getVehicles(xPlayer)


        players[#players + 1] = {
            id = playerId,
            name = xPlayer.getName(),
            cid = xPlayer.identifier,
            license = GetPlayerIdentifierByType(playerId, 'license'),
            discord = GetPlayerIdentifierByType(playerId, 'discord'),
            steam = GetPlayerIdentifierByType(playerId, 'steam'),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            dob = xPlayer.dateofbirth,
            cash = xPlayer.getAccount('money').money or 0,
            bank = xPlayer.getAccount('bank').money or 0,
            vehicles = vehicles
        }
    end

    table.sort(players, function(a, b) return a.id < b.id end)

    return players
end

lib.callback.register('ps-adminmenu:callback:GetPlayers', function(source)
    return getPlayers()
end)

-- Set Job
RegisterNetEvent('ps-adminmenu:server:SetJob', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local playerId, Job, Grade = selectedData["Player"].value, selectedData["Job"].value, selectedData["Grade"].value
    local Player = ESX.GetPlayerFromId(playerId)
    local name = Player.getName(9)
    local jobInfo = ESX.Jobs[Job]
    local grade = jobInfo["grades"][selectedData["Grade"].value]

    if not jobInfo then
        TriggerClientEvent('ox_lib:notify', src, {
            description = "Munka nem létezik!",
            type = 'error'
        })
        return
    end

    if not grade then
        TriggerClientEvent('ox_lib:notify', src, {
            description = "Érvénytelen rang",
            type = 'error'
        })
        return
    end

    Player.setJob(tostring(Job), tonumber(Grade))
    if Config.RenewedPhone then
        exports['qb-phone']:hireUser(tostring(Job), Player.PlayerData.citizenid, tonumber(Grade))
    end

    TriggerClientEvent('ox_lib:notify', src, {
        description = locale("jobset", name, Job, Grade),
        type = 'success'
    })
end)

-- Set Perms
RegisterNetEvent("ps-adminmenu:server:SetPerms", function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local rank = selectedData["Permissions"].value
    local targetId = selectedData["Player"].value
    local tPlayer = ESX.GetPlayerFromId(tonumber(targetId))

    if not tPlayer then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
        return
    end

    local name = tPlayer.getName()

    tPlayer.setGroup(rank)
    TriggerClientEvent('ox_lib:notify', src, {
        description = locale("player_perms", name, rank),
        type = 'success'
    })
end)
