local vector = require("lib/vector")

local util = {}


function util.dir(player)
    local w = player.width / 2
    
    local r = leg:getAngle()

    local v = vector.fromPolar(r - math.pi / 2 + 0.30)
    return v
end

function util.mouthpos(player)
    local h = player.height / 2
    local x, y = leg:getPosition()
    return vector(x,y) + util.dir(player) * h
end



return util