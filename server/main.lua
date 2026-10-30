local categoryOf = {}

for i, category in ipairs(Config.categories) do
    for _, sound in ipairs(category.sounds) do
        categoryOf[sound[2]] = categoryOf[sound[2]] or i
    end
end

-- false when the player can't use the menu at all, otherwise one boolean per category
local function access(src)
    if Config.ace and not IsPlayerAceAllowed(src, Config.ace) then
        return false
    end

    local allowed = {}
    for i, category in ipairs(Config.categories) do
        allowed[i] = not category.ace or IsPlayerAceAllowed(src, category.ace)
    end

    return allowed
end

lib.callback.register('enginesounds:access', access)

RegisterCommand(Config.command, function(src)
    if src == 0 then return end

    local allowed = access(src)

    if not allowed then
        return TriggerClientEvent('ox_lib:notify', src, { description = 'You don\'t have access to engine sounds', type = 'error' })
    end

    TriggerClientEvent('enginesounds:open', src, allowed)
end, false)

local lastChange = {}

RegisterNetEvent('enginesounds:set', function(netId, audio)
    local src = source
    local now = GetGameTimer()

    if lastChange[src] and now - lastChange[src] < 500 then return end
    lastChange[src] = now

    local allowed = access(src)
    if not allowed then return end

    if audio ~= false then
        local category = type(audio) == 'string' and categoryOf[audio]
        if not category or not allowed[category] then return end
    end

    local vehicle = NetworkGetEntityFromNetworkId(tonumber(netId) or 0)
    if vehicle == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then return end

    -- only the driver gets to change it
    if GetPedInVehicleSeat(vehicle, -1) ~= GetPlayerPed(src) then return end

    Entity(vehicle).state:set('engineSound', audio or nil, true)
end)

AddEventHandler('playerDropped', function()
    lastChange[source] = nil
end)
