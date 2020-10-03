-- init
-- C:\Program Files (x86)\PICO-8\pico8.exe
function _init()
    -- constants
    left = 0
    right = 1
    up = 2
    down = 3
	tics = 0
	dbg = {}

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

    player = {spr = {1, 2}, x = 0, y = 14 * 8, accel = 1, shots = {}}

    enemies = {
        list = {},
        minx = -8,
        maxx = 136,
        miny = 0,
        maxy = 80
	}

    local lvl = genlevel()
	add(cfg.levels, lvl)
	
	add(enemies.list, create_enemy())
end

-- >8
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

function create_enemy()
	local start_y = flr(rnd(80))
	local enemy = {
		x = nil,
		y = start_y,
		shot = false,
		type = "chooper",
		sprs = {3, 5},
		timer = 2,
		veloc = 2,
		dir = nil
	}
	enemy.dir = flr(rnd(2))
	if enemy.dir == 0 then
		enemy.x = -8
	else
		enemy.x = 136
	end
	return enemy
end

-- >8
-- update

function _update()
    tics = tics + 1
    update_player()
	update_shots()
	update_enemies()
end

function update_enemies()
	add(dbg, "update enemies:"..#enemies.list)
	for enemy in all(enemies.list) do
		if enemy.type == "chooper" then
			if enemy.dir == 0 then
				enemy.x = enemy.x + enemy.veloc
				if enemy.x > 136 then
					del(enemies.list, enemy)
				end
			else
				enemy.x = enemy.x - enemy.veloc
				if enemy.x < -8 then
					del(enemies.list, enemy)
				end
			end 
			add(dbg, "update/x:"..enemy.x.."/y:"..enemy.y.."/dir:"..enemy.dir)
		end
	end
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
        if (shot.y < -8) then del(player.shots, shot) end
    end
end

-- >8
-- draw

function _draw()
    cls()
    draw_terrain()
    draw_player()
	draw_enemies()
	draw_shots()
	print_debug()
end

function print_debug()
	local i = 1
	for debug_info in all(dbg) do
		print("dbg"..i..":"..debug_info, 0, i * 9, 8)
		i = i + 1
	end
	dbg = {}
end

function draw_enemies()
	add(dbg, "draw/enemies:"..#enemies.list)
	for enemy in all(enemies.list) do
		if enemy.type == "chooper" then
			local s = enemy.sprs[1]
			if enemy.x % enemy.timer == 0 then s = enemy.sprs[2] end
			if enemy.dir == 0 then
				spr(s, enemy.x, enemy.y)
			else 
				spr(s, enemy.x, enemy.y, 1, 1, true, false)
			end
		end
	end
end

function draw_shots()
    for shot in all(player.shots) do
        local s = cfg.shotspr[1]
        if shot.y % 4 == 0 then s = cfg.shotspr[2] end
        spr(s, shot.x, shot.y)
    end
end

function draw_player()
    local s = cfg.playspr[1]
    if player.x % 3 == 0 then s = cfg.playspr[2] end
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
