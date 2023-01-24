function start()
  add_listener("bullet_init", function(b)
    if not b.shot then return end
    if not stack.bounce then return end
    b.bounce = true
  end)

  add_listener("bullet_upd", function(b)
    if not b.bounce then return end
    if b.x < board_x or b.x > board_x + 128 then
      b.vx = -b.vx
    end
    if b.y < board_y or b.y > board_y + 128 then
      b.vy = -b.vy
    end
  end)
end
