pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
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

    tilemap = {
        x = 0,
        y = 0,
        xsize = 16,
        ysize = 16
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
    --draw_terrain()
    draw_map()
    draw_player()
	draw_enemies()
    draw_shots()
    draw_explosions()
	print_debug()
end

function draw_map()
    map(tilemap.x, tilemap.y, 1, 1, tilemap.xsize, tilemap.ysize)
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

__gfx__
01230000008008000080080000000000000000000000000000000000000000000000000000000000000000000055660000665500000000000000000000000000
45670000006006000060060000000000677677607677767000000000dd000000dd0000000000000000000000cc55600000065500000000000000000000000000
89ab0700006006000060060000000000000d0000000d00000000000063d0000063d000000000000000000000cc556000000655cc000000000000000000000000
cdef70000055550000555500000000006ddddccc7ddddccc00000000933ddcc0a33ddcc00000000000000000cc556000000655cc000000000000000000000000
000770000559955005599550000000005d3333cc5d3333cc0000000056d333dd96d333dd000000000000000011556000000655cc000000000000000000000000
0070070017767761167767710000000000d333d000d333d0000000009333dd00a333dd0000000000000000001155600000065511000000000000000000000000
0000000065155157751551560000000006d6060006d6060000000000633d0000633d000000000000000000006666666666666666000000000000000000000000
00000000167767711776776100000000006666600066666000000000ddd00000ddd0000000000000000000006666666666666666000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444444444444000000000000000000000000
00000000008008000080080000000000000000000000000000000000000000000000000000000000000000003445344334453444000000000000000000000000
00000000008008000080080000000000000000000000000000000000002000000010000000000000000000005334354354443334000000000000000000000000
0000000000a00a0000a00a0000000000000000000000000000000000000280000001c00000000000000000003344344333443434000000000000000000000000
000000000090090000a00a000000000000000000000000000000000000082000000c100000000000000000004443344444433444000000000000000000000000
00000000000000000090090000000000000000000000000000000000000002000000010000000000000000004344534443445344000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004344534443445344000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444444444444000000000000000000000000
00000000000000000222222000490000000000000929929000000000000000000000000000000000000000000000000000000000000000000000000000000000
0656565656565600001aa10000b33300000000000222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
06565656565656000016610000330000000000000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000
0656565656565600001aa100b334300000000000001aa10000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111000011110003433bb0000000000016610000000000000000000000000000000000000000000000000000000000000000000000000000000000
01aa1aa1aa1aa100001111003334300b00000000001aa10000000000000000000000000000000000000000000000000000000000000000000000000000000000
01661661661661b0001aa19003433330000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
01aa1aa1aa1aa130331aa1900b943000000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555555550000000550000000012222100000000000000000000000000888000080008000000000000000000000000000011100001000100c
3445344543544354453d45440000005445000000011aa1100000000000000000008000008000800000800890000000000000000000100000100010c000c00100
54443544435443544534453400000554455000000116611000000000008000000898000080908000089808000000000000c0000001c1000010c010000c1c0100
5444344443444344443455440000534433350000011aa11000000000000000000080000080008880008008000000000000000000001000001000111000c00100
44433444443443444444354400054344444450000111111000000000000000000000080008880008800080000000000000000000000001000111000110001000
43445344444433444434455400543345443445008111111d00000000000008000000898000080908088808800000000000000c0000001c1000010c01011100c0
43445344444434344534d434054434344534d450811aa11d00000000000000000000080000080008000008980000000000000000000001000001000100000c1c
4444444444444444444444445445444444444445811aa11d0000000000000000000000000000888000900080000000000000000000000000c0001110c00000c0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800008008000080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600005005000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00500500006006000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00588500006886000068860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066cc660055cc550011cc11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6cc88cc65cc88cc51cc88cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660055555500111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010001000101010000010100000000000000000000000000000101000000040404040004000000000000000000000101010303040000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002500000000000000000020222100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000035002300230000003332323230303400000023000023000022202100000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30303231313031313232321b1b1c1c1c1c1b3030313231303231303130323030320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000006070310700a0700c0703f0700f070100701207013070150703307016070170701b07009070200703707009070240703a0702807024070060702607028070030703d0702807005070270703d07004070
