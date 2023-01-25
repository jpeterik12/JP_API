id = "long_gun"
function start()
  add_listener("bullet_init", function(b)
    if not b.shot then return end
    if not stack.long_gun then return end
    b.x = b.x + 4 * b.vx
    b.y = b.y + 4 * b.vy
  end)
end
