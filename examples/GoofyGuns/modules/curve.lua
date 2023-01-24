function start()
  add_listener("bullet_init", function(b)
    if not b.shot then return end
    if not stack.curve then return end
    b.curve = true
    b.angle = hero.current_an
    b.curve_angle = atan2(b.vx, b.vy) - b.angle
    if b.curve_angle > .5 then
      b.curve_angle = b.curve_angle - 1
    elseif b.curve_angle < -.5 then
      b.curve_angle = b.curve_angle + 1
    end
    _log(b.curve_angle)
  end)

  add_listener("bullet_upd", function(b)
    if not b.curve then return end
    b.angle = b.angle + (b.curve_angle * 0.3)
    b.vx = cos(b.angle) * 8
    b.vy = sin(b.angle) * 8
  end)
end
