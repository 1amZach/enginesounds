es = {}

-- audio name -> { label, category }
es.sounds = {}
es.access = false

for i, category in ipairs(Config.categories) do
    for _, sound in ipairs(category.sounds) do
        local audio = sound[2]
        if not es.sounds[audio] then
            es.sounds[audio] = { label = sound[1], category = i }
        end
    end
end

function es.allowed(audio)
    local sound = es.sounds[audio]
    return sound and es.access and es.access[sound.category] or false
end

function es.label(audio)
    return audio and es.sounds[audio] and es.sounds[audio].label or 'Stock'
end

function es.notify(text, kind)
    lib.notify({ description = text, type = kind or 'inform' })
end

function es.refreshAccess()
    es.access = lib.callback.await('enginesounds:access', false)
    return es.access
end

CreateThread(es.refreshAccess)
