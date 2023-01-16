-- JP_API CODE
do -- VERSION 1.6
  MODNAME = current_mod
  -- LOGGING CODE
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
      lprint("JP_API 1.6", 250, 162.5, 2)
      lprint(MODNAME, 5, 162.5, 2)
      for listener in all(LISTENER.listeners["dr"]) do
        listener()
      end
    end

    local old_new_turn = on_new_turn
    on_new_trun = function()
      if old_new_turn then
        old_new_turn()
      end
      for listener in all(LISTENER.listeners["after_white"]) do
        listener()
      end
    end

    local old_bad_death = on_bad_death
    on_bad_death = function()
      if old_bad_death then
        old_bad_death()
      end
      for listener in all(LISTENER.listeners["bad_death"]) do
        listener()
      end
    end

    do -- FIX EXHAUST (Glacies)
      local old_grow = grow
      grow = function()
        old_grow()
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
  function enable_description()
    local function spawn_description()
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
          spawn_description()
        end
      end
    end

    if not mode.weapons then return end
    spawn_description()

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

  -- FIXES COND_ONLY_PIECE
  if not lang["cond_only_piece"] then
    lang["cond_only_piece"] = "There's only $0 on the board"
  end
end
-- JP_API CODE END
