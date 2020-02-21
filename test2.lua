local lume = require("libraries/lume")

px = 500
py = 300
direction = -math.pi/2


angspd = 1
mag = 10

amp = 10
ampspd = 10

points = {}
time = 0

function cfreq(amp)
  return 100/amp
end

function cspeed(amp)
 return 600/amp
end

function love.update(dt)
  time = time + dt * cfreq(amp)
    dx =  math.cos(direction)
    dy = math.sin(direction)
    px = px +dx*cspeed(amp)*dt
    py = py + dy*cspeed(amp)*dt


    phase = math.sin(time) * amp

    table.insert(points, px - dy*phase)
    table.insert(points, py + dx*phase)

    if love.keyboard.isDown("left") then
        direction = direction - angspd * dt
    end
    
    if love.keyboard.isDown("right") then
        direction = direction + angspd * dt
    end

    if love.keyboard.isDown("up") then
       amp = amp + ampspd *dt
    end
    if love.keyboard.isDown("down") then
       amp = amp - ampspd*dt
    end

    amp = lume.clamp(amp, 1, 50)
end

function love.draw()
    if #points>2 then
        love.graphics.line(points)
    end
end


function love.keypressed(key)
  if key == "escape " then
    love.event.quit()
  end
end
