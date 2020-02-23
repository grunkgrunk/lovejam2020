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
  local tileW, tileH = 80,80
  local world = wf.newWorld(0,0, true)
  world:setGravity(0, 512)
  
  
  world:addCollisionClass("Player", {ignores = {"Player"}})
  world:addCollisionClass("Leg", {ignores = {"Player"}})
  world:addCollisionClass("Solid")
  world:addCollisionClass("Foot", {ignores = {"Player"}})
  world:addCollisionClass("Hand", {ignores = {"Player"}, enter = {"Solid"} })
  
  m = assets.sfx.firstmusic
  m:play()
  m:setLooping(true)
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
  local w,h = 35, 70
  -- position players' feet at where the arrow points
  y = y - h
  leg = world:newRectangleCollider(x, y, w, h)
  leg:setCollisionClass("Player")
  leg:setObject(leg)
  leg:setFriction(10)
  leg:setMass(3.5)
  leg:setPreSolve(function(collider_1, collider_2, contact)
    --if(collider_2.getCollisionClass() == 'Ground' or collider_1.getCollisionClass() == 'Ground') then
      local vx,vy = collider_1:getLinearVelocity()
      local v = math.abs(vx)+math.abs(vy) + math.abs(collider_1:getAngularVelocity())
  
      if(v>400) then
        assets.sfx.stortsmack:play()
      elseif(v>250)then
        assets.sfx.smack:play()
      end
    --end
  end)

  -- world:addJoint('WeldJoint', arm, bind, x + w/2,y)
  -- world:addJoint('WeldJoint', hand, arm, x + w/2, y - h)
  return {
    width = w,
    height = h,
    leg = leg,
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
  state = loadlvl("finallvl")
end

function love.draw()
  local cam, world, map = state.cam, state.world, state.map
  cam:draw(function(l,t,w,h) 
    love.graphics.clear(50/255,60/255,57/255)
    if debug then 
      world:draw()
    end
    map:draw()
    playerdraw(state.player)
  end)

end


function playerdraw(player)
  local leg = player.leg
  local x,y = leg:getPosition()
  local r = leg:getAngle()
  -- love.graphics.draw(assets.art.player, x,y, r, 0.2, 0.2, 100, 801)

  x,y = leg:getPosition()
  r = leg:getAngle()
  -- local s = assets.art.arm
  -- if player.holding then
  --   s = assets.art.almosthold
  -- end
  -- if player.holdjoint then
  --   s = assets.art.hold
  -- end
  love.graphics.draw(assets.art.pengu, x,y, r, 0.4, 0.4, 75, 120)
end

function playermove(world, player)
  local leg = player.leg
  local ang = 2000
  local jmp = 100
  local up = 80
  local maxang = 5
  
  local getDir = function()
    return vector.fromPolar(leg:getAngle() - math.pi / 2)
  end

  local rotate = function(dir)
    -- player.leg:applyLinearImpulse(0, -up)
    local imp = vector.fromPolar(leg:getAngle()) * dir * ang
    local x,y = leg:getPosition()
    -- leg:applyLinearImpulse(imp.x, imp.y, x, y)
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
    local x,y = leg:getPosition()
    -- player.col:applyLinearImpulse(v.x, v.y)
    local w = player.width/2
    local h = player.height/2

    local r = leg:getAngle()
    local v = vector.fromPolar(r - math.pi / 2, h)

    local hx,hy = x + v.x, y + v.y
    local nv = v:normalized()
    --local col = world:queryCircleArea(hx,hy, w + 6, {'Solid'})
    local l = 30
    state.world:rayCast(hx,hy,hx+nv.x*l,hy+nv.y*l,function(fixt,x,y,xn,yn,frac) 
        if not player.holdjoint then
          local j = world:addJoint("RopeJoint", leg, fixt:getBody(), hx,hy,x,y,l,true)
          player.holdjoint = j
        end
      return 1 end)
    
    
  elseif player.holdjoint then
    player.holdjoint:destroy()
    player.holdjoint = nil
  end
end

function love.update(dt)
  -- require("lib/lurker").update()
  local world, player, cam = state.world, state.player, state.cam
  world:update(dt)
  timer.update(dt)
  cam:setPosition(player.leg:getPosition())

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

  if key == "up" then
    local player = state.player
    local x,y = player.leg:getPosition()
    -- player.col:applyLinearImpulse(v.x, v.y)
    local w = player.width/2
    local h = player.height/2


    local r = player.leg:getAngle()
    local v = vector.fromPolar(r - math.pi / 2, h)

    local hx,hy = x - v.x, y - v.y
    local col = state.world:queryCircleArea(hx,hy, w, {'Solid'})
    
    if #col > 0 then
      local d = vector.fromPolar(player.leg:getAngle() - math.pi / 2)
      local v = d * 1000
      player.leg:applyLinearImpulse(v.x, v.y)
    end
    
    -- player.arm:applyLinearImpulse(v.x, v.y)  
  end
end 

function love.keyreleased(key)
  
end
