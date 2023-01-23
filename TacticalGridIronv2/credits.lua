credits = {}

function credits.draw()
    buttons.drawButtons()
end

function credits.keyreleased(key)
    if key == "escape" then
        cf.RemoveScreen(SCREEN_STACK)
    end
end

function credits.mousereleased(rx, ry)
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonCreditsExit then
        cf.RemoveScreen(SCREEN_STACK)
    end
end

function credits.loadButtons()

    -- button for exit
    local mybutton = {}
    mybutton.x = SCREEN_WIDTH / 2 * 1
    mybutton.y = SCREEN_HEIGHT / 2 * 1
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Return to main menu"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3

    -- -- mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {0,0,0,1}
    mybutton.labelxoffset = 15

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneCredits
    mybutton.identifier = enum.buttonCreditsExit
    table.insert(GUI_BUTTONS, mybutton)
end




return credits
