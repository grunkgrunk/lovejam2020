Gamestate = require("lib/gamestate")
assets = require("lib/cargo").init("assets")
screen = require("lib/shack")
gameWidth, gameHeight = 1080, 720 --fixed game resolution

local lume = require("lib/lume")
local inspect = require("lib/inspect")
local timer = require("lib/timer")
local push = require("lib/push")
p = function(x)
  print(inspect(x))
end
local mk = require("mk")
local drw = require("drw")
local game = require("game")
local intro = require("intro")
local splash = require("splash")

debug = false
state = {}
raydebug = {}

function setFontSize(n)
  local font = assets.font.Shaka_Pow
  love.graphics.setFont(font(n))
end 

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  local windowWidth, windowHeight = love.window.getDesktopDimensions()
  windowWidth, windowHeight = windowWidth * .7, windowHeight * .7 --make the window a bit smaller than the screen itself

  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})
  screen:setDimensions(push:getDimensions())
  Gamestate.switch(game)
end

function love.draw()
  if Gamestate.current() == splash then
    Gamestate.draw()
  else
    push:start()
    screen:apply()
    Gamestate.draw()
    push:finish()
  end
end

function love.update(dt)
  screen:update(dt)
  --require("lib/lurker").update()
  if state.texttimer then
    state.texttimer.timer:update(dt)
  end
  Gamestate.update(dt)
end

function love.keypressed(key)
  Gamestate.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end

  if key == "d" then
    debug = not debug
  end

  if key == "r" then
    Gamestate.switch(Gamestate.current())
  end
end

function love.resize(w, h)
  return push:resize(w, h)
end
