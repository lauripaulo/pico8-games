pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- initial
flts = {}
msgs = {}

-- game constants
const_typ_player = 1
const_typ_enemy = 2
const_typ_npc = 3

-- state machine
_init = game_init
_update = game_update
_draw = game_draw

function game_init()
end

function game_update()
end

function game_draw()
end

-- d6 dices
function roll_d6(_dices)
    local value = 0
    for i = 1, _dices do
        value += flr(rnd(6)) + 1
    end
    return value
end

-- d100 dice
function roll_d100()
    return flr(rnd(100)) + 1
end

-- roll gold for an object
function roll_gold(_obj)
	return _obj.level * roll_d6(2)
end

-- create a new object
function create_obj(_x, _y, _type)
    return {
        x = _x,
        y = _y,
        map_x = 0,
        map_y = 0,
        atk = 0,
        def = 0,
        hp = 0,
        max_hp = 0,
        type = _type,
        inventory = {},
        equipped = {},
        gold = 0,
        exp = 0,
        lvl = 1,
        name = "",
        spells = {},
        status = {},
        dead = false
    }
end

-- Floater functions
function addflt(_obj, _txt, _colr)
    add(
        flts,
        {
            txt = _txt,
            frames = 0,
            colr = _colr,
            tgr =_ obj.y - 10,
            x = _obj.x,
            y = _obj.y
        }
    )
end

function update_flts()
    for fl in all(flts) do
        if fl.frames == 50 then
            del(flts, fl)
            fl = nil
        else
            fl.frames += 1
            fl.y -= (fl.y - fl.tgr) / 10
        end
    end
end

function draw_flts()
    for fl in all(flts) do
        printo(fl.txt, fl.x - 2, fl.y, fl.colr)
    end
end

-- Messages functions
function addmsg(_txt, _secs, _colr)
    add(
        msgs,
        {
            txt = _txt,
            duration = _secs * 60,
            frames = 0,
            colr = _colr
        }
    )
end

function update_messages()
    for ms in all(msgs) do
        if ms.frames
                == ms.duration then
            del(msgs, ms)
            ms = nil
        else
            ms.frames += 1
        end
    end
end

function draw_messages()
    if #msgs == 0 then
        return
    end
    local sz = (#msgs - 1) * 8
    local ys = 13 * 8 - sz - 3
    local ye = 14 * 8 - 3
    if me.mapy > 7 then
        ys = 1
        ye = 11 + sz - 3
    end
    rectfill(5, ys + 1, 125, ye + 1, 0)
    rectfill(4, ys, 124, ye, 7)

    for i = 1, #msgs do
        local txt = msgs[i].txt
        local colr = msgs[i].colr
        color(colr)
        cursor(8, ys + 2 + (i - 1) * 8)
        print(txt)
    end
end

-- draws a sprite to the screen with an outline of the specified colour
function otspr(n, col_outline, x, y, w, h, flip_x, flip_y)
    -- reset palette to black
    for c = 1, 15 do
        pal(c, col_outline)
    end
    -- draw outline
    for xx = -1, 1 do
        for yy = -1, 1 do
            spr(n, x + xx, y + yy, w, h, flip_x, flip_y)
        end
    end
    -- reset palette
    pal()
    -- draw final sprite
    spr(n, x, y, w, h, flip_x, flip_y)
end

-- print to the screen with an outline of the specified colour
function printo(txt, x, y, colr)
    for i = 1, 3 do
        print(txt, x + i - 2, y, 0)
        print(txt, x, y + i - 2, 0)
    end
    print(txt, x, y, colr)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
