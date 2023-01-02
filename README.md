# JP Shotgun King API
A listener based API for use with *Shotgun King: The Final Checkmate* by PUNKCAKE Delicieux.


**[Go to the documentation!](/doc/api.md)**

## Getting started
As a note, doing this will require knowledge in both lua and SGK's base functions 
### New Project
1. Copy the example mod into your mod folder and start editing.

### Existing Project
1. Copy the sections labeled `JP_API CODE` and `MOD CODE` into your mode's lua file.
2. If you have custom logic in `get_weapons_list`, `initialize`, or `on_new_turn`, combine that with the copies in the `JP_API CODE`.
3. Add the line `mod_setup()` into your mode's `start` function.
4. Add descriptions to your weapons using the `desc` key.

## Usage
Custom Code should be written in the section labeled `MOD CODE`, as distinct modules that are a single function. Then add that function to the `mod_setup` function.

## Example
Here is an example that simply logs each time an event occurs
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
    
    add_listener("bullet_upd", function(bullet) 
      _log("BULLET UPDATING")
    end)
    
    add_listener("after_black", function() 
      _log("BLACK MOVE")
    end)

    add_listener("after_white", function() 
      _log("WHITE MOVE")
    end)

    add_listener("upd", function() 
      _log("GENERIC UPDATE")
    end)

    add_listener("dr", function() 
      _log("GENERIC DRAW")
    end)
  end
end
-- MOD CODE END
...
```

Check out **[the docs](/doc/api.md)** for a much more complete explaination!

Have fun!
