local lume = require("lib/lume")
local wf = require("lib/windfield")
local vector = require("lib/vector")


function mkplayer()
  x = 400 - 50/2
  y = 0
  box = world:newRectangleCollider(x, y, 50, 100)
  box:setCollisionClass("Player")
  box:setObject(box)

  circ = world:newCircleCollider(x + 25, y, 25)
  circ:setMass(0)
  circ:setCollisionClass("Hand")
  circ:setObject(box) -- what is this??


  world:addJoint('WeldJoint', box, circ, x + 25,y)
  return {
    col = box,
    hand = circ,
    grounded = false,
    holding = false
  }
end

function mkground(x, y, w, h)
  local ground = world:newRectangleCollider(x, y, w, h) 
  ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
  ground:setCollisionClass("Ground")
  return ground
end

function mkcircle(x, y, r)
  local c = world:newCircleCollider(x, y, r)
  c:setType("static")
  c:setCollisionClass("Ground")
  return c 
end


function love.load()
  world = wf.newWorld(0,0, true)
  world:setGravity(0, 512)

  classes = {"Player", "Ground", "Hand"}
  lume.each(classes, function(w) world:addCollisionClass(w) end)

  mkground(0, 550, 800, 50)
  mkground(0,0,50,600)
  mkground(750,0,50,600)

  mkcircle(300, 300, 30)

  player = mkplayer()
end

function love.draw()
  world:draw()
end

function love.update(dt)
  world:update(dt)

  if player.col:enter("Ground") then
    player.grounded = true
  end

  if player.col:exit("Ground") then
    player.grounded = false
  end

  if love.keyboard.isDown("down") and player.grounded then
    angle = player.col:getAngle() - math.pi / 2
    v = vector.fromPolar(angle, 2000) 
    player.col:applyLinearImpulse(v.x, v.y)
  end

  if love.keyboard.isDown("left") then
    player.col:applyLinearImpulse(0, -80)
    player.col:applyAngularImpulse(-1000)
  end
  if love.keyboard.isDown("right") then
    player.col:applyLinearImpulse(0, -80)
    player.col:applyAngularImpulse(1000)
  end

  if love.keyboard.isDown("up") then
    angle = player.col:getAngle() - math.pi / 2
    v = vector.fromPolar(angle, 200) 
    -- player.col:applyLinearImpulse(v.x, v.y)
    if not player.holdjoint and player.hand:enter("Ground") then
      local x1,y1,x2,y2 = player.hand:getEnterCollisionData("Ground").contact:getPositions()
      local v = (vector(x1,y1) + vector(x2, y2)) / 2
      local j = world:addJoint("RevoluteJoint", player.hand, player.hand:getEnterCollisionData("Ground").collider, x1,y1)
      player.holdjoint = j
    end
  elseif player.holdjoint then
    player.holdjoint:destroy()
    player.holdjoint = nil
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
