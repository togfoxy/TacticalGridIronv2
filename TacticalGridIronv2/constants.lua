constants = {}

function constants.load()
    -- includes globals
    GAME_VERSION = "0.01"

    SCREEN_STACK = {}

    SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getDesktopDimensions(1)






    enum = {}
    enum.sceneMainMenu = 1
    enum.sceneCredits = 2
    enum.sceneDisplaySeasonStatus = 3

    enum.buttonMainMenuExit = 1
    enum.buttonMainMenuCredits = 2
    enum.buttonCreditsExit = 3
    enum.buttonMainMenuNewGame = 4


end

return constants
