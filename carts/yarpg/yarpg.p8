pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- global vars

dr_idle={0,0,0,0}

me={
	name="player",
	x=0,
	y=0,
	mapx=1, -- x in tile map
	mapy=1, -- y in tile map
	vl=1, -- velocity
	tspr=0,
 dr={0,0,0,0},  -- ⬆️⬇️⬅️➡️
	sprs={52,53,54,55}, -- sprites
	cspr=1,	-- current sprite
	vspr=.8, -- incr chg sprite
	flipx=false,
	moving=false,
	pxmoved=0,
 lm={0,0},
 keys=0,
 gold=0
}

-- init player
me.x=me.mapx*8
me.y=me.mapy*8
me.lm={me.mapx,me.mapy}

-- init mobs
mobs={}
mobid=0

-- draw debug table
debug={}

printh("=-=-=-=-=-=-=")

-->8
-- player

function update_player()
	-- ⬆️⬇️⬅️➡️
	local move={0,0,0,0}
	local bpress=false
	
	if me.moving then
	 return
		
	elseif btn(⬆️)
		or btn(⬇️)
		or btn(⬅️)
		or btn(➡️) then
		bpress = true
		
		if btn(⬆️) then
			me.flipx=false
			move[1]=me.vl
	
		elseif btn(⬇️) then
			me.flipx=true
			move[2]=me.vl
	
		elseif btn(⬅️) then
			move[3]=me.vl
			me.flipx=true
	
		elseif btn(➡️) then
			move[4]=me.vl
			me.flipx=false
	
		end
		
		update_player_map(move)
		
	else
		me.dr=dr_idle
		bpress = false
		return
	end

end

--
-- evaluates player collision
-- with map tiles
--
function update_player_map(move)
	me.dr=move
	-- colision
	if map_collide(me,0) then
		if map_collide(me,1) then
			found_door(me.lm[1],me.lm[2])
		elseif map_collide(me,2) then
			found_key(me.lm[1],me.lm[2])
		elseif map_collide(me,3) then
			found_chest(me.lm[1],me.lm[2])
		else
			sfx(0)
		end
		me.dr=dr_empty
		me.moving=false
		me.pxmoved=0
	else
		calc_map(me)
	end
end

function found_door(mlx,mly)
	printh("found a door")
	local door=mget(mlx,mly)
	if door==2 then
	 mset(mlx,mly,3)
	 sfx(1)
	elseif door==18 then
	 mset(mlx,mly,19)
	 sfx(1)
	elseif me.keys>0 then
	 me.keys-=1
		if door==34 then
		 mset(mlx,mly,35)
		else
		 mset(mlx,mly,51)
		end
	 sfx(1)				
	else 
	 -- cant open
	 sfx(0)
	end
end

function found_key(mlx,mly)
	printh("found a key")
	local key=mget(mlx,mly)
	if key==36 then
		mset(mlx,mly,37)
		me.keys+=1
		sfx(3)
	else
	 -- cant do anything
	 sfx(0)
	end
end

function found_chest(mlx,mly)
	printh("found a chest!")
	local chest=mget(mlx,mly)
	if chest==38 then
		mset(mlx,mly,39)
		sfx(4)
	else 
	 -- already looted
	 sfx(0)
	end
end

-->8
-- common

-- change sprite
function anispr(s)
 local num=count(s.sprs)
	if s.tspr>1 then
		if s.cspr==num then 
			s.cspr=1
		else 
			s.cspr+=1
		end
		s.tspr=0
	else
		s.tspr+=s.vspr
	end
end

-- return if a move collid 
-- with a tile having the 
-- gicen flag
function map_collide(obj, flag)

	-- moving to tile x,y ...
	local x1=0    local y1=0
	
	if obj.dr[1]>0 then
		-- ⬆️
		x1,y1=obj.mapx,obj.mapy-1
	elseif obj.dr[2]>0 then
		-- ⬇️	
		x1,y1=obj.mapx,obj.mapy+1
	elseif obj.dr[3]>0 then
	 -- ⬅️
		x1,y1=obj.mapx-1,obj.mapy		
	elseif obj.dr[4]>=0 then
		-- ➡️
		x1,y1=obj.mapx+1,obj.mapy
	end
	
	-- it was looking to...
	obj.lm={x1,y1}

	--debug
	xy={x1=x1*8,y1=y1*8,x2=x1*8+7,y2=y1*8+7}
	add(debug,xy)
		
	return fget(mget(x1,y1),flag)

end

function moveall()
	if me.moving then
		calc_move(me)
		anispr(me)
		-- player steps
		sfx(2)
		for mob in all(mobs) do
			if mob.moving then
				calc_move(mob)
			 anispr(mob)
			end
		end
	end
end


function calc_map(ob)
	ob.moving=true
 ob.mapx+=ob.dr[4]
 ob.mapx-=ob.dr[3]
 ob.mapy+=ob.dr[2]
 ob.mapy-=ob.dr[1]
end

function calc_move(ob)
 -- update screen x,y
 ob.x+=ob.dr[4]
 ob.x-=ob.dr[3]
 ob.y+=ob.dr[2]
 ob.y-=ob.dr[1]
 ob.pxmoved+=ob.vl
 if ob.pxmoved==8 then
 	ob.moving=false
 	ob.pxmoved=0
		debug={}
 end
end
-->8
-- mobs

function spawmobs()
	if count(mobs)==0 then
		mob=newmob(4,10,"ooze")
		add(mobs,mob)
		printh("new mob! mapx,mapy="..mob.mapx..","..mob.mapy.." - id:"..mob.id)
	end
end

function update_mob()
	for mob in all(mobs) do
	 if not mob.moving then
		 mob.dr=think(mob)
		 if map_collide(mob,0) then
		  mob.blocked=true
--		  mob.dr=dr_idle
		 else
			 mob.blocked=false
		  mob.moving=true
		 	calc_map(mob)
		 end
		end
	end
end

function think(mob)
 printh("mob blocked:"..b2s(mob.blocked))
 local move=mob.dr
 printhmap("move>>",move)
 if mob.blocked then
  if move[4]==1 then
  	move[4]=0
  	move[3]=1
  	mob.flipx=true
  else
  	move[4]=1
  	move[3]=0
  	mob.flipx=false
  end
 end
 printhmap("move<<",move)
	return move
end

function newmob(mx,my,typ)
 mobid+=1
 mob={
		name=typ,
		x=mx*8,
		y=my*8,
		mapx=mx, -- x in tile map
		mapy=my, -- y in tile map
		vl=1, -- velocity
		tspr=0,
	 dr={0,0,0,0},  -- ⬆️⬇️⬅️➡️
		sprs={10,11,12,13}, -- sprites
		cspr=1,	-- current sprite
		vspr=.8, -- incr chg sprite
		flipx=false,
		moving=false,
		pxmoved=0,
	 lm={0,0},
	 blocked=true, -- blocked on creation
	 id=mobid
	}
	return mob
end
-->8
-- util

function b2s(bool)
	return bool and 'true' or 'false'
end

function printhmap(name,m)
 local i=1
 printh("name:"..name)
 for value in all(m) do
 	printh("->map["..i.."]="..value)
 	i+=1
 end
end
-->8
-- draw/update

function _draw()
	cls()
	mapdraw(0, 0, 0, 0, 16, 16)

	local cspr=me.sprs[me.cspr]
	spr(cspr,me.x,me.y,1,1,me.flipx,false)
	
	-- moba
	for mob in all(mobs) do
		cspr=mob.sprs[mob.cspr]
		spr(cspr,mob.x,mob.y,1,1,mob.flipx,false)
	end
	
	-- debug boxes
	for obj in all(debug) do
		rect(obj.x1,obj.y1,obj.x2,obj.y2,8)	
	end

end

--
-- pico-8 update callback
--
function _update()
	update_player()
	update_mob()
	moveall()
	spawmobs()
end

__gfx__
00000000555555550055550000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d55ddd5000d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000
000000005dd5d555000aa00000000000000000000000000000000000000000000000000000000000000440000000444000044000000444000000000000000000
000000005d55d5d5000d600000000000000000000000000000000000000000000000000000000000004444400004444400444440004444400000000000000000
00000000555555d5000d6000000000000000000000000000000000000000000000000000000000000947c74400947c740447c7440047c7400000000000000000
0000000055d55dd5000d600000000000000000000000000000000000000000000000000000000000094444440094444404444444044444400000000000000000
000000005ddd55d500046000000d6000000000000000000000000000000000000000000000000000944444440944444409444444444444440000000000000000
00000000555555550055550000555500000000000000000000000000000000000000000000000000999444990999999909999999999444990000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d55ddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005dd5d5555000000550000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055d555d55ddddad55d000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005555ddd556666a6556000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005dd555d55000000550000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550044440000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d5d55d50005500000000000000000000000000000000000099999900000000000000000000000000000000000000000000000000000000000000000
000000005d5dd5d5000990000000000000000aa00000000009444490055555500000000000000000000000000000000000000000000000000000000000000000
000000005555555500055000000000000aaaaa900000000009999990055555500000000000000000000000000000000000000000000000000000000000000000
000000005dd5d5d500055000000000000a0a0aa00000000009466490094664900000000000000000000000000000000000000000000000000000000000000000
000000005555d5550005500000000000000000000000000009444490094444900000000000000000000000000000000000000000000000000000000000000000
000000005d5dd5d50004500000055000044444400444444009944990099449900000000000000000000000000000000000000000000000000000000000000000
00000000555555550044440000444400045445400454454000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000002220000022200000222000002220000022200000777000000000000000000000000000000000000000000000000000
00000000000000000000000000000000022aaa00022aaa00022aaa00022aaa00022aaa000777770000000000000060000000000000aaa0000000600000000000
00000000000000004000000440000004008afc00008afc00008afc00008afc00008a8c000077770000000000000760000000a00000a0a0000007600000000000
00000000000000004555595445000004085fff00085fff00085fff00085fff0008288800077777000000000000076000000999000a000a000007600000000000
00000000000000004555595445000004085d6694085d6694805d6640085d6690082d89000777777000000000000760000000a0000a000a000007600000000000
0000000000000000400000044000000408066600800666008006660080066640800880400707700000000000000460000000000000a9a0000004600000000000
00000000000000000000000000000000800909008009900000090900080099000802200070077000000000000004000000000000000a00000004000000000000
00000000000000000000000000000000000404000004400000040400000044000004400000077000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000
00000000000000000000000000000000000000000000000000000000d1111111111111111111111dd1111111111111111111111dd111111d0000000000000000
00000000000000000000000000000000000000000000000000000000d1515551551555515551551dd1515551515551515551551dd151551d0000000000000000
00000000000000000000000000000000000000000000000000000000d1515111511151115151511dd1515111115151115151511dd151111d0000000000000000
00000000000000000000000000000000000000000000000000000000d1111151111111511111111dd1111151511111511111111dd111551d0000000000000000
00000000000000000000000000000000000000000000000000000000d1551551515515515115551dd1551551515515515155151dd151151d0000000000000000
00000000000000000000000000000000000000000000000000000000d1151511511515115515111dd1111111111111111111111dd155151d0000000000000000
00000000000000000000000000000000000000000000000000000000d111111d11111111d111151dddddddddddddddddddddddddd111111d0000000000000000
00000000000000000000000000000000000000000000000000000000d155151115155115d155111d15155115d155511515155115d111111d0000000000000000
00000000000000000000000000000000000000000000000000000000d1511511151111115151151d151111111111111115111111d151551d0000000000000000
00000000000000000000000000000000000000000000000000000000d1515551551555515151551d551555515515555155155551d111151d0000000000000000
00000000000000000000000000000000000000000000000000000000d1515111511151115551511d511151115111511151115111d155111d0000000000000000
00000000000000000000000000000000000000000000000000000000d1111151111111511111111d111111511111115111111151d151151d0000000000000000
00000000000000000000000000000000000000000000000000000000d1551551515515511555151d515515515155155151551551d155151d0000000000000000
00000000000000000000000000000000000000000000000000000000d1111111511515115511111d511515115115151111151511d111111d0000000000000000
00000000000000000000000000000000000000000000000000000000d115551155111511d115551d5511151d55111511d1111511d151551d0000000000000000
00000000000000000000000000000000000000000000000000000000d155151d11111115d511151d1515511d1515511d55515511d151551d0000000000000000
00000000000000000000000000000000000000000000000000000000d1511511151155111511551d151111111511111151111555d111151d0000000000000000
00000000000000000000000000000000000000000000000000000000d1515551551555511515551d551555515515555111511111d151551d0000000000000000
00000000000000000000000000000000000000000000000000000000d1515111511151111111111d511151115111511115511515d151111d0000000000000000
00000000000000000000000000000000000000000000000000000000d1111151111111515115151d111111511111115111115515d111551d0000000000000000
00000000000000000000000000000000000000000000000000000000d1551551515515515155151d515515515155155155511511d151151d0000000000000000
00000000000000000000000000000000000000000000000000000000d1111111511515111111111d511515115115151111551511d111111d0000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddd551115115511151dd111111ddddddddd0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ddd00000dd00000ddd000000000007777700077777000777770000000000000000000000000000000000000ddd0000333300003333000033330000000000
000dddd0000dddd000ddddd000000000070707000707070007070700055dd5500000000000000000000000d0000dddd000333500005333000033350000000000
000d77d0000ddddd00dddddd00000000007070000070700000707000055dd55000000000000dd00000dddddd00dddddd00333300003333000033330000000000
00dd7cdd00dd77dd0dddc7d0000000000007000077070770700700700dcddcd00000000000ddddd0dddddddd0ddddddd05ddd55035d5555035dd5dd300000000
0ddddddd00ddd7cd0dd77ddd00000000007770000077700007777700055dd550000000000dd7c7dddd7c7ddd0dddddd005dddd5305dddd5035ddddd300000000
dddddddd000ddddd0dddddd00000000007070770000700000007000005dddd50000000000ddddddd0ddddddddd7c7dd005dddd5535dddd5035ddddd300000000
ddddddd000dddddd0d00ddd000000000707770070777770007707700005dd50005005000dddddddd0dddddddddddddd0055dddd3033333300333333000000000
ddd000000ddddddd0000ddd000000000070007000000000070000070005dd50005005000dddddddd0ddddddd00dddd0003300330033003300330033000000000
50000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555550008580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555500055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555550505550500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50858050055555050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000050005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555855555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000588859995aaa55bb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000588859995aaa5bbb00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c5ddd5eee5fff50000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c5ddd5eee5fff50000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000511152225333544400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000511152225333544400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556665777588859900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556665777588859900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005aaa5bbb5ccc5ddd00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005aaa5bbb5ccc5ddd00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555bb555555dd00000000
__gff__
0001030200000000000000000000000000010302000000000000000000000000000103020505090900000000000000000000030200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001010101010101000000000000000000010101010101010000000000000000000101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0111110101010101111111110111110100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000200020000110000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000100010024010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010100210111010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000100010000110000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000200020000010000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2100000100210026010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101112132110111110000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000020000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000210000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000020000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111110101112101010000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101011111110112010111110101011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d500000000d5d5d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d5e8d5d5d5d5d5d5d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d5e8e8d5d500d5d5d5d5d5d5d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d50000d5e8e800000000dbd5d5d5d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d500e8e8e8d5d5d500d5d5d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5d5d5d5d5d5d5d5d5d5d5d5d5d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c800d5d500c80000000000d5d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300001407017050177300b4000c4000b4000a4000a4000b4000240000400024000340003400044000440005400054000540005400004000040000400014000140004400044000340024700034000240001400
00070000000002005025040280302c0202c0102c0102c0002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000263001620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000260503005030030300203002030000106001c6001c600116001670011600126002d700126001360014600156001560000000000000000000000000000000000000000000000000000000000000000000
000700001c0501f050210302102021010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
