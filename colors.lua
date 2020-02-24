local lume = require("lib/lume")

local names = {
    red = {243 / 255, 0, 3 / 255},
    blue = {56 / 255, 54 / 255, 253 / 255},
    white = {242 / 255, 244 / 255, 229 / 255},
    yellow = {248 / 255, 207 / 255, 23 / 255}, 
}

local contrasts = {
    names.red,
    names.blue,
    names.white,
    names.yellow
}

return {
    names = names,
    contrasts = contrasts
}
