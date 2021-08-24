-- title:  Simple Geometric Game
-- author: lauri Laux
-- desc:   Simple game to learn tic80
-- script: lua
--
-- Game goal: combine magic gems to
-- create spells,using color and
-- position. Each gem can have
-- different colors.
--
-- You need to arrange it in lines
-- with the same color.
-- When you fill a line you destroy
-- if and the spell is cast.
-- sides
RIGHT = 1
LEFT = 2
UP = 3
DOWN = 4
SIDES = {"RIGHT", "LEFT", "UP", "DOWN"}

STATE_INITIAL = 101
STATE_RUNNING = 102
STATE_GAMEOVER = 103

-- global timer
timer = 0

-- gem: 1,2
--      3,4
gemTypes = {{1, 1, 1, 1}, {2, 2, 2, 0}, {3, 3, 0, 3}, {4, 0, 4, 4}}

-- Game State
gameState = {
  activeGem=false,
  currgem={0, 0, 0, 0},
  nextgem={0, 0, 0, 0},
  gemx=0,
  gemy=0,
  score=0,
  speed=60,
  ptsBase=100,
  state=STATE_INITIAL,
  field={cols=4 * 3, lines=16, drawx=8 * 16, drawy=0, data={}}
}

function InitField(fld)
  trace("InitField:")
  local pos = 1
  fld.data = {}
  for i = 1, fld.lines do
    for j = 1, fld.cols do
      fld.data[pos] = 0
      -- trace(">pos:"..pos.." i,j="..i..","..j)
      pos = pos + 1
    end
  end
  return fld
end

function GetDataPos(x, y, gmState)
  local pos = (y - 1) * gmState.field.cols
  pos = pos + x
  return pos
end

function NextGem(types)
  local idx = math.random(#types)
  trace("NextGem:" .. idx)
  return types[idx]
end

function RotateGem(gmState)
  trace("RotateGem:")
  ClearGem(gmState)
  local gem = gmState.currgem
  local last = table.remove(gem, #gem)
  table.insert(gem, 1, last)
  SetGem(gmState, gmState.gemx, gmState.gemy)
end

function ClearGem(gmState)
  trace("ClearGem:")
  local fld = gmState.field
  local p = GetDataPos(gmState.gemx, gmState.gemy, gmState)
  local gem = gmState.currgem
  if gem[1] > 0 then fld.data[p] = 0 end
  if gem[2] > 0 then fld.data[p + 1] = 0 end
  if gem[3] > 0 then fld.data[p + 12] = 0 end
  if gem[4] > 0 then fld.data[p + 13] = 0 end
end

function SetGem(gmState, x, y)
  trace("SetGem:")
  trace(">x,y:" .. x .. "," .. y)
  local field = gmState.field
  local gem = gmState.currgem
  local p = GetDataPos(x, y, gmState)
  if gem[1] > 0 then field.data[p] = gem[1] end
  if gem[2] > 0 then field.data[p + 1] = gem[2] end
  if gem[3] > 0 then field.data[p + 12] = gem[3] end
  if gem[4] > 0 then field.data[p + 13] = gem[4] end
  gmState.gemx = x
  gmState.gemy = y
end

function PutNewGem(gmState, gem)
  trace("PutNewGem:")
  trace(">activeGem=" .. pbool(gmState.activeGem))
  local field = gmState.field
  trace(">data size:" .. #field.data)
  if not gmState.activeGem then
    local gemx = 7
    local gemy = 1
    gmState.activeGem = true
    gmState.currgem = gem
    if EvalCollision(gemx, gemy, gmState) then
      gmState.state = STATE_GAMEOVER
    end
    SetGem(gmState, gemx, gemy)
  end
end

function DrawField(gState)
  local pos = 1
  local field = gState.field
  for i = 1, field.lines do
    for j = 1, field.cols do
      local drawY = ((i - 1) * 8) + field.drawy
      local drawX = ((j - 1) * 8) + field.drawx
      local tile = field.data[pos]
      if tile > 0 then
        spr(tile, drawX, drawY, 14, 1, 0, 0, 1, 1)
      else
        spr(20, drawX, drawY, 0, 1, 0, 0, 1, 1)
      end
      pos = pos + 1
    end
  end
end

function RemoveLines(filled, gmState)
  trace("RemoveLines:")
  local field = gmState.field
  for i = 1, #filled do
    local ln = filled[i]
    local pos = GetDataPos(1, ln, gmState)
    trace(">Remove#" .. ln)
    for j = pos, field.cols + pos do
      table.remove(field.data, j)
      table.insert(field.data, 1, 0)
      -- trace(">>pos#"..j)
    end
  end
end

function EvalFillLines(gmState)
  trace("EvalFillLines:")
  local completed = {}
  local pos = 1
  local field = gmState.field
  for i = 1, field.lines do
    local lineSum = 0
    local pos = GetDataPos(1, i, gmState)
    local its = 0
    for j = 1, field.cols do
      if field.data[pos + (j - 1)] > 0 then lineSum = lineSum + 1 end
    end
    if lineSum >= field.cols then
      trace(">Line#" .. i .. " filled!")
      table.insert(completed, i)
    end
  end
  return completed
end

function EvalCollision(x, y, gmState)
  trace("EvalCollision:")
  trace(">x,y:" .. x .. "," .. y)
  local res = false
  local p = GetDataPos(x, y, gmState)
  local f = gmState.field
  local cgem = gmState.currgem
  local ngem = {f.data[p], f.data[p + 1], f.data[p + 12], f.data[p + 13]}
  if p + 13 > #f.data then
    res = true
  else
    for i = 1, #ngem do
      if ngem[i] > 0 then
        if cgem[i] > 0 then
          res = true
          break
        end
      end
    end
  end
  trace(">res:" .. pbool(res))
  return res
end

function MoveSide(side, gmState)
  trace("MoveSide:" .. pbool(gmState.activeGem))
  trace(">side:" .. SIDES[side])
  if gmState.activeGem then
    local y = gmState.gemy
    local x = gmState.gemx
    ClearGem(gmState)
    if side == LEFT and x > 1 then
      x = x - 1
    elseif side == RIGHT and x < gmState.field.cols - 1 then
      x = x + 1
    end
    if EvalCollision(x, y, gmState) then
      SetGem(gmState, gmState.gemx, gmState.gemy)
      trace(">colision!")
    else
      SetGem(gmState, x, y)
    end
  end
end

function UpdateScore(lns, gmState)
  trace("UpdateScore:")
  local score = gmState.score
  local ptsBase = gmState.ptsBase
  score = score + (ptsBase * lns)
  score = score + (ptsBase * (lns - 1))
  trace(">score:" .. score)
  gmState.score = score
end

function MoveDown(gmState)
  trace("MoveDown:" .. pbool(gmState.activeGem))
  if gmState.activeGem then
    local x = gmState.gemx
    local y = gmState.gemy + 1
    ClearGem(gmState)
    if EvalCollision(x, y, gmState) then
      SetGem(gmState, gmState.gemx, gmState.gemy)
      local filled = EvalFillLines(gmState)
      local gem = NextGem(gemTypes)
      if #filled > 0 then
        UpdateScore(#filled, gmState)
        RemoveLines(filled, gmState)
      end
      gmState.activeGem = false
      PutNewGem(gmState, gmState.nextgem)
      gmState.nextgem = gem
    else
      SetGem(gmState, x, y)
    end
  else
    local gem = NextGem(gemTypes)
    gmState = PutNewGem(gmState, gem)
  end
end

function Start(gmState)
  trace("=-=- Start() -=-=")
  gmState.field = InitField(gmState.field)
  gmState.state = STATE_INITIAL
  local gem = NextGem(gemTypes)
  gmState.nextgem = gem
  MoveDown(gmState)
end

function DrawUI(gmState)
  map(0, 0, 30, 17, 0, 0)
  print("Score: ", 2, 2, 4)
  print(gmState.score, 8, 18, 4)

  -- next
  print("Next:", 8 * 10, 2, 4)
  spr(gmState.nextgem[1], 8 * 11, 8 * 2, 14, 1, 0, 0, 1, 1)
  spr(gmState.nextgem[2], 8 * 12, 8 * 2, 14, 1, 0, 0, 1, 1)
  spr(gmState.nextgem[3], 8 * 11, 8 * 3, 14, 1, 0, 0, 1, 1)
  spr(gmState.nextgem[4], 8 * 12, 8 * 3, 14, 1, 0, 0, 1, 1)
end

function Debug(gmState)
  local bln = 50
  local t = "gemx,gemy:" .. gmState.gemx .. "," .. gmState.gemy
  print(t, 2, bln, 15)
  t = "activeGem:" .. pbool(gmState.activeGem)
  print(t, 2, bln + 10, 15)
  local pos = GetDataPos(gmState.gemx, gmState.gemy, gmState)
  print(pos, 2, bln + 20, 15)
end

function TIC()
  cls(13)

  if gameState.state == STATE_RUNNING then
    if btnp(1) then MoveDown(gameState) end
    if btnp(0) then RotateGem(gameState) end
    if btnp(2) then MoveSide(LEFT, gameState) end
    if btnp(3) then MoveSide(RIGHT, gameState) end
    timer = timer + 1
    if timer % gameState.speed == 0 then MoveDown(gameState) end
    DrawUI(gameState)
    DrawField(gameState)
    Debug(gameState)
  elseif gameState.state == STATE_GAMEOVER then
    print("GAME OVER", 50, 50)
  elseif gameState.state == STATE_INITIAL then
    print("Press DOWN to start the game...", 40, 50)
    if btnp(0) then gameState.state = STATE_RUNNING end
    trace("[State:" .. gameState.state .. "]")
  end

end

function pbool(bool)
  return bool and "true" or "false"
end

Start(gameState)

-- <TILES>
-- 001:0000000003333320033333200333332003333320033333200222222000000000
-- 002:0000000005555560055555600555556005555560055555600666666000000000
-- 003:0000000009999980099999800999998009999980099999800888888000000000
-- 004:0000000005555560055665600556656005566560055555600666666000000000
-- 016:feeeeeefeeddddeeeddddddeeddfdddeedddfddeeddddddeeeddddeefeeeeeef
-- 017:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffff
-- 018:eeeeeeefeeeeeeefeeeeeeefeeeeeeefeeeeeeefeeeeeeefeeeeeeefffffffff
-- 020:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 021:000000000888888808888bbb08888bbb0888888808bb800008bb800008bb8000
-- 022:0000000088888888bbb88bbbbbb88bbb88888888000000000000000000000000
-- 023:0000000088888880bbb88880bbb88880888888800008bb800008bb800008bb80
-- 037:08bb800008bb800008bb8000088880000888800008bb800008bb800008bb8000
-- 039:0008bb800008bb800008bb8000088880000888800008bb800008bb800008bb80
-- 053:08bb800008bb800008bb80000888888808888bbb08888bbb0888888800000000
-- 054:00000000000000000000000088888888bbb88bbbbbb88bbb8888888800000000
-- 055:0008bb800008bb800008bb8088888880bbb88880bbb888808888888000000000
-- 081:0000000003333320033333200333332003333320033333200222222000000000
-- 082:0000000000033000003332000333332003333320003332000002200000000000
-- 083:0000000003333320033223200332232003322320033333200222222000000000
-- 084:0000000000033000003332000332232003322320003332000003200000000000
-- 085:0000000009999980099999800999998009999980099999800888888000000000
-- 086:0000000000099000009998000999998009999980009998000008800000000000
-- 087:0000000009999980099889800998898009988980099999800888888000000000
-- 088:0000000000099000009998000998898009988980009998000009800000000000
-- 089:0000000005555560055555600555556005555560055555600666666000000000
-- 090:0000000000055000005556000555556005555560005556000006600000000000
-- 091:0000000005555560055665600556656005566560055555600666666000000000
-- 092:0000000000055000005556000556656005566560005556000005600000000000
-- </TILES>

-- <MAP>
-- 000:000000000000000000000000000000520000000000000000000000007231000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:516161616161617100005161617100520000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:520000000000317200005241417200520000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:536363636363637300005241417200520000000000000000000000317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:000000000000000000005363637300520000000000000000000031317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:000000000000000000000000000000520000000000000000000031317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:000000000000000000000000000000520000000000000000000031317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:000000000000000000000000000000520000000000000000000031317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:000000000000000000000000000000520000000000000000000000317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:000000000000000000000000000000520000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:000000000000000000000000000000520000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:000000000000000000000000000000520000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:000000000000000000000000000000520000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:000000000000000000000000000000520000000000000000000000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:000000000000000000000000000000520000000000000000000000317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:000000000000000000000000000000523131313131313131313131317200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:000000000000000000000000000000536363636363636363636363637300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
