# JP_API for Shotgun King

A listener based API for use with *Shotgun King: The Final Checkmate* by PUNKCAKE Delicieux.
This allows easier creation of mods, as well as adding a few nice to haves.

**[Go to the documentation!](/doc/api.md)**

## Getting started

As a note, doing this will require knowledge in both lua and SGK's base functions

### New Project

1. Copy the [example mod](/example%20mod/) into your mod folder.
2. Rename the folder to your mod's name.
3. Start Using JP_API!

### Existing Project

1. Copy the code from [api.lua](/src/api.lua) and [mod.lua](/src/mod.lua) into your mode's lua file, outside of any functions.
2. If you have custom logic in `get_weapons_list` or `initialize`, combine that with the copies in the `JP_API CODE`.
3. Add the line `mod_setup()` into your mode's `start` function.
4. Start using JP_API!

## Usage

Custom Code should be written in the section labeled `MOD CODE`, as distinct modules that are a single function. Then add that function to the `mod_setup` function.

## Updating

To update the API, simply replace the `JP_API CODE` section in your mode's code with the newest version at [api.lua](/src/api.lua).

## Example

Here is an example that simply logs each time a few event occurs

```lua
...
-- MOD CODE
do
  function mod_setup()
    init_listeners()
    enable_logger()
  end

  function logger()
    add_listener("shot", function() 
      _log("PLAYER SHOT")
    end)
    
    add_listener("bullet_init", function(bullet) 
      _log("BULLET SPAWNED")
    end)
    
    add_listener("after_black", function() 
      _log("BLACK MOVE")
    end)

    add_listener("after_white", function() 
      _log("WHITE MOVE")
    end)
  end
end
-- MOD CODE END
...
```

For some more complete examples, check out the [example mods](/examples/).

Check out **[the docs](/doc/api.md)** for a much more complete explaination!

If you have any questions, feel free to ask in the [Discord](https://discord.gg/dpQx647USm), or message me directily (JP12#1148)

Have fun!

## Special Thanks

- PUNKCAKE Delicieux for making SGK
- Glacies#5786 on discord for the fixes to the base game as well as various code for the API
