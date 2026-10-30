-- Not a real audio object. Forcing a name the game can't find makes it fall back
-- to the vehicle's own sound, including whatever an addon car set in its meta.
local STOCK = 'enginesounds_stock'

function es.apply(vehicle, audio)
    if vehicle and DoesEntityExist(vehicle) then
        ForceUseAudioGameObject(vehicle, audio or STOCK)
    end
end

function es.current(vehicle)
    return Entity(vehicle).state.engineSound
end

-- put back whatever is synced, used after previewing
function es.revert(vehicle)
    es.apply(vehicle, es.current(vehicle))
end

-- auto is set when we're reapplying a remembered sound, so it doesn't count as a pick
function es.request(vehicle, audio, auto)
    if not NetworkGetEntityIsNetworked(vehicle) then
        if not auto then es.notify('This vehicle isn\'t synced, so nobody else would hear it', 'error') end
        return false
    end

    -- some siren resources start making noise with the lights off if the
    -- audio object changes while the siren is running
    if IsVehicleSirenOn(vehicle) then
        if not auto then es.notify('Turn your siren off first', 'error') end
        return false
    end

    TriggerServerEvent('enginesounds:set', VehToNet(vehicle), audio or false)

    if auto then return true end

    if audio then
        es.store.pushRecent(audio)
    end

    if es.store.remember then
        es.store.setModel(GetEntityModel(vehicle), audio)
    end

    return true
end

AddStateBagChangeHandler('engineSound', nil, function(bagName, _, audio)
    CreateThread(function()
        -- the bag can arrive a moment before the vehicle exists on our side
        local ok, vehicle = pcall(lib.waitFor, function()
            local entity = GetEntityFromStateBagName(bagName)
            if entity ~= 0 then return entity end
        end, nil, 5000)

        if ok and GetEntityType(vehicle) == 2 then
            es.apply(vehicle, audio)
        end
    end)
end)

-- reapply the last sound used on this model when you take the wheel
lib.onCache('seat', function(seat)
    if seat ~= -1 or not es.store.remember or not es.access then return end

    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    if vehicle == 0 then return end

    local audio = es.store.forModel(GetEntityModel(vehicle))

    if audio and es.allowed(audio) and es.current(vehicle) ~= audio then
        es.request(vehicle, audio, true)
    end
end)
