local mk = require("mk")
local drw = require("drw")
local game = require("game")
local intro = {}
local texttimer = nil

local introdone = false


local index = 1

local series = {
    {
        x = 320,
        y = 300,
        limit = 1000,
        text = "You are P-Man!",
        spd = 0.2,
    },
    {
        x = 450,
        y = 100,
        limit = 700,
        text = "The best looking super hero in the world!",
        spd = 0.2,
        img = 1
    },
    {
        x = 450,
        y = 280,
        limit = 700,
        text = "BAM!!!",
        spd = 0.2,
    },
    {
        x = 250,
        y = 200,
        limit = 700,
        text = "You have to save the world from 'evil chick'",
        spd = 0.2,
    },
    {
        x = 0,
        y = 550,
        limit = 1000,
        text = "She is hiding at the peak of the ever feared 'mount evil'",
        spd = 0.22,
        img = 2
    },
    {
        x = 420,
        y = 280,
        limit = 700,
        text = "kapow!!!",
        spd = 0.2,
    },
    {
        x = 0,
        y = 550,
        limit = 1400,
        text = "With help from 'dr. Pseudo' you will quantum-teleport directly to the top",
        spd = 0.2,
        img = 3
    },
    {
        x = 380,
        y = 280,
        limit = 700,
        text = "SCIENCE!!!!!!",
        spd = 0.2,
    },
    {
        x = 280,
        y = 280,
        limit = 700,
        text = "Get ready to teleport!",
        spd = 0.2,
    },
    {
        x = 450,
        y = 280,
        limit = 700,
        text = "3...",
        spd = 0.2,
    },
    {
        x = 450,
        y = 280,
        limit = 700,
        text = "2...",
        spd = 0.2,
    },
    {
        x = 450,
        y = 280,
        limit = 700,
        text = "1...",
        spd = 0.2,
    },
    {
        x = 450,
        y = 280,
        limit = 700,
        text = "0...",
        spd = 0.2,
    },
    {
        x = 450,
        y = 280,
        limit = 700,
        text = "-1...",
        spd = 0.2,
    },
    {
        x = 380,
        y = 500,
        limit = 700,
        text = "ohoh...",
        spd = 0.2,
        img = 4
    },
    {
        x = 90,
        y = 500,
        limit = 1000,
        text = "Looks like 'dr. Pseudo' forgot to remove the test animal",
        spd = 0.2,
        img = 4
    },
    {
        x = 400,
        y = 280,
        limit = 700,
        text = "Good luck anyways, P-man!!",
        spd = 0.2,
        img = 5
    }

    

}

function nextTimer()
    local c = series[index]
    return mk.texttimer(c.text, c.spd, 
    function()
        -- play sound
        screen:setShake(5) 
    end)
end

function intro:enter()
    local m = assets.sfx.intromusictotal
    m:play()
    m:setLooping(true)
    texttimer = nextTimer()
   
end
function intro:exit()
    love.audio.stop(m)
end

function intro:update(dt)
    if introdone then return end
    if not texttimer then return end
    texttimer.timer:update(dt)

end

function intro:draw()
    if introdone then return end
    if not texttimer then return end
    local c = series[index]
    local x,y, lim = c.x,c.y, c.limit
    if c.img then
        love.graphics.draw(assets.art.comic[c.img], 0,0)
    end
    if texttimer then
        drw.text(texttimer.currenttxt, x,y, lim)
    end
end

function intro:keypressed(key)
    if introdone then
        Gamestate.switch(game)
    end
    if not texttimer then return end
    if true or texttimer.done then
        index = index + 1
        if index > #series then 
            introdone = true
            return
        end
        texttimer = nextTimer()
    end
end

return intro