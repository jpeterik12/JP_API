id = "hook" -- BY GLACIES
function start()
  --[[
		  Relavant Card Effects:

		  special = "hook"			Activates the Hook
	  	hookdmg = <num>				Increases damage of the hook by <num>
	  	<piece>_hkim = 1			<piece> can't be pulled or stunned anymore
	  --]]
  new_special("hook", function()
    local def_dmg = 1 -- default damage of the hook
    local immune = { -- pieces that don't get pulled or stunned
      -- pawn = false,
      -- knight = false,
      -- bishop = false,
      -- rook = false,
      -- queen = false,
      king = true,
      boss = true,
      -- canonball = false
    }
    local leader_immune = false -- whether the current leader can be pulled or stunned

    -- display setup
    local hook_speed = 9 -- animation speed of the hook (unit: pixels per frame)
    local rope_time = 20 -- duration for which the rope can exist before hitting a piece (unit: frame)
    local rope_colour = 5 -- colour of the rope
    local piece_tempo = 12 -- number of frames it takes for the piece to get pulled back
    local enable_sfx = true -- enables sfx for throwing the hook
    local danger_warning = true -- enables folly shield warning when using the hook


    if danger_warning and check_folly_shields(hero.sq) then
      show_danger(hero.sq)
      return
    end
    if stack.hookdmg then
      def_dmg = stack.hookdmg + def_dmg
    end

    local hook = mke()
    if enable_sfx then sfx("grab_done") end
    hook.x = hero.x + 8 + 8 * cos(hero.current_an)
    hook.y = hero.y + 8 + 8 * sin(hero.current_an)
    hook.vx = hook_speed * cos(hero.current_an)
    hook.vy = hook_speed * sin(hero.current_an)
    hook.start_x = hero.x + 8 + 8 * cos(hero.current_an)
    hook.start_y = hero.y + 8 + 8 * sin(hero.current_an)
    hook.life = rope_time
    function hook:upd()
      local hook_sq = get_square_at(hook.x, hook.y)
      if hook_sq and hook.stop == nil then
        if hook_sq.p then
          local p = hook_sq.p
          hit(p, def_dmg) -- code by Glacies
          if p.dead or immune[p.name] or p.hkim or (p.leader and leader_immune) then
            del(ents, hook)
            hook:nxt()
          else
            p.stun = true
            hook.vx = 0
            hook.vy = 0
            hook.stop = true
            hook.life = nil
            wait(15, function()
              if hook.sq then
                p.sq.p = nil
                hook.sq.p = p
                p.sq = hook.sq
                p.sx = p.x
                p.sy = p.y
                p.ex = hook.sq.x
                p.ey = hook.sq.y
                p.tws = piece_tempo
                p.twc = 0
                if p.type == 0 and hook.sq.py == 7 then
                  add_event(ev_promote, p)
                end
                hook.sx = hook.x
                hook.sy = hook.y
                hook.ex = hook.start_x
                hook.ey = hook.start_y
                hook.tws = piece_tempo
                hook.twc = 0
                function hook:twf()
                  del(ents, hook)
                  hook:nxt()
                end
              else
                del(ents, hook)
                hook:nxt()
              end
            end)
          end
        elseif hook.sq == nil then
          hook.sq = hook_sq
        end
      end
    end

    function hook:dr()
      line(self.start_x, self.start_y, self.x, self.y, rope_colour)
    end

    function hook:nxt()
      wait(15, opp_turn)
    end

    remove_buts()
  end)
end
