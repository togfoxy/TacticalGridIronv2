waypoints = {}

local GoalHeight = 9                    -- endzone is 9m wide
local TopPostY = 5	-- how many metres to leave at the top of the screen?
local FieldHeight = 100     -- from goal to goal
local TopGoalY = TopPostY + GoalHeight
local BottomGoalY = TopGoalY + FieldHeight
local FieldWidth = 49	-- how wide (yards/metres) is the field? 48.8 mtrs wide
local LeftLineX = 100
local RightLineX = LeftLineX + FieldWidth
local CentreLineX = LeftLineX + (FieldWidth / 2)
local ScrimmageY = BottomGoalY - 25

local playcall_offense      -- set by stadium.lua in a super clumsy way
local playcall_defense

local NumberOfPlayers

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

local function setWRWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed

    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
        if obj.waypointx[1] == nil then
            -- waypoints exhausted. Decide what to do next
            local objx = obj.body:getX()
            local objy = obj.body:getY()
            if objy < ScrimmageY - 25 then  -- WR is too close to goal
                obj.waypointx[1] = objx
                obj.waypointy[1] = ScrimmageY - 25
            elseif objy > ScrimmageY - 5 then   -- WR is too close to QB
                obj.waypointx[1] = objx
                obj.waypointy[1] = ScrimmageY - 5
            else
                -- determine closest enemy and move away from it
                local enemyindex, enemydistance = determineClosestObject(index, "", false)
				print("Dist to enemy is: " .. enemydistance)
                if enemyindex > 1 and enemydistance < 7 then
                    local enemyx1 = PHYS_PLAYERS[enemyindex].body:getX()
                    local enemyy1 = PHYS_PLAYERS[enemyindex].body:getY()

					local Scale1 = cf.getInverseSqrtDistance(objx, objy, enemyx1, enemyy1)

					-- Normalise the scales
					local TotalScale = Scale1
					Scale1 = Scale1/TotalScale

					-- apply avoidance vector for closest player
					-- scale the vector before applying it
					local X1scaled,Y1scaled = cf.scaleVector(enemyx1, enemyy1, Scale1)

					-- apply this avoidance vector to the current target
					local finalvectorX,finalvectorY = cf.subtractVectors(objx, objy, X1scaled, Y1scaled)

					-- set target to that vector
					obj.waypointx[1] = objx + finalvectorX
					obj.waypointy[1] = objy + finalvectorY

					-- debugging
					if index == 3 then
						print("WR xy is: " .. cf.round(objx), cf.round(objy))
						print("Enemy xy is: " .. cf.round(enemyx1), cf.round(enemyy1))
						print("WR new vector is: " .. finalvectorX, finalvectorY)
						print("Units new wp is: " .. obj.waypointx[1], obj.waypointy[1])
						print("*********")
					end

                else
					-- no enemy found or no enemy close. Do nothing.

                end
            end
        else
            -- continue to execute waypoints (i.e. do nothing)
        end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
        obj.waypointx = {}
        obj.waypointy = {}
        obj.waypointx[1] = football.waypointx[1]
        obj.waypointy[1] = football.waypointy[1]
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
        if runnerindex == index then
            -- this object has the ball - run for goal!!
            obj.waypointx = {}
            obj.waypointy = {}
            obj.waypointx[1] = obj.body:getX()
            obj.waypointy[1] = TopPostY
        else
            -- target the enemy closest to the runner
            assert(runnerindex > 0)
            local enemyindex, _ = determineClosestObject(runnerindex, "", false)
            if enemyindex > 1 then  -- check if enemy found
                obj.waypointx = {}
                obj.waypointy = {}
                obj.waypointx[1] = PHYS_PLAYERS[enemyindex].body:getX()
                obj.waypointy[1] = PHYS_PLAYERS[enemyindex].body:getY()
            else
                error("237: enemy not found")
            end
        end
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setRBWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setTEWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setOffenseRowWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setDefenceRowWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setILBWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setOLBWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setCBWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setSSWaypoints(obj, index, runnerindex, dt)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight


    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running

    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setWaypoints(obj, index, runnerindex, dt)
    -- determine the target for the single obj
    -- runnerindex might be nil on some calls but is okay because it's only used by players 12+
	-- obj = the physical obj
	-- index = player index (1 -> 22)
	-- runner index = the carrier with the ball

    if index == 1 then

    elseif index == 2 or index == 3 or index == 4 then
        setWRWaypoints(obj, index, runnerindex, dt)
    elseif index == 5 then

    elseif index == 6 then

    elseif index == 7 then

    elseif index == 8 then

    elseif index == 9 then

    elseif index == 10 then

    elseif index == 11 then

    elseif index == 12 then

    elseif index == 13 then

    elseif index == 14 then

    elseif index == 15 then

    elseif index == 16 then

    elseif index == 17 then

    elseif index == 18 then

    elseif index == 19 then

    elseif index == 20 then

    elseif index == 21 then

    elseif index == 22 then

    end
end

function waypoints.setAllWaypoints(numofplayers, fb, pc_offense, pc_defense, dt)
    -- ensure every player has a destination to go to
	-- is called as required - usually after a change in state

    -- GAME_STATE and PHYS_PLAYERS are globals

    NumberOfPlayers = numofplayers
    playcall_offense = pc_offense
    playcall_offense = pc_defense
    football = fb

    local runnerindex = nil     -- this is determined when the first 11 players are iterated over and then used by the next 11 players
    for i = 1, NumberOfPlayers do
		if not PHYS_PLAYERS[i].fallen then

	        if PHYS_PLAYERS[i].hasBall then runnerindex = i end

	        if GAME_STATE == enum.gamestateForming and PHYS_PLAYERS[i].targetx == nil then
				setFormingWaypoints(PHYS_PLAYERS[i], i)       --! ensure to clear target when game mode shifts
	        elseif GAME_STATE == enum.gamestateInPlay then		-- QB still has the ball
				setWaypoints(PHYS_PLAYERS[i], i, runnerindex, dt)		-- a generic sub that calls many other subs
			elseif GAME_STATE == enum.gamestateAirborne then
				--! set all targets to the ball destination
				--! there is already a sub. see if it fits here
	        elseif GAME_STATE == enum.gamestateRunning then
	            --!
	        end

			--! need to cycle through every non-fallen unit and ensure wp is inside the field


		else
			-- unit fallen so do nothing
			PHYS_PLAYERS[i].waypointx = {}
			PHYS_PLAYERS[i].waypointy = {}
		end
    end
	-- print("Target for player #12 is " .. PHYS_PLAYERS[12].waypointx[1])
end

return waypoints
