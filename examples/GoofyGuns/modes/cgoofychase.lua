id = "cgoofychase"
ban = {
	"Egotic Maelstrom",
	"Undercover Mission",
	"Unholy Call",
	"Imperial Shot Put",
}
setup = {
	slots_max = { 5, 0 },
}
base = {
	chamber_max = 2, firepower = 4, firerange = 3, spread = 55, ammo_max = 5,
	ammo_regen = 1, king_hp = -2, militia = 1
}
proba = { 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4 }
pieces_danger = { 1, 3, 3, 6, 9, 0 }
fill_last_slot = true
turns = 0

weapons = {
	{ gid = 0, name = "Bursting Shotgun", chamber_max = 1, firepower = 4, firerange = 4, spread = 90, ammo_max = 4,
		airburst = 1.5, desc = "Bullets go perfectly straight before spreading. The point at the end splits the bullet." },
	{ gid = 1, name = "Perfect Barrels", chamber_max = 3, firepower = 4, firerange = 5, spread = 70, ammo_max = 5,
		fixed_angle = 1, desc = "Bullets are spread evenly across fire arc. Less a shotgun and more 4 rifles taped together." },
	{ gid = 2, name = "Deceleration Cannon", chamber_max = 2, firepower = 2, firerange = 10, spread = 50, ammo_max = 4,
		weakening = 1, desc = "Bullets do less damage the longer they exist. Get in their face." },
	{ gid = 3, name = "Acceleration Cannon", chamber_max = 1, firepower = 2, firerange = 10, spread = 50, ammo_max = 4,
		strengthening = 1, desc = "Bullets do more damage the longer they exist. Go for those snipes." },
	{ gid = 4, name = "Single Use Shotgun", chamber_max = 1, firepower = 1, firerange = 10, spread = 0, ammo_max = 0,
		one_shot = 1, desc = "No spare bullets. One shot, one kill. Get the angle, take the shot." },
	{ gid = 5, name = "Long Shotgun", chamber_max = 2, firepower = 4, firerange = 4, spread = 50, ammo_max = 5,
		long_gun = 1, desc = "You can't hit pieces within one tile. This must be why people often make sawn-offs." },
	{ gid = 6, name = "Heat Seeking Shotgun", chamber_max = 1, firepower = 4, firerange = 5, spread = 180, ammo_max = 4,
		homing = 1, desc = "Homing Bullets. Science still doesn't understand." },
	{ gid = 7, name = "Curved Shotgun", chamber_max = 2, firepower = 4, firerange = 4, spread = 80, ammo_max = 5,
		curve = 1, desc = "The bullets will start to curve once leaving your barrel. Maybe check the alignment?" },
	{ gid = 8, name = "Bouncing Shotgun", chamber_max = 1, firepower = 5, firerange = 5, spread = 30, ammo_max = 4,
		bounce = 1, desc = "BUllets will bounce off the edge of the board. Time for some trickshots." },
}
MODNAME = current_mod
-- JP API CODE
do
	-- LISTENER CODE
	function init_listeners()
		if LISTENER then
			del(ents, LISTENER)
		end
		LISTENER = mke()
		LISTENER.listeners = {}
		LISTENER.listeners["shot"] = {}
		LISTENER.listeners["upd"] = {}
		LISTENER.listeners["dr"] = {}
		LISTENER.listeners["bullet_init"] = {}
		LISTENER.listeners["bullet_upd"] = {}
		LISTENER.listeners["after_black"] = {}
		LISTENER.listeners["after_white"] = {}
		local function setup_shot()
			for ent in all(ents) do
				if ent.left_clic and not ent.old_left_clic then
					ent.old_left_clic = ent.left_clic
					ent.left_clic = function()
						ent.old_left_clic()
						local shot = false
						for b in all(bullets) do
							if b.shot and not b.old_upd then
								b.old_upd = b.upd
								b.upd = function(self)
									for listener in all(LISTENER.listeners["bullet_upd"]) do
										listener(self)
									end
									self.old_upd(self)
								end
								for listener in all(LISTENER.listeners["bullet_init"]) do
									listener(b)
								end
								shot = true
							end
						end
						if shot then
							for listener in all(LISTENER.listeners["shot"]) do
								listener()
							end
						end
					end
				end
			end
		end

		LISTENER.run = true
		LISTENER.jumping = false
		function LISTENER:upd()
			if not LISTENER.run then return end
			setup_shot()
			for listener in all(LISTENER.listeners["upd"]) do
				listener()
			end
			if hero and hero.twc then
				LISTENER.jumping = true
			end
			if hero and (not hero.twc) and LISTENER.jumping then
				LISTENER.jumping = false
				for listener in all(LISTENER.listeners["after_black"]) do
					listener()
				end
			end
		end

		function LISTENER:dr()
			if not LISTENER.run then return end
			lprint("JP_API 0.9", 248, 162.5, 2)
			for listener in all(LISTENER.listeners["dr"]) do
				listener()
			end
		end
	end

	function add_listener(event, listener)
		if not LISTENER.listeners[event] then
			LISTENER.listeners[event] = {}
		end

		del(LISTENER.listeners[event], listener)
		add(LISTENER.listeners[event], listener)
	end

	function remove_listener(event, listener)
		del(LISTENER.listeners[event], listener)
	end

	-- GUN DESCRIPTIONS
	function initialize()
		load_mod("none")
		load_mod(MODNAME)
		if (ranks) then mode.ranks_index = mid(0, bget(0, 4), #ranks - 1) end
		mode.weapons_index = mid(0, bget(1, 4), #weapons - 1)
		palette("mods\\" .. MODNAME .. "\\gfx.png")
	end

	function enable_description()
		local x = mk_hint_but(280, 64, 8, 9, weapons[mode.weapons_index + 1].desc, { 4 }, 100, nil, { x = 170, y = 75 })
		x.lastindex = mode.weapons_index
		x.dr = function(self)
			lprint("?", 284, 67, 5)
			if (mode.weapons_index ~= self.lastindex) then
				del(ents, self)
				enable_description()
			end
		end
	end

	function get_weapons_list()
		local a = { 0 }
		for i = 1, #weapons do
			add(a, i)
		end
		enable_description()
		return a
	end
end
-- LISTENER CODE END

-- MOD CODE
do
	function mod_setup()
		init_listeners()

		enable_fixed_angle()
		enable_attacked()
		enable_airburst()
		enable_weakening()
		enable_strengthening()
		enable_bullet_delay()
		enable_one_shot()
		enable_long_gun()
		enable_homing()
		enable_curve()
		enable_bounce()
	end

	-- SAFETY CODE
	function enable_attacked()
		local function showChances()
			local function getView(bad, x, y, look_angle)
				local bad_corners = {}
				bad_corners[1] = { bad.x, bad.y }
				bad_corners[2] = { bad.x + 16, bad.y }
				bad_corners[3] = { bad.x, bad.y + 16 }
				bad_corners[4] = { bad.x + 16, bad.y + 16 }

				custom_sort(bad_corners, function(a) return sqrdist(a[1], a[2], x, y) end)
				if bad.x < x and x < (bad.x + 16) or bad.y < y and (y < bad.y + 16) then
					line(x, y, bad_corners[1][1], bad_corners[1][2], 5)
					line(x, y, bad_corners[2][1], bad_corners[2][2], 5)
				else
					line(x, y, bad_corners[2][1], bad_corners[2][2], 5)
					line(x, y, bad_corners[3][1], bad_corners[3][2], 5)
				end
			end

			if not hero then return end
			if not hero.current_an then return end
			local centerx = hero.x + hero.ww / 2
			local centery = hero.y + hero.hh / 2
			local gun_dist = 8
			local gun_x = centerx + gun_dist * cos(hero.current_an)
			local gun_y = centery + gun_dist * sin(hero.current_an)
			local d_aim = get_spread() / 720
			for bad in all(get_real_bads()) do
				getView(bad, gun_x, gun_y, hero.current_an)
			end
		end

		local show_attacked = false
		mk_text_but(220, 0, 20, "SAFE", function() show_attacked = not show_attacked end).ents[1].button = false
		add_listener("dr", function(self)
			if show_attacked and playing then
				-- showChances()
				for sq in all(squares) do
					if #sq.danger > 0 then
						spr(41, sq.x, sq.y)
					end
				end
			end
		end)
	end

	-- AIRBURST
	function enable_airburst()
		add_listener("bullet_init", function(b)
			if not b.shot then return end
			if not stack.airburst or stack.airburst <= 0 then return end
			b.airburst = stack.airburst
			b.old_vx = b.vx
			b.old_vy = b.vy
			b.vx = cos(hero.current_an) * 8
			b.vy = sin(hero.current_an) * 8
		end)

		add_listener("bullet_upd", function(b)
			if not b.airburst or b.airburst <= 0 then return end
			if b.t > (-1 + 2 * stack.airburst) then
				b.vx = b.old_vx
				b.vy = b.old_vy
			end
		end)

		add_listener("upd", function()
			if not stack.airburst or stack.airburst <= 0 then
				if crosshair.old_dr then
					crosshair.dr = crosshair.old_dr
					crosshair.old_dr = nil
				end
				return
			end
			if (not crosshair) or (crosshair.old_dr) then return end
			crosshair.old_dr = crosshair.dr
			crosshair.dr = function(self)
				if not hero then return end
				if not hero.x then return end
				if not playing then return end
				if not (chamber > 0) then return end
				if mx < board_x or mx > board_x + (8 * 16) or my < board_y or my > board_y + (8 * 16) then
					crosshair.old_dr(self)
					return
				end
				local gun_x = hero.x + 8 + 8 * cos(hero.current_an)
				local gun_y = hero.y + 8 + 8 * sin(hero.current_an)
				local burst_x = hero.x + cos(hero.current_an) * 16 * stack.airburst
				local burst_y = hero.y + sin(hero.current_an) * 16 * stack.airburst
				if (sqrdist(mx, my, hero.x + 8, hero.y + 8) < (16 * stack.airburst + 8) ^ 2) and not aim then
					line(gun_x, gun_y, mx, my, 5)
					return
				end
				line(gun_x, gun_y, burst_x - hero.x + gun_x, burst_y - hero.y + gun_y, 5)
				local temp_hx = hero.x
				local temp_hy = hero.y
				hero.x = burst_x
				hero.y = burst_y
				stack.firerange = stack.firerange - stack.airburst
				crosshair.old_dr(self)
				stack.firerange = stack.firerange + stack.airburst
				hero.x = temp_hx
				hero.y = temp_hy
			end
		end)
	end

	-- FIXED ANGLE
	function enable_fixed_angle()
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

	-- WEAKENING
	function enable_weakening()
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

	-- STRENGTHENING
	function enable_strengthening()
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

	-- BULLET DELAY (OFTEN SOFTLOCKS)
	function enable_bullet_delay()
		stored_bullets = {}
		add_listener("shot", function()
			if not stack.bullet_delay then return end
			local temp = {}
			for b in all(bullets) do
				add(temp, b)
				del(bullets, b)
				b.old_life = b.life
				b.old_vx = b.vx
				b.old_vy = b.vy
				b.old_dmg = b.dmg
				b.life = 100000
				b.vx = 0
				b.vy = 0
				b.dmg = 0
			end
			for b in all(stored_bullets) do
				add(bullets, b)
				del(stored_bullets, b)
				b.life = b.old_life
				b.vx = b.old_vx
				b.vy = b.old_vy
				b.dmg = b.old_dmg
			end
			for b in all(temp) do
				add(stored_bullets, b)
				del(temp, b)
			end
		end)
	end

	-- ONE SHOT ONE KILL
	function enable_one_shot()
		add_listener("bullet_init", function()
			if not stack.one_shot then return end
			for b in all(bullets) do
				b.dmg = 100
			end
		end)
	end

	-- LONG GUN
	function enable_long_gun()
		add_listener("bullet_init", function(b)
			if not b.shot then return end
			if not stack.long_gun then return end
			b.x = b.x + 4 * b.vx
			b.y = b.y + 4 * b.vy
		end)
	end

	-- HOMING
	function enable_homing()
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

	-- CURVE
	function enable_curve()
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

	-- BOUNCING
	function enable_bounce()
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
end
-- END MOD CODE

function start()
	init_game()
	lvl = 0

	-- SPAWNER
	score = 0
	dif = 2
	mode.turns = 0

	-- MOD CODE
	mod_setup()
	-- END MOD CODE

	-- LEVEL
	new_level()

	-- FIRST SPAWN
	add_event(ev_side_spawn, { 0, 0, 0 })

	--
	--add_card("Militia")


end

function on_king_death()

	--[[
	local data={
		id="level_up", 
		pan_xm=3,
		pan_ym=1, 
		pan_width=128,
		pan_height=64,
		choices={
			{{team=0}},{{team=0}},{{team=0}},
		},
	}

	add_event(bind(level_up,data,new_turn))
	
	--]]
end

function get_slot_data(team, i)
	if team == 1 or i > 4 then return nil end

	local data = {
		x = 16,
		y = 4 + i * 32,
		team = team,
		side_icon = i == 0 and 0 or 1,
	}
	return data
end

-- ON
function on_hero_death()
	progress(0, 3, score)
	progress(1, 3, turns)
	save()
	gameover()
end

function on_new_turn()
	dif = dif + 1 / 8
	local danger = 0
	for b in all(bads) do
		danger = danger + (pieces_danger[b.type + 1] or 0)
	end



	-- NEW WAVE
	local tdif = dif + #get_slot_cards()

	if danger < tdif * .85 then
		sfx("conscription")
		local a = {}
		while danger < tdif do
			local tp = rnd(proba)
			add(a, tp)
			danger = danger + PIECES[tp + 1].danger
			add_event(ev_side_spawn, tp)
		end
	end



	-- NEW KING
	if mode.turns % 15 == 5 then
		add_event(ev_side_spawn, 5)
	end

	-- NEW AMMO BOX
	if mode.turns % 20 == 10 then
		add_event(ev_spawn_item, "ammo_box")
	end

	-- JPI CODE
	for listener in all(LISTENER.listeners["after_white"]) do
		listener()
	end

end

function on_bad_death(e)
	local danger = pieces_danger[e.type + 1]
	if not danger then return end
	local bounty = danger * 5
	score = score + bounty

	if e.type == 5 then
		local data = {
			id = "level_up",
			pan_xm = 3,
			pan_ym = 1,
			pan_width = 128,
			pan_height = 64,
			choices = {
				{ { team = 0 } }, { { team = 0 } }, { { team = 0 } },
			},
		}
		add_event(bind(level_up, data, new_turn))
	end


	--[[
	local p=mke(0,e.x,e.y)
	p.dp=DP_FX
	p.life=60
	p.vy=-2
	p.frict=.92
	p.dr=function(e,x,y)
		local str=bounty..""
		lprint(str,x,y,4,1,1)
	end
	--]]


end

--
function draw_inter()
	local s = lang.score_
	local x = lprint(s, MCW / 2, board_y - 19, 3, 1)
	lprint(score, x, board_y - 19, 5)
end

-- NEED SOLVE
-- cards with sacrifice or adding piece
-- can't use wand/grenade the turn I get them

-- ? 1+ mist ?
