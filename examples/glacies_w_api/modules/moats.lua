id = "moats" -- BY GLACIES
function start()
  --[[
		Relevant Card Effects:

		moat_row_<int> = 1			Turns Row <int> to water
		moat_col_<int> = 1			Turns Column <int> to water
		bridge_row_<int> = 1		Turns Row <int> to a land
		bridge_col_<int> = 1		Turns Column <int> to a land
		land_walk = 1				Turns any square where the black king has ever been in this floor into land
		water_walk = 1				Turns any square where the black king has ever been in this floor into water
		flip_walk = 1				Flip the state of any square where the black king has ever been in this floor

		Rule of Overriding:

		flip_walk > water_walk > land_walk > bridge > moat > original bridge > original moat
	--]]


  add_listener("upd", function(self)
    if squares then
      for i = 0, 7 do
        if stack["moat_row_" .. i] then
          for j = 0, 7 do
            gsq(j, i).moat = true
          end
          stack["moat_row_" .. i] = nil
        end
        if stack["moat_col_" .. i] then
          for j = 0, 7 do
            gsq(i, j).moat = true
          end
          stack["moat_col_" .. i] = nil
        end
      end
      for i = 0, 7 do
        if stack["bridge_row_" .. i] then
          for j = 0, 7 do
            gsq(j, i).moat = false
          end
          stack["bridge_row_" .. i] = nil
        end
        if stack["bridge_col_" .. i] then
          for j = 0, 7 do
            gsq(i, j).moat = false
          end
          stack["bridge_col_" .. i] = nil
        end
      end
      if hero and hero.sq then
        if stack.flip_walk then
          if not stack.flipping then
            stack.flipping = true
            for sq in all(squares) do
              sq.moat_ = sq.moat
            end
          end
          if not hero.sq.standing then
            hero.sq.flip = not hero.sq.flip
            hero.sq.standing = true
          end
          for sq in all(squares) do
            if sq.standing and sq ~= hero.sq then
              sq.standing = nil -- code by Glacies
            end
            sq.moat = (not sq.flip == sq.moat_)
          end
        elseif stack.water_walk then
          hero.sq.water = true
          for sq in all(squares) do
            if sq.water then sq.moat = true end
          end
        elseif stack.land_walk then
          hero.sq.land = true
          for sq in all(squares) do
            if sq.land then sq.moat = false end
          end
        end
      end
    end
  end)
end
