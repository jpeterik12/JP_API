# JP Shotgun King API
A listener based API for use with *Shotgun King: The Final Checkmate* by PUNKCAKE Delicieux.
This allows easier creation of mods, as well as adding a few nice to haves.


**[Go to the documentation!](/doc/api.md)**

## Getting started
As a note, doing this will require knowledge in both lua and SGK's base functions 
### New Project
1. Copy the example mod into your mod folder and start editing.

### Existing Project
1. Copy the sections labeled `JP_API CODE` and `MOD CODE` into your mode's lua file.
2. If you have custom logic in `get_weapons_list` or `initialize`, combine that with the copies in the `JP_API CODE`.
3. Add the line `mod_setup()` into your mode's `start` function.
4. Add descriptions to your weapons using the `desc` key.

## Usage
Custom Code should be written in the section labeled `MOD CODE`, as distinct modules that are a single function. Then add that function to the `mod_setup` function.

## Updating
To update the API, simply copy the `JP_API CODE` section from the latest version into your mode's lua file.

## Example
Here is an example that simply logs each time some event occurs
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
For a more complete example, check out the [example mods](/examples/).

Check out **[the docs](/doc/api.md)** for a much more complete explaination!

If you have any questions, feel free to ask in the [Discord](https://discord.gg/dpQx647USm), or message me directily (JP12#1148)

Have fun!
