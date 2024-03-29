inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'

require 'lib.sqlite3.sqlite3'
-- http://lua.sqlite.org/index.cgi/doc/tip/doc/lsqlite3.wiki
-- https://www.sqlite.org/index.html
-- https://www.sqlitetutorial.net/

Camera = require 'lib.cam11.cam11'
-- https://notabug.org/pgimeno/cam11


require 'lib.buttons'
require 'enums'

require 'constants'
require 'mainmenu'
require 'credits'
require 'seasonstatus'
require 'stadium'
require 'endgame'
require 'leaguestatus'
require 'tradeplayers'
require 'trainplayers'
ps = require 'playerstats'
require 'waypoints'				-- a seperate module that contains all the logic for waypoints

require 'database'
fun = require 'functions'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

function love.keyreleased( key, scancode )
	local currentscene = cf.CurrentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneMainMenu then
		mainmenu.keyreleased(key)
	elseif currentscene == enum.sceneCredits then
		credits.keyreleased(key)
	elseif currentscene == enum.sceneDisplaySeasonStatus then
		seasonstatus.keyreleased(key)
	elseif currentscene == enum.sceneStadium then
		stadium.keyreleased(key, scancode)
	end
end

function love.keypressed(key, scancode, isrepeat)
	local currentscene = cf.CurrentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneStadium then
		stadium.keypressed(key, scancode, isrepeat)
	end
end

function love.mousereleased(x, y, button, isTouch)
	local rx, ry = res.toGame(x,y)		-- does this need to be applied consistently across all mouse clicks?
	local currentscene = cf.CurrentScreenName(SCREEN_STACK)

	if currentscene == enum.sceneMainMenu then
		mainmenu.mousereleased(rx, ry)
	elseif currentscene == enum.sceneCredits then
		credits.mousereleased(rx, ry)
	elseif currentscene == enum.sceneDisplaySeasonStatus then
		seasonstatus.mousereleased(rx, ry)
	elseif currentscene == enum.sceneStadium then
		stadium.mousereleased(rx, ry, x, y)		-- need to send through the res adjusted x/y and the 'real' x/y
	elseif currentscene == enum.sceneEndGame then
		endgame.mousereleased(rx, ry)
	elseif currentscene == enum.sceneDisplayLeagueStatus then
		leaguestatus.mousereleased(rx, ry)
	elseif currentscene == enum.sceneTradePlayers then
		tradeplayers.mousereleased(rx, ry)
	elseif currentscene == enum.sceneTrainPlayers then
		trainplayers.mousereleased(rx, ry)
	end
end

function love.wheelmoved(x, y)
	local currentscene = cf.CurrentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneStadium then
		stadium.wheelmoved(x, y)
	end

end

function love.load()

	res.init({width = 1920, height = 1080, mode = 3})
	res.setMode(1920, 1080, {resizable = true})

    -- if love.filesystem.isFused( ) then
    --     void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    --     gbolDebug = false
    -- else
    --     void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    -- end

	constants.load()
	fun.loadFonts()
	mainmenu.loadButtons()
	credits.loadButtons()
	seasonstatus.loadButtons()
	stadium.loadButtons()
	endgame.loadButtons()
	stadium.loadButtons()
	tradeplayers.loadButtons()
	trainplayers.loadButtons()

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	cam:setZoom(ZOOMFACTOR)
	cam:setPos(TRANSLATEX,	TRANSLATEY)

	love.window.setTitle("Tactical Gridiron v2 " .. GAME_VERSION)

	cf.AddScreen(enum.sceneMainMenu, SCREEN_STACK)

	love.keyboard.setKeyRepeat(true)

	love.physics.setMeter(1)
	world = love.physics.newWorld(0, 0, true)

	fun.loadAudio()
	fun.loadImages()
end

function love.resize(w, h)
	res.resize(w, h)
end

function love.draw()

	local currentscene = cf.CurrentScreenName(SCREEN_STACK)

    res.start()

	if currentscene == enum.sceneMainMenu then
		mainmenu.draw()
	elseif currentscene == enum.sceneCredits then
		credits.draw()
	elseif currentscene == enum.sceneDisplaySeasonStatus then
		seasonstatus.draw()
	elseif currentscene == enum.sceneStadium then
		stadium.draw()
	elseif currentscene == enum.sceneEndGame then
		endgame.draw()
	elseif currentscene == enum.sceneDisplayLeagueStatus then
		leaguestatus.draw()
	elseif currentscene == enum.sceneTradePlayers then
		tradeplayers.draw()
	elseif currentscene == enum.sceneTrainPlayers then
		trainplayers.draw()
	end

    res.stop()
end


function love.update(dt)

	local currentscene = cf.CurrentScreenName(SCREEN_STACK)
	if currentscene == enum.sceneStadium then
		stadium.update(dt)
	end




end
