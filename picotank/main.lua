-- init
-- C:\Program Files (x86)\PICO-8\pico8.exe
-- add(dbg, "update enemies:"..#enemies.list)
-- explosion code from user: https://www.lexaloffle.com/bbs/?uid=45877
-- >> https://www.lexaloffle.com/bbs/?tid=39204&tkey=grSK2HnDKgU0eUp7XSe2

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
        explspr = {55, 56, 57, 58},
        shot_timer = 5,
        max_shots = 4,
        shot_veloc = 2
    }

    player = {
        spr = {1, 2}, 
        x = 0, 
        y = 14 * 8, 
        accel = 1, 
        shots = {}
    }

    enemies = {
        list = {},
        minx = -8,
        maxx = 136,
        miny = 0,
        maxy = 80
    }
    
    ex_emitters={}

    local lvl = genlevel()
	add(cfg.levels, lvl)
	
    add(enemies.list, create_enemy())
    add(enemies.list, create_enemy())
end

-- >8
-- common

function add_exp(x,y)
    local e={
        parts={},
        x=x,
        y=y,
        offset={x=cos(rnd())*2,y=sin(rnd())*2},
        age=0,
        maxage=25
    }
    for i=0,5 do
        add_exp_part(e)
    end
    add(ex_emitters,e)
end

function add_exp_part(e)
        local p={
            x=e.x+(cos(rnd())*5),
            y=e.y+(sin(rnd())*5),
            rad=0,
            age=0,
            maxage=5+rnd(10),
            c=rnd({15,8,9,10})
        }
        add(e.parts,p)
end

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
		sprs = {4, 5},
		timer = 3,
        veloc = 1,
        yveloc = 0,
        dir = nil,
        dead = false,
        dead_tics = 0,
        explspr = 1,
        max_tics = 20 -- how much time it takes to disapear.
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
    update_colision()
    update_level()
    update_explosions()
end

function update_colision()
    for shot in all(player.shots) do
        for enemy in all(enemies.list) do
            local htbox_x1 = shot.x
            local htbox_x2 = shot.x + 7
            local htbox_y1 = shot.y
            --local htbox_y2 = shot.y 

            -- x1 is inside enemy box
            if htbox_x1 >= enemy.x and htbox_x1 <= enemy.x + 7 then
                if htbox_y1 <= enemy.y + 7 and htbox_y1 >= enemy.y then
                    enemy.dead = true
                    del(player.shots, shot)
                end
            end
            -- x2 is inside enemy box
            if htbox_x2 >= enemy.x and htbox_x2 <= enemy.x + 7 then
                if htbox_y1 <= enemy.y + 7 and htbox_y1 >= enemy.y then
                    enemy.dead = true
                    del(player.shots, shot)
                end
            end
        end
    end
end

function update_level()
    if #enemies.list == 0 then
        add(enemies.list, create_enemy())
        add(enemies.list, create_enemy())
    end
end

function update_enemies()
    for enemy in all(enemies.list) do
        if enemy.dead and enemy.dead_tics < enemy.max_tics then
            enemy.dead_tics = enemy.dead_tics + 1
            if enemy.yveloc == 0 then
                enemy.yveloc = 1
            else
                enemy.yveloc = enemy.yveloc * 1.1
            end
            if enemy.yveloc > 5 then
                enemy.yveloc = 5
            end
            enemy.y = enemy.y + enemy.yveloc
            if enemy.y > cfg.lvl_ypos - 8 then
                enemy.y = cfg.lvl_ypos - 8
                enemy.dead_tics = enemy.max_tics
            end
        elseif enemy.dead_tics == enemy.max_tics or enemy.y == cfg.lvl_ypos - 8 then
            del(enemies.list, enemy)
            add_exp(enemy.x, enemy.y)
        end
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

function update_explosions()
    for i=#ex_emitters,1,-1 do
        local e=ex_emitters[i]
        add_exp_part(e)
        for ip=#e.parts,1,-1 do
            local p=e.parts[ip]
            p.rad+=1
            p.age+=1
            if p.age+5>p.maxage then
                p.c=5
            end
            if p.age>p.maxage then
                del(e.parts,p)
            end       
        end
        e.age+=1
        if e.age>e.maxage then
            del(ex_emitters,e)
        end
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
    draw_explosions()
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
        if enemy.dead then
            if enemy.dead_tics % 2 == 0 then
                if enemy.explspr == 5 then
                    enemy.explspr = 1
                else
                    enemy.explspr = enemy.explspr + 1
                end
            end
            local s = cfg.explspr[enemy.explspr]
            otspr(s, 0, enemy.x, enemy.y, 1, 1, false, false)
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
    otspr(s, 0, player.x, player.y, 1, 1, false, false)
end

function draw_terrain()
    local x = 0
    local tiles = cfg.levels[1]
    for t in all(tiles) do
        spr(t, x, cfg.lvl_ypos)
        x = x + 8
    end
end

-- draws a sprite to the screen with an outline of the specified colour
--
function otspr(n,col_outline,x,y,w,h,flip_x,flip_y)
	-- reset palette to black
	for c=1,15 do
		pal(c,col_outline)
	end
	-- draw outline
	for xx=-1,1 do
		for yy=-1,1 do
			spr(n,x+xx,y+yy,w,h,flip_x,flip_y)
		end
	end
	-- reset palette
	pal()
	-- draw final sprite
	spr(n,x,y,w,h,flip_x,flip_y)	
end

function draw_explosions()
    for e in all(ex_emitters) do
        for p in all(e.parts) do
            circfill(p.x,p.y,p.rad,p.c)
            circfill(p.x+e.offset.x,p.y+e.offset.y,p.rad-3,0)                                       
            circ(p.x+(cos(rnd())*5),p.y+(sin(rnd())*5),1,0)                                                       
        end
    end
end