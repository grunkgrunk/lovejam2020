local lume = require("lib/lume")
local wf = require("lib/windfield")
local vector = require("lib/vector")
local cartographer = require("lib/cartographer")
local inspect = require("lib/inspect")
local gamera = require("lib/gamera")
local timer = require("lib/timer")
local p = function(x) print(inspect(x)) end
local mk = require("mk")
local drw = require("drw")
local loadlvl = require("loadlvl")

debug = true
assets = require('lib/cargo').init('assets')
state = {}
raydebug = {}


function love.load()  
  love.graphics.setDefaultFilter( 'nearest', 'nearest' )
  state = loadlvl("finallvl")
  p(state)
end

function love.draw()
  local cam, world, map = state.cam, state.world, state.map
  cam:draw(function(l,t,w,h) 
    love.graphics.clear(50/255,60/255,57/255)
    if debug then 
      world:draw()
    end
    map:draw()
    drw.player(state.player.leg)
    drw.boulder(state.boulder)

    if debug then
      for i,v in ipairs(raydebug) do
        love.graphics.line(v.from.x, v.from.y, v.to.x, v.to.y)
      end
    end
  end)

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
    local w = player.width/2
    local h = player.height/2

    local r = leg:getAngle()
    local v = vector.fromPolar(r - math.pi / 2, h)

    local hx,hy = x + v.x, y + v.y
    local nv = v:normalized()
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
    local dir = vector.fromPolar(r + math.pi / 2, h - 2)
    local pos = vector(x,y)
    local bottom = pos + dir
    local l = w
    local found = false

    for i=r - 0.2, math.pi + r + 0.2, 0.2 do
      local nv = vector.fromPolar(i, l)
      local castto = bottom + nv
      raydebug[#raydebug + 1] = {from = bottom, to = bottom + nv}
      state.world:rayCast(bottom.x,bottom.y,castto.x,castto.y,function(fixt,x,y,xn,yn,frac)
        if found then return 0 end
        found = true
      return 1 end)
    end
    if found then 
      local d = vector.fromPolar(player.leg:getAngle() - math.pi / 2)
      local v = d * 1000
      player.leg:applyLinearImpulse(v.x, v.y)
    end
  end
end 

function love.keyreleased(key)
  
end
