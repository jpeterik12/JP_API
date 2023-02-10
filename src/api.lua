-- JP_API CODE
do -- VERSION 2.7
  MODNAME = current_mod

  MODULES = {}
  foreach(
    ls("mods/" .. MODNAME .. "/modules/"), function(module_name)
      if module_name:sub(-4) ~= ".lua" then return end
      local module = table_from_file("mods/" .. MODNAME .. "/modules/" .. module_name:sub(1, -5))
      if ban_modules and tbl_index(module.id, ban_modules) > 0 then return end
      if allow_modules and tbl_index(module.id, ban_modules) < 0 then return end
      add(MODULES, module)
    end
  )

  do -- LOGGING CODE
    function _logv(o, start_str, max_depth)
      if not start_str then start_str = "" end
      if not max_depth then max_depth = 4 end
      local function data_tostring_recursive(data, depth, parent)
        local function indent(n)
          local s = "  "
          return s:rep(n + 1)
        end

        if data == nil then return "nil" end
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
          if depth == max_depth then return "{...}" end
          local data_string = "{"
          for key, value in pairs(data) do
            if value == _G then
              data_string = data_string .. "\n" .. indent(depth) .. data_tostring_recursive(key, depth + 1, data) ..
                              ": {_G}," -- don't recurse into _G
            elseif value == parent then
              data_string = data_string .. "\n" .. indent(depth) .. data_tostring_recursive(key, depth + 1, data) ..
                              ": {parent}," -- don't recurse into parent
            else
              data_string = data_string .. "\n" .. indent(depth) .. data_tostring_recursive(key, depth + 1, data) ..
                              ": " .. data_tostring_recursive(value, depth + 1, data) .. ","
            end
          end
          if data_string == "{" then return "{}" end
          if data_string:sub(-1) == "," then data_string = data_string:sub(1, -2) end
          data_string = data_string .. "\n" .. indent(depth - 1) .. "}"
          return data_string
        else
          return "MISSING DATA TYPE: " .. data_type
        end
      end

      _log("DATA START: " .. start_str .. "\n" .. data_tostring_recursive(o, 0) .. "\nDATA END")
    end

    function _logs(o, value, max_depth)
      if not max_depth then max_depth = 4 end
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
      if LISTENER then del(ents, LISTENER) end
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

        LISTENER.listeners["floor_start"] = {}
        LISTENER.listeners["floor_end"] = {}
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
            self.old_dr(self, unpack({...}))
          end
        end

        if ent.gid and ent.gid >= 120 and not ent.card_counter then fix_card(ent) end
        if ent.cards then
          for sub_ent in all(ent.cards) do
            if sub_ent.gid and sub_ent.gid >= 120 and not sub_ent.card_counter then fix_card(sub_ent) end
          end
        end
      end

      local function click_tracking(ent)
        local function bullet_tracking()
          local shot = false
          for b in all(bullets) do
            if b.shot and not b.old_upd then
              b.old_upd = b.upd
              b.upd = function(self)
                for listener in all(LISTENER.listeners["bullet_upd"]) do listener(self) end
                self.old_upd(self)
              end
              for listener in all(LISTENER.listeners["bullet_init"]) do listener(b) end
              shot = true
            end
          end
          if shot then for listener in all(LISTENER.listeners["shot"]) do listener() end end
          return shot
        end

        local function grenade_tracking(ent) -- (Glacies)
          local function setup_bounce(grenade)
            if not grenade.twf then return end
            grenade.old_twf = grenade.twf
            grenade.state = (grenade.jz > 20)
            grenade.twf = function()
              if grenade.state then
                for listener in all(LISTENER.listeners["grenade_bounce"]) do listener(grenade) end
              else
                for listener in all(LISTENER.listeners["grenade_land"]) do listener(grenade) end
                local delay = 57
                local sq = get_square_at(grenade.x, grenade.y)
                if sq then
                  if abs(hero.sq.px - sq.px) < 2 and abs(hero.sq.py - sq.py) < 2 then delay = 236 end
                  wait(
                    delay,
                      function()
                        for listener in all(LISTENER.listeners["grenade_explode"]) do
                          listener(grenade)
                        end
                      end
                  )
                end
              end
              grenade.old_twf()
              setup_bounce(grenade)
            end
          end

          if not ent.fra then return end
          if ent.tracked then return end
          ent.tracked = true
          for listener in all(LISTENER.listeners["grenade_init"]) do listener(ent) end
          ent.old_upd = ent.upd
          ent.upd = function(self)
            for listener in all(LISTENER.listeners["grenade_upd"]) do listener(self) end
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
            if not skip then ent2.old_right_clic = ent2.right_clic end
            ent2.right_clic = function()
              ent2.old_right_clic()
              for listener in all(LISTENER.listeners["special"]) do listener() end
              for ent3 in all(ents) do grenade_tracking(ent3) end
              if bullet_tracking() and stack.special == "decree" then
                local old_heroupd = hero.upd
                local function temp_tracker()
                  bullet_tracking()
                  old_heroupd()
                  if chamber == 0 then hero.upd = old_heroupd end
                end

                hero.upd = temp_tracker
              end
            end
          end
        end

        local function shoot_tracker(ent2)
          ent2.old_left_clic = ent2.left_clic
          ent2.left_clic = function()
            local old_sq = hero.sq
            ent2.old_left_clic()
            if old_sq ~= hero.sq then for listener in all(LISTENER.listeners["move"]) do listener() end end
            bullet_tracking()
          end
          special_tracker(ent)
        end

        local function blade_tracker(ent2)
          ent2.old_left_clic = ent2.left_clic
          ent2.left_clic = function()
            local folly = check_folly_shields(hero.sq)
            if folly then
              if ((#hero.sq.danger == 1) and (hero.sq.danger[1] == get_square_at(mx, my).p)) or hero.bushido then
                folly = false
              end
            end
            ent2.old_left_clic()
            if not folly then for listener in all(LISTENER.listeners["blade"]) do listener() end end
          end
          special_tracker(ent)
        end

        local function move_tracker(ent2)
          ent2.old_left_clic = ent2.left_clic
          ent2.left_clic = function()
            local old_sq = hero.sq
            ent2.old_left_clic()
            if old_sq ~= hero.sq then for listener in all(LISTENER.listeners["move"]) do listener() end end
            bullet_tracking()
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
            if not ent_sq.p then
              move_tracker(ent)
            elseif stack.blade and ent_sq.p.hp <= stack.blade then
              blade_tracker(ent)
            else
              shoot_tracker(ent)
            end
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
        for listener in all(LISTENER.listeners["upd"]) do listener(self) end
        for special, func in pairs(LISTENER.specials) do
          if stack.special == special then
            stack.special = "grenade"
            stack[special] = true
          end
        end
        if hero and hero.twc then LISTENER.jumping = true end
        if hero and (not hero.twc) and LISTENER.jumping then
          LISTENER.jumping = false
          for listener in all(LISTENER.listeners["after_black"]) do listener() end
          for sq in all(pentasquares) do -- CUSTOM OFF PENTA
            if sq.penta and sq.penta_off then
              sq.old_dr = sq.old_dr or sq.dr
              function sq:dr(...)
                sq.old_dr(self, unpack({...}))
                if self.penta and self.penta_off then spr(16 * (14) + 12 + sq.cl, self.x, self.y) end
              end
            end
          end
        end
      end

      function LISTENER:dr()
        if not LISTENER.run then return end
        lprint("JP_API 2.7", 250, 162.5, 2)
        lprint(MODNAME, 5, 162.5, 2)
        for listener in all(LISTENER.listeners["dr"]) do listener(self) end
      end

      do -- File Loading setup
        mode.on_new_turn = function()
          if on_new_turn then on_new_turn() end
          for listener in all(LISTENER.listeners["after_white"]) do listener() end
        end

        mode.on_bad_death = function(e)
          if on_bad_death then on_bad_death(e) end
          for listener in all(LISTENER.listeners["bad_death"]) do listener(e) end
        end

        mode.on_pawn_death = function()
          if on_pawn_death then on_pawn_death() end
          for listener in all(LISTENER.listeners["pawn_death"]) do listener() end
        end

        mode.on_knight_death = function()
          if on_knight_death then on_knight_death() end
          for listener in all(LISTENER.listeners["knight_death"]) do listener() end
        end

        mode.on_bishop_death = function()
          if on_bishop_death then on_bishop_death() end
          for listener in all(LISTENER.listeners["bishop_death"]) do listener() end
        end

        mode.on_rook_death = function()
          if on_rook_death then on_rook_death() end
          for listener in all(LISTENER.listeners["rook_death"]) do listener() end
        end

        mode.on_queen_death = function()
          if on_queen_death then on_queen_death() end
          for listener in all(LISTENER.listeners["queen_death"]) do listener() end
        end

        mode.on_king_death = function()
          if on_king_death then on_king_death() end
          for listener in all(LISTENER.listeners["king_death"]) do listener() end
        end

        mode.on_empty = function()
          if on_empty then on_empty() end
          for listener in all(LISTENER.listeners["floor_end"]) do listener() end
        end

        mode.next_floor = function()
          if next_floor then next_floor() end
          for listener in all(LISTENER.listeners["floor_start"]) do listener() end
        end
      end

      do -- FIX EXHAUST (Glacies)
        mode.grow = function()
          grow()
          local total_choices = 0
          for ent in all(ents) do if ent.cards then total_choices = total_choices + 1 end end
          for ent in all(ents) do
            if ent.cards then
              for ca in all(ent.cards) do
                wait(
                  23 + 8 * total_choices + 16 * #ent.cards, function()
                    if ca.flipped then
                      ca.flipped = false
                      ca.old_upd = ca.upd
                      ca.upd = nil
                      wait(
                        2, function()
                          ca.flipped = true
                          ca.upd = ca.old_upd
                          ca.old_upd = nil
                        end
                      )
                    end
                  end
                )
              end
            end
          end
        end
      end

      do -- BAN CARDS (Glacies)
        if not mode.ban then mode.ban = {} end
        if mode.weapons and mode.weapons[mode.weapons_index + 1].ban then
          for ca in all(mode.weapons[mode.weapons_index + 1].ban) do
            for acard in all(cards.pool) do if acard.id == ca then del(cards.pool, acard) end end
          end
        end
        if mode.ranks and mode.ranks[mode.ranks_index + 1].ban then
          for ca in all(mode.ranks[mode.ranks_index + 1].ban) do
            for acard in all(cards.pool) do if acard.id == ca then del(cards.pool, acard) end end
          end
        end
      end

      do -- CUSTOM GUN ART
        weapons_width, weapons_height = srfsize("weapons")
        if weapons_width == 160 then
          target("weapons")
          if mode.weapons then
            for i = 0, 15 do
              for j = 0, 15 do sset(32 + i, j, pget(144 + i, 16 * (mode.weapons_index + 1) + j)) end
            end
          else
            for i = 0, 15 do for j = 0, 15 do sset(32 + i, j, pget(144 + i, j)) end end
          end
        end
      end

      local function_pairs = {on_new_turn = "after_white", on_empty = "floor_end", next_floor = "floor_start"}

      for module in all(MODULES) do -- Load important parts of modules
        if module.start then module.start() end
        for k, v in pairs(module) do
          if function_pairs[k] then add_listener(function_pairs[k], v) end
          if k:sub(1, 3) == "on_" and LISTENER.listeners[k:sub(4)] then add_listener(k:sub(4), v) end
        end
      end
    end

    function add_listener(event, listener)
      if not LISTENER.listeners[event] then LISTENER.listeners[event] = {} end

      del(LISTENER.listeners[event], listener)
      add(LISTENER.listeners[event], listener)
    end

    function remove_listener(event, listener) del(LISTENER.listeners[event], listener) end

    function new_special(name, special) LISTENER.specials[name] = special end
  end
  local function do_swapping()
    target("weapons")
    local weapons_img = {}
    local weapons_width, weapons_height = srfsize("weapons")
    for p = 1, weapons_width * weapons_height do weapons_img[p] = pget(p % weapons_width, flr(p / weapons_width)) end

    for k, weapon in pairs(weapons) do
      if k ~= (weapon.gid + 1) then
        y_offset = 24 * ((weapon.gid + 1) - k)
        for x = 0, 95 do
          for y = (24 * (k - 1)), (24 * (k)) - 1 do pset(x, y, weapons_img[x + (y + y_offset) * weapons_width]) end
        end
        y_offset = 16 * ((weapon.gid + 1) - k)
        for x = 96, 160 do
          for y = (16 * k), (24 * (k + 1)) - 1 do pset(x, y, weapons_img[x + (y + y_offset) * weapons_width]) end
        end
      end
    end
  end

  function initialize()
    palette("mods\\" .. MODNAME .. "\\gfx.png") -- USE CUSTOM PALLETE

    load_mod("none") -- FIX GLITCHED ART
    load_mod(MODNAME)

    if mode.ranks then mode.ranks_index = mid(0, bget(0, 4), #ranks - 1) end -- FIX RANK CRASH
    if mode.weapons then
      mode.weapons_index = mid(0, bget(1, 4), #weapons - 1) -- FIX WEAPONS CRASH
      do_swapping()
    end

    for module in all(MODULES) do -- LOAD MODULES
      for k, value in pairs(module) do
        if type(value) == "function" then
          local env = getfenv(1)
          local new_env = {}
          setmetatable(
            new_env, {
              __index = function(t, v) return rawget(t, v) or module[v] or env[v] end,
              __newindex = function(t, key, val)
                rawset(t, key, val)
                rawset(module, key, val)
              end,
            }
          )
          setfenv(value, new_env)
        end
      end
      if module.initialize then module.initialize() end
    end

    for fcard in all(CARDS) do -- FIX ART LIMIT (Thanks Glacies)
      if fcard.real_team == 0 or fcard.real_team == 1 then fcard.team = fcard.real_team end
    end

    for ach in all(ACHIEVEMENTS) do -- FIX PIECE LIMIT (Thanks Glacies)
      if ach.id == "HOW IT SHOULD BE" or "SHE IS EVERYWHERE" then del(ACHIEVEMENTS, ach) end
    end

    wait(20, enable_description) -- ENABLE GUN DESCRIPTIONS
  end

  -- GUN DESCRIPTIONS
  function enable_description()
    local function gety(id)
      local y = -100
      for ent in all(ents) do if ent.id == id then y = ent.y end end
      return y
    end

    local gunhint, rankhint

    local function spawn_gun_description()
      if gunhint then del(ents, gunhint) end
      if weapons[mode.weapons_index + 1].desc then
        hinty = gety("weapons")
        gunhint = mk_hint_but(
          283, hinty - 1, 5, 9, weapons[mode.weapons_index + 1].desc, {4}, 100, nil, {x = 170, y = hinty + 5}
        )
      else
        gunhint = mke()
      end
      gunhint.lastindex = mode.weapons_index
      function gunhint:dr()
        local printy = gety("weapons") + 1
        if printy == -99 then del(ents, self) end
        if weapons[mode.weapons_index + 1].desc then lprint("?", 284, printy, 5) end
        if (mode.weapons_index ~= self.lastindex) then
          del(ents, self)
          spawn_gun_description()
          return
        end
      end
    end

    local function spawn_rank_description()
      local x
      if rankhint then del(ents, rankhint) end
      if ranks[mode.ranks_index + 1].desc then
        local hinty = gety("ranks")
        rankhint = mk_hint_but(
          279, hinty - 1, 5, 9, ranks[mode.ranks_index + 1].desc, {4}, 100, nil, {x = 170, y = hinty + 5}
        )
      else
        rankhint = mke()
      end
      rankhint.lastindex = mode.ranks_index
      function x:dr()
        local printy = gety("ranks") + 1
        if printy == -99 then del(ents, self) end
        if ranks[mode.ranks_index + 1].desc then lprint("?", 280, printy, 5) end
        if (mode.ranks_index ~= self.lastindex) then
          del(ents, self)
          spawn_rank_description()
          return
        end
      end
    end

    if mode.weapons then
      spawn_gun_description()
      wait(40, spawn_gun_description)
    end

    if mode.ranks then
      spawn_rank_description()
      wait(40, spawn_rank_description)
    end
  end

  -- NEEDED FOR GUN DESCRIPTIONS
  function get_weapons_list()
    local a = {}
    for i = 0, #weapons do add(a, i) end
    return a
  end
end
-- JP_API CODE END
