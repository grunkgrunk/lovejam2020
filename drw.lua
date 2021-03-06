local colors = require("colors")
local lume = require("lib/lume")
local drw = {}

function drw.boulder(boulder)
    x, y = boulder:getPosition()
    r = boulder:getAngle()
    love.graphics.draw(assets.art.boulder, x, y, r, 1, 1, 45, 45)
end

function drw.chick(feet)
    x, y = feet:getPosition()
    r = feet:getAngle()
    love.graphics.draw(assets.art.chickenleg, x, y, r, 1, 1, 80, 205)
end

function drw.player(player)
    love.graphics.push( )
    love.graphics.setColor(1,1,1)
    local leg = player.leg
    local x, y = leg:getPosition()
    local r = leg:getAngle()
    local s = assets.art.pengu.idle
    if player.drawtongue or player.smallauch then
        s = assets.art.pengu.smallauch
    end
    if player.auch then
        s = assets.art.pengu.bigauch
    end
    if player.jumping then 
        s = assets.art.pengu.jump
    end
    love.graphics.draw(s, x, y, r, 0.4 * player.sx, 0.4 * player.sy, 75, 120)
    love.graphics.pop()
end

function drw.exclaim(txt, x,y,r, alpha, c1, c2)
    drw.text(txt,x,y,3000,nil,r, alpha, c1, c2)
end

function drw.text(txt, x, y, lim, align,rot, alpha,c1,c2)
    love.graphics.push()
    if align == "center" then
        local f = love.graphics.getFont()
        local textobj = love.graphics.newText(f, txt)
        love.graphics.translate(0, -textobj:getHeight() / 2)
    end
    
    local lim = lim or 1000
    local c1 = c1 or colors.names.white
    local c2 = c2 or colors.names.red
    love.graphics.setColor(c1[1], c1[2], c1[3], alpha or 1)
    love.graphics.printf(txt, x, y, lim, align,rot)
    love.graphics.setColor(c2[1],c2[2], c2[3], alpha or 1)
    love.graphics.printf(txt, x + 2, y + 3, lim, align,rot)
    love.graphics.pop()
end

return drw
