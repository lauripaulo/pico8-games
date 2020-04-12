pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- main / vars

dr_idle={0,0,0,0}

me={
	name="player",
	x=10*8,
	y=10*8,
	h=8, -- height size in pixels
	w=8, -- width size in pixels
	vl=1, -- velocity
	tspr=0,
 dr={0,0,0,0},  -- ⬆️⬇️⬅️➡️
	sprs={52,53,54,55}, -- sprites
	cspr=1,	-- current sprite
	vspr=.8, -- incr chg sprite
	flipx=false,
	flipy=false,
	moving=false,
 pxmoved=0
}

debug={}
-->8
-- draw/update

function _draw()
	cls()
	mapdraw(0, 0, 0, 0, 16, 16)

	local cspr=me.sprs[me.cspr]

	spr(cspr,me.x,me.y,1,1,me.flipx,me.flipy)
	
	-- debug boxes
	for obj in all(debug) do
		rect(obj.x1,obj.y1,obj.x2,obj.y2,8)	
	end
	debug={}

end

function _update()
	update_player()
end

function update_player()
	local bpress=false

	-- ⬆️⬇️⬅️➡️
	local move={0,0,0,0}
	
	if me.moving then
 	printh("=-=-=-=-=-=-=-=[update_player.moving()")
	 printh("me.dr[4]:"..me.dr[4])
	 printh("me.moving:"..b2s(me.moving))
	 printh("me.pxmoved:"..me.pxmoved)
	 me.x+=me.dr[4]
	 me.x-=me.dr[3]
	 me.y+=me.dr[2]
	 me.y-=me.dr[1]
	 me.pxmoved+=me.vl
	 if me.pxmoved==8 then
	 	me.moving=false
	 	me.pxmoved=0
	 	me.dr=dr_idle
	 end
		anispr(me,bpress,4)
	 return
		
	elseif btn(⬆️)
		or btn(⬇️)
		or btn(⬅️)
		or btn(➡️) then
		bpress = true
		me.moving=true
		
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
		me.dr=move
		
		-- colision
		if mcollide(me,0) then
			me.dr=dr_empty
			me.moving=false
			me.pxmoved=0
			sfx(0)
		else
			me.dr=move
		end
		
	else
		me.dr=dr_idle
		bpress = false
		return
	end

end


-->8

-- helper

-- change sprite
function anispr(s,bprs,num)
	printh("=-=-=-=-=-=-=-=[anispr]")
 printh("s.tspr:"..s.tspr)
 printh("s.cspr:"..s.cspr)
 printh("s.vspr:"..s.vspr)
	-- sprite change
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

function mcollide(o,flag)
	local x1=0			  local x2=0
	local y1=0     local y2=0
	
	-- ⬆️
	if o.dr[1]>0 then
		x1=o.x        y1=o.y-1
		x2=o.x+o.w-1  y2=o.y
	
	-- ⬇️
	elseif o.dr[2]>0 then
		x1=o.x			     y1=o.y+o.h
		x2=o.x+o.w-1  y2=o.y+o.h+1

 -- ⬅️
	elseif o.dr[3]>0 then
		x1=o.x-1			 y1=o.y
		x2=o.x   		 y2=o.y+o.h-1
		
	elseif o.dr[4]>=0 then
		x1=o.x+o.w-1	 y1=o.y
		x2=o.x+o.w   	y2=o.y+o.h-1
	
	end

	-- debug
	obj={x1=flr(x1),y1=flr(y1),
		    x2=flr(x2),y2=flr(y2)}		    
	add(debug,obj)

	-- pixels to tiles
	x1/=8      y1/=8
	x2/=8      y2/=8

	if fget(mget(x1,y1),flag)
	or fget(mget(x1,y2),flag)
	or fget(mget(x2,y1),flag)
	or fget(mget(x2,y2),flag) 
	then
		return true
	end
	return false
end
-->8
-- world
-->8
-- enemy
-->8
-- util

function b2s(bool)
	return bool and 'true' or 'false'
end
__gfx__
00000000555555550055550000555500dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000055585555555555550000000000000000
000000005d55ddd5000d600000000000d1111111111111111111111dd1111111111111111111111d0000000000000000588859995aaa55bb0000000000000000
000000005dd5d555000aa00000000000d1515551551555515551551dd1515551515551515551551d0000000000000000588859995aaa5bbb0000000000000000
000000005d55d5d5000d600000000000d1515111511151115151511dd1515111115151115151511d000000000000000055555555555555550000000000000000
00000000555555d5000d600000000000d1111151111111511111111dd1111151511111511111111d0000000000000000c5ddd5eee5fff5000000000000000000
0000000055d55dd5000d600000000000d1551551515515515115551dd1551551515515515155151d0000000000000000c5ddd5eee5fff5000000000000000000
000000005ddd55d500046000000d6000d1151511511515115515111dd1111111111111111111111d000000000000000055555555555555550000000000000000
00000000555555550055550000555500d1111111111111111111151ddddddddddddddddddddddddd000000000000000051115222533354440000000000000000
00000000666666610044440000444400d1551511151551151155111d15155115d155511515155115000000000000000051115222533354440000000000000000
000000006dddddd10005500000000000d1511511151111115151151d151111111111111115111111000000000000000055555555555555550000000000000000
000000006dddddd10009900000000000d1515551551555515151551d551555515515555155155551000000000000000055666577758885990000000000000000
000000006dddddd10005500000000000d1515111511151115551511d511151115111511151115111000000000000000055666577758885990000000000000000
000000006dddddd10005500000000000d1111151111111511111111d111111511111115111111151000000000000000055555555555555550000000000000000
000000006dddddd10005500000000000d1551551515515511555151d51551551515515515155155100000000000000005aaa5bbb5ccc5ddd0000000000000000
000000006dddddd10004500000055000d1111111511515115511111d51151511511515111115151100000000000000005aaa5bbb5ccc5ddd0000000000000000
00000000611111110044440000444400d1155511551115111115551d5511151d55111511d11115110000000000000000555555bb555555dd0000000000000000
00000000000000000000000000000000d1551511111111155511151d1515511d0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000d1511511151155111511551d151111110000000000000000000000000000000000000000000000000000000000000000
00000000000000005000000550000005d1515551551555511515551d551555510000000000000000000000000000000000000000000000000000000000000000
00000000000000005ddddad55d000005d1515111511151111111111d511151110000000000000000000000000000000000000000000000000000000000000000
000000000000000056666a6556000005d1111151111111515115151d111111510000000000000000000000000000000000000000000000000000000000000000
00000000000000005000000550000005d1551551515515515155151d515515510000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000d1111111511515111111111d511515110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000dddddddddddddddddddddddd551115110000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000
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
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55dd5ddd5ddd55dd55dd5ddd5ddd55dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5dd55ddd55dd5ddd5dd55ddd55dd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5dd55ddd5ddd5ddd5dd55ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555d5d5555dd55dd555d5d5555dd55dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555d555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55dd5ddd5ddd55dd55dd5ddd5ddd55dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555555dd555555dd555555dd555555dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010001010101010100000000000000000100010101010101000000000000000003000101010100000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0117252525252525252525252525190100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000000000140100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116010101000101010100010101140100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000002000100000100020000140100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000001000100000100010000140100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116010101000101220100010000140100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000010000140100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000010101241900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000000004051800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000000014150100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116000000000000000000000014150100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0118050505050622040505050518010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300001177017750177300b4000c4000b4000a4000a4000b4000240000400024000340003400044000440005400054000540005400004000040000400014000140004400044000340024700034000240001400
0007000000000267502e7502a7502e7402e7202e7102a7002b7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
