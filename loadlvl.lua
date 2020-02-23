local mk = require("mk")
local vector = require("lib/vector")
local cartographer = require("lib/cartographer")
local inspect = require("lib/inspect")
local gamera = require("lib/gamera")
local lume = require("lib/lume")
local wf = require("lib/windfield")

local function load(lvl)
    local tileW, tileH = 80,80
    local world = wf.newWorld(0,0, true)
    world:setGravity(0, 512)
    
    world:addCollisionClass("Player", {ignores = {"Player"}})
    world:addCollisionClass("Solid")
    world:addCollisionClass("Boulder")

    local map = cartographer.load("lvls/" .. lvl .. ".lua")
    local solidlayer = map:getLayer("Solid")
    for i,gid,gx,gy,x,y in solidlayer:getTiles() do
      mk.rect(world, x, y, tileW, tileH):setType("static")
    end


    for i,gid,gx,gy,x,y in map:getLayer("SmallSolid") do
      mk.rect(world, x, y, 20, 20):setType("static")
    end
    
    local pl = map:getLayer("Player").objects[1]
    local player = mk.player(world, pl.x, pl.y)
  
    local boulder = nil
    if map:getLayer("Boulder") then
      local b = map:getLayer("Boulder").objects[1]
      boulder = mk.circle(world, b.x, b.y,40)
    end
    
    local left, top, right, bottom = solidlayer:getPixelBounds()
    local cam = gamera.new(left,top,right,bottom)
    
    cam:setScale(2)
    return {
      cam = cam,
      world = world,
      player = player,
      map = map,
      lvl = lvl,
      boulder = boulder
    }
  end

  return load