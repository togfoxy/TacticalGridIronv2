seasonstatus = {}

local arr_seasonstatus = {}

function seasonstatus.keyreleased(key)
    -- call from love.keyreleased()
    if key == "escape" then
        cf.RemoveScreen(SCREEN_STACK)
    end
end

local function getNextTwoTeams()
    -- navigate arr_seasonstatus to determine next two teams
    -- set global variables and then exit
    for i = 1, #arr_seasonstatus do

        if arr_seasonstatus[i].OFFENCESCORE == nil then
            OFFENSIVE_TEAMID = arr_seasonstatus[i].TEAMID
            if (i % 2 == 0) then
                -- even number
                DEFENSIVE_TEAMID = arr_seasonstatus[i-1].TEAMID
                OPPONENTS_SCORE = arr_seasonstatus[i-1].OFFENCESCORE
                OPPONENTS_TIME = arr_seasonstatus[i-1].OFFENCETIME

                assert(OPPONENTS_TIME ~= nil)
            else
                -- odd number
                DEFENSIVE_TEAMID = arr_seasonstatus[i+1].TEAMID
                OPPONENTS_SCORE = nil   -- the nil means this teams opponent hasn't played yet
                OPPONENTS_TIME = nil
            end
            break
        end
    end

end

function seasonstatus.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonSeasonStatusExit then
        love.event.quit()
    elseif clickedButtonID == enum.buttonSeasonStatusNextGame then
        getNextTwoTeams()
        REFRESH_DB = true
        cf.AddScreen(enum.sceneStadium, SCREEN_STACK)
    end
end

function seasonstatus.draw()
    -- call this from love.draw()

    if arr_seasonstatus == nil then REFRESH_DB = true end

    -- get the games for this season
    if REFRESH_DB then
        arr_seasonstatus = {}
        local fbdb = sqlite3.open(DB_FILE)
        local strQuery = "select teams.TEAMNAME, season.TEAMID, season.OFFENCESCORE, season.OFFENCETIME from season inner join TEAMS on teams.TEAMID = season.TEAMID"
        for row in fbdb:nrows(strQuery) do
            local mytable = {}
            mytable.TEAMNAME = row.TEAMNAME
            mytable.TEAMID = row.TEAMID
            mytable.OFFENCESCORE = row.OFFENCESCORE
            mytable.OFFENCETIME = row.OFFENCETIME
            table.insert(arr_seasonstatus, mytable)
        end
        REFRESH_DB = false
        fbdb:close()
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(IMAGE[enum.imageBrackets], 0, 0)

    love.graphics.setFont(FONT[enum.fontCorporate])

    local index = 1
    local x, y
    for i = 1, #arr_seasonstatus do     -- this is a module level table that is scoped to this scene/screen
        if index <= 8 then
            x = 100
            y = -50 + (125 * index)
        elseif index > 8 and index <= 12 then
            x = 400
            y = 50 + (20 * index)
        elseif index > 12 then
            x = 600
            y = 200 + (20 * index)
        end

        love.graphics.setColor(1,1,1,1)
        love.graphics.print(arr_seasonstatus[index].TEAMNAME, x, y)
        if arr_seasonstatus[index].OFFENCESCORE ~= nil then
            love.graphics.print(arr_seasonstatus[index].OFFENCESCORE, x + 150, y)
        end
        index = index + 1
    end

    love.graphics.setFont(FONT[enum.fontDefault])
    buttons.drawButtons()
end

function seasonstatus.loadButtons()
    -- call this from love.load()

    local numofbuttons = 2      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for exit
    local mybutton = {}
    local buttonsequence = 2            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH / 2
    mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
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
    mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 15

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneDisplaySeasonStatus
    mybutton.identifier = enum.buttonSeasonStatusExit
    table.insert(GUI_BUTTONS, mybutton)

    -- button for next game
    local mybutton = {}
    local buttonsequence = 1            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH / 2
    mybutton.y = SCREEN_HEIGHT / numofsectors * buttonsequence
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Next game"
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
    mybutton.scene = enum.sceneDisplaySeasonStatus
    mybutton.identifier = enum.buttonSeasonStatusNextGame
    table.insert(GUI_BUTTONS, mybutton)
end

return seasonstatus
