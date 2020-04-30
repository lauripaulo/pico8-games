pico-8 cartridge // http://www.pico-8.com
version 22
__lua__
-- global vars

function _init()
	me={
		name="player",
		x=0,
		y=0,
		mapx=1, -- x in tile map
		mapy=1, -- y in tile map
		tomx=1, -- x want to go
		tomy=1, -- y want to go
		sprmx=1,
		sprmy=1,
		tspr=0,
		sprs={52,53,54,55}, -- sprites
		cspr=1,	-- current sprite
		vspr=.8, -- incr chg sprite
		flipx=false,
		moving=false,
		pxmoved=0,
	 keys=0,
	 gold=0,
	 bpress=false,
	 level=1,
	 atk=1,
	 def=1,
	 maxhp=3,
	 hp=3
	}
	
	state={
	 frames=0,
		spawmobs=true,
	 update_mobs=false,
	 resolve_collisions=false,
	 moveinmap=false,
	 combat=false,
	 level=1,
	 gameover=false,
	 gamestart=true
	}
		
	-- init player
	me.x=me.mapx*8
	me.y=me.mapy*8
	
	-- init mobs
	mobs={}
	mobid=0
	
	directions={
		{ 1,0},{0,-1},
		{-1,0},{0, 1}
	}
	
	-- draw debug table
	debug={}
	panel={}
	msgs={}
	
	printh("=-=-=-=-=-=-=")
end
-->8
-- player

function update_player()
	
	if me.moving then
	 return
		
	elseif btn(⬆️)
		or btn(⬇️)
		or btn(⬅️)
		or btn(➡️) then
		me.bpress = true
		
	 state.update_mobs=true
	 state.resolve_collisions=true
	 state.moveinmap=true
		
		if btn(⬆️) then
			me.flipx=false
			me.tomy-=1
		elseif btn(⬇️) then
			me.flipx=true
			me.tomy+=1
		elseif btn(⬅️) then
			me.flipx=true
			me.tomx-=1
		elseif btn(➡️) then
			me.flipx=false
			me.tomx+=1
		end		
		
	else
		me.bpress = false
	end
	
	return bpress
end

--
-- evaluates player collision
-- with map tiles
--
function eval_playermove()
 local mobhit,mob=hit_mob(me)
 printh("mobhit:"..b2s(mobhit))
 
	if map_collide(me,0) then
		if map_collide(me,1) then
			found_door(me.tomx,me.tomy)
		elseif map_collide(me,2) then
			found_key(me.tomx,me.tomy)
		elseif map_collide(me,3) then
			found_chest(me.tomx,me.tomy)
		else
			sfx(0)
		end
		me.tomx=me.mapx
		me.tomy=me.mapy
	elseif mobhit then
	 printh("-->mob:"..mob.id)
	 sfx(5)
		me.tomx=me.mapx
		me.tomy=me.mapy
		-- kill mob
		del(mobs,mob)
		state.combat=true
	else
		-- player steps
		sfx(2)
	end
end

function found_door(mlx,mly)
	local door=mget(mlx,mly)
	if door==219 then
		addmsg("found a door",.5)
	 mset(mlx,mly,220)
	 sfx(1)
	elseif me.keys>0 then
		if door==224 then
			addmsg("door open!",.5)
		 me.keys-=1
		 mset(mlx,mly,225)
		end
	 sfx(1)				
	else 
	 -- cant open
		addmsg("door locked!",.5)
	 sfx(0)
	end
end

function found_key(mlx,mly)
	addmsg("found key.",.5)
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
	local chest=mget(mlx,mly)
	if chest==38 then
		mset(mlx,mly,39)
		local gold=roll_gold()
		me.gold+=gold
		addmsg("found "..gold.." coins.",.5)
		sfx(4)
	else 
	 -- already looted
	 sfx(0)
	end
end

function roll_gold()
 return me.level*d6(2)
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

function map_collide(obj, flag)
	-- moving to tile x,y ...
	local x1,y1=obj.tomx,obj.tomy	

	--debug
	xy={x1=x1*8,y1=y1*8,x2=x1*8+7,y2=y1*8+7}
	add(debug,xy)
		
	return fget(mget(x1,y1),flag)

end

function movesprs()
	if me.moving then
		calc_move(me)
		anispr(me)
		for mob in all(mobs) do
			calc_move(mob)
		 anispr(mob)
		end
	end
end

function calc_map(ob)
	ob.moving=true
 ob.mapx=ob.tomx
 ob.mapy=ob.tomy
end

function calc_move(ob) 
 if ob.sprmx<ob.mapx then
 	ob.x+=1
 elseif ob.sprmx>ob.mapx then
  ob.x-=1
 end
 if ob.sprmy<ob.mapy then
 	ob.y+=1
 elseif ob.sprmy>ob.mapy then
  ob.y-=1
 end
 ob.pxmoved+=1
 if ob.pxmoved==8 then
 	ob.moving=false
 	ob.pxmoved=0
		debug={}
	 state.update_mobs=false
	 state.resolve_collisions=false
	 state.moveinmap=false
 end
end

function resolve_collisions()
 if state.resolve_collisions then
		eval_playermove()
		state.resolve_collisions=false
	end
end

function moveinmap()
	if state.moveinmap then
	 -- update screen x,y
	 me.sprmx=me.x/8 -- map loc.
	 me.sprmy=me.y/8 -- map loc.
		calc_map(me)
		for mob in all(mobs) do
		 mob.sprmx=mob.x/8 -- map loc.
		 mob.sprmy=mob.y/8 -- map loc.
			calc_map(mob)
		end
		state.moveinmap=false
	end
end

function d6(num)
 local value=0
 for i=1,num do
  value+=flr(rnd(6))+1
 end
 return value
end

function roll_atk(obj)
 return d6(2)+obj.level+obj.atk
end

function roll_def(obj)
 return d6(2)+obj.level+obj.def
end
-->8
-- mobs

function update_mobs()
	if state.update_mobs then
		for mob in all(mobs) do
		 mob.tomx=mob.mapx
		 mob.tomy=mob.mapy
		 think(mob)
		 if mob_hit(mob,me) then
		  mob.tomx=mob.mapx
		  mob.tomy=mob.mapy
		  me.hp-=1
		  state.combat=true
		  sfx(6)
		 end
		end
		state.update_mobs=false
	end
end

function spawmobs()
	if state.spawmobs then
		mob=newmob(7,1,"skeleton")
		add(mobs,mob)
		mob=newmob(4,10,"ooze")
		add(mobs,mob)
		mob=newmob(14,6,"zombie")
		add(mobs,mob)
		state.spawmobs=false
	end
end

function hit_mob(obj)
	for mob in all(mobs) do
		if mob.mapx==obj.tomx then
			if mob.mapy==obj.tomy then
			 printh("hit mob!! ->"..mob.name)
			 return true,mob
			end
		end
	end
	return false,nil
end

function mob_hit(mob,obj)
 printh(mob.name)
	if mob.tomx==obj.tomx then
		if mob.tomy==obj.tomy then
		 printh("mob hit!! ->"..mob.name)
		 return true
		end
	end
	return false
end

function think(mob)
	printh("!!!!!!!!!!!!!!!")
	printh("mob:"..mob.name)
	for ds in all(directions) do
		mob.tomx=ds[1]+mob.mapx
		mob.tomy=ds[2]+mob.mapy
		printh("mapx,mapy"..mob.mapx..","..mob.mapy)
		printh("tomx:"..mob.tomx)
		printh("tomy:"..mob.tomy)
		if map_collide(mob,0) then
			printh("collide: true")
			mob.tomx=mob.mapx
			mob.tomy=mob.mapy
		else
			printh("collide: false")
			local decision=flr(rnd(3))
			printh("decision:"..decision)
			if decision==0 then
				break
			else
				mob.tomx=mob.mapx
				mob.tomy=mob.mapy
			end
		end
	end
end

function newmob(mx,my,typ)
 mobid+=1
 mob={
		x=mx*8,
		y=my*8,
		mapx=mx,
		mapy=my,
		tomx=mx,
		tomy=my,
		sprmx=mx,
		sprmy=my,
		tspr=0,
		flipx=false,
		moving=false,
		pxmoved=0,
	 id=mobid
	}
	if typ=="ooze" then
		mob.sprs={201,202,203}
		mob.cspr=1
		mob.vspr=.2
		mob.name="green ooze"
		mob.level=3
		mob.hp=5
	elseif typ=="zombie" then
		mob.sprs={204,205,206}
		mob.cspr=1
		mob.vspr=.2
		mob.name="zombie"
		mob.level=3
		mob.hp=5
	else
		mob.sprs={196,197,198}
		mob.cspr=1
		mob.vspr=.2
		mob.name="skeleton"
		mob.level=2
		mob.hp=3
	end
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

function addmsg(_txt,_secs)
	add(msgs,
		{
		 txt=_txt,
			duration=_secs*60,
			frames=0
		}
	)
end
-->8
-- draw/update

function _update()
 state.frames+=1
	spawmobs()
 update_player()
 resolve_collisions()
 update_mobs()
 moveinmap()
 movesprs()
	update_messages()
end

function _draw()
	cls()
	draw_map()
 draw_player()
	draw_mobs()	
	draw_debug()
	draw_info()	
	draw_messages()
end

function update_messages()
 for ms in all(msgs) do
  printh("update msg:")
  printh("->txt:"..ms.txt)
  printh("->frames:"..ms.frames)
  printh("->duration:"..ms.duration)
 	if ms.frames == 
 				ms.duration then
	  printh(">> removed txt:"..ms.txt)
 	 del(msgs,ms)
 	 ms=nil
 	else
	 	ms.frames+=1
	 end
 end
end

function draw_messages()
 if #msgs==0 then 
 	return
 end
 local sz=(#msgs-1)*8
	local ys=12*8-sz-3
	local ye=13*8-3
	rectfill(5,ys+1,125,ye+1,0)
	rectfill(4,ys,124,ye,7)

 for i=1,#msgs do
 	local txt=msgs[i].txt
		color(8)
		cursor(8,ys+2+(i-1)*8)
		print(txt)
 end
end

function draw_map()
	mapdraw(0, 0, 0, 0, 16, 13)
end

function draw_debug()
	-- debug boxes
	for obj in all(debug) do
		rect(obj.x1,obj.y1,obj.x2,obj.y2,8)	
	end
end

function draw_mobs()
	-- moba
	for mob in all(mobs) do
		anispr(mob)
		cspr=mob.sprs[mob.cspr]
		spr(cspr,mob.x,mob.y,1,1,mob.flipx,false)
	end
end

function draw_player()
	local cspr=me.sprs[me.cspr]
	spr(cspr,me.x,me.y,1,1,me.flipx,false)
end

function draw_info()
 -- panel
	spr(5,0,13*8,1,1)
	spr(5,0,14*8,1,1,false,true)
	spr(5,15*8,13*8,1,1,true,false)
	spr(5,15*8,14*8,1,1,true,true)
	for i= 1,14 do
			spr(6,i*8,13*8,1,1,false,false)
			spr(6,i*8,14*8,1,1,false,true)
	end
	
	-- hit points
	color(10)
	cursor(4,(13*8)+2)
	print("life: ")
	for l=1,me.maxhp do
	 if l<=me.hp then
	 	color(8)	
		else
	 	color(6)	
		end
		cursor(16+l*8,(13*8)+2)
		print("♥")
	end
	
	-- gold	
	color(7)
	cursor(1+8*11,(13*8)+2)
	print("gold:"..me.gold)

 -- stats
	color(10)
	cursor(4,(14*8)+1)
	print("level:"..me.level.." atk:"..me.atk.." def:"..me.def)

 -- map
	cursor(1+8*13,(14*8)+1)
	print("("..me.mapx..","..me.mapy..")")	

 -- frames
	color(11)
	cursor(1+8*11,(14*8)+1)	
	print(state.frames)
	if state.frames>999 then
		state.frames=0
	end

end


__gfx__
00000000555555550000000000000000000000000666666666666666000000000000000000000000000000000000000000000000000000000000000000000000
000000005d55ddd50000000000000000000000006650000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005dd5d5550000000000000000000000006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d55d5d50000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555d50000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055d55dd50000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005ddd55d50000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d55ddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005dd5d5550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055d555d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005555ddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005dd555d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d555dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005d5d55d50000000000000000000000000000000000000000099999900000000000000000000000000000000000000000000000000000000000000000
000000005d5dd5d5000000000000000000000aa00000000009444490055555500000000000000000000000000000000000000000000000000000000000000000
000000005555555500000000000000000aaaaa900000000009999990055555500000000000000000000000000000000000000000000000000000000000000000
000000005dd5d5d500000000000000000a0a0aa00000000009466490094664900000000000000000000000000000000000000000000000000000000000000000
000000005555d5550000000000000000000000000000000009444490094444900000000000000000000000000000000000000000000000000000000000000000
000000005d5dd5d50000000000000000044444400444444009944990099449900000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000045445400454454000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000222000002220000022200000222000002220000000000000777000000000000000000000000000000000000000000000000000
000000000000000000000000022aaa00022aaa00022aaa00022aaa00022aaa00002220000777770000000000000060000000000000aaa0000000600000000000
000000000000000000000000008afc00008afc00008afc00008afc00008afc00022aaa000077770000000000000760000000a00000a0a0000007600000000000
000000000000000000000000085fff00085fff00085fff00085fff00085fff00008afc00077777000000000000076000000999000a000a000007600000000000
0000000000000000000000000859469408594640085946408054664008596690085fff000777777000000000000760000000a0000a000a000007600000000000
0000000000000000000000000806660008066600800666008006660080046640085466400707700000000000000460000000000000a9a0000004600000000000
00000000000000000000000080090900800909008009900000090900080099000809090070077000000000000004000000000000000a00000004000000000000
00000000000000000000000000040400000404000004400000040400000044000804040000077000000000000000000000000000000000000000000000000000
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
0000ddd00000dd00000ddd000000000007777700077777000777770007777700000000000000000000000000000ddd0000333300003333000033330000000000
000dddd0000dddd000ddddd000000000070707000707070007070700070707000000000000000000000000d0000dddd000333500005333000033350000000000
000d77d0000ddddd00dddddd000000000070700000707000007070000070700000000000000dd00000dddddd00dddddd00333300003333000033330000000000
00dd7cdd00dd77dd0dddc7d000000000000700007707077070070070000700000000000000ddddd0dddddddd0ddddddd05ddd55035d5555035dd5dd300000000
0ddddddd00ddd7cd0dd77ddd0000000000777000007770000777770000777000000000000dd7c7dddd7c7ddd0dddddd005dddd5305dddd5035ddddd300000000
dddddddd000ddddd0dddddd00000000007070770000700000007000007070770000080000ddddddd0ddddddddd7c7dd005dddd5535dddd5035ddddd300000000
ddddddd000dddddd0d00ddd0000000007077700000777000077077007077700000008000dddddddd0dddddddddddddd0055dddd3033333300333333000000000
ddd000000ddddddd0000ddd0000000000700070000707000070000700700070000008000dddddddd0ddddddd00dddd0003300330033003300330033000000000
500000500000000000000000000000007bbb7bb00000000000000000000000000000000006000060060000600000000000000000000000000000000000000000
0500050500000000000bbbb000000000bbbbbbb00000000000000000dd00dd000000000006000060006006000449944004000000000000000000000000000000
555555500085800000b7cc7bb7b0000bbb7cc7b70000000045454545dddddd000dd00dd005555550555555550449944009000000000000000000000000000000
05555500055555000bbbbbbb7bbb0bb77bbbbbb00000000055555555d0dd0d000dddddd005455450054554500999999004000000000000000000000000000000
5555555050555050b7bbbbbb07b7cc7b00b7b7b700000000d5d5d5d5dddddd000d0dd0d055555555555555550466944006000000000000000000000000000000
50858050055555057bbbbb7b0bbbbbbb0077000000000000000000000dddd0000dddddd005555550055555500499994004000000000000000000000000000000
0000000550505050bb7bbbbb00bb7b7b0000000000000000000000000d00d000000dd00000555500005005000949949009000000000000000000000000000000
00000000050005007bbb7bb700b7b7b000000000000000000000000000000000000dd00005000050050000500949949004000000000000000000000000000000
00000000000000009000900000000000000000000000000000000000000000000000000000000000000000000000000000000000555855555555555500000000
055aa550050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000588859995aaa55bb00000000
055aa5500a0000000900090000000000000000000000000000000000000000000000000000000000000000000000000000000000588859995aaa5bbb00000000
0aaaaaa0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
0566a550060000000090009000000000000000000000000000000000000000000000000000000000000000000000000000000000c5ddd5eee5fff50000000000
05aaaa50050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c5ddd5eee5fff50000000000
0a5aa5a00a0000000009000900000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
0a5aa5a0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000511152225333544400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000511152225333544400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556665777588859900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556665777588859900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005aaa5bbb5ccc5ddd00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005aaa5bbb5ccc5ddd00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555bb555555dd00000000
__gff__
0001000000000000000000000000000000010000000000000000000000000000000100000500090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001010101010101000000000000000000010101010101010000000000000000000101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003020000000302000000000000000000000000000000000000000000000000000000000000
__map__
0111110101010101111101110111110100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010000db00db0000110000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000100010024010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010100210111010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000100010000110000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010000db00db0000010000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
210000010021002601000000000000db00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01011121e0110111110000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000db0000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100e2e2e2e2e200210000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000000000000db0000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0121010121112101010000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111212111112111010101db2111210100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300001407017050177300b4000c4000b4000a4000a4000b4000240000400024000340003400044000440005400054000540005400004000040000400014000140004400044000340024700034000240001400
00070000000002005025040280302c0202c0102c0102c0002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000126101b600196002260018600296002060022600316002760038600256003b6003c600376002e6002060021600246001660028600106000c6000e6000000000000000001160000000000000000000000
00080000260503005030030300203002030000106001c6001c600116001670011600126002d700126001360014600156001560000000000000000000000000000000000000000000000000000000000000000000
000700001c0501f050210302102021010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000013670176701b6601e66022650276502b650286502664024640216401f6401c6301a6301762014620126200f6200d620096200961008610056100461003610016100061028600236001f600186000d600
000300000405009050090300a0300a0200a0100a010090000a0000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
