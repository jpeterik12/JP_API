-- ONE SHOT ONE KILL
function start()
  add_listener("bullet_init", function()
    if not stack.one_shot then return end
    for b in all(bullets) do
      b.dmg = 100
    end
  end)
end
