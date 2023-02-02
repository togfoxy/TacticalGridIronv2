stadium = {}

local LeftLineX = 15	-- how many metres to leave at the leftside of the field?
local TopPostY = 15	-- how many metres to leave at the top of the screen?
local FieldWidth = 53	-- how wide (yards/metres) is the field?
local RightLineX = LeftLineX + FieldWidth
local BottomPostY = TopPostY + 120
local CentreLineX = LeftLineX + (FieldWidth/2)	-- left line + half of the field
local GoalHeight = 10
local TopGoalY = TopPostY + 10
local BottomGoalY = TopPostY + 110
local ScrimmageY = TopPostY + 90
local FirstDownMarker = ScrimmageY - 10		-- yards

function stadium.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonStadiumQuit then
        love.event.quit()
    end
end

local function drawStadium()

    -- top goal
    love.graphics.setColor(153/255, 153/255, 255/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, TopPostY * SCALE, FieldWidth * SCALE, GoalHeight * SCALE)        --! the 10 should be a module level

    -- bottom goal
    love.graphics.setColor(255/255, 153/255, 51/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, 125 * SCALE, FieldWidth * SCALE, GoalHeight * SCALE)     --! work out what the 125 should be

    -- field
    love.graphics.setColor(69/255, 172/255, 79/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, 25 * SCALE, FieldWidth * SCALE, 100 * SCALE)     --! work out what 25 and 100 need to be

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
    -- local intRed = 255
    -- local intGreen = 255
    -- local intBlue = 255
    -- love.graphics.setColor(intRed/255, intGreen/255, intBlue/255)
    -- love.graphics.line(SclFactor(15),SclFactor(15),SclFactor(15),SclFactor(135))
    -- love.graphics.line(SclFactor(intRightLineX),SclFactor(15),SclFactor(intRightLineX),SclFactor(135))


    -- draw stadium
    -- draw scrimmage
    -- draw first down marker


end

function stadium.draw()
    -- call this from love.draw()

    drawStadium()

    buttons.drawButtons()
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
