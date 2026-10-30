# enginesounds

Change your car's engine sound in-game and everyone around you hears it.

Scroll through the list and you hear each sound straight away. Only you hear the preview until you press Enter, then it syncs to every player. Sounds are grouped into categories, there's search, favourites and a recent list, and it can remember the last sound you used on each model.

Works with any framework. The only dependency is [ox_lib](https://github.com/overextended/ox_lib).

## Install

1. Drop `enginesounds` into your resources.
2. Add it to `server.cfg` after ox_lib and give people access:

```
ensure ox_lib
ensure enginesounds

add_ace group.admin enginesound allow
```

Set `Config.ace = false` if you want everyone to have it.

## Usage

Get in the driver's seat and run `/enginesound` (or set `Config.key` for a keybind).

| Menu | |
|---|---|
| Browse | Sounds by category |
| Search | Find a sound by name or audio name |
| Favourites | Sounds you starred |
| Recent | The last few you used |
| Back to stock | Remove the custom sound |
| Remember per model | Reapply your last sound when you drive the same model again |

In a sound list, use left/right to switch between **Apply** and **Favourite**. Backspace goes back a menu, Escape closes it.

## Adding sounds

Each sound in `config.lua` is a label and an audio name, the same name you'd put in `audioNameHash` in `vehicles.meta`:

```lua
{
    label = 'Imports',
    icon = 'car',
    sounds = {
        { 'Supra 2JZ', 'toysupmk4' },
    },
},
```

Addon sound packs work as long as the pack is streamed on your server.

### Locking a category

Give a category an `ace` and only players with that ace can use it. Everyone else sees it with a lock (turn that off with `Config.showLocked = false`).

```lua
{ label = 'VIP', ace = 'enginesound.vip', sounds = { ... } }
```

```
add_ace group.vip enginesound.vip allow
```

## How it works

The sound is stored in a state bag on the vehicle, so it syncs to anyone who streams the car in, including players who join later. The server only accepts a change if:

- the player has access to the menu and to that sound's category
- the sound is in the config
- they're the one driving the vehicle

Changes are rate limited. Nothing gets anyone banned; bad requests are just ignored.

Changing the sound is blocked while the siren is on, because some siren resources start making noise with the lights off if the audio changes mid-siren.

## Credits

Inspired by [enginesound-menu](https://github.com/Gravxd/enginesound-menu) by Grav. This is a separate rewrite, no code is shared.

## License

MIT
