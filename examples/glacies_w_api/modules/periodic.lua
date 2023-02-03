id = "periodic_promotion" -- BY GLACIES
--[[
		Relevant Card Effects:

		promoting_<id> = <int>		Promotes a random piece of type <id> every <int> turns
	--]]
function on_new_turn()
  for i = 0, #PIECES - 1 do
    local pro = stack["promoting_" .. i]
    if pro and mode.turns and mode.turns % pro == pro - 1 and #get_pieces(i) > 0 then
      add_event(ev_promote, rnd(get_pieces(i))) -- code by Glacies
    end
  end
end
