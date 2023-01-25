id = "strengthening"
function start()
  add_listener("bullet_init", function(b)
    if not b.shot then return end
    if not stack.strengthening then return end
    b.strengthening = true
  end)

  add_listener("bullet_upd", function(b)
    if not b.strengthening then return end
    if b.t % 3 == 0 then
      b.dmg = b.dmg + 1
    end
  end)
end
