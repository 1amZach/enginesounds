local store = es.store
local position = Config.position

-- vehicle we're currently previewing on, so it can be put back if the menu goes away
local previewing

local function driving()
    local vehicle = cache.vehicle

    if not vehicle or cache.seat ~= -1 then
        es.notify('You need to be driving', 'error')
        return
    end

    if IsEntityDead(cache.ped) then
        es.notify('You can\'t do that right now', 'error')
        return
    end

    return vehicle
end

local function stopPreview()
    if previewing then
        es.revert(previewing)
        previewing = nil
    end
end

local function preview(vehicle, audio)
    if not Config.preview then return end
    previewing = vehicle
    es.apply(vehicle, audio)
end

local function usable(list)
    local out = {}
    for i = 1, #list do
        if es.allowed(list[i]) then out[#out + 1] = list[i] end
    end
    return out
end

local openMain

-- One row per sound. Left/right switches between applying it and (un)favouriting it.
local function soundList(title, list, back, startIndex)
    local vehicle = cache.vehicle
    local options = {}

    for i, audio in ipairs(list) do
        local favourite = store.isFavourite(audio)
        local active = es.current(vehicle) == audio

        options[i] = {
            label = es.label(audio) .. (active and '  (current)' or ''),
            description = audio,
            icon = favourite and 'star' or 'volume-high',
            values = { 'Apply', favourite and 'Unfavourite' or 'Favourite' },
            args = audio,
            close = false,
        }
    end

    lib.registerMenu({
        id = 'es_list',
        title = title,
        position = position,
        options = options,
        onSelected = function(_, _, audio)
            preview(vehicle, audio)
        end,
        onClose = function(key)
            stopPreview()
            if key == 'Backspace' then back() end
        end,
    }, function(selected, scrollIndex, audio)
        if scrollIndex == 2 then
            local added = store.toggleFavourite(audio)
            es.notify(('%s %s favourites'):format(es.label(audio), added and 'added to' or 'removed from'), 'success')
            return soundList(title, list, back, selected)
        end

        if es.request(vehicle, audio) then
            es.notify(('Engine sound: %s'):format(es.label(audio)), 'success')
        end
    end)

    lib.showMenu('es_list', startIndex)
    preview(vehicle, list[startIndex or 1])
end

local function categories()
    local options, ids = {}, {}

    for i, category in ipairs(Config.categories) do
        local open = es.access[i]

        if open or Config.showLocked then
            options[#options + 1] = {
                label = category.label,
                icon = open and (category.icon or 'folder') or 'lock',
                description = open and ('%d sounds'):format(#category.sounds) or 'Locked',
            }
            ids[#options] = i
        end
    end

    lib.registerMenu({
        id = 'es_categories',
        title = 'Browse',
        position = position,
        options = options,
        onClose = function(key)
            if key == 'Backspace' then openMain() end
        end,
    }, function(selected)
        if not es.access[ids[selected]] then
            es.notify('That category is locked', 'error')
            return categories()
        end

        local category = Config.categories[ids[selected]]
        local list = {}

        for i, sound in ipairs(category.sounds) do
            list[i] = sound[2]
        end

        soundList(category.label, usable(list), categories)
    end)

    lib.showMenu('es_categories')
end

local function search()
    local input = lib.inputDialog('Search engine sounds', {
        { type = 'input', label = 'Name or audio name', required = true, min = 2 },
    })

    if not input then return openMain() end

    local query = input[1]:lower()
    local results = {}

    for _, category in ipairs(Config.categories) do
        for _, sound in ipairs(category.sounds) do
            local audio = sound[2]
            if (sound[1]:lower():find(query, 1, true) or audio:find(query, 1, true)) and es.allowed(audio) then
                results[#results + 1] = audio
            end
        end
    end

    if #results == 0 then
        es.notify(('Nothing matches "%s"'):format(input[1]), 'error')
        return openMain()
    end

    soundList(('Results for "%s"'):format(input[1]), results, openMain)
end

function openMain()
    local vehicle = driving()
    if not vehicle then return end

    local current = es.current(vehicle)
    local favourites = usable(store.favourites)
    local recent = usable(store.recent)

    lib.registerMenu({
        id = 'es_main',
        title = ('Engine sound: %s'):format(es.label(current)),
        position = position,
        options = {
            { label = 'Browse', icon = 'list' },
            { label = 'Search', icon = 'magnifying-glass' },
            { label = 'Favourites', icon = 'star', description = ('%d saved'):format(#favourites) },
            { label = 'Recent', icon = 'clock-rotate-left', description = ('%d used'):format(#recent) },
            { label = 'Back to stock', icon = 'rotate-left', description = current and 'Remove the custom sound' or 'Already stock' },
            {
                label = 'Remember per model',
                icon = 'floppy-disk',
                checked = store.remember,
                description = 'Reapply your last sound whenever you drive the same model',
            },
        },
        onCheck = function(_, checked)
            store.setRemember(checked)
        end,
    }, function(selected)
        if selected == 1 then
            categories()
        elseif selected == 2 then
            search()
        elseif selected == 3 or selected == 4 then
            local list = selected == 3 and favourites or recent

            if #list == 0 then
                es.notify(selected == 3 and 'No favourites yet' or 'Nothing used yet', 'error')
                return openMain()
            end

            soundList(selected == 3 and 'Favourites' or 'Recent', list, openMain)
        elseif selected == 5 then
            if current and es.request(vehicle, false) then
                es.notify('Engine sound back to stock', 'success')
            end
            -- give the state bag a moment so the title shows the new sound
            SetTimeout(300, openMain)
        end
    end)

    lib.showMenu('es_main')
end

RegisterNetEvent('enginesounds:open', function(access)
    es.access = access
    openMain()
end)

-- left the car with the menu open
lib.onCache('vehicle', function(vehicle)
    if vehicle then return end

    local open = lib.getOpenMenu()
    if open and open:sub(1, 3) == 'es_' then
        lib.hideMenu()
    end

    stopPreview()
end)

if Config.key then
    RegisterKeyMapping(Config.command, 'Engine sound menu', 'keyboard', Config.key)
end

TriggerEvent('chat:addSuggestion', '/' .. Config.command, 'Change your engine sound')
