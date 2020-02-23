local drw = {}
function drw.boulder(boulder)
    x,y = boulder:getPosition()
    r = boulder:getAngle()
    love.graphics.draw(assets.art.boulder, x,y, r, 1, 1, 45, 45)
end

function drw.chicken(feet)
    x,y = feet:getPosition()
    r = feet:getAngle()
    love.graphics.draw(assets.art.chickenleg, x,y, r, 1, 1, 45, 45)
end

function drw.player(pl)
local x,y = pl:getPosition()
local r = pl:getAngle()
love.graphics.draw(assets.art.pengu, x,y, r, 0.4, 0.4, 75, 120)
end

return drw