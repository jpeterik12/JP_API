function start()
  add_listener("bullet_init", function(b)
    if not b.shot then return end
    if not stack.weakening then return end
    b.weakening = true
    b.dmg = 5
  end)

  add_listener("bullet_upd", function(b)
    if not b.weakening then return end
    if b.t % 3 == 0 then
      b.dmg = b.dmg - 1
    end
  end)
end
