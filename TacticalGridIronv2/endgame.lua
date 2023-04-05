endgame = {}

local offensiveteamname, defensiveteamname  -- ensure this is module level because it's used by draw AFTER the db refresh
local arr_season = {}


local function seasonOver()
    -- if season has 15 rows then all games are played and the last row is the final winner
    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select * from SEASON"
    local index = 0
    arr_season = {}
    for row in fbdb:nrows(strQuery) do
        index = index + 1

        local mytable = {}
        mytable.TEAMID = row.TEAMID
        mytable.OFFENCESCORE = row.OFFENCESCORE
        mytable.OFFENCETIME = row.OFFENCETIME
        table.insert(arr_season, mytable)

        if index == 15 then
            -- winner winner chicken dinner

            CHAMPION_TEAMID = row.TEAMID

            -- now we have the winner - traverse the array again to work out the score and time for that winner
            -- can only be element 13 or 14
            if arr_season[13].TEAMID == CHAMPION_TEAMID then
                CHAMPION_SCORE = arr_season[13].OFFENCESCORE
                CHAMPION_TIME = arr_season[13].OFFENCETIME
            else
                CHAMPION_SCORE = arr_season[14].OFFENCESCORE
                CHAMPION_TIME = arr_season[14].OFFENCETIME
            end
            fbdb:close()
            return true
        end
    end
    fbdb:close()
    return false
end

function endgame.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonEndGameQuit then
        love.event.quit()
    elseif clickedButtonID == enum.buttonEndGameContinue then
        if not seasonOver() then
            -- go to seasonstatus
            REFRESH_DB = true
            cf.SwapScreen(enum.sceneDisplaySeasonStatus, SCREEN_STACK)
        else
            -- go to league status
            print("League winner " .. CHAMPION_TEAMID, CHAMPION_SCORE, CHAMPION_TIME)
            REFRESH_DB = true
            cf.SwapScreen(enum.sceneDisplayLeagueStatus, SCREEN_STACK)
        end
    end
end

local function getWinningTeamID(team1, score1, time1, team2, score2, time2)
    if score1 > score2 then
        return team1
    elseif score2 > score1 then
        return team2
    else
        -- score is tied
        -- break tie on smallest time if not zero
        -- or longest time if zero
        if score1 > 0 then
            -- remember score2 = score 1
            if time1 < time2 then
                return team1
            elseif time2 < time1 then
                return team2
            else
                -- score and time is tied
                error("Game is a draw. Aborting.")  --!
            end
        else
            -- both scores are zero. Winner is the longest time
            if time1 > time2 then
                return team1
            elseif time2 > time1 then
                return team2
            else
                -- draw
                error("Game is a draw. Aborting.")  --!
            end
        end
    end
end

function endgame.draw()

    if REFRESH_DB then

        -- need to firstly destroy some globals that still linger from teh STADIUM scene
    	-- destroy the physical objects
    	for i = 1, NumberOfPlayers do
            PHYS_PLAYERS[i].body:destroy()
        end
    	PHYS_PLAYERS = {}
    	print("Player array destroyed")
        GAME_STATE = nil

        -- do normal 'load' activities

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
        fbdb:close()

        -- update next bracket if opponent has played
        if OPPONENTS_SCORE ~= nil then
            assert(OPPONENTS_TIME ~= nil)

            -- print("alpha " .. OFFENSIVE_TEAMID, OFFENSIVE_SCORE, OFFENSIVE_TIME, DEFENSIVE_TEAMID, OPPONENTS_SCORE, OPPONENTS_TIME)

            local winningid = getWinningTeamID(OFFENSIVE_TEAMID, OFFENSIVE_SCORE, OFFENSIVE_TIME, DEFENSIVE_TEAMID, OPPONENTS_SCORE, OPPONENTS_TIME)

            local fbdb = sqlite3.open(DB_FILE)
            strQuery = "Insert into SEASON ('TEAMID') values ('" .. winningid .. "')"
            local dberror = fbdb:exec(strQuery)
            fbdb:close()

        end
        REFRESH_DB = false
    end

    love.graphics.setColor(1,1,1,1)
    -- print team name and score
    love.graphics.print(offensiveteamname, 100, 100)
    love.graphics.print(OFFENSIVE_SCORE, 100, 200)
    love.graphics.print(cf.round(OFFENSIVE_TIME, 2), 100, 250)

    -- print team name and score
    love.graphics.print(defensiveteamname, 750, 100)
    if OPPONENTS_SCORE ~= nil then love.graphics.print(OPPONENTS_SCORE, 750, 200) end       --! 750 needs to be screenwidth - something
    if OPPONENTS_TIME ~= nil then love.graphics.print(cf.round(OPPONENTS_TIME, 2), 750, 250) end

    buttons.drawButtons()
end

function endgame.loadButtons()
    -- call this from love.load()

    local numofbuttons = 1      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for continue
    local mybutton = {}
    local buttonsequence = 1            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH * 1/2
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

    -- -- button for exit
    -- local mybutton = {}
    -- local buttonsequence = 2            -- sequence on the screen
    -- mybutton.x = SCREEN_WIDTH * 2/3
    -- mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
    -- mybutton.width = 125
    -- mybutton.height = 25
    -- mybutton.bgcolour = {169/255,169/255,169/255,1}
    -- mybutton.drawOutline = false
    -- mybutton.outlineColour = {1,1,1,1}
    -- mybutton.label = "Save and quit"
    -- mybutton.image = nil
    -- mybutton.imageoffsetx = 20
    -- mybutton.imageoffsety = 0
    -- mybutton.imagescalex = 0.9
    -- mybutton.imagescaley = 0.3
    -- mybutton.labelcolour = {1,1,1,1}
    -- mybutton.labeloffcolour = {1,1,1,1}
    -- mybutton.labeloncolour = {1,1,1,1}
    -- mybutton.labelcolour = {0,0,0,1}
    -- mybutton.labelxoffset = 15
    --
    -- mybutton.state = "on"
    -- mybutton.visible = true
    -- mybutton.scene = enum.sceneEndGame
    -- mybutton.identifier = enum.buttonEndGameQuit
    -- table.insert(GUI_BUTTONS, mybutton)


end

return endgame
