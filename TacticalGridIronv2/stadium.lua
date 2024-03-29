stadium = {}

local arr_seasonstatus, offensiveteamname, defensiveteamname, deadBallTimer
local playcall_offense = 3 -- enum.playcallThrow
local playcall_defense = 2 -- enum.playcallManOnMan
local downNumber = 1

local playerTeamID			-- the team ID controlled by the player
local pauseOn = false		-- can be invoked by player to stop time

-- globals
football = {}			-- contains the x/y of the football
football.waypointx = {}
football.waypointy = {}

local OFF_RED, OFF_GREEN, OFF_BLUE, DEF_RED, DEF_GREEN, DEF_BLUE
local DEFENSIVE_TIME, DEFENSIVE_SCORE
local DOWN_TIME = 0		-- how long has this down lasted

-- field dimensions
local FieldWidth = 49	-- how wide (yards/metres) is the field? 48.8 mtrs wide
local FieldHeight = 100     -- from goal to goal
local GoalHeight = 9                    -- endzone is 9m wide

-- field positioning
local TopPostY = 5	-- how many metres to leave at the top of the screen?
local LeftLineX = 100

-- everything else is derived
local TopGoalY = TopPostY + GoalHeight
local BottomGoalY = TopGoalY + FieldHeight
local BottomPostY = BottomGoalY + GoalHeight

local HalfwayY = TopGoalY + ((BottomGoalY - TopGoalY) / 2)

local RightLineX = LeftLineX + FieldWidth

local CentreLineX = LeftLineX + (FieldWidth / 2)
local ScrimmageY = BottomGoalY - 25
local FirstDownMarkerY = ScrimmageY - 10		-- yards

function stadium.keypressed( key, scancode, isrepeat )
	-- this is in keypressed because the keyrepeat needs to be detected.

	local translatefactor = 10 * ZOOMFACTOR		-- screen moves faster when zoomed in

	local leftpressed = love.keyboard.isDown("left")
	local rightpressed = love.keyboard.isDown("right")
	local uppressed = love.keyboard.isDown("up")
	local downpressed = love.keyboard.isDown("down")
	local shiftpressed = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")	-- either shift key will work

	-- adjust translatex/y based on keypress combinations
	if shiftpressed then translatefactor = translatefactor * 2 end	-- ensure this line is above the lines below
	if leftpressed then TRANSLATEX = TRANSLATEX - translatefactor end
	if rightpressed then TRANSLATEX = TRANSLATEX + translatefactor end
	if uppressed then TRANSLATEY = TRANSLATEY - translatefactor end
	if downpressed then TRANSLATEY = TRANSLATEY + translatefactor end
end

function stadium.keyreleased(key, scancode)
	-- this is keyreleased because we detect just a single stroke
	if scancode == "kp5" then
		ZOOMFACTOR = 1
		TRANSLATEX = SCREEN_WIDTH / 2
		TRANSLATEY = SCREEN_HEIGHT / 2
	end

	if scancode == "-" then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if scancode == "=" then
		ZOOMFACTOR = ZOOMFACTOR + 0.05
	end
end

function stadium.wheelmoved(x, y)

	if y > 0 then
		-- wheel moved up. Zoom in
		ZOOMFACTOR = ZOOMFACTOR + 0.05
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if ZOOMFACTOR < 0.8 then ZOOMFACTOR = 0.8 end
	if ZOOMFACTOR > 3 then ZOOMFACTOR = 3 end
	print("Zoom factor = " .. ZOOMFACTOR)
end

function stadium.mousereleased(rx, ry, x, y)
    -- called from love.mousereleased()
	-- input: x/y adjusted by res
	-- input: raw and unadjusted x/y used by cam
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonStadiumQuit then
        love.event.quit()
    end

	if OFFENSIVE_TEAMID == playerTeamID and GAME_STATE == enum.gamestateInPlay then
		-- player has clicked the mouse while ball is in play. Throw the ball if the QB has it.
		if PHYS_PLAYERS[1].hasBall then
			-- adjust the raw mouse x/y to cam x/y
			local mousex, mousey = cam:toWorld(x, y)	-- converts screen x/y to world x/y

			-- now need to unscale it so it converts to physical world
			mousex = mousex / SCALE
			mousey = mousey / SCALE

			football.waypointx[1] = mousex		--! add a random element based on throw skill of QB
			football.waypointy[1] = mousey

			PHYS_PLAYERS[1].waypointx[1] = nil
			PHYS_PLAYERS[1].waypointy[1] = nil
			PHYS_PLAYERS[1].hasBall = false

			GAME_STATE = enum.gamestateAirborne
		end
	end
end

local function determineClosestObject(playernum, enemytype, bolCheckOwnTeam)
	-- receives the player index in question and the target type string (eg "WR") and finds the closest enemy player of that type
	-- enemytype can be an empty string ("") which will search for ANY type
	-- bolCheckOwnTeam = false means scan only the enemy
	-- will not target fallen players
	-- returns two values:
		-- returns (zero, 1000) if none found
	    -- returns (index, dist) if an object is found. Index is (1 -> 22)

	local myclosestdist = 1000
	local myclosesttarget = 0

	local currentplayerX = PHYS_PLAYERS[playernum].body:getX()
	local currentplayerY = PHYS_PLAYERS[playernum].body:getY()

	-- set up loop to scan opposing team or the whole team
	if bolCheckOwnTeam then
		a = 1
		b = NumberOfPlayers
	else
		if playernum > (NumberOfPlayers / 2) then
			a = 1
			b = NumberOfPlayers / 2
		else
			a = (NumberOfPlayers / 2) + 1
			b = NumberOfPlayers
		end
	end
	for i = a,b do
		if not PHYS_PLAYERS[i].fallen then
			if PHYS_PLAYERS[i].positionletters == enemytype or enemytype == "" then
				-- determine distance
				local thisdistance = cf.getDistance(currentplayerX, currentplayerY, PHYS_PLAYERS[i].body:getX(), PHYS_PLAYERS[i].body:getY())

				if thisdistance < myclosestdist then
					-- found a closer target. Make that one the focuse
					myclosesttarget = i
					myclosestdist = thisdistance
					--print("Just set closest target for player " .. playernum .. " to " .. i)
				end
			end
		end
	end		-- for loop

	return myclosesttarget, myclosestdist
end

local function getCarrierXY()
	-- searches for the carrier and then returns the x/y of that carrier
	-- returns two values or nil, nil
	for i = 1, NumberOfPlayers / 2 do
		if PHYS_PLAYERS[i].hasBall then
			local objx = PHYS_PLAYERS[i].body:getX()
			local objy = PHYS_PLAYERS[i].body:getY()
			return objx, objy
		end
	end
	return nil, nil
end

local function createPhysicsPlayers()
    -- called once during drawStadium()

    local rndx, rndy

    for i = 1, NumberOfPlayers do
        rndx = love.math.random(LeftLineX, RightLineX)
        if i <= (NumberOfPlayers / 2) then      -- attacker
            rndy = love.math.random(FirstDownMarkerY, BottomGoalY)
        else
            rndy = love.math.random(TopGoalY + 40, HalfwayY + 10)
        end

        PHYS_PLAYERS[i] = {}
        PHYS_PLAYERS[i].body = love.physics.newBody(world, rndx, rndy, "dynamic") --place the body in the the world and make it dynamic
        PHYS_PLAYERS[i].body:setMass(love.math.random(80,100))	 -- kilograms
        PHYS_PLAYERS[i].shape = love.physics.newCircleShape(0.75)        -- circle radius
        PHYS_PLAYERS[i].fixture = love.physics.newFixture(PHYS_PLAYERS[i].body, PHYS_PLAYERS[i].shape, 1)   -- Attach fixture to body and give it a density of 1.
		PHYS_PLAYERS[i].body:setLinearDamping(0.9)      -- this applies braking force and removes inertia
        PHYS_PLAYERS[i].fixture:setRestitution(0.25)        -- bounce/rebound
        PHYS_PLAYERS[i].fixture:setSensor(true)	    -- start without collisions
        PHYS_PLAYERS[i].fixture:setUserData(i)      -- a handle to its own index

        PHYS_PLAYERS[i].fallen = false
        PHYS_PLAYERS[i].targetx = nil
        PHYS_PLAYERS[i].targety = nil
		PHYS_PLAYERS[i].waypointx = {}
		PHYS_PLAYERS[i].waypointy = {}
        PHYS_PLAYERS[i].targettimer = nil
        PHYS_PLAYERS[i].gamestate = enum.gamestateForming
        PHYS_PLAYERS[i].hasBall = false

		ps.getStatsFromDB(PHYS_PLAYERS[i], i)		-- load stats from DB for this single player


    end
end

local function endTheDown()
	fun.playAudio(enum.soundWhistle, false, true)

	downNumber = downNumber + 1
	DOWN_TIME = 0
	deadBallTimer = 3       -- three second pause before resetting
end

local function endtheround(score)
    -- end the game
    OFFENSIVE_SCORE = score
    OFFENSIVE_TIME = cf.round(OFFENSIVE_TIME, 4)

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery
    strQuery = "Update SEASON set OFFENCESCORE = " .. score .. ", OFFENCETIME = " .. OFFENSIVE_TIME .. " where TEAMID = " .. OFFENSIVE_TEAMID
    local dberror = fbdb:exec(strQuery)
    fbdb:close()

    -- move to the next scene
    REFRESH_DB = true
    -- need to reset status here. Some are done in the endgame scene
    GAME_STATE = nil

    cf.SwapScreen(enum.sceneEndGame, SCREEN_STACK)
end

local function vectorMovePlayer(obj, dt)
	-- receives a player physical object and uses vector math to move it towards target
	-- determine actual velocity vs intended velocity based on target

	local fltForceAdjustment = 20	-- tweak this to get fluid motion
	local fltMaxVAdjustment = 0.25	-- tweak this to get fluid motion


	local playervelx, playervely = obj.body:getLinearVelocity()		-- this is the players velocity vector

	local objx = obj.body:getX()
	local objy = obj.body:getY()

	local targetx = obj.waypointx[1]
	local targety = obj.waypointy[1]

	-- determine vector to target
	local vectorxtotarget = targetx - objx
	local vectorytotarget = targety - objy

	-- if the game is in play, then make sure obj doesn't stop short of target
	if GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateAirborne or GAME_STATE == enum.running then
		vectorxtotarget = vectorxtotarget * 10
		vectorytotarget = vectorytotarget * 10
	end

	-- determine the aceleration vector that needs to be applied to the velocity vector to reach the target.
	-- target vector - player velocity vector
	local acelxvector,acelyvector = cf.subtractVectors(vectorxtotarget, vectorytotarget,playervelx,playervely)

	-- so we now have mass and aceleration. Time to determine Force.
	-- F = m * a
	-- Fx = m * Xa
	-- Fy = m * Ya
	-- local intendedxforce = obj.body:getMass() * acelxvector
	-- local intendedyforce = obj.body:getMass() * acelyvector
	local intendedxforce = acelxvector * 100		--! this formula doesn't look right
	local intendedyforce = acelyvector * 100

	-- if target is in front of player and at maxV then discontinue the application of force (intendedforce = 0)
	-- can't cut aceleration because that is the braking force and we don't want to disallow that
	if cf.dotVectors(playervelx, playervely,vectorxtotarget,vectorytotarget) > 0 then	-- > 0 means target is in front of player
		-- if player is exceeding maxV then cancel force
		if (playervelx > obj.maxV * fltMaxVAdjustment) or (playervelx < (obj.maxV * -1 * fltMaxVAdjustment)) then
			-- don't apply any force until vel drops down
			intendedxforce = 0
		end
		-- repeat for y axis vector
		if (playervely > obj.maxV) or (playervely < (obj.maxV * -1)) then
			-- don't apply any force
			intendedyforce = 0
		end
	end

	-- if i == 1 and GAME_STATE == enum.gamestateForming and intendedxforce == 0 then error() end

	-- if player intended force is great than the limits for that player then dial that intended force back
	if intendedxforce > obj.maxF then
		intendedxforce = obj.maxF
	end
	if intendedxforce < (obj.maxF * -1) then
		intendedxforce = obj.maxF * -1
	end
	if intendedyforce > obj.maxF then
		intendedyforce = obj.maxF
	end
	if intendedyforce < (obj.maxF * -1) then
		intendedyforce = obj.maxF * -1
	end

	-- now apply dtime to intended force and then apply a game speed factor that works
	intendedxforce = intendedxforce * fltForceAdjustment * dt
	intendedyforce = intendedyforce * fltForceAdjustment * dt

	-- safeties move at half speed so they slowly move across the field and don't stray from their zone too much
	if obj.positionletters == "S1" or obj.positionletters == "S2" then
		if GAME_STATE == enum.gamestateInPlay then
			intendedxforce = intendedxforce / 2
			intendedyforce = intendedyforce / 2
		end
	end

	-- now we can apply force
	obj.body:applyForce(intendedxforce,intendedyforce)

	-- debugging
	-- if i == 1 then
	-- 	print("Physics data for QB:")
	-- 	print(fltForceAdjustment, fltMaxVAdjustment, obj.maxF, obj.maxV, playervelx, playervely, intendedxforce, intendedyforce)
	-- 	print("***")
	-- end
end

local function moveAllPlayers(dt)
    local fltForceAdjustment = 20	-- tweak this to get fluid motion
    local fltMaxVAdjustment = 0.25	-- tweak this to get fluid motion


    if GAME_STATE ~= enum.gamestateDeadBall then
		-- ball is not dead

		local ballcarrier		-- declared here and used way down the bottom

		-- determine what to do for all 22 players
        for i = 1, NumberOfPlayers do
			if PHYS_PLAYERS[i].hasBall then ballcarrier = i end		-- set here and used way down the bottom

            local objx = PHYS_PLAYERS[i].body:getX()
            local objy = PHYS_PLAYERS[i].body:getY()
			local targetx = PHYS_PLAYERS[i].waypointx[1]
			local targety = PHYS_PLAYERS[i].waypointy[1]

			-- see if unit has waypoints
			if targetx == nil or targety == nil then
				-- do nothing as there are no waypoints
			else
				-- this player has a target. Move towards it if not fallen
	            if not PHYS_PLAYERS[i].fallen then

	                -- get distance to waypoint
	                local disttotarget = cf.getDistance(objx, objy, targetx, targety)

	                -- see if arrived
	                if disttotarget <= 0.75 then
	                    -- arrived
	                    if PHYS_PLAYERS[i].gamestate == enum.gamestateForming then
	                        PHYS_PLAYERS[i].gamestate = enum.gamestateReadyForSnap
						end

						-- Remove this waypoint.
						table.remove(PHYS_PLAYERS[i].waypointx, 1)
						table.remove(PHYS_PLAYERS[i].waypointy, 1)

						-- apply brakes
						local velx, vely = PHYS_PLAYERS[i].body:getLinearVelocity()
						PHYS_PLAYERS[i].body:setLinearVelocity(velx / 2, vely / 2)
	                else
	                    -- player not arrived
						vectorMovePlayer(PHYS_PLAYERS[i], dt)
	                end
	            else
	            end
			end
        end

		-- update the football x/y so it aligns to the player holding it
		if (GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateRunning) and football.waypointx[1] == nil then
			-- no waypoints set for football. That means it is being held
			-- ballcarrier is set in the loop above
			football.x = PHYS_PLAYERS[ballcarrier].body:getX()
			football.y = PHYS_PLAYERS[ballcarrier].body:getY()
		end
    end
end

local function moveFootball(dt)
	local throwspeed = 20		-- 20 metres / second  (adjusted by dt)

	if football.waypointx[1] ~= nil then
		-- there is a waypoint. Move the ball towards it.

		-- print("Footballx is " .. football.x)
		-- print("Football targetx is " .. football.waypointx[1])
		-- print("Max dist possible is " .. throwspeed * dt)

		-- understand the vector for ball to target.
		local vectorx = football.waypointx[1] - football.x
		local vectory = football.waypointy[1] - football.y

		-- get length of this vector
		local disttotarget = cf.getDistance(0, 0, vectorx, vectory)

		-- print("Dist to target is " .. disttotarget)

		-- see if whole distance can be travelled in this time step
		if disttotarget <= (throwspeed * dt) then
			-- ball has arrived because whole distance is travelled during this time step

			football.x = football.waypointx[1]
			football.y = football.waypointy[1]

			-- clear the waypoint for the ball
			football.waypointx = {}
			football.waypointy = {}

			-- set the new carrier to the closest player
			local closestdistance = 1000
			local closestplayer = 0

			for i = 2,22 do	-- Loop is 2,22 because the QB is not a valid receiver
				-- check distance between this player and the ball
				-- ignore anyone fallen down
				if not PHYS_PLAYERS[i].fallendown then
					local mydistance = cf.getDistance(football.x,football.y, PHYS_PLAYERS[i].body:getX(), PHYS_PLAYERS[i].body:getY())
					if mydistance < closestdistance then
						-- we have a new candidate
						closestdistance = mydistance
						closestplayer = i
					end
				end
			end
			PHYS_PLAYERS[closestplayer].hasBall = true
			GAME_STATE = enum.gamestateRunning		-- move from airborne to running regardless of throw outcome

			if closestdistance > 5 then		-- this number might need tuning
				--! should make this based on catchskill and a percentage or something more sophisticated
				-- unit too far away. Ball is dropped. Incomplete
				endTheDown()
				GAME_STATE = enum.gamestateDeadBall
			end
			if PHYS_PLAYERS[closestplayer].fallendown then
				endTheDown()
				GAME_STATE = enum.gamestateDeadBall
			end
			if closestplayer > 11 then
				-- turn over		--! possible intercept?
				endTheDown()
				GAME_STATE = enum.gamestateDeadBall
			end
		else
			-- ball won't reach target this time step
			-- determine new x/y
			-- get the % of distance moved along vector (ratio) and then determine a new vector of that ratio
			-- add that smaller vector to the football x/y
			local distancemoved = throwspeed * dt		-- ball will move this much along x and y, depending on angle
			local ratio = distancemoved / disttotarget		-- this is a percentage
			local distancex, distancey = cf.scaleVector(vectorx, vectory, ratio)

			-- add the distance travelled to football x/y
			football.x = football.x + distancex
			football.y = football.y + distancey

			-- print("Adding this value to Y: " .. distancey)
		end
	else
		-- print("Football has no target")
	end
end

local function drawStadium()

    if REFRESH_DB then	-- this only happens once per game
        arr_seasonstatus = {}
        local fbdb = sqlite3.open(DB_FILE)
        local strQuery = "select teams.TEAMNAME, teams.RED, teams.GREEN, teams.BLUE, season.TEAMID, season.OFFENCESCORE, season.OFFENCETIME from season inner join TEAMS on teams.TEAMID = season.TEAMID"
        for row in fbdb:nrows(strQuery) do
            local mytable = {}
            mytable.TEAMNAME = row.TEAMNAME
            mytable.TEAMID = row.TEAMID
            mytable.OFFENCESCORE = row.OFFENCESCORE
            table.insert(arr_seasonstatus, mytable)

            if row.TEAMID == OFFENSIVE_TEAMID then
                offensiveteamname = row.TEAMNAME
                OFF_RED = row.RED
                OFF_GREEN = row.GREEN
                OFF_BLUE = row.BLUE

            end
            if row.TEAMID == DEFENSIVE_TEAMID then
                defensiveteamname = row.TEAMNAME
				DEFENSIVE_SCORE = row.OFFENCESCORE		-- the offense score becomes the defense score when defending
				DEFENSIVE_TIME = row.OFFENCETIME
                DEF_RED = row.RED
                DEF_GREEN = row.GREEN
                DEF_BLUE = row.BLUE
            end
        end
        REFRESH_DB = false
        fbdb:close()

		playerTeamID = fun.getPlayerTeamID()

        assert(OFF_RED ~= nil, strQuery)
        assert(DEF_RED ~= nil, strQuery)

        createPhysicsPlayers(OFFENSIVE_TEAMID, DEFENSIVE_TEAMID)
        GAME_STATE = enum.gamestateForming
		OFFENSIVE_TIME = 0
    end

    -- top goal
    love.graphics.setColor(153/255, 153/255, 255/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, TopPostY * SCALE, FieldWidth * SCALE, GoalHeight * SCALE)

    -- bottom goal
    love.graphics.setColor(255/255, 153/255, 51/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, (TopPostY + GoalHeight + FieldHeight) * SCALE, FieldWidth * SCALE, GoalHeight * SCALE)

    -- field
    love.graphics.setColor(69/255, 172/255, 79/255)
    love.graphics.rectangle("fill", LeftLineX * SCALE, (TopPostY + GoalHeight) * SCALE, FieldWidth * SCALE, FieldHeight * SCALE)

    -- yard lines
    for i = 0,20 do
        if cf.isEven(i) then
            love.graphics.setColor(1,1,1,1)
        else
            love.graphics.setColor(1,1,1,0.5)
        end
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
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line", LeftLineX * SCALE, TopPostY * SCALE, FieldWidth * SCALE, (GoalHeight + FieldHeight + GoalHeight) * SCALE)

    -- draw stadium seats
	local drawx = (LeftLineX - 16) * SCALE
	local drawy = (TopGoalY - 6) * SCALE
	local stadiumheight = 115

	love.graphics.setColor(1,1,1,1)
	for i = 1, 6 do
		love.graphics.draw(IMAGE[enum.imageStadium], drawx, drawy + (i * stadiumheight), 0, 0.25, 0.25)
	end

    -- draw scrimmage
	love.graphics.setColor(93/255, 138/255, 169/255,1)
	love.graphics.setLineWidth(5)
	love.graphics.line(LeftLineX * SCALE, ScrimmageY * SCALE, RightLineX * SCALE, ScrimmageY * SCALE)
	love.graphics.setLineWidth(1)	-- return width back to default

    -- draw first down marker
	love.graphics.setColor(255/255, 255/255, 51/255,1)
	love.graphics.setLineWidth(5)
	love.graphics.line(LeftLineX * SCALE, FirstDownMarkerY * SCALE, RightLineX * SCALE, FirstDownMarkerY * SCALE)
	love.graphics.setLineWidth(1)	-- return width back to default
end

local function drawPlayers()

    for i = 1, NumberOfPlayers do
        local objx = PHYS_PLAYERS[i].body:getX()
        local objy = PHYS_PLAYERS[i].body:getY()
        local objradius = PHYS_PLAYERS[i].shape:getRadius()

        -- scale to screen
        objx = objx * SCALE
        objy = objy * SCALE
        objradius = objradius * SCALE

        -- draw player
		local alpha
		if PHYS_PLAYERS[i].fallen then
			alpha = 0.5
		else
			alpha = 1
		end
        if i <= (NumberOfPlayers / 2) then
            -- offense
            love.graphics.setColor(OFF_RED/255, OFF_GREEN/255, OFF_BLUE/255, alpha)
        else
            -- defense
            love.graphics.setColor(DEF_RED/255, DEF_GREEN/255, DEF_BLUE/255, alpha)
        end
        love.graphics.circle("fill", objx, objy, objradius)

		-- draw ball
		if GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateAirborne or GAME_STATE == enum.gamestateRunning then
			love.graphics.setColor(1,0,0,1)
			love.graphics.draw(IMAGE[enum.imageFootball], football.x * SCALE, (football.y * SCALE) - 15, 0, 0.25, 0.25, 0, 0)
		end

        -- draw fallen
        if PHYS_PLAYERS[i].fallen then
            love.graphics.setColor(1,0,0,1)
            love.graphics.circle("fill", objx, objy, objradius / 2)
        end

        -- draw position letters
        if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") then
            local drawx = objx + 10
            local drawy = objy - 15
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(PHYS_PLAYERS[i].positionletters, drawx, drawy)
        end

		-- if i == 1 then	-- special QB debugging
		-- 	local drawx = objx - 30
		-- 	local drawy = objy - 15
		-- 	local playervelx, playervely = PHYS_PLAYERS[1].body:getLinearVelocity()		-- this is the players velocity vector
		-- 	playervelx = cf.round(playervelx, 1)
		-- 	playervely = cf.round(playervely, 1)
		-- 	love.graphics.setColor(1,1,1,1)
		-- 	love.graphics.print(playervelx, drawx, drawy)
		-- 	love.graphics.print(playervely, drawx, drawy + 7)
		-- end

		-- debugging
		if i == 0 or i == 0 then
			-- draw the waypoint
			if PHYS_PLAYERS[i].waypointx[1] ~= nil then
				local x2 = PHYS_PLAYERS[i].waypointx[1] * SCALE
				local y2 = PHYS_PLAYERS[i].waypointy[1] * SCALE
				love.graphics.line(objx, objy, x2, y2)
			end
		end
    end

    -- draw the QB target
    if (PHYS_PLAYERS[1].waypointx[1] ~= nil) and (OFFENSIVE_TEAMID == playerTeamID) then
		if PHYS_PLAYERS[1].waypointx ~= nil and PHYS_PLAYERS[1].hasBall then
	        local drawx = PHYS_PLAYERS[1].waypointx[1] * SCALE
	        local drawy = PHYS_PLAYERS[1].waypointy[1] * SCALE
	        love.graphics.setColor(1,1,0,1) -- yellow
	        love.graphics.circle("line", drawx, drawy, 0.75 * SCALE)
		end
    end
end

local function drawScoreboard()
	-- draws the team scores etc. Happens when camera is detached
	-- print the two teams
	love.graphics.setColor(1,1,1,1)
	love.graphics.print(offensiveteamname, 50, 50)       -- this needs to be the team name and not the ID
	love.graphics.print("Time used: " .. cf.round(OFFENSIVE_TIME, 2), 50, 100)
	love.graphics.print("Down #: " .. downNumber, 50, 125)
	love.graphics.print("Yards to go: " .. cf.round(ScrimmageY - FirstDownMarkerY, 0), 50, 150)


	-- love.graphics.print("QB throw: " .. PHYS_PLAYERS[1].throwaccuracy, 50, 150)

	-- defense score board
	love.graphics.print(defensiveteamname, SCREEN_WIDTH - 250, 50)
	if DEFENSIVE_SCORE ~= nil then love.graphics.print(DEFENSIVE_SCORE, SCREEN_WIDTH - 250, 100) end	-- will be nil if team not played yet
	if DEFENSIVE_TIME ~= nil then love.graphics.print(cf.round(DEFENSIVE_TIME, 2), SCREEN_WIDTH - 250, 150) end
end

local function beginContact(a, b, coll)
    if GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateAirborne or GAME_STATE == enum.gamestateRunning then
        local aindex = a:getUserData()
        local bindex = b:getUserData()

		if (aindex <= (NumberOfPlayers / 2) and bindex >= (NumberOfPlayers / 2 + 1)) or (aindex >= (NumberOfPlayers / 2 +1) and bindex <= NumberOfPlayers / 2) then
            -- contact with the enemy

			if PHYS_PLAYERS[aindex].fallen == true or PHYS_PLAYERS[bindex].fallen == true then
				-- can't fall over fallen players. Do nothing
			else
	            abalance = PHYS_PLAYERS[aindex].balance
	            bbalance = PHYS_PLAYERS[bindex].balance

				print("Balance stats are " .. abalance .. " and " .. bbalance)

	            if love.math.random(0, 100) > abalance then
	                PHYS_PLAYERS[aindex].fallen = true
	                PHYS_PLAYERS[aindex].fixture:setSensor(true)
					PHYS_PLAYERS[aindex].waypointx = {}
					PHYS_PLAYERS[aindex].waypointy = {}
	            end

	            if love.math.random(0, 100) > bbalance then
	                PHYS_PLAYERS[bindex].fallen = true
	                PHYS_PLAYERS[bindex].fixture:setSensor(true)
					PHYS_PLAYERS[bindex].waypointx = {}
					PHYS_PLAYERS[bindex].waypointy = {}

	            end
			end
        else
            -- friendly contact. Do nothing
        end
    end
end

local function resetFallenPlayers()
    -- pick up all the players
    for i = 1, NumberOfPlayers do
        PHYS_PLAYERS[i].fixture:setSensor(true)	    -- start without collisions. Shouldn't be necessary here
        PHYS_PLAYERS[i].fallen = false
        PHYS_PLAYERS[i].targetx = nil
        PHYS_PLAYERS[i].targety = nil
        PHYS_PLAYERS[i].targettimer = nil
        PHYS_PLAYERS[i].gamestate = enum.gamestateForming
        PHYS_PLAYERS[i].hasBall = false
    end
end

local function resetFirstDown()
    -- a first down is detected
	-- uses global variables
    FirstDownMarkerY = ScrimmageY - 10
    if FirstDownMarkerY < TopGoalY then FirstDownMarkerY = TopGoalY end
    downNumber = 1
end

local function checkForStateChange(dt)
	-- looks for key events that will trigger a change in game state

	if GAME_STATE == enum.gamestateForming then
		-- print("Game state = forming")

        -- check if everyone is formed up
        for i = 1, NumberOfPlayers do
			-- print("Player gamestate for player " .. i .. " = " .. PHYS_PLAYERS[i].gamestate)
            if PHYS_PLAYERS[i].gamestate ~= enum.gamestateReadyForSnap then
                -- no state change. Abort.
                return
            end
        end

        -- if above loop didn't abort then all players are ready for snap. Change state
        GAME_STATE = enum.gamestateInPlay
        PHYS_PLAYERS[1].hasBall = true
		football.x = PHYS_PLAYERS[1].body:getX()
		football.y = PHYS_PLAYERS[1].body:getY()
		football.waypointx = {}	-- there is only nil or one waypoint but made an array for coding consistency
		football.waypointy = {}

        for i = 1, NumberOfPlayers do
            PHYS_PLAYERS[i].fixture:setSensor(false)
            PHYS_PLAYERS[i].gamestate = enum.gamestateInPlay

			if i <= 11 then
				waypoints.setInPlayWapointsThrow(PHYS_PLAYERS[i], i)		-- set offensive routes just once when ball is snapped
			end
	    end

		fun.playAudio(enum.soundGo, false, true)

    elseif GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateRunning then
        -- check for a number of conditions

        for i = 1, NumberOfPlayers / 2 do
            if PHYS_PLAYERS[i].hasBall then
                if PHYS_PLAYERS[i].fallen then
                    -- the runner is down/fallen
					endTheDown()
                    ScrimmageY = PHYS_PLAYERS[i].body:getY()
                    if ScrimmageY <= FirstDownMarkerY then
                        resetFirstDown()
                    end
					GAME_STATE = enum.gamestateDeadBall
                end

                -- runner is outside the field
                local objx = PHYS_PLAYERS[i].body:getX()
                if objx < LeftLineX or objx > RightLineX then
					endTheDown()
                    ScrimmageY = PHYS_PLAYERS[i].body:getY()
                    if ScrimmageY <= FirstDownMarkerY then
                        resetFirstDown()
                    end
					GAME_STATE = enum.gamestateDeadBall
                end

                -- runner is across the goal
                local objy = PHYS_PLAYERS[i].body:getY()
                if objy <= TopGoalY then
                    -- touchdown!
                    GAME_STATE = enum.gamestateGameOver
                    endtheround(6)
                end
            end
        end

    elseif GAME_STATE == enum.gamestateDeadBall then
        deadBallTimer = deadBallTimer - dt
        if deadBallTimer <= 0 then
            -- reset for next down
            GAME_STATE = enum.gamestateForming
            resetFallenPlayers()
        end
    end

	-- turnover on downs
	if downNumber > 4 then
		GAME_STATE = enum.gamestateGameOver
		endtheround(0)
	end
end

local function checkForOutOfBounds(dt)
	-- check if ball is out of bounds
	if GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateAirborne or GAME_STATE == enum.gamestateRunning then
		if football.x < LeftLineX or football.x > RightLineX then
			-- set the scrimmage to where the runner took the ball out
			if GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateRunning then
				ScrimmageY = football.y
			end
			endTheDown()
			GAME_STATE = enum.gamestateDeadBall
		end
		if football.y > BottomPostY then
			-- touchback
			endtheround(-2)
			GAME_STATE = enum.gamestateDeadBall
		end
	end
end

local function getkeyPressed()
	-- returns the key being pressed by the player
	-- only returns legit keys and ignores non-legit
	-- returns nil if no valid keys are pressed

	if love.keyboard.isDown("kp8") then
		return enum.keyUp
	elseif love.keyboard.isDown("kp2") then
		return enum.keyDown
	elseif love.keyboard.isDown("kp4") then
		return enum.keyLeft
	elseif love.keyboard.isDown("kp6") then
		return enum.keyRight
	elseif love.keyboard.isDown("space") then
		return enum.keySpace
	else
		return nil
	end
end

function stadium.draw()
    -- call this from love.draw()

	cam:attach()

    drawStadium()
    drawPlayers()

    buttons.drawButtons()

	cam:detach()

	drawScoreboard()
end

local function doUpdateLoop(dt)

	if GAME_STATE == enum.gamestateInPlay or GAME_STATE == enum.gamestateAirborne or GAME_STATE == enum.gamestateRunning then
		OFFENSIVE_TIME = OFFENSIVE_TIME + dt
		DOWN_TIME = DOWN_TIME + dt
	end

	waypoints.setAllWaypoints(NumberOfPlayers, playerTeamID, playcall_offense, playcall_defense, ScrimmageY, DOWN_TIME, dt)
	moveAllPlayers(dt)
	moveFootball(dt)
	checkForStateChange(dt)
	checkForOutOfBounds(dt)

	world:update(dt) --this puts the world into motion
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function stadium.update(dt)
    -- called from love.update()

    if REFRESH_DB then
        -- update happens before draw so this bit needs to be placed here to avoid a nil value error
        OFFENSIVE_TIME = 0

		playcall_offense = 3
		playcall_defense = 2

		GAME_STATE = enum.gamestateForming
	else
        -- update gets called before draw so do NOT try to move players before they are initialised and drawn.

		-- if team = user team and key press then set target for QB
		if OFFENSIVE_TEAMID == playerTeamID and GAME_STATE == enum.gamestateInPlay then		-- playerTeamID is set on drawStadium() i.e. on load.
			local keypressed = getkeyPressed()		-- returns an enum
			if keypressed ~= nil then
				-- a key has been pressed. Update current target
				local objx = PHYS_PLAYERS[1].body:getX()
	            local objy = PHYS_PLAYERS[1].body:getY()

				if PHYS_PLAYERS[1].waypointx[1] == nil then
					PHYS_PLAYERS[1].waypointx[1] = objx
					PHYS_PLAYERS[1].waypointy[1] = objy
				end

				local adjamount = 60 * dt		-- for convenience and tuning. Less than 60 doesn't work for some reason
				if keypressed == enum.keyDown then
					PHYS_PLAYERS[1].waypointy[1] = PHYS_PLAYERS[1].waypointy[1] + adjamount
				elseif keypressed == enum.keyLeft then
					PHYS_PLAYERS[1].waypointx[1] = PHYS_PLAYERS[1].waypointx[1] - adjamount
				elseif keypressed == enum.keyRight then
					PHYS_PLAYERS[1].waypointx[1] = PHYS_PLAYERS[1].waypointx[1] + adjamount
				elseif keypressed == enum.keyUp then
					PHYS_PLAYERS[1].waypointy[1] = PHYS_PLAYERS[1].waypointy[1] - adjamount
				end
				-- print("QB WP1 is now " .. PHYS_PLAYERS[1].waypointx[1], PHYS_PLAYERS[1].waypointy[1] )
			end

			if PHYS_PLAYERS[1].hasBall then
				-- see if QB is near waypoint
				if PHYS_PLAYERS[1].waypointx[1] ~= nil then
					local objx = PHYS_PLAYERS[1].body:getX()
					local objy = PHYS_PLAYERS[1].body:getY()
					local wpx = PHYS_PLAYERS[1].waypointx[1]
					local wpy = PHYS_PLAYERS[1].waypointy[1]

					-- get distance from QB to QB waypoint
					local disttotarget = cf.getDistance(objx, objy, wpx, wpy)
					if disttotarget >= 0.3 then
						doUpdateLoop(dt)
					else
						-- QB is on the target with the ball. Pause the sim so user can think
						-- do nothing (no update loop)
						-- QB has no waypoint. Check if space is pushed
						if keypressed == enum.keySpace then
							doUpdateLoop(dt)
						else
							-- no wp and no space. Do nothing. Pause the sim
						end
					end
				else
					-- QB has no waypoint. Check if space is pushed
					if keypressed == enum.keySpace then
						doUpdateLoop(dt)
					else
						-- no wp and no space. Do nothing. Pause the sim
					end
				end
			else
				doUpdateLoop(dt)
			end
		else
			doUpdateLoop(dt)
		end

		cam:setZoom(ZOOMFACTOR)
		cam:setPos(TRANSLATEX,	TRANSLATEY)
    end
end

function stadium.loadButtons()
    -- call this from love.load()

    local numofbuttons = 1      -- how many buttons on this form, assuming a single column
    local numofsectors = numofbuttons + 1

    -- button for exit
    local mybutton = {}
    local buttonsequence = 1            -- sequence on the screen
    mybutton.x = SCREEN_WIDTH * 2/3
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
