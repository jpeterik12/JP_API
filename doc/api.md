# API

- Contents:
  - [Fixes and Features](#fixes-and-features)
    - [Card Art Limit Removal](#card-art-limit-removal)
    - [Card Exhaustion Fix](#card-exhaustion-fix)
    - [Gun Descriptions](#gun-and-rank-descriptions)
    - [Custom Gun Art](#custom-gun-art)
    - [Gun GID Fix](#gun-gid-fix)
    - [`force` `ban` Fix](#force-ban-fix)
    - [Piece Limit Removal](#piece-limit-removal)
    - [`ban` on Weapons and Ranks](#ban-on-weapons-and-ranks)
    - [`ban_modules`](#ban_modules)
  - [Listeners](#listeners)
    - [`add_listener()`](#add_listener-event-function)
    - [`remove_listener()`](#remove_listener-event-function)
  
  - [`new_special()`](#new_special-name-function)
  - [Debug Tools](#debug)
    - [`_logv()`](#_logv-to_log-title)
    - [`_logs()`](#_logs-to_search-value)
  
&#8202;

## Fixes and Features

These are things JP_API that aren't part of the listener system, but are features that are useful

### Fixes

#### Card Art Limit Removal

- JP_API removes the limit of 120 Cards (60 Black, 60 White).
- To mark a card above `gid` 119 to the black team, add `real_team = 0` to the card.
- Otherwise, cards above `gid` 119 will be marked as white.
- Thanks to Glacies for finding out how to set the team!

&#8202;

#### Card Exhaustion Fix

- JP_API removes the limit of 5 cards when choosing a card.
- Nothing needs to be done to enable this feature.
- Thanks to Glacies for this feature!

&#8202;

### New Features

#### `ban` on Weapons and Ranks

- Allows you to ban cards with specific weapons or ranks.
- To ban a card, add `ban = {"Card 1", "Card 2", ...}` to the weapon or rank.
- The ban does not apply to higher ranks, so to ban a card on all ranks above a certain rank, add `ban = {"Card 1", "Card 2", ...}` to all ranks above the first.
- Thanks to Glacies for this feature!

&#8202;

#### Gun and Rank Descriptions

- Add `desc = "<Description>"` to any weapon or rank to add a description to it.
- The description will be displayed in the weapon/rank select menu as a hoverable `?`.

&#8202;

#### Custom Gun Art

- If you expand the file `weapons.png` 16 px to the right, you can add custom weapon holding art.
- The sprite will take the 16 by 16 px area to the right of the weapon's reload art.

#### Gun GID Fix

- The gid of a weapon is now used to set the image that is displayed in the weapon select menu.
- This means that you can now have multiple weapons with the same texture, remove certain weapons from modes, or rearrage weapons.

#### Piece Limit Removal

- JP_API removes the limit of 10 pieces.
- As a side effect, it will prevent you from achieving "HOW IT SHOULD BE" or "SHE IS EVERYWHERE" achievements.
  - This also applies to any other mods or the base game, unless you restart the game.
- Thanks to Glacies for finding out how to remove the limit!

#### `force` `ban` fix

- In vanilla, if you force a card, it will undo any bans on that card.
- JP_API fixes this by making it so that if you force a card, it will be forced, but then banned afterwards.

#### `allow_modules`

- Allows you to select specific modules to be loaded based on gamemode
- To add a module, just add `allow_modules = {"<module>"}` in the same place you would but `ban={...}` for the mode
- Note: This does not work on weapons or cards
- By default, All modules are loaded

#### `ban_modules`

- Allows you to ban specific modules from loading based on gamemode
- To ban a module, just add `ban_modules = {"<module>"}` in the same place you would but `ban={...}` for the mode
- Note: This does not work on weapons or cards
- By default, All modules are loaded

&#8202;

### Listeners

The following functions are used for interacting with the listener system of JP_API

#### `add_listener (event, function)`

- Attaches `function` to the `event`. Any arguements are passed to `function`.
- `event` must be a string.
- `function` must be a function.
- [List of `event`s](events)

&#8202;

#### `remove_listener (event, function)`

- Removes `function` from the `event`.
- Must be the same function that was passed to `add_listener`.
- `event` must be a string.
- `function` must be a function.
- [List of `event`s](events)

&#8202;

#### `new_special (name, function)`

- Creates a new special with the name `name` and the function `function`.
- To use in code, assign a card or weapon `special = "<name>"`
- `name` must be a string.
- `function` must be a function.

&#8202;

### Debug

These functions are useful for debugging / or developing.
Logs are found in log.txt in the game directory.

#### `_logv (to_log[, title])`

- Logs `to_log` to the log file. Table values are fully logged, with a max depth of 4.  
- `title` must be a string
- If `title` is passed, it will be used as the title of the log.

&#8202;

#### `_logs (to_search, value)`

- Searches `to_search` for `value` and logs any paths that are equal to the log file.
- Useful for finding the path to a specific value, or places where an entity is referenced.
- `to_search` must be a table.
- `value` can be any type.

&#8202;
