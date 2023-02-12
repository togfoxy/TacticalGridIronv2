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
    DB_FILE = DB_PATH .. "databasenew.db"

    NUM_OF_TEAMS = 8

    SCALE = 8   -- for graphics/drawing

    CURRENT_SEASON = 1
    OFFENSIVE_TEAMID = nil
    DEFENSIVE_TEAMID = nil
    OFFENSIVE_SCORE = nil   -- this is the first team to play
    OFFENSIVE_TIME = nil      -- the number of turns taken to score. Used to break a tie
    OPPONENTS_SCORE = nil
    OPPONENTS_TIME = nil

    CHAMPION_TEAMID = nil
    CHAMPION_SCORE = nil
    CHAMPION_TIME = nil

    enums.load()
end

return constants
