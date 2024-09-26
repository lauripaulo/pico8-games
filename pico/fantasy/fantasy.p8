pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- initial
flts = {}
msgs = {}

-- game constants
typ_player = 1
typ_enemy = 2
typ_npc = 3
state_start_screen = 1
state_playing = 2
state_game_over = 3
state_win = 4

-- player
player = nil

-- state machine
function change_state(_state)
  if _state == state_start_screen then
    _init = start_screen_init
    _update = start_screen_update
    _draw = start_screen_draw
    start_screen_init()
  elseif _state == state_playing then
    _init = game_init
    _update = game_update
    _draw = game_draw
    game_init()
  elseif _state == state_game_over then
    _init = game_over_init
    _update = game_over_update
    _draw = game_over_draw
    game_over_init()
  elseif _state == state_win then
    _init = win_init
    _update = win_update
    _draw = win_draw
    win_init()
  end
end

-- title screen
function start_screen_init()
end

function start_screen_update()
  if btnp(4) then
    change_state(state_playing)
  end
end

function start_screen_draw()
  cls()
  printo("fantasy game", col2x(2), row2y(2), 7)
  printo("-- press z to start --", col2x(2), row2y(10), 7)
end

-- playing game
function game_init()
  player = create_obj(64, 64, typ_player, "Zeno")
  player.atk = 55
  player.def = 45
  player.hp = 20
  player.max_hp = 20
  player.gold = 0
  player.exp = 0
  player.lvl = 1

  addmsg("welcome to the game!", 3, 2)
  addmsg("game loop working ok.", 5, 3)
end

function game_update()
  if btnp(5) then
    change_state(state_game_over)
  end
  update_messages()
end

function game_draw()
  cls()
  printo("playing game...", col2x(2), row2y(2), 7)
  draw_messages(player)
end

-- game over
function game_over_init()
  game_over_timer = 0
end

function game_over_update()
  game_over_timer += 1
  if game_over_timer == 120 then
    change_state(state_start_screen)
  end
end

function game_over_draw()
  cls()
  printo("game over", col2x(2), row2y(2), 7)
end

-- win game!!!
function win_init()
end

function win_update()
end

function win_draw()
end

-- initial game state
change_state(state_start_screen)

-->8
-- Game Engine functions
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
function create_obj(_x, _y, _type, _name)
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
    name = _name,
    spells = {},
    status = {},
    dead = false
  }
end

-->8
-- Helper functions
-- Floater functions
function addflt(_obj, _txt, _colr)
  add(
    flts,
    {
      txt = _txt,
      frames = 0,
      colr = _colr,
      tgr = _obj.y - 10,
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

function draw_messages(_obj)
  if #msgs == 0 then
    return
  end
  local sz = (#msgs - 1) * 8
  local ys = 13 * 8 - sz - 3
  local ye = 14 * 8 - 3
  if _obj.map_y > 7 then
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

function col2x(col)
  return col * 8
end

function x2col(x)
  return flr(x / 8)
end

function row2y(row)
  return row * 8
end

function y2row(y)
  return flr(y / 8)
end

-->8

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
