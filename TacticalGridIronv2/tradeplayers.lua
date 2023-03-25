tradeplayers = {}

local teamPlayers = {}
local freePlayers = {}

-- used for drawing things. Used by draw and mouse click functions
local toprowx = 45
local toprowy = 75
local rowgap = 40
local colgap = 85

local function getCountSelected(thisTable)
    -- counts how many items are selected
    -- input: the table that has an isSelected property
    -- output: a number
    local retvalue = 0
    for k, v in pairs(thisTable) do
        if v.isSelected then
            retvalue = retvalue + 1
        end
    end
    return retvalue
end

local function swapPlayers()
    -- swap players by updating the db
    local selectedPlayers = {}
    local strWhere

    -- create a table of selected players and construct a SQL string at the same time
    for k, v in pairs(teamPlayers) do
        if v.isSelected then
            table.insert(selectedPlayers, v)
            if strWhere == nil then
                strWhere = v.playerID
            else
                strWhere = strWhere .. " OR PLAYERID = " .. v.playerID
            end
        end
    end

    -- delete the selected players from the players table
    local strQuery = "Update PLAYERS SET TEAMID = NULL WHERE PLAYERID = " .. strWhere
    local fbdb = sqlite3.open(DB_FILE)
    fbdb:execute(strQuery)

    print("executed " .. strQuery)

    -- add the free agents into the players team
    -- get the players teamid first
    local playerTeamID
    local strQuery = "Select * from GLOBALS"
    for row in fbdb:nrows(strQuery) do      -- should only execute once
        playerTeamID = row.PLAYERTEAMID
    end

    -- now can add the players team to each free agent
    -- loop through all the selected positions and find the same in the free agent list

    local strWhere
    for k, v in pairs(selectedPlayers) do
        for q, w in pairs(freePlayers) do
            if w.position == v.position then
                -- add this playerID to the future WHERE statement
                if strWhere == nil then
                    strWhere = w.playerID
                else
                    strWhere = strWhere .. " OR PLAYERID = " .. w.playerID
                end
            end
        end
    end

    local strQuery = "Update PLAYERS SET TEAMID = " .. playerTeamID .. " WHERE PLAYERID = " .. strWhere
    fbdb:execute(strQuery)
    print("executed " .. strQuery)
    fbdb:close()

    REFRESH_DB = true
end

function tradeplayers.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonTradePlayersContinue then
        cf.SwapScreen(enum.sceneTrainPlayers, SCREEN_STACK)
    elseif clickedButtonID == enum.buttonTradePlayersSwap then
        -- swap players then move to next screen
        swapPlayers()

        -- cf.SwapScreen(enum.sceneTrainPlayers, SCREEN_STACK)


    else
        -- see if one of the left columns is clicked
        -- print(rx, ry)

        local maxSelected = 6

        if rx >= toprowx and rx <= 800 then  -- arbitrary value that seems to work
            if ry >= toprowy and ry <= 990 then
                -- inside left panel. Work out which row
                local yvalue = ry - toprowy
                print(yvalue, yvalue / rowgap, math.floor(yvalue / rowgap))
                if yvalue <= rowgap then
                    --! a header is clicked
                    print("Header clicked")
                else
                    local rownum = math.floor(yvalue / rowgap)
                    print("Row #" .. rownum .. " clicked")
                    for k, v in pairs(teamPlayers) do
                        if v.index == rownum then
                            -- print(v.position, v.mass, v.maxv)
                            if not v.isSelected then
                                if getCountSelected(teamPlayers) < maxSelected then
                                    v.isSelected = true
                                else
                                    -- there is already another selected. Disallow this action
                                    --! play error DING sound
                                end
                            else
                                v.isSelected = false
                            end
                            break
                        end
                    end
                end

            end
        end
    end
end

local function drawTeam(myTable, rowx)
    -- will draw either the players team on the left or
    -- the free agents on the right, depending on parameter
    -- assumes exactly 22 players
    -- input: myTable = either teamPlayers or freePlayers
    -- input: rowx = x value to draw. Either left or right

    local drawx = rowx
    local drawy = toprowy
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(FONT[enum.fontCorporate])
    love.graphics.print("Name", drawx, drawy)
    drawx = drawx + colgap
    love.graphics.print("", drawx, drawy)
    drawx = drawx + colgap
    love.graphics.print("Pos", drawx, drawy)
    drawx = drawx + colgap
    love.graphics.print("Weight", drawx - 20, drawy)
    drawx = drawx + colgap
    love.graphics.print("Speed", drawx - 10, drawy)
    drawx = drawx + colgap
    love.graphics.print("Str", drawx + 5, drawy)
    drawx = drawx + colgap
    love.graphics.print("Balance", drawx - 20, drawy)
    drawx = drawx + colgap
    love.graphics.print("Throw", drawx - 20, drawy)
    drawx = drawx + colgap
    love.graphics.print("Catch", drawx - 10, drawy)

    love.graphics.rectangle("line", rowx - 10, toprowy, (colgap * 9), rowgap)

    drawx = drawx + colgap
    drawx = rowx
    drawy = drawy + rowgap
    for k,v in pairs(myTable) do
        love.graphics.print(v.firstname .. " " .. v.familyname, drawx, drawy)

        -- draw highlights if selected
        if v.isSelected then
            love.graphics.setColor(1,1,0,0.25)
            love.graphics.rectangle("fill", drawx - 10, drawy, (colgap * 9), rowgap)
        else
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle("line", drawx - 10, drawy, (colgap * 9), rowgap)
        end
        love.graphics.setColor(1,1,1,1)
        drawx = drawx + colgap
        love.graphics.print("", drawx, drawy)       --!
        drawx = drawx + colgap
        love.graphics.print(v.position, drawx, drawy)
        drawx = drawx + colgap
        love.graphics.print(v.mass, drawx, drawy)
        drawx = drawx + colgap
        love.graphics.print(v.maxv, drawx, drawy)
        drawx = drawx + colgap
        love.graphics.print(v.maxf, drawx, drawy)
        drawx = drawx + colgap
        love.graphics.print(v.balance, drawx, drawy)
        drawx = drawx + colgap
        love.graphics.print(v.throwaccuracy, drawx, drawy)
        drawx = drawx + colgap
        love.graphics.print(v.catchskill, drawx, drawy)

        drawx = rowx
        drawy = drawy + rowgap
    end
end

function tradeplayers.draw()

    if REFRESH_DB then

        teamPlayers = {}
        freePlayers = {}

        local strQuery = "select teams.TEAMNAME, players.PLAYERID, players.FIRSTNAME, players.FAMILYNAME, players.POSITION, players.MASS, players.MAXV, "
        strQuery = strQuery .. "players.MAXF, players.BALANCE, players.THROWACCURACY, players.CATCHSKILL from PLAYERS inner join teams "
        strQuery = strQuery .. "on teams.TEAMID = players.TEAMID where teams.PLAYERCONTROLLED = 1"

        local index = 1
        local fbdb = sqlite3.open(DB_FILE)
        for row in fbdb:nrows(strQuery) do
            local mytable = {}
            mytable.playerID = row.PLAYERID
            mytable.firstname = row.FIRSTNAME
            mytable.familyname = row.FAMILYNAME
            mytable.position = row.POSITION
            mytable.mass = row.MASS
            mytable.maxv = row.MAXV
            mytable.maxf = row.MAXF
            mytable.balance = row.BALANCE
            mytable.throwaccuracy = row.THROWACCURACY
            mytable.catchskill = row.CATCHSKILL
            mytable.index = index
            mytable.isSelected = false
            table.insert(teamPlayers, mytable)
            index = index + 1
        end

        -- now load the players with no team ID
        local strQuery = "select * from PLAYERS where TEAMID IS NULL"
        for row in fbdb:nrows(strQuery) do
            local mytable = {}
            mytable.playerID = row.PLAYERID
            mytable.firstname = row.FIRSTNAME
            mytable.familyname = row.FAMILYNAME
            mytable.position = row.POSITION
            mytable.mass = row.MASS
            mytable.maxv = row.MAXV
            mytable.maxf = row.MAXF
            mytable.balance = row.BALANCE
            mytable.throwaccuracy = row.THROWACCURACY
            mytable.catchskill = row.CATCHSKILL
            mytable.index = index
            mytable.isSelected = false
            table.insert(freePlayers, mytable)
            index = index + 1
        end

        REFRESH_DB = false
        fbdb:close()
    end

    drawTeam(teamPlayers, 45)
    drawTeam(freePlayers, 1100)

    love.graphics.setFont(FONT[enum.fontDefault])
    -- love.graphics.setColor(1,1,1,1)
    -- love.graphics.print("Under construction", 300, 300)

    buttons.drawButtons()
end

function tradeplayers.loadButtons()
    -- call this from love.load()

    local numofbuttons = 1      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for exit
    local mybutton = {}
    local buttonsequence = 2            -- sequence on the screen
    mybutton.x = (SCREEN_WIDTH / 2) - 75
    mybutton.y = SCREEN_HEIGHT - 75
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
    mybutton.visible = false
    mybutton.scene = enum.sceneTradePlayers
    mybutton.identifier = enum.buttonTradePlayersContinue
    table.insert(GUI_BUTTONS, mybutton)

    -- button for swapping players
    local mybutton = {}
    local buttonsequence = 1            -- sequence on the screen
    mybutton.x = (SCREEN_WIDTH / 2) - 75
    mybutton.y = SCREEN_HEIGHT / 2
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Swap and continue"
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
    mybutton.scene = enum.sceneTradePlayers
    mybutton.identifier = enum.buttonTradePlayersSwap
    table.insert(GUI_BUTTONS, mybutton)

end


return tradeplayers
