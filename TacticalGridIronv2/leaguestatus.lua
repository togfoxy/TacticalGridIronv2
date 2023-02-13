leaguestatus = {}

local champion_team_name

function leaguestatus.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonLeagueStatusContinue then
        --!
        error("This not coded yet")
    end
end

function leaguestatus.draw()
    -- call this from love.draw()

    if REFRESH_DB then
        -- write result to the league table
        REFRESH_DB = false
        db.updateLeague(CURRENT_SEASON, CHAMPION_TEAMID, CHAMPION_SCORE, CHAMPION_TIME)
    end

    if CHAMPION_TEAMID ~= nil and champion_team_name == nil then
        champion_team_name = db.getTeamName(CHAMPION_TEAMID)
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(champion_team_name, 300, 300)
    love.graphics.print(CHAMPION_SCORE, 475, 300)
    love.graphics.print(CHAMPION_TIME, 550, 300)

    buttons.drawButtons()
end

function leaguestatus.update(dt)

    if REFRESH_DB then

    end
end

function stadium.loadButtons()
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
    mybutton.scene = enum.sceneDisplayLeagueStatus
    mybutton.identifier = enum.buttonLeagueStatusContinue
    table.insert(GUI_BUTTONS, mybutton)
end

return leaguestatus
