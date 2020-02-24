function love.conf(t)
    t.releases = {
        title = "The Fantastic F-Man",              -- The project title (string)
        package = nil,            -- The project command and package name (string)
        loveVersion = "11.3",        -- The project LÖVE version
        version = nil,            -- The project version
        author = "Schrunkin",             -- Your name (string)
        email = nil,              -- Your email (string)
        description = nil,        -- The project description (string)
        homepage = nil,           -- The project homepage (string)
        identifier = nil,         -- The project Uniform Type Identifier (string)
        excludeFileList = {"*.tmx", "*.kra"},     -- File patterns to exclude. (string list)
        releaseDirectory = "./release",   -- Where to store the project releases (string)
      }
    t.identity = nil                    -- The name of the save directory (string)
    t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.console = false                    -- Attach a console (boolean, Windows only)
    t.accelerometerjoystick = true      -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = false           -- True to save files (and read from the save directory) in external storage on Android (boolean) 
    t.window.title = "The Fantastic F-man"         -- The window title (string)
    t.window.width = 1600                -- The window width (number)
    t.window.height = 900               -- The window height (number)
    t.window.borderless = false         -- Remove all border visuals from the window (boolean)
end
