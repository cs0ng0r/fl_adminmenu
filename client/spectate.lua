RegisterNetEvent('ps-adminmenu:requestSpectate', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    exports.fl_spectate:spectatePlayer(selectedData['Player'].value)
end)
