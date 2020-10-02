pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- init

	-- map pico calls to funcs
--	_draw = main_draw
--	_update = main_update
--	_init =	game_init


function _init()
	-- constants
	left=0
	right=1
	up=2
	down=3
	
	-- game config
	cfg={
--		redexspr={55,56,57,58}, -- red explosion
--	 bluexspr={60,61,62,63}, -- blue explosion
--		score=0,
--		gravity=0.2,
--		maxgravity=5,
--		chopspr={4,5}, -- chopper
--		jetspr={7,8}, -- jet	
--		bulletspr={17,18}, -- bullet
		levels={},
		lvl_ypos=15*8,
		terrspr={48,49,50}
	}
	
	player={
		playerspr={1,2},
		x=0,
		y=0,
		accel=1,
		frict=0.3
	}
	
	bsconsspr={32,33,34,35}
	
	local lvl=genlevel()
	add(cfg.levels,lvl)
			
end

function genlevel(num)
	local lvlterr={}
 local tile=nil
 local initial=cfg.terrspr[1]
 for i=1,16 do
 	tile=flr(rnd(#cfg.terrspr)+initial)
 	add(lvlterr,tile)
 end
 return lvlterr
end
-->8
-- common

-->8
-- update

function _update()
end
-->8
-- draw

--function main_draw()
function _draw()
 cls()
	
	-- terrain
	local x=0
	local tiles=cfg.levels[1]
	--print(#tiles)
	for t in all(tiles) do
		spr(t,x,cfg.lvl_ypos)
 	--print(t.." x:"..x.." y:"..cfg.lvl_ypos)
 	x+=8
	end
end

__gfx__
00000000008008000080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006006000060060000000000677677607677767000000000dd000000dd00000000000000000000000000000000000000000000000000000000000000
00700700006006000060060000000000000d0000000d00000000000063d0000063d0000000000000000000000000000000000000000000000000000000000000
000770000055550000555500000000006ddddaaa7ddddaaa00000000933ddaa0a33ddaa000000000000000000000000000000000000000000000000000000000
000770000559955005599550000000005d3333aa5d3333aa0000000056d333dd96d333dd00000000000000000000000000000000000000000000000000000000
0070070017767761167767710000000000d333d000d333d0000000009333dd00a333dd0000000000000000000000000000000000000000000000000000000000
0000000065155157751551560000000006d6d6d006d6d6d000000000633d0000633d000000000000000000000000000000000000000000000000000000000000
00000000167767711776776100000000006666660066666600000000ddd00000ddd0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008008000080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008008000080080000000000000000000000000000000000002000000010000000000000000000000000000000000000000000000000000000000000
0000000000a00a0000a00a0000000000000000000000000000000000000280000001c00000000000000000000000000000000000000000000000000000000000
0000000000a00a00009009000000000000000000000000000000000000082000000c100000000000000000000000000000000000000000000000000000000000
00000000009009000090090000000000000000000000000000000000000002000000010000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000222222000490000000000000292929000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000001800000000120000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000110000000000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000202021000000010023230035002200210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000323031303130323031323231313230320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000006070310700a0700c0703f0700f070100701207013070150703307016070170701b07009070200703707009070240703a0702807024070060702607028070030703d0702807005070270703d07004070
