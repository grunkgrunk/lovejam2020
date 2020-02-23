function love.conf(t)
    t.identity = nil                    -- The name of the save directory (string)
    t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.console = true                    -- Attach a console (boolean, Windows only)
    t.accelerometerjoystick = true      -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = false           -- True to save files (and read from the save directory) in external storage on Android (boolean) 
    t.window.title = "Untitled"         -- The window title (string)
    t.window.width = 1600                -- The window width (number)
    t.window.height = 900               -- The window height (number)
    t.window.borderless = false         -- Remove all border visuals from the window (boolean)
end
