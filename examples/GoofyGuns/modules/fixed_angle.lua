function start()
  add_listener("shot", function()
    if not stack.fixed_angle then return end
    for i, b in ipairs(bullets) do
      local arc = get_spread() / 360
      local b_offset = i * (arc / (#bullets + 1))
      local b_angle = (hero.current_an - arc / 2) + b_offset
      b.vx = cos(b_angle) * 8
      b.vy = sin(b_angle) * 8
    end
  end)
end
