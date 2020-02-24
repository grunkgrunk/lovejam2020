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
local colors = require("colors")
local loadlvl = require("loadlvl")

local game = {}

local fader = {r = 0, g = 0, b = 0, a = 0}

local bossfight = false
local bosstext = {
  {
    text = "hahahaha! well done f-man!",
    spd = 0.1,
    shake = 5
  },
  {
    text = "i am chick, your arch nemesis!!!",
    spd = 0.1,
    shake = 5
  },
  {
    text = "I was the one who turned you into a frog!!",
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
    text = "but be prepared to get fried!",
    spd = 0.1,
    shake = 40
  },
  {
    text = "lets' see what frog tastes like!!!!",
    spd = 0.1,
    shake = 100
  },

}

local tutor = {
  roll = "'left' and 'right' to roll",
  jump = "'up' to jump!",
  tongue = "'space' to tongue!"
}

local talkid = 1
local textobj = nil
local bossradius = 100
local gameover = false

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
          player.tonguefollow = false
          local j = world:addJoint("RopeJoint", leg, fixt:getBody(), hx, hy, x, y, l, true)
          assets.sfx.tongue:setVolume(10)
          assets.sfx.tongue:play()

          mk.headexclaim(player, {"Slurp!", "Omnomom!", "Slerp!", "Wham!", "Tongue!"})
          player.holdjoint = j
          player.tx = hx
          player.ty = hy
          flux.to(player, 0.5, {tx = x, ty = y}):ease("elasticout"):oncomplete(
            function()
              player.tonguefollow = true
            end
          )
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
          love.graphics.setColor(colors.names.red)
          love.graphics.setLineWidth(4)
          if state.player.tonguefollow then
            state.player.tx = x2
            state.player.ty = y2
          end
          love.graphics.circle("fill", x1, y1, 2)
          love.graphics.circle("fill", state.player.tx, state.player.ty, 2)

          love.graphics.setLineStyle("smooth")
          love.graphics.line(x1, y1, state.player.tx, state.player.ty)
        end

        local x, y = state.talk.x, state.talk.y
        if debug then
          love.graphics.setColor(0, 0, 0, 1)
          love.graphics.circle("line", x, y, bossradius)
        end
      end
    )
    love.graphics.push()
    setFontSize(64)
    lume.each(
      state.player.exclaims,
      function(e)
        local x, y = cam:toScreen(e.x, e.y)
        drw.exclaim(e.txt, x, y, e.r, e.alpha, e.c1, e.c2)
      end
    )
    setFontSize(70)
    lume.each(
      state.tutorial,
      function(e)
        local txt = tutor[e.properties.hint]
        local x, y = cam:toScreen(e.x, e.y)  
        drw.text(txt, x, y, 1000, nil, 0, 1, {0, 0, 0}, colors.names.red)
      end
    )
    love.graphics.pop()
  end

  -- draw the fader
  love.graphics.setColor(fader.r, fader.g, fader.b, fader.a)
  love.graphics.rectangle("fill", -100, -100, gameWidth + 100, gameHeight + 100)
  if bossfight and textobj then
    setFontSize(55)
    love.graphics.setColor(0, 0, 0, 1)
    local c1 = colors.names.white
    local c2 = colors.names.yellow
    
    if gameover then 
      c1,c2 = colors.names.white, colors.names.red
    end
    drw.text(textobj.currenttxt, 0, gameHeight / 2 - 200, gameWidth, "center",0,1, colors.names.white, colors.names.yellow)
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
      assets.sfx.talksnd:setVolume(2)
      assets.sfx.talksnd:setPitch(lume.random(0.7, 1.5))
      assets.sfx.talksnd:play()
      if c.callback then
        c.callback()
      end
    end
  )
end

function game:update(dt)
  local world, player, cam = state.world, state.player, state.cam
  local x, y = player.leg:getPosition()
  cam:setPosition(x, y - 50)
  local dist = vector(x, y) - vector(state.talk.x, state.talk.y)
  if (dist:len() < bossradius) and not bossfight then
    bossfight = true
    player.leg:setType("static")
    textobj = nexttalk()
    love.audio.stop()
  end
  if (textobj) then
    textobj.timer:update(dt)
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

  -- remove dead exclaims
  for i = #player.exclaims, 1, -1 do
    if player.exclaims[i].dead then
      table.remove(player.exclaims, i)
    end
  end

  world:update(dt)
  timer.update(dt)

  playermove(world, player)
  player.timer:update(dt)

  if player.leg:enter("Chicken") then
    assets.sfx.bowl:play()
    gameover = true

    local d = player.leg:getEnterCollisionData("Chicken").collider
    local x, y = player.leg:getPosition()
    local a, b = d:getPosition()
    local dir = (vector(a, b) - vector(x, y)):normalized() * 10000

    d:applyLinearImpulse(dir.x, dir.y)
    flux.to(fader, 0.4, {a = 1}):delay(2):oncomplete(
      function()
        fader.complete = true
        timer.after(
          1,
          function()
            textobj =
              mk.texttimer(
              "Good job, f-man! You saved the world!",
              0.5,
              function()
                  assets.sfx.endgame:play()
              end
            )
          end
        )
      end
    )
  end
end

function game:keypressed(key)
  if fader.complete then
    return
  end
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
      flux.to(player, 0.15, {sx = 0.9, sy = 1.3}):oncomplete(
        function()
          player.jumping = false
        end
      ):after(0.2, {sx = 1, sy = 1})
      assets.sfx.jump:setVolume(0.4)
      assets.sfx.jump:play()
      mk.headexclaim(player, {"Jump!", "C ya!", "Woosh!", "Pow!", "Fly!", "Huergh!"})
      player.jumping = true
      player.canauch = false
      local d = vector.fromPolar(player.leg:getAngle() - math.pi / 2)
      local v = d * 2000
      player.leg:applyLinearImpulse(v.x, v.y)
    end
  end
end

function game:enter()
  screen:setShake(20)
  assets.sfx.teleport:play()
  assets.sfx.teleportintro:play()
  local m = assets.sfx.background
  timer.after(
    3,
    function()
      m:play()
      m:setLooping(true)
    end
  )

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
