id = "examplethrone"
setup = {
  slots_max = { 10, 10 },
}
weapons = {
  { gid = 0, name = "Example 0", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 0" },
  { gid = 1, name = "Example 1", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 1" },
  { gid = 2, name = "Example 2", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 2" },
  { gid = 3, name = "Example 3", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 3" },
  { gid = 4, name = "Example 4", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 4" },
  { gid = 5, name = "Example 5", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 5" },
  { gid = 6, name = "Example 6", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 6" },
  { gid = 7, name = "Example 7", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 7" },
  { gid = 8, name = "Example 8", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 8" },
  { gid = 9, name = "Example 9", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 9" },
  { gid = 10, name = "Example 10", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 10" },
  { gid = 11, name = "Example 11", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 11" },
  { gid = 12, name = "Example 12", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 12" },
  { gid = 13, name = "Example 13", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 13" },
  { gid = 14, name = "Example 14", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 14" },
  { gid = 15, name = "Example 15", chamber_max = 2, firepower = 5, firerange = 5, spread = 50, ammo_max = 4,
    desc = "Description 15" },
}
ranks = {
  { nothing = 1 },
  { gain = { 0, 0 } },
  { gain = { 3 } },
  { king_hp = 1 },
  { gain = { 1 } },
  { spread = 10 },
  { king_hp = 1 },
  { gain = { 2 } },
  { rook_hp = 1 },
  { knight_hp = 1 },
  { boss_hprc = 200 },
  { spread = 15 },
  { rook_hp = 1 },
  { ammo_max = -1 },
  { all_hp = 1, ammo_max = 2 },
}
base = {
  promotion = 1, surrender = 1,
  gain = { 0, 0, 0, 1, 5, 2, 0 },

}
MODNAME = current_mod


-- JP_API CODE
do -- VERSION 1.4
  -- LOGGING CODE
  function _logv(o, start_str)
    if not start_str then
      start_str = ""
    end
    local function data_tostring_recursive(data, depth)
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
        if depth == 4 then
          return "{...}"
        end
        local data_string = "{"
        for key, value in pairs(data) do
          if value == "_G" then
            data_string = data_string .. "\n" .. indent(depth) ..
                "_G: {...}," -- don't recurse into _G
          else
            data_string = data_string .. "\n" .. indent(depth) ..
                data_tostring_recursive(key, depth + 1) .. ": " .. data_tostring_recursive(value, depth + 1) .. ","
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

  function _logs(o, value)
    local function search_recurse(p, v, d, path)
      if type(p) == type({}) then
        for k, v2 in pairs(p) do
          if v2 == v then
            if (type(k) == type("")) or (type(k) == type(1)) then
              _log(path .. "." .. k)
            else
              _log(path .. "[non-string key]")
            end
          elseif (d < 4) and (v2 ~= _G) then
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

  -- LISTENER CODE
  ons_updated = false
  function init_listeners()
    if LISTENER then
      del(ents, LISTENER)
    end
    LISTENER = mke()
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

    LISTENER.listeners["after_black"] = {}
    LISTENER.listeners["after_white"] = {}
    local function card_fixing(ent)
      function fix_card(tfcard)
        tfcard.old_dr = tfcard.dr
        tfcard.og_gid = tfcard.gid
        tfcard.dr = function(self)
          if self.flip_co and self.flip_co > 0.5 then
            self.gid = 59 + self.team
          else
            self.gid = self.og_gid
          end
          self.old_dr(self)
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
          end
        end
      end

      local function blade_tracker(ent2)
        ent2.old_left_clic = ent2.left_clic
        ent2.left_clic = function()
          local folly = check_folly_shields(hero.sq)
          if folly then
            if ((#hero.sq.danger == 1) and (hero.sq.danger[1] == get_square_at(mx, my).p)) or stack.bushido then
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
          end
        end
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
          end
        end
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
            if abs(hero.sq.px - sq.px) < 2 and abs(hero.sq.py - sq.py) < 2 then delay = 236 end
            wait(delay, function()
              for listener in all(LISTENER.listeners["grenade_explode"]) do
                listener(grenade)
              end
            end)
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

    LISTENER.run = true
    LISTENER.jumping = false
    function LISTENER:upd()
      if not LISTENER.run then return end
      for ent in all(ents) do
        click_tracking(ent)
        card_fixing(ent)
        grenade_tracking(ent)
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
      lprint("JP_API 1.4", 250, 162.5, 2)
      lprint(MODNAME, 5, 162.5, 2)
      for listener in all(LISTENER.listeners["dr"]) do
        listener()
      end
    end

    if not ons_updated then
      old_new_turn = on_new_turn
      on_new_trun = function()
        if old_new_turn then
          old_new_turn()
        end
        for listener in all(LISTENER.listeners["after_white"]) do
          listener()
        end
      end

      old_bad_death = on_bad_death
      on_bad_death = function()
        if old_bad_death then
          old_bad_death()
        end
        for listener in all(LISTENER.listeners["bad_death"]) do
          listener()
        end
      end
    end

    ons_updated = true

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
    do -- FIX EXHAUST (Glacies)
      old_grow = grow
      grow = function()
        old_grow()
        total_choices = 0
        for ent in all(ents) do
          if ent.cards then
            total_choices = total_choices + 1
          end
        end
        for ent in all(ents) do
          if ent.cards then
            for ca in all(ent.cards) do
              wait(55 + 8 * total_choices, function(fcard)
                if fcard.flipped then
                  fcard.flipped = false
                  fcard.old_upd = fcard.upd
                  fcard.upd = nil
                  wait(2, function(kcard)
                    kcard.flipped = true
                    kcard.upd = kcard.old_upd
                    kcard.old_upd = nil
                  end, fcard)
                end
              end, ca)
            end
          end
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

  function initialize()
    load_mod("none") -- FIX GLITCHED ART
    load_mod(MODNAME)

    if mode.ranks then mode.ranks_index = mid(0, bget(0, 4), #ranks - 1) end -- FIX RANK CRASH
    if mode.weapons then mode.weapons_index = mid(0, bget(1, 4), #weapons - 1) end -- FIX WEAPONS CRASH

    palette("mods\\" .. MODNAME .. "\\gfx.png") -- USE CUSTOM PALLETE

    for cahd in all(CARDS) do -- FIX ART LIMIT (Thanks Glacies)
      if cahd.real_team == 0 or cahd.real_team == 1 then
        cahd.team = cahd.real_team
      end
    end
  end

  -- GUN DESCRIPTIONS
  desc_start = true
  function enable_description()
    local x = {}
    if weapons[mode.weapons_index + 1].desc then
      x = mk_hint_but(280, 64, 8, 9, weapons[mode.weapons_index + 1].desc, { 4 }, 100, nil, { x = 170, y = 75 })
    else
      x = mke()
    end
    x.lastindex = mode.weapons_index
    if (desc_start) then
      desc_start = false
      wait(30, function()
        x.dr = function(self)
          if weapons[mode.weapons_index + 1].desc then
            lprint("?", 284, 67, 5)
          end
          if (mode.weapons_index ~= self.lastindex) then
            del(ents, self)
            enable_description()
          end
        end
      end)
    else
      x.dr = function(self)
        if weapons[mode.weapons_index + 1].desc then
          lprint("?", 284, 67, 5)
        end
        if (mode.weapons_index ~= self.lastindex) then
          del(ents, self)
          enable_description()
        end
      end
    end
  end

  -- NEEDED FOR GUN DESCRIPTIONS
  function get_weapons_list()
    local a = {}
    for i = 0, #weapons do
      add(a, i)
    end
    enable_description()
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

  init_vig({ 1, 2, 3 }, function()
    init_game()
    mode.lvl = 0
    mode.turns = 0

    -- MOD SETUP
    mod_setup()

    next_floor()
  end)

end

function next_floor()
  mode.lvl = mode.lvl + 1
  new_level()
end

function grow()
  if mode.lvl < 11 then
    local data = {
      id = "level_up",
      pan_xm = 1,
      pan_ym = 2,
      pan_width = 80,
      pan_height = 96,
      choices = {
        { { team = 0 }, { team = 1 } },
        { { team = 0 }, { team = 1 } },
      },
      force = {
        { lvl = 3, id = "Homecoming", choice_index = 0, card_index = 1, desc_key = "queen_escape" },
        { lvl = 3, id = "Homecoming", choice_index = 1, card_index = 1, desc_key = "queen_everywhere" }
      }
    }
    level_up(data, next_floor)
  elseif mode.lvl == 11 then
    add(upgrades, { gain = { 6 }, sac = { 5 } })
    init_vig({ 4 }, next_floor)
  end
end

function outro()

  local v = { 6, 7 }
  local best = 13
  trig_achievement("COMPLETE")

  if boss.book then
    best = 14
    v = { 8, 6, 11 }
    trig_achievement("AVENGED")
    if chamber > 0 then
      best = 15
      v = { 8, 9, 10, 6, 12 }
      trig_achievement("EXORCISED")
    end
  end

  -- BEST FLOOR
  local rank = mode.ranks_index + 1
  progress(rank, 1, bfl)

  -- BEST RANK
  progress(0, 1, rank)

  -- BEST TIME
  if opt("speedrun") == 1 then
    local best_time = bget(rank, 2)
    if best_time == 0 or chrono_time < best_time then
      bset(rank, 2, chrono_time)
      new_best_time = true
    end
  end
  --
  save()


  -- COLLECTION
  check_collections()


  init_vig(v, init_menu)
end

-- ON
function on_empty()
  end_level(grow)

end

function on_hero_death()
  progress(mode.ranks_index + 1, 1, mode.lvl)
  check_collections()
  save()
  gameover()
end

function on_boss_death()
  -- CHECK BLACK BISHOP SPAWN
  local bishops = get_pieces(2)
  local book = has_card("The Red Book")
  local theo = perm["Theocracy"]
  if book and theo and (#bishops == 1 or (DEV and #bishops >= 1)) then
    bishops[1].chosen = true
    spawn_dark_bishop()
    return
  end

  -- END GAME
  music("ending_A", 0)
  fade_to(-4, 30, outro)

end

function check_unlocks()
end

function save_preferences()
  bset(0, 4, mode.ranks_index)
  bset(1, 4, mode.weapons_index)
  save()
end

--
function draw_inter()
  local s = lang.floor_
  local x = lprint(s, MCW / 2, board_y - 19, 3, 1)
  lprint(mode.lvl, x, board_y - 19, 5)
end
