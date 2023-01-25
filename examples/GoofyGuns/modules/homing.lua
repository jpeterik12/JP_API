id = "homing"
function start()
  add_listener("bullet_init", function(b)
    if not b.shot then return end
    if not stack.homing then return end
    b.homing = true
  end)

  add_listener("bullet_upd", function(b)
    if not b.homing then return end
    if not b.target or b.target.hp < 1 then
      local closest = nil
      local closest_dist = 100000
      for e in all(get_real_bads()) do
        local dist = sqrdist(b.x, b.y, e.x + 8, e.y)
        if dist < closest_dist then
          closest = e
          closest_dist = dist
        end
      end
      b.target = closest
    end
    if b.target then
      local current_angle = atan2(b.vx, b.vy)
      local target_angle = atan2(b.target.x - b.x, b.target.y - b.y)
      if current_angle - target_angle > .5 then
        target_angle = target_angle + 1
      elseif target_angle - current_angle > .5 then
        target_angle = target_angle - 1
      end
      local angle = current_angle + (target_angle - current_angle) / 8
      b.vx = cos(angle) * 8
      b.vy = sin(angle) * 8
    end
  end)
end
