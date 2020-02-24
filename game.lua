local lume = require("lib/lume")
local wf = require("lib/windfield")
local vector = require("lib/vector")
local cartographer = require("lib/cartographer")
local inspect = require("lib/inspect")
local gamera = require("lib/gamera")
local timer = require("lib/timer")
local push = require("lib/push")
local flux = require("lib/flux")
local mk = require("mk")
local drw = require("drw")
local loadlvl = require("loadlvl")

local game = {}

local fader = {r = 0, g = 0, b = 0, a = 0}

local bossfight = false
local bosstext = {
  {
    text = "hahahaha! well done p-man!",
    spd = 0.1,
    shake = 5
  },
  {
    text = "i am chick, your arch nemesis!!!",
    spd = 0.1,
    shake = 5
  },
  {
    text = "I was the one who turned you into a penguin!",
    spd = 0.1,
    shake = 10
  },
  {
    text = "Cock-a-doodle-dooooooo, b*tch!!",
    spd = 0.5,
    shake = 100,
    callback = function()
      assets.sfx.chicken:play()
    end
  },
  {
    text = "Come closer...",
    spd = 0.1,
    shake = 5
  },
  {
    text = "but be prepared to dodge my death-ray!",
    spd = 0.1,
    shake = 30
  }
}
local talkid = 1
local textobj = nil
local bossradius = 200

local function playermove(world, player)
  local leg = player.leg
  local ang = 2000
  local jmp = 100
  local up = 80
  local maxang = 5

  local getDir = function()
    return vector.fromPolar(leg:getAngle() - math.pi / 2)
  end

  local rotate = function(dir)
    local imp = vector.fromPolar(leg:getAngle()) * dir * ang
    local x, y = leg:getPosition()
    leg:applyAngularImpulse(ang * dir)
  end
  local av = leg:getAngularVelocity()
  if math.abs(av) > maxang then
    leg:setAngularVelocity(maxang * lume.sign(av))
  end

  if love.keyboard.isDown("left") then
    rotate(-1)
  end
  if love.keyboard.isDown("right") then
    rotate(1)
  end

  player.holding = false
  if love.keyboard.isDown("space") then
    player.holding = true
    local x, y = leg:getPosition()
    local w = player.width / 2
    local h = player.height / 2

    local r = leg:getAngle()
    local v = vector.fromPolar(r - math.pi / 2 + 0.30, h)

    local hx, hy = x + v.x, y + v.y
    local nv = v:normalized()
    local l = 40
    state.world:rayCast(
      hx,
      hy,
      hx + nv.x * l,
      hy + nv.y * l,
      function(fixt, x, y, xn, yn, frac)
        if not player.holdjoint then
          local j = world:addJoint("RopeJoint", leg, fixt:getBody(), hx, hy, x, y, l, true)
          assets.sfx.tongue:setVolume(10)
          assets.sfx.tongue:play()
          player.holdjoint = j
          player.tx = hx
          player.ty = hy
          flux.to(player, 0.5, {tx = x, ty = y}):ease("elasticout")
        end
        return 1
      end
    )
  elseif player.holdjoint then
    player.holdjoint:destroy()
    player.holdjoint = nil
  end
end

function game:draw()
  local cam, world, map = state.cam, state.world, state.map
  cam:setScale(2)
  if not fader.complete then
    cam:draw(
      function(l, t, w, h)
        love.graphics.clear(50 / 255, 60 / 255, 57 / 255)

        if debug then
          world:draw()
        end
        map:draw()
        drw.player(state.player)
        drw.boulder(state.boulder)
        lume.each(state.chicks, drw.chick)

        if debug then
          for i, v in ipairs(raydebug) do
            love.graphics.line(v.from.x, v.from.y, v.to.x, v.to.y)
          end
        end

        if state.player.holdjoint then
          local x1, y1, x2, y2 = state.player.holdjoint:getAnchors()
          love.graphics.setLineWidth(5)
          love.graphics.setLineStyle("smooth")
          love.graphics.setColor(172 / 255, 50 / 255, 50 / 255)
          love.graphics.line(x1, y1, state.player.tx, state.player.ty)
        end

        setFontSize(32)
        lume.each(
          state.player.exclaims,
          function(e)
            drw.exclaim(e.txt, e.x, e.y, e.r, e.alpha, e.c1, e.c2)
          end
        )
        local x, y = state.talk.x, state.talk.y
        if debug then
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.circle("line", x, y, bossradius)
        end
      end
    )
  end
  -- draw the fader
  love.graphics.setColor(fader.r, fader.g, fader.b, fader.a)
  love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
  if bossfight and textobj then
    setFontSize(64)
    love.graphics.setColor(0, 0, 0, 1)
    drw.text(textobj.currenttxt, 0, gameHeight / 2, gameWidth, "center")
  end
end

local function nexttalk()
  if talkid > #bosstext then
    return nil
  end
  local c = bosstext[talkid]
  return mk.texttimer(
    c.text,
    c.spd,
    function()
      screen:setShake(c.shake)
      if c.callback then
        c.callback()
      end
    end
  )
end

function game:update(dt)
  local world, player, cam = state.world, state.player, state.cam
  local x, y = player.leg:getPosition()
  local dist = vector(x, y) - vector(state.talk.x, state.talk.y)
  if (dist:len() < bossradius) and not bossfight then
    bossfight = true
    player.leg:setType("static")
    textobj = nexttalk()
    love.audio.stop()
  end
  if (textobj) then
    textobj.timer:update(dt)
    print(textobj.currenttxt)
  end

  flux.update(dt)
  if state.texttimer then
    state.texttimer.timer:update(dt)
  end

  lume.each(
    player.exclaims,
    function(e)
      e.flux:update(dt)
    end
  )
  world:update(dt)
  timer.update(dt)
  local x, y = player.leg:getPosition()
  cam:setPosition(x, y - 60)
  playermove(world, player)
  player.timer:update(dt)

  if player.leg:enter("Chicken") then
    assets.sfx.bowl:play()
    local d = player.leg:getEnterCollisionData("Chicken").collider
    local x, y = player.leg:getPosition()
    local a, b = d:getPosition()
    local dir = (vector(a, b) - vector(x, y)):normalized() * 10000

    d:applyLinearImpulse(dir.x, dir.y)
    flux.to(fader, 0.4, {a = 1}):delay(1):oncomplete(
      function()
        fader.complete = true
        timer.after(
          1,
          function()
            textobj =
              mk.texttimer(
              "Good job, P-man!",
              0.5,
              function()
                screen:setShake(10)
              end
            )
          end
        )
      end
    )
  end
end

function game:keypressed(key)
  if fader.complete then return end
  if (bossfight) and textobj and textobj.done then
    talkid = talkid + 1
    textobj = nexttalk()
    if not textobj then
      state.player.leg:setType("dynamic")
    end
  end
  if key == "up" then
    local player = state.player
    local x, y = player.leg:getPosition()
    -- player.col:applyLinearImpulse(v.x, v.y)
    local w = player.width / 2
    local h = player.height / 2

    local r = player.leg:getAngle()
    local dir = vector.fromPolar(r + math.pi / 2, h - 2)
    local pos = vector(x, y)
    local bottom = pos + dir
    local l = w
    local found = false

    for i = r, math.pi + r, 0.2 do
      local nv = vector.fromPolar(i, 1)
      local dirnorm = dir:normalized()
      local sc = (dirnorm.x * nv.x + dirnorm.y * nv.y) * l * 2 + 0.1
      local castto = bottom + nv * sc
      raydebug[#raydebug + 1] = {from = bottom, to = bottom + nv * sc}
      state.world:rayCast(
        bottom.x,
        bottom.y,
        castto.x,
        castto.y,
        function(fixt, x, y, xn, yn, frac)
          if found then
            return 0
          end
          found = true
          return 1
        end
      )
    end
    if found or debug then
      player.leg:setLinearVelocity(0, 0)
      flux.to(player, 0.1, {sx = 0.9, sy = 1.3}):after(0.2, {sx = 1, sy = 1})
      assets.sfx.jump:setVolume(0.4)
      assets.sfx.jump:play()
      player.canauch = false
      local d = vector.fromPolar(player.leg:getAngle() - math.pi / 2)
      local v = d * 2000
      player.leg:applyLinearImpulse(v.x, v.y)
    end
  end
end

function game:enter()
  screen:setShake(20)
  local m = assets.sfx.firstmusic
  m:play()
  m:setLooping(true)
  state = loadlvl("finallvl")
  local p = state.player
  p.sx = 0
  p.sy = 0
  p.leg:setType("static")
  flux.to(p, 1, {sx = 1, sy = 1}):ease("elasticout"):delay(0.5):oncomplete(
    function()
      p.leg:setType("dynamic")
    end
  )
end

return game
