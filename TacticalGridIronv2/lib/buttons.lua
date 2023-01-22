buttons = {}

GUI_BUTTONS = {}        -- global

function buttons.setButtonVisible(enumvalue)
	-- receives an enum (number) and sets the visibility of that button to true
	for k, button in pairs(GUI_BUTTONS) do
		if button.identifier == enumvalue then
			button.visible = true
			break
		end
	end
end

function buttons.setButtonInvisible(enumvalue)
	-- receives an enum (number) and sets the visibility of that button to false
	for k, button in pairs(GUI_BUTTONS) do
		if button.identifier == enumvalue then
			button.visible = false
			break
		end
	end
end

function buttons.buttonClicked(mx, my, button)
	-- the button table is a global table
	-- check if mouse click is inside any button
	-- mx, my = mouse click X/Y
	-- button is from the global table
	-- returns the identifier of the button (enum) or nil
	if mx >= button.x and mx <= button.x + button.width and
		my >= button.y and my <= button.y + button.height then
			return button.identifier
	else
		return nil
	end
end

function buttons.changeButtonLabel(enumvalue, newlabel)
	for k, button in pairs(GUI_BUTTONS) do
		if button.identifier == enumvalue then
			button.label = tostring(newlabel)
			break
		end
	end
end

return buttons
