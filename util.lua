local vector = require("lib/vector")

local util = {}


function util.dir(player)
    local w = player.width / 2
    local r = leg:getAngle()
    local v = vector.fromPolar(r - math.pi / 2)
    return v
end

function util.mouthpos(player)
    local h = player.height / 2 - 6
    local x, y = leg:getPosition()
    local dir = util.dir(player)
    return vector(x,y) + dir * h + vector(-dir.y, dir.x) * 12
end



return util