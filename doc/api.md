# API
- Contents:
  - [`add_listener()`](#add_listener-event-function)
  - [`remove_listener()`](#remove_listener-event-function)
  - [`_logv()`](#_logv-to_log-title)
  - [`_logs()`](#_logs-to_search-value)
  
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
