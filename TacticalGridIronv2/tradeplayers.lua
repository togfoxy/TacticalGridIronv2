tradeplayers = {}

local teamPlayers = {}
local freePlayers = {}

function tradeplayers.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonTradePlayersContinue then
        cf.SwapScreen(enum.sceneTrainPlayers, SCREEN_STACK)
    end
end

function tradeplayers.draw()

    if REFRESH_DB then

        local strQuery = "select teams.TEAMNAME, players.PLAYERID, players.FIRSTNAME, players.FAMILYNAME, players.POSITION, players.MASS, players.MAXV, "
        strQuery = strQuery .. "players.MAXF, players.BALANCE, players.THROWACCURACY, players.CATCHSKILL from PLAYERS inner join teams "
        strQuery = strQuery .. "on teams.TEAMID = players.TEAMID where teams.PLAYERCONTROLLED = 1"

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
            table.insert(teamPlayers, mytable)
        end
        REFRESH_DB = false
        fbdb:close()
    end

    local drawx = 100
    local drawy = 100
    love.graphics.setColor(1,1,1,1)
    for k,v in pairs(teamPlayers) do
        love.graphics.print(v.firstname, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.familyname, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.position, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.mass, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.maxv, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.maxf, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.balance, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.throwaccuracy, drawx, drawy)
        drawy = drawy + 75
        love.graphics.print(v.catchskill, drawx, drawy)
        drawy = drawy + 75
        drawx = drawx + 40
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Under construction", 300, 300)

    buttons.drawButtons()
end

function tradeplayers.loadButtons()
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
    mybutton.scene = enum.sceneTradePlayers
    mybutton.identifier = enum.buttonTradePlayersContinue
    table.insert(GUI_BUTTONS, mybutton)
end


return tradeplayers
