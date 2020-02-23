local o_ten_one = require("lib/o-ten-one")
local intro = require("intro")
local splash = {}

local spl = nil

function splash:enter()
    spl = o_ten_one()
    spl.onDone = function() Gamestate.switch(intro) end
end

function splash:update(dt)
    spl:update(dt)
end

function splash:draw()
    spl:draw(dt)
end


return splash