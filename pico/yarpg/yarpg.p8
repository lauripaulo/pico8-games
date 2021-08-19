pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- game states

function _init()
	menu_init()
end

function menu_init()
	_draw = menu_draw
	_update = menu_update
	mdelay=30
	starprs=false
	music(0)
end

function gameover_init()
	_draw = gameover_draw
	_update = gameover_update
	mdelay=60
end

function game_init()
	-- state machine
	_init = game_init
	_draw = game_draw
	_update = game_update
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
		atack=2,
		defense=2,
		maxhp=3,
		hp=3
	}
	
	state={
		frames=0,
		spawmobs=true,
		update_mobs=false,
		resolve_collisions=false,
		moveinmap=false,
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
	
	-- events
	msgs={}
	hits={}
	flts={}
	still={}
	
	-- sprite animations
	mspr={23,24,25,26}
	dspr={11,12,13,14}
	hspr={27,28,29,30}
	
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
			findpath(me.mapx,me.mapy,7,7,20)
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
		me.tomx=me.mapx
		me.tomy=me.mapy
		attack(me,mob)
	else
		-- player steps
		sfx(2)
	end
end

function found_door(mlx,mly)
	local door=mget(mlx,mly)
	if door==219 then
		addmsg("found a door",.5,0)
		mset(mlx,mly,220)
		sfx(1)
	elseif me.keys>0 then
		if door==224 then
			addmsg("door open!",.5,0)
			me.keys-=1
			mset(mlx,mly,225)
		end
		sfx(1)				
	else 
		-- cant open
		addmsg("door locked!",.5,0)
		sfx(0)
	end
end

function found_key(mlx,mly)
	addmsg("found key.",.5,0)
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
		addmsg("found "..gold.." coins.",.5,11)
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

-- path finding
pathstk={}

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

function addhit(_ob,_sprs)
	printh("addhit:".._ob.name.." x:".._ob.x.." y:".._ob.y)
	add(hits,
		{
			ob=_ob,
			cspr=1, -- none
			dur=0,
			sprs=_sprs
		}
	)
end

function addmsg(_txt,_secs,_colr)
	add(msgs,
		{
			txt=_txt,
			duration=_secs*60,
			frames=0,
			colr=_colr
		}
	)
end

function addflt(obj,_txt,_colr)
	add(flts,
		{
			txt=_txt,
			frames=0,
			colr=_colr,
			tgr=obj.y-10,
			x=obj.x,
			y=obj.y
		}
	)
end

function addstill(_x,_y,_sprn)
	add(still,
			{
				x=_x,
				y=_y,
				sprn=_sprn
			}
	)
end

function attack(obj,target)
	local t=1
	local atk=rollatk(obj)
	local def=rolldef(target)
	local result=atk-def
	local colr,sprn=10,44
	if result>=0 then
		if target==me then 
			colr=8
			sprn=43
		end
		addflt(target,"-"..obj.level,colr)
		addmsg(obj.name.." attack hit!",t,8)
		target.hp-=obj.level
		addhit(target,dspr)
		if target.hp<=0 then
			sfx(6)
			addstill(target.x,target.y,sprn)
		else
			sfx(5)
			addhit(target,hspr)
		end
	else
		addhit(target,mspr)
		addmsg(obj.name.." attack miss",t,3)
		sfx(7)
	end
end

function d6(num)
	local value=0
	for i=1,num do
		value+=flr(rnd(6))+1
	end
	return value
end

function rollatk(obj)
	return d6(2)+obj.level+obj.atack
end

function rolldef(obj)
	return d6(2)+obj.level+obj.defense
end

function newcell(_x,_y,_from)
	return {
		x=_x,
		y=_y,
		from=_from
	}
end

-- ob: source obj
-- tg: target obj
-- depth: how deep to search
function findpath(ox,oy,tx,ty,depth)
	printh()
	printh("findpath("..ox..","..oy..","..tx..","..ty..","..depth..")")
	local vist=0
	local minfo={}
	local cells,cur,fnd=0,nil,false
	local start=newcell(ox,oy,nil)
	equeue(minfo,start)
	while vist<=depth do
		vist+=1
		cur=dqueue(minfo)
		printh("->inspect cur: ("..cur.x..","..cur.y..") - visit: "..vist)
		fnd=cur.x==tx and cur.y==ty
		if fnd then
			printh("->found! cur==tg")
			break
		end
		local cs=mvcells(cur.x,cur.y)
		printh("->found #"..#cs.." cells")
		for p in all(cs) do
			local nc=newcell(
				p.x,p.y,curr
			)
			equeue(minfo,nc)
			printh("added to m info->p.x:"..p.x.." p.y:"..p.y)
		end
		printh("->minfo #="..#minfo)
	end
	printh("->search ends.")
	local path={} 
	local i=0
	while curr do
		printh(">>step:"..i.." ("..curr.x..","..curr.y..")")
		curr=curr.from
		i+=1
	end
end

function mvcells(mx,my)
	printh("getmovcells("..mx..","..my..")")
	local cs={}
	for ds in all(directions) do
		local xx=ds[1]+mx
		local yy=ds[2]+my
		printh("->cell ("..xx..","..yy..")")
		if xx>0 and yy>0 then
			if not fget(mget(xx,yy),0) then
				add(cs,{x=xx,y=yy})
				printh("->can move to ("..xx..","..yy..")")
			end
		end
	end
	printh("end mvcells()") 
	return cs
end

--
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
-->8
-- mobs

function update_mobs()
	if state.update_mobs then
		for mob in all(mobs) do
			if mob.hp<=0 then
				del(mobs,mob)
			else
				mob.tomx=mob.mapx
				mob.tomy=mob.mapy
				think(mob)
				if mob_hit(mob,me) then
					mob.tomx=mob.mapx
					mob.tomy=mob.mapy
					attack(mob,me)
				end
			end
		end
		state.update_mobs=false
	end
end

function spawmobs()
	if state.spawmobs then
		mob=newmob(7,1,"skeleton")
		add(mobs,mob)
		addflt(mob," !",10)
		mob=newmob(4,10,"ooze")
		add(mobs,mob)
		addflt(mob," !",10)
		mob=newmob(14,6,"zombie")
		add(mobs,mob)
		addflt(mob," !",10)
		state.spawmobs=false
	end
end

function hit_mob(obj)
	for mob in all(mobs) do
		if mob.mapx==obj.tomx then
			if mob.mapy==obj.tomy then
				return true,mob
			end
		end
	end
	return false,nil
end

function mob_hit(mob,obj)
	if mob.tomx==obj.tomx then
		if mob.tomy==obj.tomy then
			return true
		end
	end
	return false
end

function think(mob)
	for ds in all(directions) do
		mob.tomx=ds[1]+mob.mapx
		mob.tomy=ds[2]+mob.mapy
		if map_collide(mob,0) then
			mob.tomx=mob.mapx
			mob.tomy=mob.mapy
		else
			local decision=flr(rnd(3))
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
		mob.level=1
		mob.hp=3
		mob.atack=1
		mob.defense=2
	elseif typ=="zombie" then
		mob.sprs={204,205,206}
		mob.cspr=1
		mob.vspr=.2
		mob.name="zombie"
		mob.level=2
		mob.hp=2
		mob.atack=1
		mob.defense=3
	else
		mob.sprs={196,197,198}
		mob.cspr=1
		mob.vspr=.2
		mob.name="skeleton"
		mob.level=1
		mob.hp=1
		mob.atack=1
		mob.defense=2
	end
	return mob
end
-->8
-- update

function menu_update()
	if btn(❎) then
		startprs=true
		sfx(3)
	end
	if startprs then
		mdelay-=1
	end 
if mdelay==0 then
		startprs=false
		game_init()
	end
end

function gameover_update()
	if mdelay==0 then
		menu_init()
	else
		mdelay-=1
	end
end

function game_update()
	if me.hp>0 or #hits>0 
	or #flts>0 or #msgs>0
	then
		spawmobs()
		if me.hp>0 then
			update_player()
		end
		resolve_collisions()
		update_mobs()
		moveinmap()
		movesprs()
		update_messages()
		update_hits()
		update_flts()
	else
		gameover_init()
	end
end

function update_hits()
	for h in all(hits) do
		if h.dur>4 then
			del(hits,h)
		else
		if (state.frames%2)==0 then
				h.cspr+=1
				h.dur+=1
				if h.cspr>4 then
					h.cspr=1
				end
		 end
		end
	end
end

function update_messages()
	for ms in all(msgs) do
		if ms.frames == 
					ms.duration then
			del(msgs,ms)
			ms=nil
		else
			ms.frames+=1
		end
	end
end

function update_flts()
	for fl in all(flts) do
		if fl.frames==50 then
			del(flts,fl)
			fl=nil
		else
			fl.frames+=1
			fl.y-=(fl.y-fl.tgr)/10
		end
	end
end


-->8
-- draw

function menu_draw()
	cls()
	for i=1,5 do
		spr(130+i,10*(i-1)+39,45,1,1)
		spr(146+i,8*(i-1)+39,55,1,1)
	end
	spr(147,8*5+39,55,1,1)
	if startprs then
		local cl=mdelay%5
		if cl==0 then 
			color(8)
		else 
			color(9) 
		end
	else
		color(9)
	end
	cursor(32,70)
	print("press ❎ to start")	
end

function gameover_draw()
	cls()
	color(8)
	cursor(42,54)
	print(" you died!",10)
	color(10)
	cursor(42,70)
	print(" game over ",10)
end

function game_draw()
	cls()
	state.frames+=1
	draw_map()
	draw_still()
	draw_player()
	draw_mobs()	
	draw_hits()
	draw_flts()
	--draw_debug()
	camera()
	draw_info()	
	draw_messages()
end

function draw_hits()
	for h in all(hits) do
		otspr(h.sprs[h.cspr],0,h.ob.x,h.ob.y,1,1)
	end
end

function draw_still()
	for h in all(still) do
		otspr(h.sprn,0,h.x,h.y)
	end
end

function draw_flts()
	for fl in all(flts) do
		printo(fl.txt,fl.x-2,fl.y,fl.colr)
	end
end

function draw_messages()
	if #msgs==0 then 
		return
	end
	local sz=(#msgs-1)*8
	local ys=13*8-sz-3
	local ye=14*8-3
	if me.mapy>7 then
		ys=1
		ye=11+sz-3
	end
	rectfill(5,ys+1,125,ye+1,0)
	rectfill(4,ys,124,ye,7)
	
	for i=1,#msgs do
		local txt=msgs[i].txt
		local colr=msgs[i].colr
		color(colr)
		cursor(8,ys+2+(i-1)*8)
		print(txt)
	end
end

function draw_map()
	local roomx=flr(me.mapx/16)
	local roomy=flr(me.mapy/14)
	local mappx=(16*roomx)*8
	local mappy=(13*roomy)*8
-- print ("roomx:"..roomx.."/roomy:"..roomy)
-- print ("mappx:"..mappx.."/mappy:"..mappy)
	camera(mappx,mappy,0,0,4,4,0) 
	mapdraw()
end

--function draw_map()
-- local ctrx=(128/2)-4
-- local ctry=(128/2)-4
-- if me.x>ctrx and me.y<ctry then
--		camera(-64+me.x+4,0,0,0,4,4,0) 
--	elseif me.x<ctrx and me.y>ctry then
--	 camera(0,-64+me.y+4,0,0,4,4,0)
--	elseif me.x>ctrx and me.y>ctry then
--	 camera(-64+me.x+4,0,-64+me.y+4,0,0,4,4,0)
--	else 
--		camera()
-- end
--	mapdraw(0, 0, 0, 0, 16, 13)
--end

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
		otspr(cspr,0,mob.x,mob.y,1,1,mob.flipx,false)
	end
end

function draw_player()
	if me.hp>0 then
		local cspr=me.sprs[me.cspr]
	otspr(cspr,0,me.x,me.y,1,1,me.flipx,false)
	end
end

function draw_info()
 -- panel
	spr(5,0,14*8,1,1)
	spr(5,0,15*8,1,1,false,true)
	spr(5,15*8,14*8,1,1,true,false)
	spr(5,15*8,15*8,1,1,true,true)
	for i= 1,14 do
			spr(6,i*8,14*8,1,1,false,false)
			spr(6,i*8,15*8,1,1,false,true)
	end
	
	-- hit points
	print("life: ",4,(14*8)+2,10)
	for l=1,me.maxhp do
		if l<=me.hp then
			color(8)	
		else
			color(6)	
		end
		print("♥",16+l*8,(14*8)+2)
	end
	
	-- gold	
	print("gold:"..me.gold,1+8*11,(14*8)+2,7)

 -- stats
	print("level:"..me.level.." atk:"..me.atack.." def:"..me.defense,4,(15*8)+1,10)

 -- map
	print("("..me.mapx..","..me.mapy..")",1+8*13,(15*8)+1,10)

 -- frames
	print(state.frames,1+8*11,(15*8)+1,11)
	if state.frames>999 then
		state.frames=0
	end
end

function printo(txt,x,y,colr)
	for i=1,3 do
		print(txt,(x+(i-2)),y,0)
		print(txt,x,(y+(i-2)),0)
	end
	print(txt,x,y,colr)
end
-->8
-- stack and queues
-- https://www.lexaloffle.com/bbs/?tid=3389

-- stack
push=add

function pop(stack)
	local v = stack[#stack]
	stack[#stack]=nil
	return v
end

function pop_discard(stack)
	stack[#stack]=nil
end

-- fifo
equeue=add

function dqueue(queue)
	local v = queue[1]
	del(queue, v)
	return v
end

function findtbl(tbl,ob)
	for t in all(tbl) do
		if (t==obj) return t
	end
	return nil
end
__gfx__
000000005555555500000000000000000000000056666666666666660000000000000000011100001000100c0000000000000000088800008000800000000000
000000005d55ddd500000000000000000000000066555555555555550000000000100000100010c000c001000000000000800000800080000080089000000000
000000005dd5d555000000000000000000000000655555555555555500c0000001c1000010c010000c1c01000080000008980000809080000898080000000000
000000005d55d5d5000000000000000000000000655555555555555500000000001000001000111000c001000000000000800000800088800080080000000000
00000000555555d50000000000000000000000006555555555555555000000000000010001110001100010000000000000000800088800088000800000000000
0000000055d55dd5000000000000000000000000655555555555555500000c0000001c1000010c01011100c00000080000008980000809080888088000000000
000000005ddd55d5000000000000000000000000655555555555555500000000000001000001000100000c1c0000000000000800000800080000089800000000
000000005555555500000000000000000000000065555555555555550000000000000000c0001110c00000c00000000000000000000088800090008000000000
00000000555555550000000000000000000000000000000000000000000000006000000000000000000000000000000060000000000000000000000000000000
000000005d55ddd50000000000000000000000000000000000000000070000000660070000000000000000000700000006600700000000000000000000000000
000000005dd5d5550000000000000000000000000000000000000000007000000676007000000000000000000070000006860080000000800000000000000000
0000000055d555d50000000000000000000000000000000000000000000700000067000700060006000000000008000000680007000600060000000000000000
000000005555ddd50000000000000000000000000000000000000000000000000000000000007600000060000000000000000000000086000000600000000000
000000005dd555d50000000000000000000000000000000000000000000000000700000000006760000007600000000007000000000068600000086000000000
000000005d555dd50000000000000000000000000000000000000000000000000070000000000670000006760000000000800000008006700000068600000000
00000000555555550000000000000000000000000000000000000000000000000007000000060000000000670000000000070000000600000000006700000000
000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000880008b00b0000000000000000005000000000
000000005d5d55d500000000000000000000000000000000000000000999999000000000000000000000000000700087007000b00d0000d0100500d100000000
000000005d5dd5d5000000000000000000000aa0000000000944449005555550000000000000000000000000800880800a0880b0006006000060060000000000
000000005555555500000000000000000aaaaa900000000009999990055555500000000000000000000000000889880800b8880b0001b0000500000000000000
000000005dd5d5d500000000000000000a0a0aa000000000094664900946649000000000000000000000000080787800a08878b0000810000005800000000000
000000005555d5550000000000000000000000000000000009444490094444900000000000000000000000000708800007088b70006006000060000000000000
000000005d5dd5d500000000000000000444444004444440099449900994499000000000000000000000000080007080b00070000d0000d0100b00d000000000
0000000055555555000000000000000004544540045445400000000000000000000000000000000000000000080808800b000b07000000000000050000000000
00000000000000000000000000222000002220000022200000222000002220000000000000777000000000000000000000000000000000000000000000000000
000000000000000000000000022aaa00022aaa00022aaa00022aaa00022aaa00002220000777770000000000000060000000000000aaa0000000600000000000
000000000000000000000000008afc00008afc00008afc00008afc00008afc00022aaa000077770000000000000760000000a00000a0a0000007600000000000
000000000000000000000000085fff00085fff00085fff00085fff00085fff00008afc00077777000000000000076000000999000a000a000007600000000000
0000000000000000000000000859469408594640085946408054664008596690085fff000777777000000000000760000000a0000a000a000007600000000000
0000000000000000000000000806660008066600800666008006660080046640085466400707700000000000000460000000000000a9a0000004600000000000
00000000000000000000000080090900800909008009900000090900080099000809090070077000000000000004000000000000000a00000004000000000000
00000000000000000000000000040400000404000004400000040400000044000804040000077000000000000000000000000000000000000000000000000000
00066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00644460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0064f500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cdddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009ddd90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000006500590065555900655559006555590065555900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006500590065005900650059006500590065665900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006500590065005900650059006500590065600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006566590065665900656659006566590065600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006590065005900655559006555590065655900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006590065005900650590006590000065605900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006590065005900650559006590000065665900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006550055005500550655005550000055555900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000060000000000000006600000000000060060000060000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000099900069960009999990006996000999999000690000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005996699996099500599669999069950059960990000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005599995099990500559999509999050015999950000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000100505050100100050050505010010001005050000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000101010000000000050501000000000005010000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000555855555555555500000000
055aa55005000000191111d100000000000000000000000000000000000000000000000000000000000000000000000000000000588859995aaa55bb00000000
055aa5500a0000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000588859995aaa5bbb00000000
0aaaaaa005000000111d111100000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
0566a550060000001111d11100000000000000000000000000000000000000000000000000000000000000000000000000000000c5ddd5eee5fff50000000000
05aaaa50050000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000c5ddd5eee5fff50000000000
0a5aa5a00a0000001d11119100000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
0a5aa5a0050000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000511152225333544400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000511152225333544400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556665777588859900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556665777588859900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005aaa5bbb5ccc5ddd00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005aaa5bbb5ccc5ddd00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555bb555555dd00000000
__gff__
0001000000000000000000000000000000010000000000000000000000000000000100000500090900000000001111000000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003020000000302000000000000000000000000000000000000000000000000000000000000
__map__
0111110101010101111101110111110101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010000db00db0000110000000000000101000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100000100010024010000000000000101000101010000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010100210111010000000000000101012600000100000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010000010001000011000000000000110101240000db00000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010000db00db0000010000000000001101012600000100000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
214000010021002601000000000000db00000101010000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01011121e0110111110000000000001111000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000db0000000000000111000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100e2e2e2e2e200210000000000001111000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1100e2e2e2e2e200db0000000000000111000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000000100000000002d1111000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111212111112111010101db2111210101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111111111111111111111001111110100000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000101010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000010024000100000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000010000000100000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000010000000100000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000001db010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000001010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010300000c0700c0500e7300e0500c0500c0500e0500c0500e0500c05000400024000340003400044000440005400054000540005400004000040000400014000140004400044000340024700034000240001400
00070000000002005025040280302c0202c0102c0102c0002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000126101b600196002260018600296002060022600316002760038600256003b6003c600376002e6002060021600246001660028600106000c6000e6000000000000000001160000000000000000000000
00080000260503005030030300203002030000106001c6001c600116001670011600126002d700126001360014600156001560000000000000000000000000000000000000000000000000000000000000000000
000700001c0501f050210302102021010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000013610176201b6301e64022650226101e650286002660024600216001f6001c6001a6001760014600126000f6000d600096000960008600056000460003600016000060028600236001f600186000d600
0003000022060210601e0701c07014670146701467011670086600766006660026500364004630046300462004620036100162000600006000060000000000000000000000000000000000000000000000000000
000400000755009540055300552000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018450102401a1301335018240111301a350152401c1301735021240131301c350112401c1300c3500c2400e130103501124011130113500c2400e1300c3500e2400e1300e35000000000000000000000
0117000028020280202702028020280202702028020280202a0202702023000210001400014000140001400000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c051190501e050190500c650190500c650200500c05119050200501e0500c6501965019050000000c051190501b050190500c6501905022650200500c0511e0501b0501b0500c6500c6500c60000000
011600000c3500c3500c3500e3500e3500c3500c3500c3501d3501f3501d3501c3501c3501c3500c3500c3500e3500c350103500e3500c3500c3500c650000000000000000000000000000000000000000000000
__music__
03 0a0c4344
