local timer = require("lib/timer")
local lume = require("lib/lume")
local mk = {}
local flux = require("lib/flux")
local colors = require("colors")
function mk.boulder(world, x, y)
  local c = mk.circle(world, x, y, 40)
  c:setCollisionClass("Solid")
  c:setAngularDamping(4)
  c:setMass(3)
  c:setFriction(2)
  return c
end

function mk.rect(world, x, y, w, h)
  local r = world:newRectangleCollider(x, y, w, h)
  -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
  r:setCollisionClass("Solid")
  return r
end

function mk.circle(world, x, y, r)
  local c = world:newCircleCollider(x, y, r)
  c:setCollisionClass("Solid")
  return c
end

function mk.texttimer(txt, spd,every)
  every = every or function()
    end
  local finaltxt = lume.split(txt)
  local t = timer.new()
  local o = {
    n = 1,
    finaltxt = finaltxt,
    currenttxt = "",
    timer = t,
    done = false
  }
  t:every(
    spd,
    function()
      every()
      o.currenttxt = o.currenttxt .. " " .. o.finaltxt[o.n]
      if o.n == #o.finaltxt then
        o.done = true
      end
      o.n = o.n + 1
    end,
    #finaltxt
  )

  return o
end

function mk.exclaim(txt, x, y, r)
  local f = flux.group()
  local c = lume.shuffle(colors.contrasts)
  local o = {
    x = x,
    y = y,
    r = r,
    txt = txt,
    flux = f,
    alpha = 1,
    dead = false,
    c1 = c[1],
    c2 = c[2]
  }
  f:to(o, 0.3, {alpha = 0}):delay(1):oncomplete(
    function()
      o.dead = true
    end
  )
  return o
end

function mk.headexclaim(player, words)
  if lume.any(player.exclaims, function(e) return (e.alpha == 1) end) then return end
  local x, y = player.leg:getPosition()
  
  player.exclaims[#player.exclaims + 1] = mk.exclaim(lume.randomchoice(words), x, y - 80 + lume.random(-10, 10), lume.random(-0.5, 0.5))
end

function mk.player(world, x, y)
  local exclaims = {}
  local w, h = 35, 70
  local t = timer.new()
  y = y - h
  leg = world:newRectangleCollider(x, y, w, h)
  local o = {
    sx = 1,
    sy = 1,
    tx = 0,
    ty = 0,
    width = w,
    height = h,
    leg = leg,
    grounded = false,
    drawtongue = false,
    auch = false,
    smallauch = false,
    canauch = true,
    jumping = false,
    timer = t,
    exclaims = exclaims,
  }

  -- position players' feet at where the arrow points
  leg:setCollisionClass("Player")
  leg:setObject(leg)
  leg:setFriction(10)
  leg:setMass(3.5)
  leg:setPreSolve(
    function(collider_1, collider_2, contact)
      local vx, vy = collider_1:getLinearVelocity()
      local v = math.abs(vx) + math.abs(vy) + math.abs(collider_1:getAngularVelocity())

      if o.canauch then
        if (v > 400) then
          o.canauch = false
          local x, y = leg:getPosition()
          local excl = {"auch!", "ow!", "ahhh!", "argg!", "av!", "ugh!", "bonk!", "bam!"}
          mk.headexclaim(o, excl)
          o.auch = true
          t:after(
            0.2,
            function()
              o.auch = false
            end
          )
          assets.sfx["av" .. lume.randomchoice({1, 2, 3})]:play()
          screen:setShake(30)
        elseif (v > 250) then
          o.canauch = false
          o.smallauch = true
          t:after(
            0.1,
            function()
              o.smallauch = false
            end
          )
          assets.sfx.smack:play()
          assets.sfx.wetbelly:setVolume(0.2)
          assets.sfx.wetbelly:play()
        end
      end
    end
  )
  leg:setPostSolve(
    function(c1, c2, c)
      o.canauch = true
    end
  )
  return o
end

function mk.chick(world, x, y)
  x, y = x, y - 200
  local r = mk.rect(world, x, y, 30, 200)
  r:setCollisionClass("Chicken")
  return r
end

return mk
