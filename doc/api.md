# API
- Contents:
  - [Gun Descriptions](#gun-descriptions)
  - [Card Art Limit Removal](#card-art-limit-removal)
  - [Card Exhaustion Fix](#card-exhaustion-fix)
  - [`ban` on Weapons and Ranks](#ban-on-weapons-and-ranks)
  - [`add_listener()`](#add_listener-event-function)
  - [`remove_listener()`](#remove_listener-event-function)
  - [`new_special()`](#new_special-name-function)
  - [`_logv()`](#_logv-to_log-title)
  - [`_logs()`](#_logs-to_search-value)
  
&#8202;

#### Gun Descriptions
 - Add `desc = "<Description>"` to any weapon to add a description to it.
 - The description will be displayed in the weapon select menu as a hoverable `?`.

&#8202;

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

#### `ban` on Weapons and Ranks
 - Allows you to ban cards with specific weapons or ranks.
 - To ban a card, add `ban = {"Card 1", "Card 2", ...}` to the weapon or rank.
 - The ban does not apply to higher ranks, so to ban a card on all ranks above a certain rank, add `ban = {"Card 1", "Card 2", ...}` to all ranks above the first.
 - Thanks to Glacies for this feature!


&#8202;

#### `add_listener (event, function)`
- Attaches `function` to the `event`. Any arguements are passed to `function`.
- `event` must be a string.
- `function` must be a function.
- [List of `event`s](#events)

&#8202;

#### `remove_listener (event, function)`
- Removes `function` from the `event`.
- Must be the same function that was passed to `add_listener`.
- `event` must be a string.
- `function` must be a function.
- [List of `event`s](#events)

&#8202;

#### `new_special (name, function)`
- Creates a new special with the name `name` and the function `function`.
- To use in code, assign a card or weapon `special = "<name>"`
- `name` must be a string.
- `function` must be a function.

&#8202;

#### `_logv (to_log[, title])`
- Verbosely logs `to_log` to the console. (depth of 4)
- `title` must be a string
- If `title` is passed, it will be used as the title of the log.

&#8202;

#### `_logs (to_search, value)`
- Searches `to_search` for `value` and logs any paths that are equal to the console.
- Useful for finding the path to a specific value, or places where an entity is referenced.
- `to_search` must be a table.
- `value` can be any type.

&#8202;

# Events
- Contents:
  - [`shot`](#shot)
  - [`move`](#move)
  - [`blade`](#blade)
  - [`special`](#special)
  - [`bullet_init`](#bullet_init)
  - [`bullet_upd`](#bullet_upd)
  - [`after_white`](#after_white)
  - [`after_black`](#after_black)
  - [`upd`](#upd)
  - [`dr`](#dr)


&#8202;

#### `shot`
- Event fires after the player shoots. All bullets exist, and have not moved.
#### `move`
- Event fires after the player moves. The player is still moving when called.
#### `blade`
- Event fires after the player uses their blade. The piece is already killed.
#### `special`
- Event fires after the player uses a special. Objects exist (grenades) or other effects are set.
#### `bullet_init`
- Event fires for each bullet when it is spawned. Has the bullet passed in as a paramater.
#### `bullet_upd`
- Event fires for each bullet each update. Has the bullet passed in as a paramater.
#### `after_white`
- Event fires after all white pieces are done moving
#### `after_black`
- Event first after the black piece moves/shoots/reloads
#### `upd`
- Fires once per update
#### `dr`
- Fires once per screen draw
