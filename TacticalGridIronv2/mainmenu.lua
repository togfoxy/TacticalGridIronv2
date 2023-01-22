mainmenu = {}

function mainmenu.draw()

    -- draw buttons
    local currentscene = cf.CurrentScreenName(SCREEN_STACK)

	for k, button in pairs(GUI_BUTTONS) do
		if button.scene == currentscene and button.visible then
			-- draw the button

            -- draw the bg
            love.graphics.setColor(button.bgcolour)
            love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)			-- drawx/y is the top left corner of the square

            -- draw the outline
            if button.drawOutline then
                love.graphics.setColor(button.outlineColour)
                love.graphics.rectangle("line", button.x, button.y, button.width, button.height)			-- drawx/y is the top left corner of the square
            end

			if button.image ~= nil then
                love.graphics.setColor(1,1,1,1)
				love.graphics.draw(button.image, button.x, button.y, 0, button.imagescalex, button.imagescaley, button.imageoffsetx, button.imageoffsety)
			end

			-- draw the label
			local labelxoffset = button.labelxoffset or 0
            love.graphics.setColor(button.labelcolour)
			-- love.graphics.setFont(FONT[enum.fontDefault])        --! the font should be a setting and not hardcoded here
			love.graphics.print(tostring(button.label), button.x + labelxoffset, button.y + 5)
		end
	end



end

function mainmenu.loadButtons()
    -- button for exit
    local mybutton = {}
    mybutton.width = 80
    mybutton.x = (90)
    mybutton.y = (225)
    mybutton.width = 40
    mybutton.height = 25
    mybutton.bgcolour = {1,1,1,1}
    mybutton.drawOutline = false
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Hello world"
    mybutton.image = nil
    mybutton.imageoffsetx = 20
    mybutton.imageoffsety = 0
    mybutton.imagescalex = 0.9
    mybutton.imagescaley = 0.3

    -- -- mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {1,1,1,1}
    mybutton.labelxoffset = 7

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneMainMenu
    mybutton.identifier = enum.buttonMainMenuExit
    table.insert(GUI_BUTTONS, mybutton)
end

return mainmenu
