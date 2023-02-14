trainplayers = {}

local function prepForNextSeason()
    -- reset database tables for next season
    local fbdb = sqlite3.open(DB_FILE)
    local strQuery, dberror

    -- update tables
    strQuery = "Update GLOBALS set CURRENTSEASON = " .. CURRENT_SEASON + 1
    CURRENT_SEASON = CURRENT_SEASON + 1
    dberror = fbdb:exec(strQuery)
    assert(dberror == 0, dberror .. strQuery)

    -- purge tables
    strQuery = "delete from SEASON"
    dberror = fbdb:exec(strQuery)
    assert(dberror == 0, dberror .. strQuery)

    -- populate tables
    db.populateSeasonTable()

    fbdb:close()

    REFRESH_DB = true
    cf.SwapScreen(enum.sceneDisplaySeasonStatus, SCREEN_STACK)
end

function trainplayers.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonTrainNextSeason then
        prepForNextSeason()
    end
end


function trainplayers.draw()

    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Under construction", 400, 400)

    buttons.drawButtons()

end

function trainplayers.loadButtons()
    -- call this from love.load()

    local numofbuttons = 1      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for exit
    local mybutton = {}
    local buttonsequence = 1            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH / 2
    mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Start next season"
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
    mybutton.scene = enum.sceneTrainPlayers
    mybutton.identifier = enum.buttonTrainNextSeason
    table.insert(GUI_BUTTONS, mybutton)
end



return trainplayers
