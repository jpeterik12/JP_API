id = "3_goofy_chase"
ban = {
  "Egotic Maelstrom",
  "Undercover Mission",
  "Unholy Call",
  "Imperial Shot Put",
}
setup = {
  slots_max = { 5, 0 },
}
base = {
  ammo_regen = 1, king_hp = -2, militia = 1
}
proba = { 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4 }
pieces_danger = { 1, 3, 3, 6, 9, 0 }
fill_last_slot = true
turns = 0

weapons = {
  { gid = 0, name = "Bursting Shotgun", chamber_max = 1, firepower = 4, firerange = 4, spread = 90, ammo_max = 4,
    airburst = 1.5, desc = "Bullets go perfectly straight before spreading. The point at the end splits the bullet." },
  { gid = 1, name = "Perfect Barrels", chamber_max = 3, firepower = 4, firerange = 5, spread = 70, ammo_max = 5,
    fixed_angle = 1, desc = "Bullets are spread evenly across fire arc. Less a shotgun and more 4 rifles taped together." },
  { gid = 2, name = "Acceleration Cannon", chamber_max = 1, firepower = 2, firerange = 10, spread = 50, ammo_max = 4,
    strengthening = 1, desc = "Bullets do more damage the longer they exist. Go for those snipes." },
  { gid = 3, name = "Deceleration Cannon", chamber_max = 2, firepower = 2, firerange = 10, spread = 50, ammo_max = 4,
    weakening = 1, desc = "Bullets do less damage the longer they exist. Get in their face." },
  { gid = 4, name = "Single Use Shotgun", chamber_max = 1, firepower = 1, firerange = 10, spread = 0, ammo_max = 0,
    one_shot = 1, desc = "No spare bullets. One shot, one kill. Get the angle, take the shot." },
  { gid = 5, name = "Long Shotgun", chamber_max = 2, firepower = 4, firerange = 4, spread = 50, ammo_max = 5,
    long_gun = 1, desc = "You can't hit pieces within one tile. This must be why people often make sawn-offs." },
  { gid = 6, name = "Heat Seeking Shotgun", chamber_max = 1, firepower = 4, firerange = 5, spread = 180, ammo_max = 4,
    homing = 1, desc = "Homing Bullets. Science still doesn't understand." },
  { gid = 7, name = "Curved Shotgun", chamber_max = 2, firepower = 4, firerange = 4, spread = 80, ammo_max = 5,
    curve = 1, desc = "The bullets will start to curve once leaving your barrel. Maybe check the alignment?" },
  { gid = 8, name = "Bouncing Shotgun", chamber_max = 1, firepower = 5, firerange = 5, spread = 30, ammo_max = 4,
    bounce = 1, desc = "BUllets will bounce off the edge of the board. Time for some trickshots." },
}

-- JP_API CODE
do -- VERSION 2.1
  MODNAME = current_mod

  MODULES = {}
  foreach(ls("mods/" .. MODNAME .. "/modules/"), function(module_name)
    if module_name:sub(-4) ~= ".lua" then return end
    module = table_from_file("mods/" .. MODNAME .. "/modules/" .. sub(module_name, 1, #module_name - 4))
    if ban_modules and tbl_index(module.id, ban_modules) > 0 then return end
    if allow_modules and tbl_index(module.id, ban_modules) < 0 then return end
    add(MODULES, module)
  end)

  do -- LOGGING CODE
    function _logv(o, start_str, max_depth)
      if not start_str then
        start_str = ""
      end
      if not max_depth then
        max_depth = 4
      end
      local function data_tostring_recursive(data, depth, parent)
        local function indent(n)
          local str = ""
          for i = 0, n do
            str = str .. "  "
          end
          return str
        end

        if data == nil then
          return "nil"
        end
        local data_type = type(data)
        if data_type == type(true) then
          if data then
            return "true"
          else
            return "false"
          end
        elseif data_type == type(1) then
          return "" .. data
        elseif data_type == type("") then
          return "\"" .. data .. "\""
        elseif data_type == type(function() end) then
          return "function()"
        elseif data_type == type({}) then
          if depth == max_depth then
            return "{...}"
          end
          local data_string = "{"
          for key, value in pairs(data) do
            if value == _G then
              data_string = data_string .. "\n" .. indent(depth) ..
                  data_tostring_recursive(key, depth + 1, data) .. ": {_G}," -- don't recurse into _G
            elseif value == parent then
              data_string = data_string .. "\n" .. indent(depth) ..
                  data_tostring_recursive(key, depth + 1, data) .. ": {parent}," -- don't recurse into parent
            else
              data_string = data_string .. "\n" .. indent(depth) ..
                  data_tostring_recursive(key, depth + 1, data) ..
                  ": " .. data_tostring_recursive(value, depth + 1, data) .. ","
            end
          end
          if data_string == "{" then
            return "{}"
          end
          if data_string:sub(-1) == "," then
            data_string = data_string:sub(1, -2)
          end
          data_string = data_string .. "\n" .. indent(depth - 1) .. "}"
          return data_string
        else
          return "MISSING DATA TYPE: " .. data_type
        end
      end

      _log("DATA START: " .. start_str .. "\n" .. data_tostring_recursive(o, 0) .. "\nDATA END")
    end

    function _logs(o, value, max_depth)
      if not max_depth then
        max_depth = 4
      end
      local function search_recurse(p, v, d, path)
        if type(p) == type({}) then
          for k, v2 in pairs(p) do
            if v2 == v then
              if (type(k) == type("")) or (type(k) == type(1)) then
                _log(path .. "." .. k)
              else
                _log(path .. "[non-string key]")
              end
            elseif (d < max_depth) and (v2 ~= _G) then
              if (type(k) == type("")) or (type(k) == type(1)) then
                search_recurse(v2, v, d + 1, path .. "." .. k)
              else
                search_recurse(v2, v, d + 1, path .. "[non-string key]")
              end
            end
          end
        end
      end

      if (type(value) == type("")) or (type(value) == type(1)) then
        _log("SEARCHING FOR " .. value)
      else
        _log("SEARCHING FOR NON-STRING/NUMBER")
      end
      search_recurse(o, value, 0, "")
    end
  end

  do -- LISTENER CODE
    ons_updated = false
    function init_listeners()
      if LISTENER then
        del(ents, LISTENER)
      end
      LISTENER = mke()
      do -- EVENT LIST
        LISTENER.listeners = {}
        LISTENER.specials = {}

        LISTENER.listeners["shot"] = {}
        LISTENER.listeners["blade"] = {}
        LISTENER.listeners["move"] = {}
        LISTENER.listeners["special"] = {}

        LISTENER.listeners["upd"] = {}
        LISTENER.listeners["dr"] = {}

        LISTENER.listeners["bullet_init"] = {}
        LISTENER.listeners["bullet_upd"] = {}

        LISTENER.listeners["grenade_init"] = {}
        LISTENER.listeners["grenade_upd"] = {}
        LISTENER.listeners["grenade_bounce"] = {}
        LISTENER.listeners["grenade_land"] = {}
        LISTENER.listeners["grenade_explode"] = {}

        LISTENER.listeners["bad_death"] = {}

        LISTENER.listeners["pawn_death"] = {}
        LISTENER.listeners["knight_death"] = {}
        LISTENER.listeners["bishop_death"] = {}
        LISTENER.listeners["rook_death"] = {}
        LISTENER.listeners["queen_death"] = {}
        LISTENER.listeners["king_death"] = {}

        LISTENER.listeners["after_black"] = {}
        LISTENER.listeners["after_white"] = {}
      end
      local function card_fixing(ent)
        function fix_card(tfcard)
          tfcard.old_dr = tfcard.dr
          tfcard.og_gid = tfcard.gid
          tfcard.card_counter = true
          tfcard.dr = function(self, ...)
            if self.flip_co and self.flip_co > 0.5 then
              self.gid = 59 + self.team
            else
              self.gid = self.og_gid
            end
            self.old_dr(self, unpack({ ... }))
          end
        end

        if ent.gid and ent.gid >= 120 and not ent.card_counter then
          fix_card(ent)
        end
        if ent.cards then
          for sub_ent in all(ent.cards) do
            if sub_ent.gid and sub_ent.gid >= 120 and not sub_ent.card_counter then
              fix_card(sub_ent)
            end
          end
        end
      end

      local function click_tracking(ent)
        local function grenade_tracking(ent) -- (Glacies)
          local function setup_bounce(grenade)
            if not grenade.twf then return end
            grenade.old_twf = grenade.twf
            grenade.state = (grenade.jz > 20)
            grenade.twf = function()
              if grenade.state then
                for listener in all(LISTENER.listeners["grenade_bounce"]) do
                  listener(grenade)
                end
              else
                for listener in all(LISTENER.listeners["grenade_land"]) do
                  listener(grenade)
                end
                local delay = 57
                local sq = get_square_at(grenade.x, grenade.y)
                if sq then
                  if abs(hero.sq.px - sq.px) < 2 and abs(hero.sq.py - sq.py) < 2 then delay = 236 end
                  wait(delay, function()
                    for listener in all(LISTENER.listeners["grenade_explode"]) do
                      listener(grenade)
                    end
                  end)
                end
              end
              grenade.old_twf()
              setup_bounce(grenade)
            end
          end

          if not ent.fra then return end
          if ent.tracked then return end
          ent.tracked = true
          for listener in all(LISTENER.listeners["grenade_init"]) do
            listener(ent)
          end
          ent.old_upd = ent.upd
          ent.upd = function(self)
            for listener in all(LISTENER.listeners["grenade_upd"]) do
              listener(self)
            end
            self.old_upd(self)
          end
          setup_bounce(ent)
        end

        local function special_tracker(ent2)
          if ent2.right_clic then
            local skip = false
            for special, func in pairs(LISTENER.specials) do
              if stack[special] then
                ent2.old_right_clic = func
                skip = true
              end
            end
            if not skip then
              ent2.old_right_clic = ent2.right_clic
            end
            ent2.right_clic = function()
              ent2.old_right_clic()
              for listener in all(LISTENER.listeners["special"]) do
                listener()
              end
              for ent3 in all(ents) do
                grenade_tracking(ent3)
              end
            end
          end
        end

        local function shoot_tracker(ent2)
          ent2.old_left_clic = ent2.left_clic
          ent2.left_clic = function()
            local old_sq = hero.sq
            ent2.old_left_clic()
            if old_sq ~= hero.sq then
              for listener in all(LISTENER.listeners["move"]) do
                listener()
              end
            end
            local shot = false
            for b in all(bullets) do
              if b.shot and not b.old_upd then
                b.old_upd = b.upd
                b.upd = function(self)
                  for listener in all(LISTENER.listeners["bullet_upd"]) do
                    listener(self)
                  end
                  self.old_upd(self)
                end
                for listener in all(LISTENER.listeners["bullet_init"]) do
                  listener(b)
                end
                shot = true
              end
            end
            if shot then
              for listener in all(LISTENER.listeners["shot"]) do
                listener()
              end
            end
          end
          special_tracker(ent)
        end

        local function blade_tracker(ent2)
          ent2.old_left_clic = ent2.left_clic
          ent2.left_clic = function()
            local folly = check_folly_shields(hero.sq)
            if folly then
              if ((#hero.sq.danger == 1) and (hero.sq.danger[1] == get_square_at(mx, my).p)) or
                  hero.bushido then
                folly = false
              end
            end
            ent2.old_left_clic()
            if not folly then
              for listener in all(LISTENER.listeners["blade"]) do
                listener()
              end
            end
          end
          special_tracker(ent)
        end

        local function move_tracker(ent2)
          ent2.old_left_clic = ent2.left_clic
          ent2.left_clic = function()
            local old_sq = hero.sq
            ent2.old_left_clic()
            if old_sq ~= hero.sq then
              for listener in all(LISTENER.listeners["move"]) do
                listener()
              end
            end
          end
          special_tracker(ent)
        end

        if not hero then return end
        local ent_sq = get_square_at(ent.x, ent.y)
        if ent.button and ent_sq and ent.left_clic and not ent.old_left_clic then
          local hero_square = hero.sq
          if not hero_square then return end
          if abs(ent_sq.px - hero_square.px) <= 1 and abs(ent_sq.py - hero_square.py) <= 1 then
            -- WITHIN 3x3
            if not ent_sq.p then move_tracker(ent)
            elseif stack.blade and ent_sq.p.hp <= stack.blade then blade_tracker(ent)
            else shoot_tracker(ent) end
          else
            shoot_tracker(ent)
          end
        end

      end

      LISTENER.run = true
      LISTENER.jumping = false
      function LISTENER:upd()
        if not LISTENER.run then return end
        for ent in all(ents) do
          click_tracking(ent)
          card_fixing(ent)
        end
        for listener in all(LISTENER.listeners["upd"]) do
          listener()
        end
        for special, func in pairs(LISTENER.specials) do
          if stack.special == special then
            stack.special = "grenade"
            stack[special] = true
          end
        end
        if hero and hero.twc then
          LISTENER.jumping = true
        end
        if hero and (not hero.twc) and LISTENER.jumping then
          LISTENER.jumping = false
          for listener in all(LISTENER.listeners["after_black"]) do
            listener()
          end
        end
      end

      function LISTENER:dr()
        if not LISTENER.run then return end
        lprint("JP_API 2.1", 250, 162.5, 2)
        lprint(MODNAME, 5, 162.5, 2)
        for listener in all(LISTENER.listeners["dr"]) do
          listener()
        end
      end

      do -- File Loading setup
        mode.on_new_turn = function()
          if on_new_turn then
            on_new_turn()
          end
          for listener in all(LISTENER.listeners["after_white"]) do
            listener()
          end
        end

        mode.on_bad_death = function(e)
          if on_bad_death then
            on_bad_death(e)
          end
          for listener in all(LISTENER.listeners["bad_death"]) do
            listener(e)
          end
        end

        mode.on_pawn_death = function()
          if on_pawn_death then
            on_pawn_death()
          end
          for listener in all(LISTENER.listeners["pawn_death"]) do
            listener()
          end
        end

        mode.on_knight_death = function()
          if on_knight_death then
            on_knight_death()
          end
          for listener in all(LISTENER.listeners["knight_death"]) do
            listener()
          end
        end

        mode.on_bishop_death = function()
          if on_bishop_death then
            on_bishop_death()
          end
          for listener in all(LISTENER.listeners["bishop_death"]) do
            listener()
          end
        end

        mode.on_rook_death = function()
          if on_rook_death then
            on_rook_death()
          end
          for listener in all(LISTENER.listeners["rook_death"]) do
            listener()
          end
        end

        mode.on_queen_death = function()
          if on_queen_death then
            on_queen_death()
          end
          for listener in all(LISTENER.listeners["queen_death"]) do
            listener()
          end
        end

        mode.on_king_death = function()
          if on_king_death then
            on_king_death()
          end
          for listener in all(LISTENER.listeners["king_death"]) do
            listener()
          end
        end
      end

      do -- FIX EXHAUST (Glacies)
        mode.grow = function()
          grow()
          local total_choices = 0
          for ent in all(ents) do
            if ent.cards then
              total_choices = total_choices + 1
            end
          end
          for ent in all(ents) do
            if ent.cards then
              for ca in all(ent.cards) do
                wait(23 + 8 * total_choices + 16 * #ent.cards, function()
                  if ca.flipped then
                    ca.flipped = false
                    ca.old_upd = ca.upd
                    ca.upd = nil
                    wait(2, function()
                      ca.flipped = true
                      ca.upd = ca.old_upd
                      ca.old_upd = nil
                    end)
                  end
                end)
              end
            end
          end
        end
      end

      do -- BAN CARDS (Glacies)
        if not mode.ban then mode.ban = {} end
        if mode.weapons and mode.weapons[mode.weapons_index + 1].ban then
          for ca in all(mode.weapons[mode.weapons_index + 1].ban) do
            add(mode.ban, ca)
          end
        end
        if mode.ranks and mode.ranks[mode.ranks_index + 1].ban then
          for ca in all(mode.ranks[mode.ranks_index + 1].ban) do
            add(mode.ban, ca)
          end
        end
      end

      do -- CUSTOM GUN ART
        weapons_width, weapons_height = srfsize("weapons")
        if weapons_width == 160 then
          target("weapons")
          if mode.weapons then
            for i = 0, 15 do
              for j = 0, 15 do
                sset(32 + i, j, pget(144 + i, 16 * (mode.weapons_index + 1) + j))
              end
            end
          else
            for i = 0, 15 do
              for j = 0, 15 do
                sset(32 + i, j, pget(144 + i, j))
              end
            end
          end
          window("Shotgun King")
        end
      end

      for module in all(MODULES) do -- Load important parts of modules
        if module.start then
          setfenv(module.start, getfenv(1))
          module.start()
        end
        for k, v in pairs(module) do
          if k == "on_new_turn" then
            setfenv(v, getfenv(1))
            add_listener("after_white", v)
          end
          if sub(k, 1, 3) == "on_" and LISTENER.listeners[sub(k, 4)] then
            setfenv(v, getfenv(1))
            add_listener(sub(k, 4), v)
          end
        end
      end
    end

    function add_listener(event, listener)
      if not LISTENER.listeners[event] then
        LISTENER.listeners[event] = {}
      end

      del(LISTENER.listeners[event], listener)
      add(LISTENER.listeners[event], listener)
    end

    function remove_listener(event, listener)
      del(LISTENER.listeners[event], listener)
    end

    function new_special(name, special)
      LISTENER.specials[name] = special
    end
  end

  function initialize()
    palette("mods\\" .. MODNAME .. "\\gfx.png") -- USE CUSTOM PALLETE

    load_mod("none") -- FIX GLITCHED ART
    load_mod(MODNAME)

    if mode.ranks then mode.ranks_index = mid(0, bget(0, 4), #ranks - 1) end -- FIX RANK CRASH
    if mode.weapons then mode.weapons_index = mid(0, bget(1, 4), #weapons - 1) end -- FIX WEAPONS CRASH

    for module in all(MODULES) do -- LOAD MODULES
      if module.initialize then
        setfenv(module.initialize, getfenv(1))
        module.initialize()
      end
    end

    for fcard in all(CARDS) do -- FIX ART LIMIT (Thanks Glacies)
      if fcard.real_team == 0 or fcard.real_team == 1 then
        fcard.team = fcard.real_team
      end
    end

    for ach in all(ACHIEVEMENTS) do -- FIX PIECE LIMIT (Thanks Glacies)
      if ach.id == "HOW IT SHOULD BE" or "SHE IS EVERYWHERE" then
        del(ACHIEVEMENTS, ach)
      end
    end

    wait(20, enable_description) -- ENABLE GUN DESCRIPTIONS
  end

  -- GUN DESCRIPTIONS
  function enable_description()
    local function spawn_gun_description()
      local hinty = 67
      if not mode.ranks then hinty = 40 end
      local x = {}
      if weapons[mode.weapons_index + 1].desc then
        x = mk_hint_but(280, hinty - 3, 8, 9, weapons[mode.weapons_index + 1].desc, { 4 }, 100, nil,
          { x = 170, y = hinty + 8 })
        x.button = false
      else
        x = mke()
      end
      x.lastindex = mode.weapons_index
      x.dr = function(self)
        if (not mode.weapons_index) then
          del(ents, self)
          return
        end
        if weapons[mode.weapons_index + 1].desc then
          local printy = -10
          for ent in all(ents) do
            if ent.id == "weapons" then
              printy = ent.y + 1
            end
          end
          lprint("?", 284, printy, 5)
        end
        if (mode.weapons_index ~= self.lastindex) then
          del(ents, self)
          spawn_gun_description()
        end
      end
    end

    local function spawn_rank_description()
      local hinty = 14
      if not mode.weapons then hinty = 45 end
      local x = {}
      if ranks[mode.ranks_index + 1].desc then
        x = mk_hint_but(278, hinty - 3, 8, 9, ranks[mode.ranks_index + 1].desc, { 4 }, 100, nil,
          { x = 170, y = hinty + 8 })
        x.button = false
      else
        x = mke()
      end
      x.lastindex = mode.ranks_index
      x.dr = function(self)
        if (not mode.ranks_index) then
          del(ents, self)
          return
        end
        if ranks[mode.ranks_index + 1].desc then
          local printy = -10
          for ent in all(ents) do
            if ent.id == "ranks" then
              printy = ent.y + 1
            end
          end
          if printy == -10 then
            del(ents, self)
            return
          end
          lprint("?", 280, printy, 5)
        end
        if (mode.ranks_index ~= self.lastindex) then
          del(ents, self)
          spawn_rank_description()
        end
      end
    end

    if mode.weapons then
      spawn_gun_description()
    end

    if mode.ranks then
      spawn_rank_description()
    end
  end

  -- NEEDED FOR GUN DESCRIPTIONS
  function get_weapons_list()
    local a = {}
    for i = 0, #weapons do
      add(a, i)
    end
    return a
  end
end
-- JP_API CODE END

-- MOD CODE
do
  function mod_setup()
    init_listeners()
  end
end
-- MOD CODE END

function start()
  init_game()
  lvl = 0

  -- SPAWNER
  score = 0
  dif = 2
  mode.turns = 0

  -- MOD CODE
  mod_setup()
  -- END MOD CODE

  -- LEVEL
  new_level()

  -- FIRST SPAWN
  add_event(ev_side_spawn, { 0, 0, 0 })

  --
  --add_card("Militia")


end

function on_king_death()

  --[[
	local data={
		id="level_up", 
		pan_xm=3,
		pan_ym=1, 
		pan_width=128,
		pan_height=64,
		choices={
			{{team=0}},{{team=0}},{{team=0}},
		},
	}

	add_event(bind(level_up,data,new_turn))
	
	--]]
end

function get_slot_data(team, i)
  if team == 1 or i > 4 then return nil end

  local data = {
    x = 16,
    y = 4 + i * 32,
    team = team,
    side_icon = i == 0 and 0 or 1,
  }
  return data
end

-- ON
function on_hero_death()
  progress(0, 3, score)
  progress(1, 3, turns)
  save()
  gameover()
end

function on_new_turn()
  dif = dif + 1 / 8
  local danger = 0
  for b in all(bads) do
    danger = danger + (pieces_danger[b.type + 1] or 0)
  end



  -- NEW WAVE
  local tdif = dif + #get_slot_cards()

  if danger < tdif * .85 then
    sfx("conscription")
    local a = {}
    while danger < tdif do
      local tp = rnd(proba)
      add(a, tp)
      danger = danger + PIECES[tp + 1].danger
      add_event(ev_side_spawn, tp)
    end
  end



  -- NEW KING
  if mode.turns % 15 == 5 then
    add_event(ev_side_spawn, 5)
  end

  -- NEW AMMO BOX
  if mode.turns % 20 == 10 then
    add_event(ev_spawn_item, "ammo_box")
  end
end

function on_bad_death(e)
  local danger = pieces_danger[e.type + 1]
  if not danger then return end
  local bounty = danger * 5
  score = score + bounty

  if e.type == 5 then
    local data = {
      id = "level_up",
      pan_xm = 3,
      pan_ym = 1,
      pan_width = 128,
      pan_height = 64,
      choices = {
        { { team = 0 } }, { { team = 0 } }, { { team = 0 } },
      },
    }
    add_event(bind(level_up, data, new_turn))
  end


  --[[
	local p=mke(0,e.x,e.y)
	p.dp=DP_FX
	p.life=60
	p.vy=-2
	p.frict=.92
	p.dr=function(e,x,y)
		local str=bounty..""
		lprint(str,x,y,4,1,1)
	end
	--]]


end

--
function draw_inter()
  local s = lang.score_
  local x = lprint(s, MCW / 2, board_y - 19, 3, 1)
  lprint(score, x, board_y - 19, 5)
end

-- NEED SOLVE
-- cards with sacrifice or adding piece
-- can't use wand/grenade the turn I get them

-- ? 1+ mist ?