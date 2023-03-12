stadium = {}

local NumberOfPlayers = 22	-- total. 11 + 11
local arr_seasonstatus, offensiveteamname, defensiveteamname, deadBallTimer
local playcall_offense = 3 --!enum.playcallThrow
local playcall_defense = 2 --!enum.playcallManOnMan
local downNumber = 1
local football = {}			-- contains the x/y of the football
football.waypointx = {}
football.waypointy = {}


local OFF_RED, OFF_GREEN, OFF_BLUE, DEF_RED, DEF_GREEN, DEF_BLUE
local DEFENSIVE_TIME, DEFENSIVE_SCORE

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
	if GAME_STATE == enum.gamestateReadyForSnap then
		if scancode == "a" then
			GAME_STATE = enum.gamestateInPlay

		elseif scancode == "s" then
			GAME_STATE = enum.gamestateInPlay

		elseif scancode == "d" then
			GAME_STATE = enum.gamestateInPlay

		elseif scancode == "w" then
			GAME_STATE = enum.gamestateInPlay
		end
	end

	if GAME_STATE == enum.gamestateInPlay then
		if scancode == "a" then
			PHYS_PLAYERS[1].targetx = PHYS_PLAYERS[1].targetx - 1

		elseif scancode == "s" then
			PHYS_PLAYERS[1].targety = PHYS_PLAYERS[1].targety + 1

		elseif scancode == "d" then
			PHYS_PLAYERS[1].targetx = PHYS_PLAYERS[1].targetx + 1

		elseif scancode == "w" then
			PHYS_PLAYERS[1].targety = PHYS_PLAYERS[1].targety - 1
		end
	end

	local translatefactor = 5 * (ZOOMFACTOR * 2)		-- screen moves faster when zoomed in

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

	if key == "kp5" then		--! make this scancode later on
		ZOOMFACTOR = 1
		TRANSLATEX = SCREEN_WIDTH / 2
		TRANSLATEY = SCREEN_HEIGHT / 2
	end

	if key == "-" then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if key == "=" then
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

function stadium.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonStadiumQuit then
        love.event.quit()
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
            rndy = love.math.random(HalfwayY, BottomGoalY)
        else
            rndy = love.math.random(TopGoalY + 30, HalfwayY)
        end

        PHYS_PLAYERS[i] = {}
        PHYS_PLAYERS[i].body = love.physics.newBody(world, rndx, rndy, "dynamic") --place the body in the the world and make it dynamic
        PHYS_PLAYERS[i].body:setLinearDamping(0.7)      -- this applies braking force and removes inertia
        PHYS_PLAYERS[i].body:setMass(love.math.random(80,100))	 -- kilograms
        PHYS_PLAYERS[i].shape = love.physics.newCircleShape(0.75)        -- circle radius
        PHYS_PLAYERS[i].fixture = love.physics.newFixture(PHYS_PLAYERS[i].body, PHYS_PLAYERS[i].shape, 1)   -- Attach fixture to body and give it a density of 1.
        PHYS_PLAYERS[i].fixture:setRestitution(0.25)        -- bounce/rebound
        PHYS_PLAYERS[i].fixture:setSensor(true)	    -- start without collisions
        PHYS_PLAYERS[i].fixture:setUserData(i)      -- a handle to itself

        PHYS_PLAYERS[i].fallen = false
        PHYS_PLAYERS[i].targetx = nil
        PHYS_PLAYERS[i].targety = nil
		PHYS_PLAYERS[i].waypointx = nil
		PHYS_PLAYERS[i].waypointy = nil
        PHYS_PLAYERS[i].targettimer = nil
        PHYS_PLAYERS[i].gamestate = enum.gamestateForming
        PHYS_PLAYERS[i].hasBall = false

        -- ps.setCustomStats(PHYS_PLAYERS[i], i)		--! this needs to be removed when loading from DB
		ps.getStatsFromDB(PHYS_PLAYERS[i], i)		-- load stats from DB for this single player


    end
end

local function setInPlayTargetRun(obj, index)
	-- the targets for obj[index] to rush the goal
	if index == 1 then
		obj.targety = TopPostY
	elseif index == 2 or index == 3 or index == 4 then	-- WR
		local enemyindex, enemydist = determineClosestObject(index, "CB", false)
		if enemyindex == 0 then
			local enemyindex, enemydist = determineClosestObject(index, "", false)
			if enemyindex == 0 then
				-- no target (what?!)
				obj.targety = TopPostY
			else
				-- bee line to the nearest defender
				obj.targetx = PHYS_PLAYERS[enemyindex].body:getX()
				obj.targety = PHYS_PLAYERS[enemyindex].body:getY()
			end
		else
			obj.targetx = PHYS_PLAYERS[enemyindex].body:getX()
			obj.targety = PHYS_PLAYERS[enemyindex].body:getY()
		end
	elseif index == 6 then		-- TE
		local enemyindex, enemydist = determineClosestObject(index, "ILB", false)
		if enemyindex == 0 then		-- 0 means the correct position type was not found
			-- target closest player
			local enemyindex, enemydist = determineClosestObject(index, "", false)
			if enemyindex == 0 then
				-- no target (what?!)
				obj.targety = TopPostY
			else
				-- bee line to the nearest defender
				obj.targetx = PHYS_PLAYERS[enemyindex].body:getX()
				obj.targety = PHYS_PLAYERS[enemyindex].body:getY()
			end
		else
			-- bee line to the nearest defender
			obj.targetx = PHYS_PLAYERS[enemyindex].body:getX()
			obj.targety = PHYS_PLAYERS[enemyindex].body:getY()
		end
	elseif index == 7 or index == 8 or index == 9 or index == 10 or index == 11 then
		-- target closest player
		local enemyindex, enemydist = determineClosestObject(index, "", false)
		if enemyindex ~= 0 then
			local enemyx = PHYS_PLAYERS[enemyindex].body:getX()
			local enemyy = PHYS_PLAYERS[enemyindex].body:getY()
			local carrierx, carriery = getCarrierXY()
			if carrierx ~= nil then
				-- get the distance from the carrier to the nearest target
				-- then half that and use that as the target
				local dist = cf.getDistance(carrierx, carriery, enemyx, enemyy)
				local bearing = cf.getBearing(carrierx, carriery, enemyx, enemyy)
				local targetx, targety = cf.addVectorToPoint(carrierx, carriery, bearing, dist / 2)

				obj.targetx = targetx

				-- if target is 'forward' then move forward. If it's behind, then just shuffle sideways
				local objy = obj.body:getY()
				if targety < objy then
					obj.targety = targety
				else
					-- nothing
				end
			else
				--! idk
			end
		else
			--! idk
		end
	else
		-- target closest player
		local enemyindex, enemydist = determineClosestObject(index, "", false)
		if enemyindex == 0 then
			-- no target (what?!)
			obj.targety = TopPostY
		else
			-- bee line to the nearest defender
			obj.targetx = PHYS_PLAYERS[enemyindex].body:getX()
			obj.targety = PHYS_PLAYERS[enemyindex].body:getY()
		end
	end
end

local function setInPlayTargetManOnMan(obj, carrierindex)
	-- sets the defense to target the carrier
	--! this is not the correct behavior for man on man

	print("setting man on man targets for position " .. obj.positionletters)

	-- default to carrier and then overwrite below
	obj.targetx = PHYS_PLAYERS[carrierindex].body:getX()
	obj.targety = PHYS_PLAYERS[carrierindex].body:getY()

	local thisindex = obj.fixture:getUserData()

	if obj.positionletters == "DT1" or obj.positionletters == "DT2" or obj.positionletters == "LE" or obj.positionletters == "RE" then
		-- rush the carrier
		obj.targetx = PHYS_PLAYERS[carrierindex].body:getX()
		obj.targety = PHYS_PLAYERS[carrierindex].body:getY()

	elseif obj.positionletters == "CB1" then
		local targetindex, targetdist = determineClosestObject(thisindex, "WR3", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		end
	elseif obj.positionletters == "CB2" then
		local targetindex, targetdist = determineClosestObject(thisindex, "WR2", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		end
	elseif obj.positionletters == "ILB" then
		local targetindex, targetdist = determineClosestObject(thisindex, "RB", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		end
	elseif obj.positionletters == "OLB1" then
		local targetindex, targetdist = determineClosestObject(thisindex, "WR1", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		end
	elseif obj.positionletters == "OLB2" then
		local targetindex, targetdist = determineClosestObject(thisindex, "TE", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		end
	elseif obj.positionletters == "S1" then
		-- target WR1 first and then WR3
		local targetindex, targetdist = determineClosestObject(thisindex, "WR1", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		else
			-- if no WR1 then target WR3
			local targetindex, targetdist = determineClosestObject(thisindex, "WR3", false)
			if targetindex ~= 0 then
				obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
				obj.targety = PHYS_PLAYERS[targetindex].body:getY()
			end
		end
	elseif obj.positionletters == "S2" then
		-- target TE first and then WR2
		local targetindex, targetdist = determineClosestObject(thisindex, "TE", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		else
			-- if no WR1 then target WR2
			local targetindex, targetdist = determineClosestObject(thisindex, "WR2", false)
			if targetindex ~= 0 then
				obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
				obj.targety = PHYS_PLAYERS[targetindex].body:getY()
			end
		end
	end
end

local function setFormingWaypoints(obj, index)
    -- receives a single object and sets it's target

	-- clear old waypoints
	obj.waypointx = {}
	obj.waypointy = {}
	-- player 1 = QB
    if index == 1 then
		table.insert(obj.waypointx, CentreLineX)	-- centre line
		table.insert(obj.waypointy, ScrimmageY + 8)
	elseif index == 2 then		-- WR (left closest to centre)
		table.insert(obj.waypointx, CentreLineX - 14)		-- left 'wing'
		table.insert(obj.waypointy, ScrimmageY + 2)			-- just behind scrimmage
	elseif index == 3 then				-- WR (right)
		table.insert(obj.waypointx, CentreLineX + 18)
		table.insert(obj.waypointy, ScrimmageY + 2)
	elseif index == 4 then		-- WR (left on outside)
		table.insert(obj.waypointx, CentreLineX - 18)	 -- left 'wing')
		table.insert(obj.waypointy, ScrimmageY + 2)		-- just behind scrimmage
	elseif index == 5 then 		-- RB
		table.insert(obj.waypointx, CentreLineX)
		table.insert(obj.waypointy, ScrimmageY + 14)
	elseif index == 6 then		-- TE (right side)
		table.insert(obj.waypointx, CentreLineX + 13)
		table.insert(obj.waypointy, ScrimmageY + 3)
	elseif index == 7 then
		table.insert(obj.waypointx, CentreLineX)
		table.insert(obj.waypointy, ScrimmageY)
	elseif index == 8 then		-- left guard
		table.insert(obj.waypointx, CentreLineX - 4)
		table.insert(obj.waypointy, ScrimmageY + 2)
	elseif index == 9 then		-- right guard
		table.insert(obj.waypointx, CentreLineX + 4)
		table.insert(obj.waypointy, ScrimmageY + 2)
	elseif index == 10 then		-- left tackle
		table.insert(obj.waypointx, CentreLineX - 7)
		table.insert(obj.waypointy, ScrimmageY + 3)
	elseif index == 11 then		-- right tackle
		table.insert(obj.waypointx, CentreLineX + 7)
		table.insert(obj.waypointy, ScrimmageY + 3)
	elseif index == 12 then		-- left tackle (left side of screen)
		table.insert(obj.waypointx, CentreLineX - 2)
		table.insert(obj.waypointy, ScrimmageY - 2)
	elseif index == 13 then		-- right tackle
		table.insert(obj.waypointx, CentreLineX + 2)
		table.insert(obj.waypointy, ScrimmageY - 2)
	elseif index == 14 then		-- left end
		table.insert(obj.waypointx, CentreLineX - 6)
		table.insert(obj.waypointy, ScrimmageY - 2)
	elseif index == 15 then		-- right end
		table.insert(obj.waypointx, CentreLineX + 6)
		table.insert(obj.waypointy, ScrimmageY - 2)
	elseif index == 16 then		-- inside LB
		table.insert(obj.waypointx, CentreLineX)
		table.insert(obj.waypointy, ScrimmageY - 11)
	elseif index == 17 then		-- left outside LB
		table.insert(obj.waypointx, CentreLineX - 15)
		table.insert(obj.waypointy, ScrimmageY - 10)
	elseif index == 18 then		-- left guard
		table.insert(obj.waypointx, CentreLineX + 15)
		table.insert(obj.waypointy, ScrimmageY - 10)
	elseif index == 19 then		-- left CB
		table.insert(obj.waypointx, CentreLineX - 18)
		table.insert(obj.waypointy, ScrimmageY - 18)
	elseif index == 20 then		-- left guard
		table.insert(obj.waypointx, CentreLineX + 18)
		table.insert(obj.waypointy, ScrimmageY - 18)
	elseif index == 21 then		-- left safety
		table.insert(obj.waypointx, CentreLineX - 4)
		table.insert(obj.waypointy, ScrimmageY - 17)
	elseif index == 22 then		-- right safety
		table.insert(obj.waypointx, CentreLineX + 4)
		table.insert(obj.waypointy, ScrimmageY - 17)
    end
end

local function setInPlayWapointsThrow(obj, index)
	-- clear old waypoints
	obj.waypointx = {}
	obj.waypointy = {}
	-- player 1 = QB
    if index == 1 then
		table.insert(obj.waypointx, CentreLineX)	-- centre line
		table.insert(obj.waypointy, ScrimmageY + 11)
	elseif index == 2 then		-- WR (left closest to centre)
		table.insert(obj.waypointx, CentreLineX - 14)		-- left 'wing'
		table.insert(obj.waypointy, ScrimmageY - 12)
		table.insert(obj.waypointx, CentreLineX)
		table.insert(obj.waypointy, ScrimmageY - 12)
	elseif index == 3 then				-- WR (right)
		table.insert(obj.waypointx, CentreLineX + 18)
		table.insert(obj.waypointy, ScrimmageY - 17)
	elseif index == 4 then		-- WR (left on outside)
		table.insert(obj.waypointx, CentreLineX - 18)	 -- left 'wing')
		table.insert(obj.waypointy, ScrimmageY - 17)		-- just behind scrimmage
	elseif index == 5 then 		-- RB
		table.insert(obj.waypointx, CentreLineX - 5)
		table.insert(obj.waypointy, ScrimmageY + 10)
	elseif index == 6 then		-- TE (right side)
		table.insert(obj.waypointx, CentreLineX + 13)
		table.insert(obj.waypointy, ScrimmageY - 8)
		table.insert(obj.waypointx, CentreLineX + 5)
		table.insert(obj.waypointy, ScrimmageY - 18)
	elseif index == 7 then		-- centre
		table.insert(obj.waypointx, CentreLineX)
		table.insert(obj.waypointy, ScrimmageY - 5)
	elseif index == 8 then		-- left guard
		table.insert(obj.waypointx, CentreLineX - 4)
		table.insert(obj.waypointy, ScrimmageY - 3)
	elseif index == 9 then		-- right guard
		table.insert(obj.waypointx, CentreLineX + 4)
		table.insert(obj.waypointy, ScrimmageY - 3)
	elseif index == 10 then		-- left tackle
		table.insert(obj.waypointx, CentreLineX - 7)
		table.insert(obj.waypointy, ScrimmageY - 2)
	elseif index == 11 then		-- right tackle
		table.insert(obj.waypointx, CentreLineX + 7)
		table.insert(obj.waypointy, ScrimmageY - 2)
	end
end

local function setInPlayWaypoints(obj, index, runnerindex, dt)
    -- determine the target for the single obj
    -- runnerindex might be nil on some calls but is okay because it's only used by players 12+
	-- obj = the physical obj
	-- index = index
	-- runner index = the carrier with the ball

    if obj.targettimer ~= nil then obj.targettimer = obj.targettimer - dt end

    if obj.targettimer == nil or obj.targettimer <= 0 then
        -- set new target
        obj.targettimer = 0     -- only change targets every x seconds

		if index <= 11 then
			-- process offense team
			if playcall_offense == enum.playcallRun then
				setInPlayTargetRun(obj, index)		-- sets target for a single index
			elseif playcall_offense == enum.playcallThrow then
				setInPlayWapointsThrow(obj, index)
			else
				--! add more plays here
			end
		else
			-- process defense team
			if playcall_defense == enum.playcallManOnMan then
				setInPlayTargetManOnMan(obj, runnerindex)
			else
				--! add more plays here
			end
		end
    end
end

local function setAllWaypoints(dt)
    -- ensure every player has a destination to go to
	-- is called as required - usually after a change in state

    local runnerindex = nil     -- this is determined when the first 11 players are iterated over and then used by the next 11 players
    for i = 1, NumberOfPlayers do
        if PHYS_PLAYERS[i].hasBall then runnerindex = i end

        if GAME_STATE == enum.gamestateForming then
            if PHYS_PLAYERS[i].targetx == nil then
				setFormingWaypoints(PHYS_PLAYERS[i], i)       --! ensure to clear target when game mode shifts
            end
        elseif GAME_STATE == enum.gamestateInPlay then
			setInPlayWaypoints(PHYS_PLAYERS[i], i, runnerindex, dt)		-- a generic sub that calls many other subs
        end
    end
	print("Target for player #12 is " .. PHYS_PLAYERS[12].waypointx[1])
end

local function setInPlayReceiverRunning()
	-- called when a receiver has caught the ball and their is a crazy dash for the TD

	local ballcarrierx, ballcarriery = getCarrierXY()

	for i = 1, NumberOfPlayers do
		PHYS_PLAYERS[i].waypointx = {}
		PHYS_PLAYERS[i].waypointy = {}

		if ballcarrierx ~= nil then			-- this will be nil if the ball is airborne

			if i <= 11 then
				if PHYS_PLAYERS[i].hasBall then
					-- this is the runner - run for TD
					PHYS_PLAYERS[i].waypointx[1] = PHYS_PLAYERS[i].body:getX()
					PHYS_PLAYERS[i].waypointy[1] = TopPostY
				else
					-- not the runner - move to protect the runner
					PHYS_PLAYERS[i].waypointx[1] = ballcarrierx
					PHYS_PLAYERS[i].waypointy[1] = ballcarriery - 10
				end
			else
				-- get defense to intercept the runner
				PHYS_PLAYERS[i].waypointx[1] = ballcarrierx
				PHYS_PLAYERS[i].waypointy[1] = ballcarriery - 5
			end
		end
	end
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

    -- need to reset all sorts of player status here
    for i = 1, NumberOfPlayers do
        PHYS_PLAYERS[i].body:destroy()
    end
    GAME_STATE = nil
    downNumber = 1
    ScrimmageY = BottomGoalY - 25
    FirstDownMarkerY = ScrimmageY - 10

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
	if GAME_STATE == enum.gamestateInPlay then
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
	local intendedxforce = obj.body:getMass() * acelxvector
	local intendedyforce = obj.body:getMass() * acelyvector

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

	-- if fallen down then no force
	--! probably want to fill out the ELSE statements here
	if obj.fallen == true then
		if GAME_STATE == enum.gamestateForming then
			obj.fallen = false
		end
	end

	--! something about safeties moving at half speed

	-- now apply dtime to intended force and then apply a game speed factor that works
	intendedxforce = intendedxforce * fltForceAdjustment * dt
	intendedyforce = intendedyforce * fltForceAdjustment * dt
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
	--! check to see if all these variables are used/called
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

			if i == 12 then
				print("Targetx for player #12 is " .. targetx)
			end

			-- see if player has waypoints
			if targetx == nil or targety == nil then
				-- out of waypoints

				-- if index = QB and QB has the ball and play = throw and ball has no waypoints then ...
				if i == 1 and ballcarrier == 1 and playcall_offense == enum.playcallThrow then	-- QB has run out of waypoints
					if football.waypointx[1] == nil then
						-- try to throw ball

						-- pick a random player on same side that is not fallen down
						local balltarget = nil
						repeat
							local rndnum = love.math.random(2, 6)	-- these are the only valid receivers
							if PHYS_PLAYERS[rndnum].fallen then
								rndnum = nil
							else
								balltarget = rndnum
							end
						until balltarget ~= nil		--! need to ensure this isn't and endless loop
						football.waypointx[1] = PHYS_PLAYERS[balltarget].body:getX()
						football.waypointy[1] = PHYS_PLAYERS[balltarget].body:getY()
						PHYS_PLAYERS[1].hasBall = false

						-- print("QB is at ".. PHYS_PLAYERS[1].body:getX() .. ", " .. PHYS_PLAYERS[1].body:getY())
						-- print("Target is player #" .. balltarget)
						-- print("Target is at ".. PHYS_PLAYERS[balltarget].body:getX() .. ", " .. PHYS_PLAYERS[balltarget].body:getY())
					end
				end

				if PHYS_PLAYERS[i].gamestate == enum.gamestateForming then
					PHYS_PLAYERS[i].gamestate = enum.gamestateReadyForSnap
					-- print("Setting player " .. i .. " to ready for snap. TargetX = " .. tostring(targetx))
				end

				if GAME_STATE == enum.gamestateInPlay and not PHYS_PLAYERS[1].hasBall then
					-- set waypoints to the ball carrier
					setInPlayReceiverRunning()
				end
			else
	            if not PHYS_PLAYERS[i].fallen then

	                -- get distance to target
	                local disttotarget = cf.getDistance(objx, objy, targetx, targety)		-- actually waypoints

	                -- see if arrived
	                if disttotarget <=  0.1 then
	                    -- arrived

	                    if PHYS_PLAYERS[i].gamestate == enum.gamestateForming then
	                        PHYS_PLAYERS[i].gamestate = enum.gamestateReadyForSnap
						elseif PHYS_PLAYERS[i].gamestate == enum.gamestateInPlay then
							-- in play and reached waypoint. Remove this waypoint.
							table.remove(PHYS_PLAYERS[i].waypointx, 1)
							table.remove(PHYS_PLAYERS[i].waypointy, 1)
	                    end
	                    --! put other game states here
	                else
	                    -- player not arrived
						vectorMovePlayer(PHYS_PLAYERS[i], dt)
	                end
	            else
	            end
			end
        end

		if GAME_STATE == enum.gamestateInPlay then
			-- set the ball x/y
			-- ballcarrier is set in the loop above
			if football.waypointx[1] == nil then
				-- no waypoints set for football. That means it is being held
				football.x = PHYS_PLAYERS[ballcarrier].body:getX()
				football.y = PHYS_PLAYERS[ballcarrier].body:getY()
			end
		end
    end
end

local function moveFootball(dt)
	local throwspeed = 20		-- 20 metres / second  (adjusted by dt)		--! speed should be adjusted by player ability

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
			-- whole distance is travelled during this time step
			football.x = football.waypointx[1]
			football.y = football.waypointy[1]

			-- clear the waypoint for the ball
			football.waypointx = {}
			football.waypointy = {}

			--! check if ball is out of bounds

			-- set the new carrier
			-- find closest player
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
			PHYS_PLAYERS[closestplayer].hasBall = true	--! factor in player too far away and fumble ball

			if closestplayer > 11 then
				-- turn over
				endTheDown()
			else
				-- offense caught the ball
				-- reset all waypoints for everyone
				setInPlayReceiverRunning()		-- resets all waypoints for all players
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

        assert(OFF_RED ~= nil, strQuery)
        assert(DEF_RED ~= nil, strQuery)

        createPhysicsPlayers(OFFENSIVE_TEAMID, DEFENSIVE_TEAMID)      --! need to destroy these things when leaving the scene
        GAME_STATE = enum.gamestateForming
		setAllWaypoints(dt)
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

    --! draw stadium seats

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
        if i <= (NumberOfPlayers / 2) then
            -- offense
            love.graphics.setColor(OFF_RED/255, OFF_GREEN/255, OFF_BLUE/255, 1)
        else
            -- defense
            love.graphics.setColor(DEF_RED/255, DEF_GREEN/255, DEF_BLUE/255, 1)
        end
        love.graphics.circle("fill", objx, objy, objradius)

		-- draw ball
		if GAME_STATE == enum.gamestateInPlay then
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

    end

    -- draw the QB target
    if PHYS_PLAYERS[1].targetx ~= nil then
        local drawx = PHYS_PLAYERS[1].targetx * SCALE
        local drawy = PHYS_PLAYERS[1].targety * SCALE
        love.graphics.setColor(1,1,0,1) -- yellow
        love.graphics.circle("line", drawx, drawy, 0.75 * SCALE)
    end
end

local function drawScoreboard()
	-- draws the team scores etc. Happens when camera is detached
	-- print the two teams
	love.graphics.setColor(1,1,1,1)
	love.graphics.print(offensiveteamname, 50, 50)       -- this needs to be the team name and not the ID
	love.graphics.print("Time used: " .. cf.round(OFFENSIVE_TIME, 2), 50, 100)
	love.graphics.print("Down #: " .. downNumber, 50, 125)
	love.graphics.print("Yards to go: " .. ScrimmageY - FirstDownMarkerY, 50, 150)


	-- love.graphics.print("QB throw: " .. PHYS_PLAYERS[1].throwaccuracy, 50, 150)

	-- defense score board
	love.graphics.print(defensiveteamname, SCREEN_WIDTH - 250, 50)
	if DEFENSIVE_SCORE ~= nil then love.graphics.print(DEFENSIVE_SCORE, SCREEN_WIDTH - 250, 100) end	-- will be nil if team not played yet
	if DEFENSIVE_TIME ~= nil then love.graphics.print(cf.round(DEFENSIVE_TIME, 2), SCREEN_WIDTH - 250, 150) end
end

local function beginContact(a, b, coll)
    if GAME_STATE == enum.gamestateInPlay then
        local aindex = a:getUserData()
        local bindex = b:getUserData()

		-- print(PHYS_PLAYERS[aindex].fixture:isSensor(), PHYS_PLAYERS[bindex].fixture:isSensor())

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
	            end

	            if love.math.random(0, 100) > bbalance then
	                PHYS_PLAYERS[bindex].fallen = true
	                PHYS_PLAYERS[bindex].fixture:setSensor(true)
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

local function endTheDown()
	fun.playAudio(enum.soundWhistle, false, true)
	GAME_STATE = enum.gamestateDeadBall     --! need to do things when ball is dead
	downNumber = downNumber + 1
	deadBallTimer = 3       -- three second pause before resetting
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
				-- print("Player #" .. i .. " is not ready for snap yet.")
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
	    end
		setAllWaypoints(dt)		-- sets all waypoints for all players

		fun.playAudio(enum.soundGo, false, true)
        -- print("all sensors are now turned on")
    elseif GAME_STATE == enum.gamestateInPlay then
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
                end

                -- runner is outside the field
                local objx = PHYS_PLAYERS[i].body:getX()
                if objx < LeftLineX or objx > RightLineX then
					endTheDown()
                    ScrimmageY = PHYS_PLAYERS[i].body:getY()
                    if ScrimmageY <= FirstDownMarkerY then
                        resetFirstDown()
                    end
                end

                -- runner is across the goal
                local objy = PHYS_PLAYERS[i].body:getY()
                if objy <= TopGoalY then
                    -- touchdown!
                    GAME_STATE = enum.gamestateGameOver
                    endtheround(6)
                end

                -- turnover on downs
                if downNumber > 4 then
                    GAME_STATE = enum.gamestateGameOver
                    endtheround(0)
                end
            end

            --! ball is dropped
        end

    elseif GAME_STATE == enum.gamestateDeadBall then
        deadBallTimer = deadBallTimer - dt
        if deadBallTimer <= 0 then
            -- reset for next down
            GAME_STATE = enum.gamestateForming
            resetFallenPlayers()
			setAllWaypoints(dt)
        end
    end
end

function stadium.draw()
    -- call this from love.draw()

	cam:attach()		--! will need to put cam in the right place later on

    drawStadium()
    drawPlayers()

    buttons.drawButtons()

	cam:detach()

	drawScoreboard()
end

function stadium.update(dt)
    -- called from love.update()

    if REFRESH_DB then
        -- update happens before draw so this bit needs to be placed here to avoid a nil value error
        OFFENSIVE_TIME = 0

		playcall_offense = 3		--! make this smarter
		playcall_defense = 2

		GAME_STATE = enum.gamestateForming
    end

    if GAME_STATE == enum.gamestateInPlay then
        OFFENSIVE_TIME = OFFENSIVE_TIME + dt
    end

    if not REFRESH_DB then
        -- update gets called before draw so do NOT try to move players before they are initialised and drawn.
        moveAllPlayers(dt)
		moveFootball(dt)
        checkForStateChange(dt)
    end

    world:update(dt) --this puts the world into motion
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	cam:setZoom(ZOOMFACTOR)
	cam:setPos(TRANSLATEX,	TRANSLATEY)
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
