lib.addCommand('admin', {
    help = 'Open the admin menu', --# TODO: translate
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent('ps-adminmenu:client:OpenUI', source)
end)
