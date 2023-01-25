id = "check_button"
function start()
  local show_attacked = false
  mk_text_but(220, 0, 20, "SAFE", function() show_attacked = not show_attacked end).ents[1].button = false
  add_listener("dr", function(self)
    if show_attacked and playing then
      for sq in all(squares) do
        if #sq.danger > 0 then
          spr(41, sq.x, sq.y)
        end
      end
    end
  end)
end
