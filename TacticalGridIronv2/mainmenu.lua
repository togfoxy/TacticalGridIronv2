mainmenu = {}

function mainmenu.draw()

    buttons.drawButtons()



end

function mainmenu.loadButtons()
    -- button for exit
    local mybutton = {}
    mybutton.x = (90)
    mybutton.y = (225)
    mybutton.width = 125
    mybutton.height = 25
    mybutton.bgcolour = {169/255,169/255,169/255,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "New game"
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
    mybutton.scene = enum.sceneMainMenu
    mybutton.identifier = enum.buttonMainMenuExit
    table.insert(GUI_BUTTONS, mybutton)
end

return mainmenu
