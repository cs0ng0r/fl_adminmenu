-- Toggles Invincibility
local visible = true
RegisterNetEvent('ps-adminmenu:client:ToggleInvisible', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    visible = not visible

    SetEntityVisible(cache.ped, visible, 0)
end)

-- God Mode
local godmode = false
RegisterNetEvent('ps-adminmenu:client:ToggleGodmode', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end
    godmode = not godmode

    if godmode then
        lib.notify({
            description = locale("godmode", "enabled"),
            type = 'inform'
        })
        while godmode do
            Wait(0)
            SetPlayerInvincible(cache.playerId, true)
        end
        SetPlayerInvincible(cache.playerId, false)
        lib.notify({
            description = locale("godmode", "disabled"),
            type = 'inform'
        })
    end
end)

-- Cuff/Uncuff
RegisterNetEvent('ps-adminmenu:client:ToggleCuffs', function(player)
    local target = GetPlayerServerId(player)
    TriggerEvent("police:client:GetCuffed", target)
end)

-- Copy Coordinates
local function CopyCoords(data)
    local coords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)
    local formats = {
        vector2 = "%.2f, %.2f",
        vector3 = "%.2f, %.2f, %.2f",
        vector4 = "%.2f, %.2f, %.2f, %.2f",
        heading =
        "%.2f"
    }
    local format = formats[data]

    local clipboardText = ""
    if data == "vector2" then
        clipboardText = string.format(format, coords.x, coords.y)
    elseif data == "vector3" then
        clipboardText = string.format(format, coords.x, coords.y, coords.z)
    elseif data == "vector4" then
        clipboardText = string.format(format, coords.x, coords.y, coords.z, heading)
    elseif data == "heading" then
        clipboardText = string.format(format, heading)
    end

    lib.setClipboard(clipboardText)
end

RegisterCommand("vector2", function()
    if not CheckPerms('mod') then return end
    CopyCoords("vector2")
end, false)

RegisterCommand("vector3", function()
    if not CheckPerms('mod') then return end
    CopyCoords("vector3")
end, false)

RegisterCommand("vector4", function()
    if not CheckPerms('mod') then return end
    CopyCoords("vector4")
end, false)

RegisterCommand("heading", function()
    if not CheckPerms('mod') then return end
    CopyCoords("heading")
end, false)

-- Toggle coords
local showCoords = false
local function showCoordsMenu()
    while showCoords do
        Wait(50)
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        SendNUIMessage({
            action = "showCoordsMenu",
            data = {
                show = showCoords,
                x = ESX.Math.Round(coords.x, 2),
                y = ESX.Math.Round(coords.y, 2),
                z = ESX.Math.Round(coords.z, 2),
                heading = ESX.Math.Round(heading, 2)
            }
        })
    end
end

RegisterNetEvent('ps-adminmenu:client:ToggleCoords', function(data)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    showCoords = not showCoords

    if showCoords then
        CreateThread(showCoordsMenu)
    end
end)

-- Set Ammo
RegisterNetEvent('ps-adminmenu:client:SetAmmo', function(data, selectedData)
    local data = CheckDataFromKey(data)
    if not data or not CheckPerms(data.perms) then return end

    local ammo = selectedData["Ammo Ammount"].value
    local weapon = GetSelectedPedWeapon(cache.ped)

    if weapon ~= nil then
        SetPedAmmo(cache.ped, weapon, ammo)
        lib.notify({
            description = locale("set_wepaon_ammo", tostring(ammo)),
            type = 'success'
        })
    else
        lib.notify({
            description = locale("no_weapon"),
            type = 'error'
        })
    end
end)

RegisterCommand("setammo", function(source)
    if not CheckPerms('mod') then return end
    local weapon = GetSelectedPedWeapon(cache.ped)
    local ammo = 999
    if weapon ~= nil then
        SetPedAmmo(cache.ped, weapon, ammo)
        lib.notify({
            description = locale("set_wepaon_ammo", tostring(ammo)),
            type = 'success'
        })
    else
        lib.notify({
            description = locale("no_weapon"),
            type = 'error'
        })
    end
end, false)

--Toggle Dev
local ToggleDev = false

RegisterNetEvent('ps-adminmenu:client:ToggleDev', function(dataKey)
    local data = CheckDataFromKey(dataKey)
    if not data or not CheckPerms(data.perms) then return end

    ToggleDev = not ToggleDev

    TriggerEvent("qb-admin:client:ToggleDevmode")              -- toggle dev mode (ps-hud/qb-hud)
    TriggerEvent('ps-adminmenu:client:ToggleCoords', dataKey)  -- toggle Coords
    TriggerEvent('ps-adminmenu:client:ToggleGodmode', dataKey) -- Godmode


    lib.notify({
        description = locale("toggle_dev"),
        type = 'success'
    })
end)

-- Key Bindings
local toogleAdmin = lib.addKeybind({
    name = 'toogleAdmin',
    description = locale("command_admin_desc"),
    defaultKey = Config.AdminKey,
    onPressed = function(self)
        ExecuteCommand('admin')
    end
})

--noclip
RegisterCommand('nc', function()
    TriggerEvent(Config.Actions["noclip"].event)
end, false)

local toogleNoclip = lib.addKeybind({
    name = 'toogleNoclip',
    description = locale("command_noclip_desc"),
    defaultKey = Config.NoclipKey,
    onPressed = function(self)
        ExecuteCommand('nc')
    end
})

if Config.Keybindings then
    toogleAdmin:disable(false)
    toogleNoclip:disable(false)
else
    toogleAdmin:disable(true)
    toogleNoclip:disable(true)
end

-- Set Ped
RegisterNetEvent("ps-adminmenu:client:setPed", function(pedModels)
    lib.requestModel(pedModels, 1500)
    SetPlayerModel(cache.playerId, pedModels)
    SetPedDefaultComponentVariation(cache.ped)
    SetModelAsNoLongerNeeded(pedModels)
end)
