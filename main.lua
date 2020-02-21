px = 500
py = 300
direction = -math.pi/2


speed = 6*10
angspd = 1
mag = 10

amp = 10
ampspd = 1
freq = 10
points = {}
time = 0
function love.update(dt)
    time = time + dt
    dx =  math.cos(direction)
    dy = math.sin(direction)
    px = px +dx*speed*dt
    py = py + dy*speed*dt


    phase = math.sin(time * freq) * amp

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
    if love.keyboard.isDown("down") and amp > 0 then
        amp = amp - ampspd*dt
    end
    freq = 1/amp*200
    spd = freq*6
end

function love.draw()
    love.graphics.print(spd,px,py)
    if #points>2 then
        love.graphics.line(points)
    end
end