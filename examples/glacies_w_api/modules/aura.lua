function start()
  add_listener("dr", function()
    lprint(lang.credits, 181, 158, 6)
  end)
  add_listener("after_white", function()
    --[[
		    Relavant Card Effects:

		    aura = <int>			  	Activates the Aura. The Aura covers a square of width <int>
		    auradmg = <num>				Increases damage of the aura by <num>
		    auracd = <int>   			Increases the number of turns between two auras by <int>
		    <piece>_auraim = 1		<piece> can't be hurt by the aura anymore
	    --]]

    if stack.aura then

      -- gameplay setup
      local def_dmg = 1 -- default damage of the aura
      local def_cd = 1 -- default time interval between auras
      local immune = { -- pieces that can't be hurt by the aura
        -- pawn = false,
        -- knight = false,
        -- bishop = false,
        -- rook = false,
        -- queen = false,
        -- king = false,
        -- boss = false,
        -- canonball = false
      }
      local leader_immune = false -- whether the current leader can be hurt by the aura

      -- display setup
      local aura_tempo = 12 -- number of frames it takes for the aura to expand to maximum
      local aura_colour = 5 -- colour of the aura
      local enable_sfx = true -- enables sfx for the aura

      if stack.auradmg then def_dmg = def_dmg + stack.auradmg end
      if stack.auracd then def_cd = def_cd + stack.auracd end

      if mode.turns and mode.turns % def_cd == 0 then
        for i = -stack.aura, stack.aura do
          for j = -stack.aura, stack.aura do
            if not (i == 0 and j == 0) and gsq(hero.sq.px + i, hero.sq.py + j) and
                gsq(hero.sq.px + i, hero.sq.py + j).p then
              local p = gsq(hero.sq.px + i, hero.sq.py + j).p
              if not immune[p.name] and not (p.leader and leader_immune) and not p.aruaim then
                hit(p, def_dmg, hero) -- code by Glacies
              end
            end
          end
        end
        if enable_sfx then sfx("lift") end
        local marker1 = mke()
        local marker2 = mke()

        marker1.sx = hero.x
        marker1.sy = hero.y
        marker1.ex = hero.x - stack.aura * 16
        marker1.ey = hero.y - stack.aura * 16
        marker1.tws = aura_tempo
        marker1.twc = 0
        function marker1.twf()
          del(ents, marker1)
        end

        function marker1:dr()
          rect(marker1.x, marker1.y, marker2.x, marker2.y, aura_colour)
        end

        marker2.sx = hero.x + 15
        marker2.sy = hero.y + 15
        marker2.ex = hero.x + 15 + stack.aura * 16
        marker2.ey = hero.y + 15 + stack.aura * 16
        marker2.tws = aura_tempo
        marker2.twc = 0
        function marker2.twf()
          del(ents, marker2)
        end
      end
    end
  end)
end
