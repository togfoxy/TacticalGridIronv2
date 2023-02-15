stadium = {}

local arr_seasonstatus, offensiveteamname, defensiveteamname

local TopPostY = 5	-- how many metres to leave at the top of the screen?
local FieldWidth = 53	-- how wide (yards/metres) is the field?
local FieldHeight = 100     -- from touchdown to touchdown
local LeftLineX
local RightLineX
local BottomPostY = TopPostY + 120
local CentreLineX
local GoalHeight = 10
local TopGoalY = TopPostY + 10
local BottomGoalY = TopPostY + 110
local ScrimmageY = TopPostY + 90
local FirstDownMarkerY = ScrimmageY - 10		-- yards


function stadium.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonStadiumQuit then
        love.event.quit()
    end
end

local function drawStadium()

    if REFRESH_DB then
        arr_seasonstatus = {}
        local fbdb = sqlite3.open(DB_FILE)
        local strQuery = "select teams.TEAMNAME, season.TEAMID, season.OFFENCESCORE, season.OFFENCETIME from season inner join TEAMS on teams.TEAMID = season.TEAMID"
        for row in fbdb:nrows(strQuery) do
            local mytable = {}
            mytable.TEAMNAME = row.TEAMNAME
            mytable.TEAMID = row.TEAMID
            mytable.OFFENCESCORE = row.OFFENCESCORE
            table.insert(arr_seasonstatus, mytable)

            if row.TEAMID == OFFENSIVE_TEAMID then
                offensiveteamname = row.TEAMNAME
            end
            if row.TEAMID == DEFENSIVE_TEAMID then
                defensiveteamname = row.TEAMNAME
            end
        end
        REFRESH_DB = false
        fbdb:close()
        print("Hi")
    end

    LeftLineX = (SCREEN_WIDTH / 2) - ((FieldWidth * SCALE) / 2)	-- how many metres to leave at the leftside of the field?
    LeftLineX = LeftLineX / SCALE   -- need to divide by scale and then further down multiply by scale
    RightLineX = LeftLineX + FieldWidth
    CentreLineX = LeftLineX + (FieldWidth / 2)	-- left line + half of the field

    -- top goal
    love.graphics.setColor(153/255, 153/255, 255/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, TopPostY * SCALE, FieldWidth * SCALE, GoalHeight * SCALE)

    -- bottom goal
    love.graphics.setColor(255/255, 153/255, 51/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, (TopPostY + GoalHeight + FieldHeight) * SCALE, FieldWidth * SCALE, GoalHeight * SCALE)

    -- field
    love.graphics.setColor(69/255, 172/255, 79/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, (TopPostY + GoalHeight) * SCALE, FieldWidth * SCALE, FieldHeight * SCALE)

    -- yard lines
    love.graphics.setColor(1,1,1,1)
    for i = 0,20
	do
		love.graphics.line(LeftLineX * SCALE, (TopGoalY + (i * 5))  * SCALE, RightLineX * SCALE, (TopGoalY + (i * 5))  * SCALE)
	end

    -- left and right ticks
    love.graphics.setColor(1,1,1,1)
    for i = 1, 99 do
        -- draw left tick mark
        love.graphics.line((LeftLineX + 1)  * SCALE, (TopGoalY + i)  * SCALE, (LeftLineX + 2) * SCALE, (TopGoalY + i) * SCALE)

        -- draw left and right hash marks (inbound lines)
        love.graphics.line((LeftLineX + 22) * SCALE, (TopGoalY + i) * SCALE, (LeftLineX + 23) * SCALE, (TopGoalY + i) * SCALE)
        love.graphics.line((RightLineX - 23) * SCALE, (TopGoalY + i) * SCALE, (RightLineX - 22) * SCALE, (TopGoalY + i) * SCALE)

        -- draw right tick lines
        love.graphics.line((RightLineX -2) * SCALE, (TopGoalY + i) * SCALE, (RightLineX - 1) * SCALE, (TopGoalY + i) * SCALE)
    end

    --draw sidelines
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line", LeftLineX * SCALE, TopPostY * SCALE, FieldWidth * SCALE, (GoalHeight + FieldHeight + GoalHeight) * SCALE)

    -- draw stadium

    -- draw scrimmage

	love.graphics.setColor(93/255, 138/255, 169/255,1)
	love.graphics.setLineWidth(5)
	love.graphics.line(LeftLineX * SCALE, ScrimmageY * SCALE, RightLineX * SCALE, ScrimmageY * SCALE)
	love.graphics.setLineWidth(1)	-- return width back to default

    -- draw first down marker
	love.graphics.setColor(255/255, 255/255, 51/255,1)
	love.graphics.setLineWidth(5)
	love.graphics.line(LeftLineX * SCALE, FirstDownMarkerY * SCALE, RightLineX * SCALE, FirstDownMarkerY * SCALE)
	love.graphics.setLineWidth(1)	-- return width back to default

    -- print the two teams
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(offensiveteamname, 50, 50)       --! this needs to be the team name and not the ID
    love.graphics.print(defensiveteamname, SCREEN_WIDTH - 250, 50)


end

local function endtheround()
    -- dummy function to test the scene progression
    local score = love.math.random(0, 30)
    OFFENSIVE_SCORE = score
    OFFENSIVE_TIME = cf.round(OFFENSIVE_TIME, 4)

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery
    strQuery = "Update SEASON set OFFENCESCORE = " .. score .. ", OFFENCETIME = " .. OFFENSIVE_TIME .. " where TEAMID = " .. OFFENSIVE_TEAMID
    local dberror = fbdb:exec(strQuery)
    fbdb:close()

    -- move to the next scene
    REFRESH_DB = true
    cf.SwapScreen(enum.sceneEndGame, SCREEN_STACK)
end

function stadium.draw()
    -- call this from love.draw()

    drawStadium()

    buttons.drawButtons()
end

function stadium.update(dt)
    -- called from love.update()

    if REFRESH_DB then
        OFFENSIVE_TIME = 0
        print("Ho")
    end

    --! fake the ending of the scene
    OFFENSIVE_TIME = OFFENSIVE_TIME + dt
    if love.math.random(1,100) == 1 then
        -- end game
        endtheround()
    end
end

function stadium.loadButtons()
    -- call this from love.load()

    local numofbuttons = 1      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for exit
    local mybutton = {}
    local buttonsequence = 1            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH * 2/3
    mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Quit (no save)"
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
    mybutton.scene = enum.sceneStadium
    mybutton.identifier = enum.buttonStadiumQuit
    table.insert(GUI_BUTTONS, mybutton)
end

return stadium
