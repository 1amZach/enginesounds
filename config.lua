Config = {}

Config.command = 'enginesound'
Config.key = false -- e.g. 'F7', false to skip the keybind
Config.position = 'top-right'

-- Ace needed to open the menu. Set to false to let everyone use it.
--   add_ace group.admin enginesound allow
Config.ace = 'enginesound'

-- Hear a sound as soon as you scroll onto it. Only you hear the preview,
-- everyone else hears it once you press Enter.
Config.preview = true

-- Default for "remember per model". Players can toggle it in the menu.
Config.rememberByModel = true

Config.recentLimit = 8

-- Show categories the player can't use, greyed out with a lock.
Config.showLocked = true

-- Each sound is { label, audio name }. The audio name is what you'd put in
-- audioNameHash in vehicles.meta, so addon sound packs work as long as they're streamed.
-- Give a category an `ace` to lock it behind its own permission:
--   add_ace group.vip enginesound.fun allow
-- If an audio name shows up twice, the first category wins.
Config.categories = {
    {
        label = 'Supercars',
        icon = 'bolt',
        sounds = {
            { 'Adder', 'adder' },
            { 'Zentorno', 'zentorno' },
            { 'T20', 't20' },
            { 'Osiris', 'osiris' },
            { 'Nero', 'nero' },
            { 'Krieger', 'krieger' },
            { 'Emerus', 'emerus' },
            { 'Tezeract (electric)', 'tezeract' },
        },
    },
    {
        label = 'Sports',
        icon = 'car-side',
        sounds = {
            { 'Elegy RH8', 'elegy2' },
            { 'Comet', 'comet2' },
            { 'Jester', 'jester' },
            { 'Banshee', 'banshee' },
            { 'Carbonizzare', 'carbonizzare' },
            { 'Feltzer', 'feltzer2' },
            { 'Sultan', 'sultan' },
            { 'Kuruma', 'kuruma' },
        },
    },
    {
        label = 'Muscle',
        icon = 'fire',
        sounds = {
            { 'Dominator', 'dominator' },
            { 'Gauntlet', 'gauntlet' },
            { 'Dukes', 'dukes' },
            { 'Sabre Turbo', 'sabregt' },
            { 'Vigero', 'vigero' },
            { 'Phoenix', 'phoenix' },
            { 'Hotknife', 'hotknife' },
        },
    },
    {
        label = 'Off-road & trucks',
        icon = 'truck-monster',
        sounds = {
            { 'Sandking', 'sandking' },
            { 'Trophy Truck', 'trophytruck' },
            { 'Bison', 'bison' },
            { 'Insurgent', 'insurgent' },
            { 'Phantom', 'phantom' },
        },
    },
    {
        label = 'Just for fun',
        icon = 'face-grin-squint',
        ace = 'enginesound.fun',
        sounds = {
            { 'Lazer jet', 'lazer' },
            { 'Rhino tank', 'rhino' },
            { 'Faggio', 'faggio' },
            { 'Hakuchou', 'hakuchou' },
            { 'Caddy', 'caddy' },
        },
    },
}
