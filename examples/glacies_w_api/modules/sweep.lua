id = "sweep"
function start()
  --[[
		  Relavant Card Effects:

		  sweep=<int>			When set to 1: Sweep attack 2 adjacent squares
		  					      When set to higher values: Sweep attack 2 more squares
		  sweepdmg = <num>	Increases the sweep damage by <num>
	  --]]
  add_listener("dr", function()
    lprint(lang.credits, 181, 158, 6)
  end)
  add_listener("blade", function()
    if not stack.sweep or not stack.blade then return end
    local bladed_square = get_square_at(mx, my)
    local to_sweep = { bladed_square }
    local function in_range(sq)
      if not sq then return false end
      for sq2 in all(to_sweep) do
        if sq == sq2 then return false end
      end
      if abs(sq.px - bladed_square.px) <= 1 and abs(sq.py - bladed_square.py) <= 1 then
        if abs(sq.px - hero.sq.px) <= 1 and abs(sq.py - hero.sq.py) <= 1 then
          return true
        end
        return false
      end
    end

    for i = 1, min(3, stack.sweep) do
      local to_add = {}
      for sq in all(to_sweep) do
        local north = gsq(sq.px, sq.py - 1)
        local east = gsq(sq.px + 1, sq.py)
        local south = gsq(sq.px, sq.py + 1)
        local west = gsq(sq.px - 1, sq.py)
        if in_range(north) then add(to_add, north) end
        if in_range(east) then add(to_add, east) end
        if in_range(south) then add(to_add, south) end
        if in_range(west) then add(to_add, west) end
      end
      for sq in all(to_add) do
        add(to_sweep, sq)
      end
    end
    for sq in all(to_sweep) do
      if sq.p and sq.p.hp then
        if not stack.sweepdmg then stack.sweepdmg = 0 end
        hit(sq.p, stack.sweepdmg + flr(stack.blade / 2))
      end
    end
  end)
end
