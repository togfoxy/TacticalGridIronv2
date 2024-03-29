waypoints = {}

local GoalHeight = 9                    -- endzone is 9m wide
local TopPostY = 5	-- how many metres to leave at the top of the screen?
local FieldHeight = 100     -- from goal to goal
local TopGoalY = TopPostY + GoalHeight
local BottomGoalY = TopGoalY + FieldHeight
local BottomPostY = BottomGoalY + GoalHeight
local FieldWidth = 49	-- how wide (yards/metres) is the field? 48.8 mtrs wide
local LeftLineX = 100
local RightLineX = LeftLineX + FieldWidth
local CentreLineX = LeftLineX + (FieldWidth / 2)

local ScrimmageY	-- a parameter that is passed in
local DownTime

local playcall_offense      -- set by stadium.lua in a super clumsy way
local playcall_defense

local function setFormingWaypoints(obj, index)
    -- receives a single object and sets it's target
	-- used when forming up before snap.
	-- check setInPlayWapointsThrow() for wp after snap

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
		table.insert(obj.waypointx, CentreLineX - 2)
		table.insert(obj.waypointy, ScrimmageY + 2)
	elseif index == 9 then		-- right guard
		table.insert(obj.waypointx, CentreLineX + 2)
		table.insert(obj.waypointy, ScrimmageY + 2)
	elseif index == 10 then		-- left tackle
		table.insert(obj.waypointx, CentreLineX - 4)
		table.insert(obj.waypointy, ScrimmageY + 3)
	elseif index == 11 then		-- right tackle
		table.insert(obj.waypointx, CentreLineX + 4)
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
	elseif index == 20 then		-- right CB
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

function waypoints.setInPlayWapointsThrow(obj, index)
    -- used by offense team when QB is throwing
    -- should only be called once when ball is put into play (snapped)
	-- clear old waypoints
	obj.waypointx = {}
	obj.waypointy = {}

	-- player 1 = QB
    if index == 1 then
		print(OFFENSIVE_TEAMID, playerTeamID)
		if OFFENSIVE_TEAMID == playerTeamID then
			-- do nothing
		else
			table.insert(obj.waypointx, CentreLineX)	-- centre line
			table.insert(obj.waypointy, ScrimmageY + 11)
		end
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
		table.insert(obj.waypointx, CentreLineX - 2)
		table.insert(obj.waypointy, ScrimmageY - 3)
	elseif index == 9 then		-- right guard
		table.insert(obj.waypointx, CentreLineX + 2)
		table.insert(obj.waypointy, ScrimmageY - 3)
	elseif index == 10 then		-- left tackle
		table.insert(obj.waypointx, CentreLineX - 4)
		table.insert(obj.waypointy, ScrimmageY - 2)
	elseif index == 11 then		-- right tackle
		table.insert(obj.waypointx, CentreLineX + 4)
		table.insert(obj.waypointy, ScrimmageY - 2)
	end
end

local function determineClosestObject(playernum, enemytype, bolCheckOwnTeam)
	-- receives the player index in question and the target type string (eg "WR") and finds the closest enemy player of that type
	-- enemytype can be an empty string ("") which will search for ANY type
	-- bolCheckOwnTeam = false means scan only the enemy
	-- will not target fallen players
	-- enemytype is not case sensitive (but best to use upper case)
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
			if string.upper(PHYS_PLAYERS[i].positionletters) == string.upper(enemytype) or enemytype == "" then
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

local function setWPtoFootballWP(obj)
	-- move to the expected football destination
	obj.waypointx = {}
	obj.waypointy = {}
	obj.waypointx[1] = football.waypointx[1]
	obj.waypointy[1] = football.waypointy[1]
end

local function setWPtoProtectRunner(obj, index, runnerindex)	-- including if unit is also runner
	if runnerindex == nil then
		print("Error: runnerindex = nil")
	else
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
				error("212: enemy not found")
			end
		end
	end
end

local function setWPtoTackleUnit(obj, index, targetunit, yoffset)
	-- set wp in front of runner so that unit intercepts runner
	-- the yoffset is how far IN FRONT of the target the wp needs to be. e.g. 10 = 10 yards in front of target (closer to the top)
	obj.waypointx = {}
	obj.waypointy = {}
	obj.waypointx[1] = PHYS_PLAYERS[targetunit].body:getX()

	obj.waypointy[1] = PHYS_PLAYERS[targetunit].body:getY() - yoffset
end

local function setQBWaypoints(obj, index, runnerindex)
	if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball

		print("Down time: " .. DownTime)

		if DownTime >= 3 and PHYS_PLAYERS[1].hasBall then		--! can make this smarter
			-- throw ball to target
			local WRindex, _ = determineClosestObject(index, "WR", true)
			if WRindex > 0 then
				--- throw ball to WR
				football.waypointx[1] = PHYS_PLAYERS[WRindex].body:getX()		--! add a random element based on throw skill of QB
				football.waypointy[1] = PHYS_PLAYERS[WRindex].body:getY()

				PHYS_PLAYERS[1].waypointx[1] = nil
				PHYS_PLAYERS[1].waypointy[1] = nil
				PHYS_PLAYERS[1].hasBall = false

				GAME_STATE = enum.gamestateAirborne
			else
				-- look for TE
				local TEindex, _ = determineClosestObject(index, "TE", true)
				if TEindex > 0 then
					--- throw ball to WR
					football.waypointx[1] = PHYS_PLAYERS[TEindex].body:getX()		--! add a random element based on throw skill of QB
					football.waypointy[1] = PHYS_PLAYERS[TEindex].body:getY()

					PHYS_PLAYERS[1].waypointx[1] = nil
					PHYS_PLAYERS[1].waypointy[1] = nil
					PHYS_PLAYERS[1].hasBall = false

					GAME_STATE = enum.gamestateAirborne
				else
					--! no targets. Do something smart like run the ball or pass to RB
				end
			end
		else
			if DownTime < 3 and PHYS_PLAYERS[1].hasBall then
				-- do nothing
			else
				print(PHYS_PLAYERS[1].hasBall)
				error("IDK", 286)
			end
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		setWPtoFootballWP(obj)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoProtectRunner(obj, index, runnerindex)	-- runs to goal if runner or moves to protect runner
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setWRWaypoints(obj, index, runnerindex)
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
		setWPtoFootballWP(obj)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoProtectRunner(obj, index, runnerindex)	-- runs to goal if runner or moves to protect runner
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setRBWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      		-- QB still has the ball
		if obj.waypointx[1] == nil then
			-- set wp to the  enemy closest to QB
            local enemyindex, _ = determineClosestObject(1, "", false)		-- 1 = QB
			if enemyindex > 1 then
				local enemyx1 = PHYS_PLAYERS[enemyindex].body:getX()
				local enemyy1 = PHYS_PLAYERS[enemyindex].body:getY()
				obj.waypointx = {}
				obj.waypointy = {}
				obj.waypointx[1] = enemyx1
				obj.waypointy[1] = enemyy1
			else
				-- no enemy left?!?!  Probably do nothing
			end
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		-- move to the expected football destination
		setWPtoFootballWP(obj, index, runnerindex)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoProtectRunner(obj, index, runnerindex)	-- runs to goal if runner or moves to protect runner
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setTEWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
		if obj.waypointx[1] == nil then
			-- move to the centre of the field and in front of scrimmage
			obj.waypointx = {}
			obj.waypointy = {}
			obj.waypointx[1] = CentreLineX
			obj.waypointy[1] = ScrimmageY
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		setWPtoFootballWP(obj, index, runnerindex)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoProtectRunner(obj, index, runnerindex)	-- runs to goal if runner or moves to protect runner
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setOffenseRowWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
		if obj.waypointx[1] == nil then
			-- determine how many offensive linemen are active (not fallen)
			local numofactiveunits = 0
			for i = 7, 11 do
				if not PHYS_PLAYERS[i].fallen then numofactiveunits = numofactiveunits + 1 end
			end

			--! all of this next bit doesn't work so well
			-- formula for X placement: x coord = zone offset * (i-1) + zonesize
			-- this means space the players 'zonesize' apart, but then place them in the middle of that zone (offset)
			local zoneSize = 20						-- total 'frontage' that neesd protecting (metres)
			zoneSize = zoneSize / numofactiveunits	-- zoneSize yards of front row shared between all active front row players (e.g. 20 / 5)
			local zoneSizeOffset = zoneSize / 2		-- this positions the player in the middle of the zone ( e.g. 4 / 2)

			-- zone is x yards wide so start half the distance from where the QB is
			local startOfFront = PHYS_PLAYERS[1].body:getX() - (zoneSize/2)		-- e.g. QB X value - (20 / 2)

			-- cycle through the five units and assign a zone/x value
			local zoneNumber = 0		-- track the next zone
			for i = 1,5 do
				local pnum						-- index, except index is already used as input parameter
				if i == 1 then pnum = 10 end	-- sadly, we can't cycle through 7 -> 11. It needs to be left side then centre then right side
				if i == 2 then pnum = 8 end
				if i == 3 then pnum = 7 end
				if i == 4 then pnum = 9 end
				if i == 5 then pnum = 11 end

				PHYS_PLAYERS[pnum].waypointx = {}
				PHYS_PLAYERS[pnum].waypointy = {}

				PHYS_PLAYERS[pnum].waypointx[1] = cf.round((startOfFront + zoneSizeOffset + (zoneSize * (zoneNumber - 1 ))))
				PHYS_PLAYERS[pnum].waypointy[1] = cf.round(PHYS_PLAYERS[1].body:getY() - (10))		-- move in front of QB and block
				zoneNumber = zoneNumber + 1
			end
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		setWPtoFootballWP(obj, index, runnerindex)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoProtectRunner(obj, index, runnerindex)	-- runs to goal if runner or moves to protect runner
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setDefenceRowWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
		-- mad rush the QB
		setWPtoTackleUnit(obj, index, 1, 0)		-- use '1' for QB instead of runnerindex (which might be nil)
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		setWPtoFootballWP(obj, index, runnerindex)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoTackleUnit(obj, index, runnerindex, 10)
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setILBWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
		local RBindex, _ = determineClosestObject(index, "RB", false)
		if RBindex > 0 then
			-- target the RB
			setWPtoTackleUnit(obj, index, RBindex, 10)
		else
			-- RB not found. Target QB
			setWPtoTackleUnit(obj, index, 1, 0)
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		setWPtoFootballWP(obj, index, runnerindex)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoTackleUnit(obj, index, runnerindex, 10)
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setOLBWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
		if index == 17 then		-- left most OLB1
			-- target closest WR
			local WRindex, WRdist = determineClosestObject(index, "WR", false)
			if WRindex > 0 then
				setWPtoTackleUnit(obj, index, WRindex, 5)
			else
				-- no WR found. Target closest enemy)
				local targetindex = determineClosestObject(index, "", false)
				if targetindex > 0 then
					setWPtoTackleUnit(obj, index, targetindex, 5)
				else
					-- no enmy found. do nothing
				end
			end
		else	-- right most OLB2
			-- target the TE
			local TEindex, _ = determineClosestObject(index, "TE", false)
			if TEindex > 0 then
				setWPtoTackleUnit(obj, index, TEindex, 5)
			else
				-- no TE found. Target closest WR)
				local WRindex, WRdist = determineClosestObject(index, "WR", false)
				if WRindex > 0 then
					setWPtoTackleUnit(obj, index, WRindex, 5)
				else
					local targetindex = determineClosestObject(index, "", false)
					if targetindex > 0 then
						setWPtoTackleUnit(obj, index, targetindex, 5)
					else
						-- no enmy found. do nothing
					end
				end
			end
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		setWPtoFootballWP(obj, index, runnerindex)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoTackleUnit(obj, index, runnerindex, 10)
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setCBWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
		-- note: this happens every dt and not just when the wp is exhausted
		-- get closest WR/TE
		local WRindex, WRdist = determineClosestObject(index, "WR", false)
		local TEindex, TEdist = determineClosestObject(index, "TE", false)

		local targetindex		-- this isn't actually target. It's a friendly. I used a confusing name
		if WRindex > 0 or TEindex > 0 then
			if WRdist < TEdist then				-- dist = 1000 if unit not found
				targetindex = WRindex
			else
				targetindex = TEindex
			end

			obj.waypointx = {}
			obj.waypointy = {}
			obj.waypointx[1] = PHYS_PLAYERS[targetindex].body:getX()
			obj.waypointy[1] = PHYS_PLAYERS[targetindex].body:getY()
		else
			-- can't find a TE or WR. Look for a friently SS
			local s1index, s1dist = determineClosestObject(index, "S1", true)
			local s2index, s2dist = determineClosestObject(index, "S2", true)

			if s1index > 0 or s2index > 0 then
				-- found a friendly SS. Which one is closest?
				if s1dist < s2dist then		-- s1 is closer
					targetindex = s1index
				else
					targetindex = s2index
				end

				-- set x/y
				local targety = PHYS_PLAYERS[targetindex].body:getY()
				local qbx = PHYS_PLAYERS[1].body:getX()
				local qby = PHYS_PLAYERS[1].body:getY()

				obj.waypointx = {}
				obj.waypointy = {}
				obj.waypointx[1] = qbx
				obj.waypointy[1] = qby - ((qby - targety) / 2)		-- halfway between QB and friendly SS
			else
				-- can't find a WR or a TE or an SS. Position between QB and goal
				local qbx = PHYS_PLAYERS[1].body:getX()
				local qby = PHYS_PLAYERS[1].body:getY()
				obj.waypointx = {}
				obj.waypointy = {}
				obj.waypointx[1] = CentreLineX
				obj.waypointy[1] = qby - ((qby - TopGoalY) / 2)		-- halfway between QB and goal
				print("beta:" .. qbyx, qpy, targety, obj.waypointy[1])
			end
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		setWPtoFootballWP(obj, index, runnerindex)
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoTackleUnit(obj, index, runnerindex, 10)
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setSSWaypoints(obj, index, runnerindex)      --! check that all these params are needed
    if GAME_STATE == enum.gamestateInPlay then      -- QB still has the ball
		-- target WR
		local WRindex, WRdist = determineClosestObject(index, "WR", false)
		if WRindex > 0 then
			setWPtoTackleUnit(obj, index, WRindex, 5)
		else
			-- target the TE
			local TEindex, _ = determineClosestObject(index, "TE", false)
			if TEindex > 0 then
				setWPtoTackleUnit(obj, index, TEindex, 5)
				local targetindex = determineClosestObject(index, "", false)
				if targetindex > 0 then
					setWPtoTackleUnit(obj, index, targetindex, 5)
				else
					-- no enemy found. do nothing
				end
			end
		end
    elseif GAME_STATE == enum.gamestateAirborne then    -- ball is in-flight
		-- target space between ball target and goal
		obj.waypointx[1] = football.waypointx[1]

		local y = ((football.waypointy[1] - TopGoalY) / 2) + TopGoalY
		obj.waypointy[1] = y
    elseif GAME_STATE == enum.gamestateRunning then     -- ball has been caught (maybe) and runner is running
		setWPtoTackleUnit(obj, index, runnerindex, 10)
    elseif GAME_STATE == enum.gamestateForming then
        --! migrate other function into here at some point

    elseif GAME_STATE == enum.gamestateDeadBall then
        --! not sure if this is needed
    end
end

local function setWaypoints(obj, index, runnerindex)
    -- determine the target for the single obj
    -- runnerindex might be nil on some calls but is okay because it's only used by players 12+
	-- obj = the physical obj
	-- index = player index (1 -> 22)
	-- runner index = the carrier with the ball

    if index == 1 then
		setQBWaypoints(obj, index, runnerindex)
    elseif index == 2 or index == 3 or index == 4 then		-- WR
        setWRWaypoints(obj, index, runnerindex)
    elseif index == 5 then	-- RB
		setRBWaypoints(obj, index, runnerindex)
    elseif index == 6 then	-- TE
		setTEWaypoints(obj, index, runnerindex)
    elseif index == 7 then	-- Centre
		setOffenseRowWaypoints(obj, index, runnerindex)
    elseif index == 8 then
		setOffenseRowWaypoints(obj, index, runnerindex)
    elseif index == 9 then
		setOffenseRowWaypoints(obj, index, runnerindex)
	elseif index == 10 then
		setOffenseRowWaypoints(obj, index, runnerindex)
    elseif index == 11 then
		setOffenseRowWaypoints(obj, index, runnerindex)
    elseif index == 12 then
		setDefenceRowWaypoints(obj, index, runnerindex)
    elseif index == 13 then
		setDefenceRowWaypoints(obj, index, runnerindex)
    elseif index == 14 then
		setDefenceRowWaypoints(obj, index, runnerindex)
    elseif index == 15 then
		setDefenceRowWaypoints(obj, index, runnerindex)
    elseif index == 16 then
		setILBWaypoints(obj, index, runnerindex)
    elseif index == 17 then
		setOLBWaypoints(obj, index, runnerindex)
    elseif index == 18 then
		setOLBWaypoints(obj, index, runnerindex)
    elseif index == 19 then
		setCBWaypoints(obj, index, runnerindex)
    elseif index == 20 then
		setCBWaypoints(obj, index, runnerindex)
    elseif index == 21 then
		setSSWaypoints(obj, index, runnerindex)
    elseif index == 22 then
		setSSWaypoints(obj, index, runnerindex)
    end
end

function waypoints.setAllWaypoints(numofplayers, ptid, pc_offense, pc_defense, scrimmage, downt, dt)
    -- ensure every player has a destination to go to
	-- is called as required - usually after a change in state

    -- GAME_STATE, OFFENSIVE_TEAMID and PHYS_PLAYERS are globals

    NumberOfPlayers = numofplayers
	playerTeamID = ptid
    playcall_offense = pc_offense
    playcall_offense = pc_defense
	ScrimmageY = scrimmage
	DownTime = downt

	if ScrimmageY < 50 then error() end

    local runnerindex = nil     -- this is determined when the first 11 players are iterated over and then used by the next 11 players
	for i = 1, NumberOfPlayers do
		if PHYS_PLAYERS[i].hasBall then runnerindex = i end
	end

    for i = 1, NumberOfPlayers do
		if not PHYS_PLAYERS[i].fallen then
	        if GAME_STATE == enum.gamestateForming and PHYS_PLAYERS[i].targetx == nil then
				setFormingWaypoints(PHYS_PLAYERS[i], i)
	        elseif GAME_STATE == enum.gamestateInPlay then		-- QB still has the ball
				setWaypoints(PHYS_PLAYERS[i], i, runnerindex)		-- a generic sub that calls many other subs
			elseif GAME_STATE == enum.gamestateAirborne then
				setWaypoints(PHYS_PLAYERS[i], i, runnerindex)		-- a generic sub that calls many other subs
	        elseif GAME_STATE == enum.gamestateRunning then
	            setWaypoints(PHYS_PLAYERS[i], i, runnerindex)		-- a generic sub that calls many other subs
	        end

			-- cycle through every non-fallen unit and ensure wp is inside the field
			for j = 1, NumberOfPlayers do
				if PHYS_PLAYERS[j].waypointx[1] ~= nil then
					if PHYS_PLAYERS[j].waypointx[1] < LeftLineX then PHYS_PLAYERS[j].waypointx[1] = LeftLineX + 2 end
					if PHYS_PLAYERS[j].waypointx[1] > RightLineX then PHYS_PLAYERS[j].waypointx[1] = RightLineX - 2 end
					if PHYS_PLAYERS[j].waypointy[1] < TopPostY then PHYS_PLAYERS[j].waypointy[1] = TopPostY + 2 end
					if PHYS_PLAYERS[j].waypointy[1] > BottomPostY then PHYS_PLAYERS[j].waypointy[1] = BottomPostY - 2 end
				end
			end
		else
			-- unit fallen so do nothing
			PHYS_PLAYERS[i].waypointx = {}
			PHYS_PLAYERS[i].waypointy = {}
		end
    end
end

return waypoints
