seasonstatus = {}

local arr_seasonstatus = {}

function seasonstatus.keyreleased(key)
    -- call from love.keyreleased()
    if key == "escape" then
        cf.RemoveScreen(SCREEN_STACK)
    end
end

function seasonstatus.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonSeasonStatusExit then
        love.event.quit()
    end
end

function seasonstatus.draw()
    -- call this from love.draw()

    if arr_seasonstatus == nil then REFRESH_DB = true end

    -- get the games for this season
    if REFRESH_DB then
        local fbdb = sqlite3.open(DB_FILE)
        local strQuery = "select teams.TEAMNAME from season inner join TEAMS on teams.TEAMID = season.TEAMID"
        for row in fbdb:nrows(strQuery) do
            table.insert(arr_seasonstatus, row.TEAMNAME)
        end
        REFRESH_DB = false
        print("Hi")
    end

    local index = 1
    local x, y
    for i = 1, #arr_seasonstatus do
        if index <= 8 then
            x = 100
            y = 0 + (100 * index)
        elseif index > 8 and index <= 12 then
            x = 200
            y = 100 + (100 * index)
        elseif index > 12 then
            x = 300
            y = 200 + (100 * index)
        end

        love.graphics.setColor(1,1,1,1)
        love.graphics.print(arr_seasonstatus[index], x, y)
        index = index + 1
    end
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
