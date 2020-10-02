-- init

function _init()
	-- constants
	left = 0
	right = 1
	up = 2
	down = 3
	tics = 0

	cfg = {
		levels = {},
		lvl_ypos = 15 * 8,
		playspr = {1, 2},
		terrspr = {48, 49, 50},
		shotspr = {17, 18},
		shot_timer = 5,
		max_shots = 4,
		shot_veloc = 3
	}

	player = {
		spr = {1, 2},
		x = 0,
		y = 14 * 8,
		accel = 1,
		shots = {}
	}
	local lvl = genlevel()
	add(cfg.levels, lvl)
end

-->8
-- common

function genlevel(num)
	local lvlterr = {}
	local tile = nil
	local initial = cfg.terrspr[1]
	for i = 1, 16 do
		tile = flr(rnd(#cfg.terrspr) + initial)
		add(lvlterr, tile)
	end
	return lvlterr
end

-->8
-- update

function _update()
	tics = tics + 1
	update_player()
	update_shots()
end

function update_player()
	if btn(0) and player.x > 0 then
		player.x = player.x - player.accel
	elseif btn(1) and player.x < 120 then
		player.x = player.x + player.accel
	end
	if btn(2) then
		-- shot timer
		if tics % cfg.shot_timer == 0 then
			if #player.shots < cfg.max_shots then
				shot = {x = player.x, y = player.y - 4}
				add(player.shots, shot)
			end
		end
	end
end

function update_shots()
	for shot in all(player.shots) do
		shot.y = shot.y - cfg.shot_veloc
		if (shot.y < -8) then
			del(player.shots, shot)
		end
	end
end

-->8
-- draw

function _draw()
	cls()
	draw_terrain()
	draw_player()
	draw_shots()
end

function draw_shots()
	for shot in all(player.shots) do
		local s = cfg.shotspr[1]
		if shot.y % 4 == 0 then
			s = cfg.shotspr[2]
		end
		spr(s, shot.x, shot.y)
	end
end

function draw_player()
	local s = cfg.playspr[1]
	if player.x % 3 == 0 then
		s = cfg.playspr[2]
	end
	spr(s, player.x, player.y)
end

function draw_terrain()
	local x = 0
	local tiles = cfg.levels[1]
	for t in all(tiles) do
		spr(t, x, cfg.lvl_ypos)
		x = x + 8
	end
end
