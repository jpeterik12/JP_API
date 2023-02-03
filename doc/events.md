# Events

This is a list of all events you can access using JP_API

## All Events

### TOC

- Actions
  - [`shot`](#shot)
  - [`move`](#move)
  - [`blade`](#blade)
  - [`special`](#special)
- Bullets
  - [`bullet_init`](#bullet_init)
  - [`bullet_upd`](#bullet_upd)
- Grenades
  - [`grenade_init`](#grenade_init)
  - [`grenade_upd`](#grenade_upd)
  - [`grenade_bouce`](#grenade_bouce)
  - [`grenade_land`](#grenade_land)
  - [`grenade_explode`](#grenade_explode)
- Pieces
  - [`bad_death`](#bad_death)
  - [`pawn_death`](#pawn_death)
  - [`knight_death`](#knight_death)
  - [`bishop_death`](#bishop_death)
  - [`rook_death`](#rook_death)
  - [`queen_death`](#queen_death)
  - [`king_death`](#king_death)
- Generic
  - [`after_white`](#after_white)
  - [`after_black`](#after_black)
  - [`floor_start`](#floor_start)
  - [`floor_end`](#floor_end)
  - [`bad_death`](#bad_death)
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

#### `grenade_init`

- Event fires for each grenade when it is spawned. Has the grenade passed in as a paramater.

#### `grenade_upd`

- Event fires for each grenade each update. Has the grenade passed in as a paramater.

#### `grenade_bouce`

- Event fires for each grenade when it bounces. Has the grenade passed in as a paramater.

#### `grenade_land`

- Event fires for each grenade when it lands. Has the grenade passed in as a paramater.

#### `grenade_explode`

- Event fires for each grenade when it explodes. Has the grenade passed in as a paramater.

#### `after_white`

- Event fires after all white pieces are done moving

#### `after_black`

- Event first after the black piece moves/shoots/reloads

#### `floor_start`

- Event fires when a new floor is started

#### `floor_end`

- Event fires when a floor is ended

#### `bad_death`

- Event fires when a piece dies. Has the piece passed in as a paramater.

#### `pawn_death`

- Event fires when a pawn dies. No paramater.

#### `knight_death`

- Event fires when a knight dies. No paramater

#### `bishop_death`

- Event fires when a bishop dies. No paramater

#### `rook_death`

- Event fires when a rook dies. No paramater

#### `queen_death`

- Event fires when a queen dies. No paramater

#### `king_death`

- Event fires when a king dies. No paramater

#### `upd`

- Fires once per update

#### `dr`

- Fires once per screen draw
