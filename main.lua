local lume = require("lib/lume")
local wf = require("lib/windfield")
local vector = require("lib/vector")
local cartographer = require("lib/cartographer")
local inspect = require("lib/inspect")
local gamera = require("lib/gamera")
local timer = require("lib/timer")
local p = function(x) print(inspect(x)) end

debug = true
assets = require('lib/cargo').init('assets')
state = {}

function loadlvl(lvl)
  local tileW, tileH = 16,16
  local world = wf.newWorld(0,0, true)
  world:setGravity(0, 512)
  
  
  world:addCollisionClass("Player", {ignores = {"Player"}})
  world:addCollisionClass("Leg", {ignores = {"Player"}})
  world:addCollisionClass("Solid")
  world:addCollisionClass("Foot", {ignores = {"Player"}})
  world:addCollisionClass("Hand", {ignores = {"Player"}, enter = {"Solid"} })
  

  world:setQueryDebugDrawing(true)
  local map = cartographer.load("lvls/" .. lvl .. ".lua")
  local solidlayer = map:getLayer("Solid")
  for i,gid,gx,gy,x,y in solidlayer:getTiles() do
    mksolid(world, x, y, tileW, tileH)
  end
  
  local pl = map:getLayer("Player").objects[1]
  local player = mkplayer(world, pl.x, pl.y)
  
  local left, top, right, bottom = solidlayer:getPixelBounds()
  local cam = gamera.new(left,top,right,bottom)
  cam:setScale(2)
  return {
    cam = cam,
    world = world,
    player = player,
    map = map,
    lvl = lvl
  }
end

function mkplayer(world, x, y)
  local w,h = 20, 80
  -- position players' feet at where the arrow points
  y = y - h
  leg = world:newRectangleCollider(x, y, w, h)
  leg:setCollisionClass("Player")
  leg:setObject(leg)
  leg:setFriction(10)
  --leg:addShape("Foot", "RectangleShape", x, y+h, w + w / 2, 8)
  
  --world:addJoint('WeldJoint', foot, leg, x, y+h)
  --world:addJoint('WeldJoint', foot, leg, x+w, y+h)
  -- j:setDampingRatio(0.01)
  bind = world:newCircleCollider(x + w/2, y, w / 2)
  bind:setMass(0)
  -- bind:setCollisionClass("Hand")
  bind:setObject(leg) -- what is this??
  
  arm = world:newRectangleCollider(x, y - h, w, h)
  arm:setCollisionClass("Player")
  arm:setObject(leg)
  
  -- hand = world:newCircleCollider(x + w/2, y - h, w / 4)
  -- hand:setMass(0)
  -- hand:setCollisionClass("Hand")
  -- hand:setObject(leg) -- maybe no collisions
  
  local j = world:addJoint('PrismaticJoint', leg, bind, x + w/2,y, 0, -1)
  j:setLimits(-40, 0) 
  --j:setDampingRatio(1)
  --j:setFrequency(50)
  world:addJoint('WeldJoint', arm, bind, x + w/2,y)
  -- world:addJoint('WeldJoint', hand, arm, x + w/2, y - h)
  return {
    width = w,
    height = h,
    arm = arm,
    -- hand = hand,
    leg = leg,
    bind = bind,
    legjoint = j,
    grounded = false,
    holding = false
  }
end

function mksolid(world, x, y, w, h)
  local ground = world:newRectangleCollider(x, y, w, h) 
  ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
  ground:setCollisionClass("Solid")
  return ground
end

function mkcircle(world, x, y, r)
  local c = world:newCircleCollider(x, y, r)
  c:setType("static")
  c:setCollisionClass("Solid")
  return c 
end

function love.load()  
  love.graphics.setDefaultFilter( 'nearest', 'nearest' )
  state = loadlvl("test")
end

function love.draw()
  local cam, world, map = state.cam, state.world, state.map
  cam:draw(function(l,t,w,h) 
    if debug then 
      world:draw()
    end
    map:draw()
    playerdraw(state.player)
  end)

end


function playerdraw(player)
  local arm, leg = player.arm, player.leg
  local x,y = leg:getPosition()
  local r = leg:getAngle()
  love.graphics.draw(assets.art.leg, x,y, r, 0.2, 0.2, 100, 801)

  x,y = arm:getPosition()
  r = arm:getAngle()

  local s = assets.art.arm
  if player.holding then
    s = assets.art.almosthold
  end
  if player.holdjoint then
    s = assets.art.hold
  end

  love.graphics.draw(s, x,y, r, 0.2, 0.2, 100, 400)
end

function playermove(world, player)
  local leg,arm = player.leg, player.arm
  local ang = 7000
  local jmp = 100
  local up = 80
  
  local getDir = function()
    return vector.fromPolar(leg:getAngle() - math.pi / 2)
  end

  local rotate = function(dir)
    -- player.leg:applyLinearImpulse(0, -up)
    local imp = vector.fromPolar(leg:getAngle()) * dir * ang
    local x,y = player.bind:getPosition()
    -- leg:applyLinearImpulse(imp.x, imp.y, x, y)
    player.bind:applyAngularImpulse(ang * dir)
  end


  --if love.keyboard.isDown("down") and not player.grounded then
  --  local v = -getDir() * jmp * 10
  --  player.leg:applyLinearImpulse(v.x, v.y)
  --end

  if love.keyboard.isDown("left") then
    rotate(-1)
  end
  if love.keyboard.isDown("right") then
    rotate(1)
  end

  player.holding = false
  if love.keyboard.isDown("space") then
    player.holding = true
    v = getDir()
    local x,y = arm:getPosition()
    -- player.col:applyLinearImpulse(v.x, v.y)
    local w = player.width/2
    local h = player.height/2

    local r = arm:getAngle()
    local v = vector.fromPolar(r - math.pi / 2, h)

    local hx,hy = x + v.x, y + v.y
    local col = world:queryCircleArea(hx,hy, w + 6, {'Solid'})
    
    if not player.holdjoint and #col > 0 then
      local c = col[1]
      local j = world:addJoint("RevoluteJoint", arm, c, hx,hy )
      player.holdjoint = j
    end
  elseif player.holdjoint then
    player.holdjoint:destroy()
    player.holdjoint = nil
  end

  if love.keyboard.isDown("down") then
    local player = state.player
    local d = vector.fromPolar(player.leg:getAngle() - math.pi / 2)
    local v = d * 100
    player.leg:applyLinearImpulse(v.x, v.y)
    player.arm:applyLinearImpulse(-v.x, -v.y)
  else
    local player = state.player
    local d = vector.fromPolar(player.leg:getAngle() - math.pi / 2)
    local v = d * 100
    player.leg:applyLinearImpulse(-v.x, -v.y)
    player.arm:applyLinearImpulse(v.x, v.y)
  end
end

function love.update(dt)
  require("lib/lurker").update()
  local world, player, cam = state.world, state.player, state.cam
  world:update(dt)
  timer.update(dt)
  cam:setPosition(player.bind:getPosition())

  if player.leg:enter("Ground") then
    player.grounded = true
  end

  if player.leg:exit("Ground") then
    player.grounded = false
  end

  playermove(world, player)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if key == "r" then
    state = loadlvl(state.lvl)
  end

  if key == "d" then 
    debug = not debug
  end
end 

function love.keyreleased(key)
  if key == "down" then
    local player = state.player
    local d = vector.fromPolar(player.leg:getAngle() - math.pi / 2)
    local v = d * 1000 * 4
    player.leg:applyLinearImpulse(-v.x, -v.y)
    player.arm:applyLinearImpulse(v.x, v.y)
  end
end
