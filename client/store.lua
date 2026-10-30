local store = {}
es.store = store

local function load(key, default)
    local raw = GetResourceKvpString(key)
    if not raw then return default end

    local ok, value = pcall(json.decode, raw)
    return ok and type(value) == 'table' and value or default
end

local function save(key)
    SetResourceKvp(key, json.encode(store[key]))
end

store.favourites = load('favourites', {})
store.recent = load('recent', {})
store.models = load('models', {})

-- 0 means never set, so fall back to the config default
local remember = GetResourceKvpInt('remember')
store.remember = remember == 0 and Config.rememberByModel or remember == 1

function store.setRemember(on)
    store.remember = on
    SetResourceKvpInt('remember', on and 1 or 2)
end

local function indexOf(list, value)
    for i = 1, #list do
        if list[i] == value then return i end
    end
end

function store.isFavourite(audio)
    return indexOf(store.favourites, audio) ~= nil
end

function store.toggleFavourite(audio)
    local i = indexOf(store.favourites, audio)

    if i then
        table.remove(store.favourites, i)
    else
        store.favourites[#store.favourites + 1] = audio
    end

    save('favourites')
    return not i
end

function store.pushRecent(audio)
    local i = indexOf(store.recent, audio)
    if i then table.remove(store.recent, i) end

    table.insert(store.recent, 1, audio)

    for j = #store.recent, Config.recentLimit + 1, -1 do
        store.recent[j] = nil
    end

    save('recent')
end

-- kvp keys must be strings, model hashes are stored as text
function store.forModel(model)
    return store.models[tostring(model)]
end

function store.setModel(model, audio)
    store.models[tostring(model)] = audio or nil
    save('models')
end
