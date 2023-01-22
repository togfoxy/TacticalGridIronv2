inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'


require 'constants'
require 'mainmenu'
require 'lib.buttons'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
end

function love.mousereleased(x, y, button, isTouch)
	local rx, ry = res.toGame(x,y)		-- does this need to be applied consistently across all mouse clicks?
	local currentscene = cf.CurrentScreenName(SCREEN_STACK)

	if currentscene == enum.sceneMainMenu then
		mainmenu.mousereleased(rx, ry)
	end


	

	-- do button stuff



end

function love.load()

	res.init({width = 640, height = 480, mode = 3})
	res.setMode(800, 600, {resizable = true})

    -- if love.filesystem.isFused( ) then
    --     void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    --     gbolDebug = false
    -- else
    --     void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    -- end

	constants.load()
	mainmenu.loadButtons()

	love.window.setTitle("Tactical Gridiron v2 " .. GAME_VERSION)

	cf.AddScreen(enum.sceneMainMenu, SCREEN_STACK)

end

function love.resize(w, h)
	res.resize(w, h)
end

function love.draw()

	local currentscene = cf.CurrentScreenName(SCREEN_STACK)

    res.start()

	if currentscene == enum.sceneMainMenu then
		mainmenu.draw()
	end

    res.stop()
end


function love.update(dt)



end
