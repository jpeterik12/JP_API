id = "grenades" -- BY GLACIES
--[[
		Relevant Card Effects:

		gren_bounceless = 1					the grenade won't bounce any more
		gren_frag = <int>					blasts out <int> fragments on explosion
		frag_range = <multiple of 0.5>		increases minimum range of fragments (unit: squares)
		frag_interval = <multiple of 0.5>	increases the diff between min and max range (unit: squares)
		frag_dmg = <num>					increases the damage of each fragment
		frag_pierce = <num>					increases the pierce of each fragment
		gren_stun = 1						stuns nearby pieces on explosion
		gren_frost = <int>					delays nearby pieces movement by <int> turns
		gren_burn = <int>					sets fire in nearby non-water squares that lasts for <int> turns,
											and burns pieces on it every turn
		burn_dmg = <num>					increases the damage of fire burning
		burn_stack = <num>					increases Burning Stackablity State by <num> (for details see below)
		gren_rats = <int>					summons <int> rats on explosion
		gren_pierc = 1						damage of grenades pierces through iron armour
		expl_<id> = <num>					pieces of type <id> explode and deal <num> damage when they die
		expl_range_<id> = <int>				increases the range of explosion of pieces of type <id> by <int>
		expl_burn_<id> = <int>				pieces of type <id> ignite all squares within range of explosion
		<piece>_stim = 1					<piece> will not be stunned by grenades
		<piece>_frim = 1					<piece> will not be delayed by grenades
		<piece>_buim = 1					<piece> will not be burned by grenades
		<piece>_piim = 1					<piece> will not be damaged through iron armour by grenades
		<piece>_exim = 1					<piece> will not be damaged by other pieces' explosion
	--]]


-- SETTINGS
burn_gfx = true -- enables gfx for burning squares
start_gid = 352 -- the index of the 16*16 square for the first frame of animation
animation_length = 64 -- number of frames in one cycle of animation
piece_explosion_sfx = true -- enables sfx for piece death explosions
piece_explosion_delay = 12 -- the delay between piece death and their explosions
DEFAULT_frag_min_range = 3 -- default minimum range of fragments (unit: squares)
DEFAULT_frag_range_interval = 2 -- default diff between min and max range (unit: squares)
DEFAULT_frag_dmg = 1 -- default damage of each fragment
DEFAULT_frag_pierce = 0 -- default pierce of each fragment
DEFAULT_burn_dmg = 1 -- default damage of fire burning
DEFAULT_burn_stack = 0 -- default Burning Stackablity State (BSS)
-- When a burning square is ignited again, if BSS is:
-- Positive: duration of burning stacks
-- Else: duration of burning is set to the largest
DEFAULT_explode_range = { -- the range of explosion when these pieces die
  pawn = 1,
  knight = 1,
  bishop = 1,
  rook = 1,
  queen = 1,
  king = 1,
  boss = 1,
  canonball = 1
}
immune = { -- pieces that don't get:
  stun = { -- stunned
    -- pawn = false,
    -- knight = false,
    -- bishop = false,
    -- rook = false,
    -- queen = false,
    -- king = false,
    -- boss = false,
    -- canonball = false,
    -- leader = false
  },
  frost = { -- delayed
    -- same as above
  },
  burn = { -- burned
    -- same as above
  },
  pierc = { -- damaged through iron armour
    -- same as above
  },
  expl = { -- damaged by other pieces' explosion
    -- same as above
  },
}

function on_new_turn()
  for sq in all(squares) do
    if sq.burn then
      if sq.p and sq.p.bad and not (immune.burn[sq.p.name] or sq.p.buim
          or (sq.p.leader and immune.burn.leader)) then hit(sq.p, burn_dmg) end
      if sq.burn == 1 then
        sq.burn = nil
        del(ents, sq.flame)
        sq.flame = nil
      else sq.burn = sq.burn - 1 end
    end
  end
end

local function ignite(sq, dura)
  burn_dmg = DEFAULT_burn_dmg
  burn_stack = DEFAULT_burn_stack
  if stack.burn_dmg then burn_dmg = burn_dmg + stack.burn_dmg end
  if stack.burn_stack then burn_stack = burn_stack + stack.burn_stack end
  if not sq.moat then
    if sq.burn then
      if burn_stack > 0 then
        sq.burn = sq.burn + dura
      else
        sq.burn = max(sq.burn, dura)
      end
    else
      sq.burn = dura
    end
    if burn_gfx and not sq.flame then
      local function dr_burn()
        local e = mke(0, sq.x, sq.y)
        e.glacies = "fire drawer"
        e.dp = 2 -- code by Glacies
        e.life = animation_length
        e.upd = function(self)
          if sq.moat or hero.win then
            sq.burn = nil
            sq.flame = nil
            del(ents, self)
          end
        end
        e.dr = function(self)
          spr(start_gid + animation_length - self.life, self.x, self.y)
        end
        sq.flame = e
        e.nxt = dr_burn
      end

      dr_burn()
    end
  end
end

function start()
  -- display setup


  add_listener("grenade_init", function(ent)
    -- gameplay setup





    frag_min_range = DEFAULT_frag_min_range
    frag_range_interval = DEFAULT_frag_range_interval
    frag_dmg = DEFAULT_frag_dmg
    frag_pierce = DEFAULT_frag_pierce


    if stack.frag_range then frag_min_range = frag_min_range + stack.frag_range end
    if stack.frag_interval then frag_range_interval = frag_range_interval + stack.frag_interval end
    if stack.frag_dmg then frag_dmg = frag_dmg + stack.frag_dmg end
    if stack.frag_pierce then frag_pierce = frag_pierce + stack.frag_pierce end


    if stack.gren_bounceless and not ent.bounceless then
      ent.bounceless = true -- code by Glacies
      ent.jz = min(ent.jz, 19.9)
    end
  end)

  add_listener("grenade_explode", function(ent)
    if stack.gren_frag then
      for i = 1, stack.gren_frag do
        local b = mk_bullet(ent.x, ent.y, rnd(1) - 0.5, 8)
        b.glacies = "fragment " .. i
        b.life = irnd(frag_range_interval * 2 + 1) + 2 * (frag_min_range)
        b.dmg = frag_dmg
        b.pierce = frag_pierce
      end
    end
    if stack.gren_stun then
      for i = -1, 1 do
        for j = -1, 1 do
          local sq = get_square_at(ent.x + i * 16, ent.y + j * 16)
          if sq and sq.p and sq.p.bad and not (immune.stun[sq.p.name] or sq.p.stim
              or (sq.p.leader and immune.stun.leader)) then sq.p.stun = true end
        end
      end
    end
    if stack.gren_frost then
      for i = -1, 1 do
        for j = -1, 1 do
          local sq = get_square_at(ent.x + i * 16, ent.y + j * 16)
          if sq and sq.p and sq.p.bad and not (immune.frost[sq.p.name]
              or sq.p.frim or (sq.p.leader and immune.frost.leader)) then
            sq.p.cd = sq.p.cd - stack.gren_frost
            if sq.p.tempo - sq.p.cd > 0 then sq.p.ready = false end
          end
        end
      end
    end
    if stack.gren_burn then
      for i = -1, 1 do
        for j = -1, 1 do
          local sq = get_square_at(ent.x + i * 16, ent.y + j * 16)
          if sq then ignite(sq, stack.gren_burn) end
        end
      end
    end
    if stack.gren_rats then
      local rats = stack.rats
      local p = sq.p
      stack.rats = stack.gren_rats
      xpl({ x = ent.x - 8, y = ent.y - 8, name = "rats", type = 1000, sq = sq })
      stack.rats = rats
      sq.p = p
    end
    if stack.gren_pierc then
      for i = -1, 1 do
        for j = -1, 1 do
          local sq = get_square_at(ent.x + i * 16, ent.y + j * 16)
          if sq and sq.p and sq.p.iron and sq.p.bad and not (sq.p.piim or
              immune.pierc[sq.p.name] or (sq.p.leader and immune.pierc.leader)) then
            local p = sq.p
            p.iron = nil
            wait(1, function() p.iron = 1 end)
          end
        end
      end
    end
  end)
end

function on_bad_death(p)
  local dmg = nil
  if stack["expl_" .. p.type] then dmg = stack["expl_" .. p.type] end
  if stack.expl_7 then
    if dmg then dmg = dmg + stack.expl_7
    else dmg = stack.expl_7 end
  end
  if stack.expl_8 and p.leader then
    if dmg then dmg = dmg + stack.expl_8
    else dmg = stack.expl_8 end
  end
  if dmg and get_square_at(p.x + 8, p.y + 8) then
    local range = DEFAULT_explode_range[p.name]
    if stack["expl_range_" .. p.type] then range = range + stack["expl_range_" .. p.type] end
    if stack.expl_range_7 then range = range + stack.expl_range_7 end
    if stack.expl_range_8 and p.leader then range = range + stack.expl_range_8 end
    for i = -range, range do
      for j = -range, range do
        local sq = gsq(get_square_at(p.x + 8, p.y + 8).px + i, get_square_at(p.x + 8, p.y + 8).py + j)
        if sq then
          if piece_explosion_sfx then sfx("grenade_xpl") end
          wait(piece_explosion_delay, function()
            if sq.p and sq.p.bad and not ((sq.p.leader and immune.expl.leader) or
                immune.expl[sq.p.name] or sq.p.exim) and dmg ~= 0 then hit(sq.p, dmg) end
            local burn = nil
            if stack["expl_burn_" .. p.type] then burn = stack["expl_burn_" .. p.type] end
            if stack.expl_burn_7 then
              if burn then burn = burn + stack.expl_burn_7
              else burn = stack.expl_burn_7 end
            end
            if stack.expl_burn_8 and p.leader then
              if burn then burn = burn + stack.expl_burn_8
              else burn = stack.expl_burn_8 end
            end
            if burn then ignite(sq, burn) end
          end)
        end
      end
    end
  end
end
