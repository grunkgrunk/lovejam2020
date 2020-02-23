local drw = {}



function drw.boulder(boulder)
    x,y = boulder:getPosition()
    r = boulder:getAngle()
    love.graphics.draw(assets.art.boulder, x,y, r, 1, 1, 45, 45)
end

function drw.chick(feet)
    x,y = feet:getPosition()
    r = feet:getAngle()
    love.graphics.draw(assets.art.chickenleg, x,y, r, 1, 1, 80, 205)
end

function drw.player(pl)
local x,y = pl:getPosition()
local r = pl:getAngle()
love.graphics.draw(assets.art.pengu, x,y, r, 0.4, 0.4, 75, 120)
end

function drw.text(txt, x, y, lim)
    love.graphics.push()
    love.graphics.setColor(251/255,242/255,54/255)
    love.graphics.printf(txt, x, y, lim)
    love.graphics.setColor(1,0,0)
    love.graphics.printf(txt, x + 2, y + 3, lim)
    love.graphics.pop()
end



return drw