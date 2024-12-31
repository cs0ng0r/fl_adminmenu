local function noPerms(xPlayer)
    xPlayer.showNotification("You are not Admin or God.", 'error')
end

--- @param perms string
function CheckPerms(source, perms)
    local xPlayer = ESX.GetPlayerFromId(source)
    print('CheckPerms', perms)
    local hasPerms = true --# TODO: perm check
    if not hasPerms then
        return noPerms(xPlayer)
    end

    return hasPerms
end

function CheckDataFromKey(key)
    local actions = Config.Actions[key]
    if actions then
        local data = nil

        if actions.event then
            data = actions
        end

        if actions.dropdown then
            for _, v in pairs(actions.dropdown) do
                if v.event then
                    local new = v
                    new.perms = actions.perms
                    data = new
                    break
                end
            end
        end

        return data
    end

    local playerActions = Config.PlayerActions[key]
    if playerActions then
        return playerActions
    end

    local otherActions = Config.OtherActions[key]
    if otherActions then
        return otherActions
    end
end

---@param plate string
---@return boolean
function CheckAlreadyPlate(plate)
    local vPlate = ESX.Math.Trim(plate)
    local result = MySQL.single.await("SELECT plate FROM owned_vehicles WHERE plate = ?", { vPlate })
    if result and result.plate then return true end
    return false
end

lib.callback.register('ps-adminmenu:callback:CheckPerms', function(source, perms)
    return CheckPerms(source, perms)
end)

lib.callback.register('ps-adminmenu:callback:CheckAlreadyPlate', function(_, vPlate)
    return CheckAlreadyPlate(vPlate)
end)

--- @param source number
--- @param target number
function CheckRoutingbucket(source, target)
    local sourceBucket = GetPlayerRoutingBucket(source)
    local targetBucket = GetPlayerRoutingBucket(target)

    if sourceBucket == targetBucket then return end

    SetPlayerRoutingBucket(source, targetBucket)
    TriggerClientEvent('ox_lib:notify', source, {
        description = locale("bucket_set", targetBucket),
        type = 'error'
    })
end

lib.callback.register('fl_adminmenu:getBasicServerData', function()
    local vehicles = MySQL.query.await('SELECT * FROM vehicles')

    return {
        vehicles = vehicles,
        jobs = ESX.GetJobs()
    }
end)

RegisterNetEvent('fl_adminmenu:discordLog', function(title, msg)
    ESX.DiscordLog(
        "fl_adminmenu",
        title,
        "green",
        msg
    )
end)
