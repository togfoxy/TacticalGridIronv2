endgame = {}

local offensiveteamname, defensiveteamname

local function seasonOver()
    return false        --!
end

function endgame.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)

print(clickedButtonID)

    if clickedButtonID == enum.buttonEndGameQuit then
        love.event.quit()
    elseif clickedButtonID == enum.buttonEndGameContinue then
        if not seasonOver() then
            --! go to seasonstatus
            REFRESH_DB = true
            cf.SwapScreen(enum.sceneDisplaySeasonStatus, SCREEN_STACK)
        else
            --! go to league status
        end
    end
end

function endgame.draw()
    if REFRESH_DB then
        local fbdb = sqlite3.open(DB_FILE)
        local strQuery = "select * from TEAMS"

        for row in fbdb:nrows(strQuery) do
            if row.TEAMID == OFFENSIVE_TEAMID then
                offensiveteamname = row.TEAMNAME
            end
            if row.TEAMID == DEFENSIVE_TEAMID then
                defensiveteamname = row.TEAMNAME
            end
        end
        REFRESH_DB = false
    end

    love.graphics.setColor(1,1,1,1)
    -- print team name and score
    love.graphics.print(offensiveteamname, 100, 100)
    love.graphics.print(OFFENSIVE_SCORE, 100, 200)

    -- print team name and score
    love.graphics.print(defensiveteamname, 750, 100)

    buttons.drawButtons()
end

function endgame.loadButtons()
    -- call this from love.load()

    local numofbuttons = 2      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for continue
    local mybutton = {}
    local buttonsequence = 1            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH * 2/3
    mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Save and continue"
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
    mybutton.scene = enum.sceneEndGame
    mybutton.identifier = enum.buttonEndGameContinue
    table.insert(GUI_BUTTONS, mybutton)

    -- button for exit
    local mybutton = {}
    local buttonsequence = 2            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH * 2/3
    mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Save and quit"
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
    mybutton.scene = enum.sceneEndGame
    mybutton.identifier = enum.buttonEndGameQuit
    table.insert(GUI_BUTTONS, mybutton)


end

return endgame
