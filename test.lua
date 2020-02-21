local lume = require("libraries/lume")

x = 4
y = 4
gs = 16
mvspd = 100

time = 0

buttons = {}


function collides(x1,y1, x2, y2)
  return not (x1 > x2 + gs or x2 > x1 + gs or y1 > y2 + gs or y2 > y1 + gs)
end

function istimed(stop)
  return math.abs(time - stop) < 2 
end

function mkbutton(id, x, y, stop)
  return {
    id = id,
    x = x,
    y = y,
    stop = stop,
    success = false
  }
end

function love.load()
  buttons = {
    mkbutton(1, 12, 10, 50),
    mkbutton(2, 50, 100, 10)
  }
end

function love.update(dt)
  time = time + dt
  if time > 100 then
    if lume.all(buttons, function(x) return x.success == true end) then
      buttons = lume.merge({
        mkbutton(3, 40, 20, 10),
        mkbutton(4, 100, 100, 90)
                           }, buttons)
    end

    lume.each(buttons, function(x) x.success = false end)
    time = 0
  end
  if love.keyboard.isDown("left") then
    x = x - mvspd * dt
  end
  if love.keyboard.isDown("right") then
    x = x + mvspd * dt
  end
  if love.keyboard.isDown("up") then
    y = y - mvspd * dt
  end
  if love.keyboard.isDown("down") then
    y = y + mvspd * dt
  end
end

function love.keypressed(key)
  if key == "space" then
    for i,v in ipairs(buttons) do
      if collides(x,y,v.x,v.y) then
        if istimed(v.stop) then
          v.success = true
        end
      end
    end
  end
  if key == "esc" or key == "escape" then
    love.event.quit()
  end
end

function drawbutton(b)
  if b.success then
    love.graphics.setColor(0,1,0)
  else
    love.graphics.setColor(0, 1, 1)
  end
  love.graphics.rectangle("fill",b.x,b.y, gs,gs)
  love.graphics.setColor(0,0,0)
  love.graphics.print(b.id, b.x, b.y)
end

function love.draw()
  local scale = 5
  lume.each(buttons, drawbutton)
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill",x,y, gs,gs)
  love.graphics.rectangle("fill", 70, 10, (100 - time)*scale, 20)

  for i,v in ipairs(buttons) do
    love.graphics.setColor(0,0,0)
    love.graphics.print(v.id, 70 + (100 - v.stop) * scale, 10)
  end
end

