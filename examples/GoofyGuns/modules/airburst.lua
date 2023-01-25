id = "airburst"
function start()
  add_listener("bullet_init", function(b)
    if not b.shot then return end
    if not stack.airburst or stack.airburst <= 0 then return end
    b.airburst = stack.airburst
    b.old_vx = b.vx
    b.old_vy = b.vy
    b.vx = cos(hero.current_an) * 8
    b.vy = sin(hero.current_an) * 8
  end)

  add_listener("bullet_upd", function(b)
    if not b.airburst or b.airburst <= 0 then return end
    if b.t > (-1 + 2 * stack.airburst) then
      b.vx = b.old_vx
      b.vy = b.old_vy
    end
  end)

  add_listener("upd", function()
    if not stack.airburst or stack.airburst <= 0 then
      if crosshair.old_dr then
        crosshair.dr = crosshair.old_dr
        crosshair.old_dr = nil
      end
      return
    end
    if (not crosshair) or (crosshair.old_dr) then return end
    crosshair.old_dr = crosshair.dr
    crosshair.dr = function(self)
      if not hero then return end
      if not hero.x then return end
      if not playing then return end
      if not (chamber > 0) then return end
      if mx < board_x or mx > board_x + (8 * 16) or my < board_y or my > board_y + (8 * 16) then
        crosshair.old_dr(self)
        return
      end
      local gun_x = hero.x + 8 + 8 * cos(hero.current_an)
      local gun_y = hero.y + 8 + 8 * sin(hero.current_an)
      local burst_x = hero.x + cos(hero.current_an) * 16 * stack.airburst
      local burst_y = hero.y + sin(hero.current_an) * 16 * stack.airburst
      if (sqrdist(mx, my, hero.x + 8, hero.y + 8) < (16 * stack.airburst + 8) ^ 2) and not aim then
        line(gun_x, gun_y, mx, my, 5)
        return
      end
      line(gun_x, gun_y, burst_x - hero.x + gun_x, burst_y - hero.y + gun_y, 5)
      local temp_hx = hero.x
      local temp_hy = hero.y
      hero.x = burst_x
      hero.y = burst_y
      stack.firerange = stack.firerange - stack.airburst
      crosshair.old_dr(self)
      stack.firerange = stack.firerange + stack.airburst
      hero.x = temp_hx
      hero.y = temp_hy
    end
  end)
end
