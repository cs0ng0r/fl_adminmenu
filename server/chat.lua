local messages = {}

-- Staff Chat
RegisterNetEvent('ps-adminmenu:server:sendMessageServer', function(message, citizenid, fullname)
    if not CheckPerms(source, 'mod') then return end

    local time = os.time() * 1000
    local players = GetPlayers()

    for _, player in pairs(players) do
        --# TODO: admin check!
        TriggerClientEvent('ox_lib:notify', player, {
            description = locale("new_staffchat"),
            type = 'inform'
        })
    end

    messages[#messages + 1] = { message = message, citizenid = citizenid, fullname = fullname, time = time }
end)


lib.callback.register('ps-adminmenu:callback:GetMessages', function()
    if not CheckPerms(source, 'mod') then return {} end
    return messages
end)
