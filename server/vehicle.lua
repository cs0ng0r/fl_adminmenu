-- Admin Car
RegisterNetEvent('ps-adminmenu:server:SaveCar', function(mods, vehicle, _, plate)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })

    if result[1] == nil then
        MySQL.insert(
            'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
            {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                vehicle.model,
                vehicle.hash,
                json.encode(mods),
                plate,
                0
            })
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("veh_owner"),
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("u_veh_owner"),
            type = 'error'
        })
    end
end)

-- Give Car
RegisterNetEvent("ps-adminmenu:server:givecar", function(data, selectedData)
    local src = source

    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("no_perms"),
            type = 'error'
        })
        return
    end

    local vehmodel = selectedData['Vehicle'].value
    local vehicleData = lib.callback.await("ps-adminmenu:client:getvehData", src, vehmodel)

    if not next(vehicleData) then
        return
    end

    local tsrc = selectedData['Player'].value
    local plate = selectedData['Plate (Optional)'] and selectedData['Plate (Optional)'].value or vehicleData.plate
    local garage = selectedData['Garage (Optional)'] and selectedData['Garage (Optional)'].value or Config.DefaultGarage
    local Player = ESX.GetPlayerFromId(tsrc)

    if plate and #plate < 1 then
        plate = vehicleData.plate
    end

    if garage and #garage < 1 then
        garage = Config.DefaultGarage
    end

    if plate:len() > 8 then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("plate_max"),
            type = 'error'
        })
        return
    end

    if not Player then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
        return
    end

    if CheckAlreadyPlate(plate) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("givecar.error.plates_alreadyused", plate:upper()),
            type = 'error'
        })
        return
    end

    MySQL.insert(
        'INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)',
        {
            Player.identifier,
            plate,
            json.encode(vehicleData),
            1
        })

    --# TODO: add esx vehicle name getter!
    TriggerClientEvent('ox_lib:notify', src, {
        description = locale(
            "givecar.success.source",
            'Kocsi neve',
            Player.getName()
        ),
        type = 'success'
    })

    TriggerClientEvent('ox_lib:notify', Player.source, {
        description = locale("givecar.success.target", plate:upper(), garage),
        type = 'success'
    })
end)

-- Give Car
RegisterNetEvent("ps-adminmenu:server:SetVehicleState", function(data, selectedData)
    local src = source

    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("no_perms"),
            type = 'error'
        })
        return
    end

    local plate = string.upper(selectedData['Plate'].value)
    local state = tonumber(selectedData['State'].value)

    if plate:len() > 8 then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("plate_max"),
            type = 'error'
        })
        return
    end

    if not CheckAlreadyPlate(plate) then
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("plate_doesnt_exist"),
            type = 'error'
        })
        return
    end

    MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', { state, 0, plate })

    TriggerClientEvent('ox_lib:notify', src, {
        description = locale("state_changed"),
        type = 'success'
    })
end)

-- Change Plate
RegisterNetEvent('ps-adminmenu:server:ChangePlate', function(newPlate, currentPlate)
    local newPlate = newPlate:upper()

    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:UpdateVehicle(currentPlate, newPlate)
    end

    MySQL.Sync.execute('UPDATE player_vehicles SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
    MySQL.Sync.execute('UPDATE trunkitems SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
    MySQL.Sync.execute('UPDATE gloveboxitems SET plate = ? WHERE plate = ?', { newPlate, currentPlate })
end)

lib.callback.register('ps-adminmenu:server:GetVehicleByPlate', function(source, plate)
    local result = MySQL.query.await('SELECT vehicle FROM owned_vehicles WHERE plate = ?', { plate })
    local veh = result[1] and result[1].vehicle or {}
    return json.decode(veh)
end)

-- Fix Vehicle for player
RegisterNetEvent('ps-adminmenu:server:FixVehFor', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(source, data.perms) then return end
    local src = source
    local playerId = selectedData['Player'].value
    local Player = ESX.GetPlayerFromId(tonumber(playerId))
    if Player then
        TriggerClientEvent('fl_adminmenu:fixVehicle', Player.source)
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("veh_fixed", Player.getName()),
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            description = locale("not_online"),
            type = 'error'
        })
    end
end)
