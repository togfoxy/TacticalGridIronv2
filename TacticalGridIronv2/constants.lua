constants = {}

function constants.load()
    -- includes globals
    GAME_VERSION = "0.01"

    SCREEN_STACK = {}

    SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getDesktopDimensions(1)

    -- declaring these nil for readability
    DB_PATH = nil
    DB_FILE = nil
    REFRESH_DB = false

    DB_PATH = love.filesystem.getSourceBaseDirectory()
    if love.filesystem.isFused() then
        DB_PATH = DB_PATH .. "\\savedata\\"
    else
        DB_PATH = DB_PATH .. "/TacticalGridIronv2/savedata/"
    end
    DB_FILE = DB_PATH .. "database.db"

    NUM_OF_TEAMS = 8

    SCALE = 6   -- for graphics/drawing



    enums.load()
end

return constants
