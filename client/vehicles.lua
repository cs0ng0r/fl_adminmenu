local function GetVehicleName(hash)
    local label = GetDisplayNameFromVehicleModel(hash)

    return GetFilenameForAudioConversation(label)
end
RegisterNUICallback('getVehicleName', function(model, cb)
    model = type(model) == 'number' and model or GetHashKey(model)
    cb(GetVehicleName(model))
end)

-- Own Vehicle
RegisterNetEvent('ps-adminmenu:client:Admincar', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local model = selectedData['Vehicle'].value
    ExecuteCommand('car ' .. model)
end)

-- Spawn Vehicle
RegisterNetEvent('ps-adminmenu:client:SpawnVehicle', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local selectedVehicle = selectedData["Vehicle"].value
    local hash = GetHashKey(selectedVehicle)

    if not IsModelValid(hash) then return end

    lib.requestModel(hash)

    if cache.vehicle then
        DeleteVehicle(cache.vehicle)
    end

    local vehicle = CreateVehicle(hash, GetEntityCoords(cache.ped), GetEntityHeading(cache.ped), true, false)
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)

    Wait(100)

    if Config.Fuel == "ox_fuel" then
        Entity(vehicle).state.fuel = 100.0
    else
        exports[Config.Fuel]:SetFuel(vehicle, 100.0)
    end
end)

-- Refuel Vehicle
RegisterNetEvent('ps-adminmenu:client:RefuelVehicle', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    if cache.vehicle then
        if Config.Fuel == "ox_fuel" then
            Entity(cache.vehicle).state.fuel = 100.0
        else
            exports[Config.Fuel]:SetFuel(cache.vehicle, 100.0)
        end
        lib.notify({
            description = locale("refueled_vehicle"),
            type = 'success'
        })
    else
        lib.notify({
            description = locale("not_in_vehicle"),
            type = 'error'
        })
    end
end)

-- Change plate
RegisterNetEvent('ps-adminmenu:client:ChangePlate', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    local plate = selectedData["Plate"].value

    if string.len(plate) > 8 then
        lib.notify({
            description = locale("plate_max"),
            type = 'error'
        })

        return
    end

    if cache.vehicle then
        local AlreadyPlate = lib.callback.await("ps-adminmenu:callback:CheckAlreadyPlate", false, plate)

        if AlreadyPlate then
            lib.notify({
                description = locale("already_plate"),
                type = 'error'
            })
            return
        end

        local currentPlate = GetVehicleNumberPlateText(cache.vehicle)
        TriggerServerEvent('ps-adminmenu:server:ChangePlate', plate, currentPlate)
        Wait(100)
        SetVehicleNumberPlateText(cache.vehicle, plate)
    else
        lib.notify({
            description = locale("not_in_vehicle"),
            type = 'error'
        })
    end
end)


-- Toggle Vehicle Dev mode
local VEHICLE_DEV_MODE = false
local function UpdateVehicleMenu()
    while VEHICLE_DEV_MODE do
        Wait(1000)

        local vehicle = lib.getVehicleProperties(cache.vehicle)
        local name = GetVehicleName(vehicle.model)
        local netID = VehToNet(cache.vehicle)

        SendNUIMessage({
            action = "showVehicleMenu",
            data = {
                show = VEHICLE_DEV_MODE,
                name = name,
                model = vehicle.model,
                netID = netID,
                engine_health = vehicle.engineHealth,
                body_health = vehicle.bodyHealth,
                plate = vehicle.plate,
                fuel = vehicle.fuelLevel,
            }
        })
    end
end

RegisterNetEvent('ps-adminmenu:client:ToggleVehDevMenu', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    if not cache.vehicle then return end

    VEHICLE_DEV_MODE = not VEHICLE_DEV_MODE

    if VEHICLE_DEV_MODE then
        CreateThread(UpdateVehicleMenu)
    end
end)

-- Max Mods
local PERFORMANCE_MOD_INDICES = { 11, 12, 13, 15, 16 }
local function UpgradePerformance(vehicle)
    SetVehicleModKit(vehicle, 0)
    ToggleVehicleMod(vehicle, 18, true)
    SetVehicleFixed(vehicle)

    for _, modType in ipairs(PERFORMANCE_MOD_INDICES) do
        local maxMod = GetNumVehicleMods(vehicle, modType) - 1
        SetVehicleMod(vehicle, modType, maxMod, customWheels)
    end

    lib.notify({
        description = locale("vehicle_max_modded"),
        type = 'success'
    })
end


RegisterNetEvent('ps-adminmenu:client:maxmodVehicle', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    if cache.vehicle then
        UpgradePerformance(cache.vehicle)
    else
        lib.notify({
            description = locale("vehicle_not_driver"),
            type = 'error'
        })
    end
end)

-- Spawn Personal vehicles

RegisterNetEvent("ps-adminmenu:client:SpawnPersonalVehicle", function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local plate = selectedData['VehiclePlate'].value
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local vehicleData = lib.callback.await('ps-adminmenu:server:GetVehicleByPlate', false, plate)

    ESX.Game.SpawnVehicle(vehicleData.model, coords, heading, function(vehicle)
        SetEntityHeading(vehicle, heading)
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        SetVehicleModKit(vehicle, 0)
        ESX.Game.SetVehicleProperties(vehicle, vehicleData)
        SetVehicleNumberPlateText(vehicle, plate)

        if Config.Fuel == "ox_fuel" then
            Entity(vehicle).state.fuel = 100.0
        else
            exports[Config.Fuel]:SetFuel(vehicle, 100.0)
        end
    end)
end)

-- Get Vehicle Data
lib.callback.register("ps-adminmenu:client:getvehData", function(vehicle)
    lib.requestModel(vehicle)

    local coords = vec(GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.5), GetEntityHeading(cache.ped) + 90)
    local veh = CreateVehicle(vehicle, coords, false, false)

    local prop = {}
    if DoesEntityExist(veh) then
        SetEntityCollision(veh, false, false)
        FreezeEntityPosition(veh, true)
        prop = ESX.Game.GetVehicleProperties(veh)
        Wait(500)
        DeleteVehicle(veh)
    end

    return prop
end)
