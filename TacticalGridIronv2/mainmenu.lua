mainmenu = {}

function mainmenu.keyreleased(key)
    if key == "escape" then
        cf.RemoveScreen(SCREEN_STACK)
    end
end

function mainmenu.mousereleased(rx, ry)
    local clickedButtonID = buttons.getButtonID(rx, ry)

    if clickedButtonID == enum.buttonMainMenuExit then
        cf.RemoveScreen(SCREEN_STACK)
    elseif clickedButtonID == enum.buttonMainMenuCredits then
        cf.AddScreen(enum.sceneCredits, SCREEN_STACK)
    elseif clickedButtonID == enum.buttonMainMenuNewGame then
        fun.createNewGame()   -- populates the database but doesn't load the game
        fun.loadGame()  -- reads the database and loads arrays
        REFRESH_DB = true
        cf.AddScreen(enum.sceneDisplaySeasonStatus, SCREEN_STACK)
    elseif clickedButtonID == enum.buttonMainMenuLoad then
        fun.loadGame()
        REFRESH_DB = true

        local countofgames = db.getCountSeasonTable()
        if countofgames < 15 then
            cf.AddScreen(enum.sceneDisplaySeasonStatus, SCREEN_STACK)
        else
            --! go to trading screen
            error("Need to go to trading screen")
        end
    end
end

function mainmenu.draw()

    buttons.drawButtons()
end

function mainmenu.loadButtons()

    local numofbuttons = 4      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for exit
    local mybutton = {}
    mybutton.x = SCREEN_WIDTH / 2
    mybutton.y = SCREEN_HEIGHT / numofsectors * 4
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Exit game"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3

    -- -- mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 15

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneMainMenu
    mybutton.identifier = enum.buttonMainMenuExit
    table.insert(GUI_BUTTONS, mybutton)

    -- button for continue
    local mybutton = {}
    local buttonsequence = 2            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH / 2
    mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Load game"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3
    mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 15
    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneMainMenu
    mybutton.identifier = enum.buttonMainMenuLoad
    table.insert(GUI_BUTTONS, mybutton)

    -- button for credits
    local mybutton = {}
    mybutton.x = SCREEN_WIDTH / 2
    mybutton.y = SCREEN_HEIGHT / numofsectors * 3
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Credits"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3

    -- -- mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 15

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneMainMenu
    mybutton.identifier = enum.buttonMainMenuCredits
    table.insert(GUI_BUTTONS, mybutton)

    -- button for New game
    local mybutton = {}
    mybutton.x = SCREEN_WIDTH / 2
    mybutton.y = SCREEN_HEIGHT / numofsectors * 1
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "New game"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3

    -- -- mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 15

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneMainMenu
    mybutton.identifier = enum.buttonMainMenuNewGame
    table.insert(GUI_BUTTONS, mybutton)



end

return mainmenu
