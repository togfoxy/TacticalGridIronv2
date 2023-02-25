stadium = {}

local NumberOfPlayers = 22
local arr_seasonstatus, offensiveteamname, defensiveteamname, deadBallTimer
local playcall_offense = 1 --!enum.playcallRun
local playcall_defense = 2 --!enum.playcallManOnMan
local downNumber = 1

local OFF_RED, OFF_GREEN, OFF_BLUE, DEF_RED, DEF_GREEN, DEF_BLUE

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

function stadium.mousereleased(rx, ry)
    -- call from love.mousereleased()
    local clickedButtonID = buttons.getButtonID(rx, ry)
    if clickedButtonID == enum.buttonStadiumQuit then
        love.event.quit()
    end
end

local function createPhysicsPlayers()
    -- called once during drawStadium()

    local rndx, rndy

    for i = 1, NumberOfPlayers do
        rndx = love.math.random(LeftLineX, RightLineX)
        if i <= (NumberOfPlayers / 2) then      -- attacker
            rndy = love.math.random(HalfwayY, BottomGoalY)
        else
            rndy = love.math.random(TopGoalY, HalfwayY)
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
        PHYS_PLAYERS[i].targettimer = nil
        PHYS_PLAYERS[i].gamestate = enum.gamestateForming
        PHYS_PLAYERS[i].hasBall = false

        ps.setCustomStats(PHYS_PLAYERS[i], i)
		ps.getStatsFromDB(PHYS_PLAYERS[i], i)
    end
end

local function drawStadium()

    if REFRESH_DB then
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

    -- draw stadium

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

    -- print the two teams
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(offensiveteamname, 50, 50)       -- this needs to be the team name and not the ID
    love.graphics.print(defensiveteamname, SCREEN_WIDTH - 250, 50)

	-- print some key player stats
	love.graphics.print("QB throw: " .. PHYS_PLAYERS[1].throwaccuracy, 50, 100)

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

local function setFormingTarget(obj, index)
    -- receives a single object and sets it's target
    -- obj.targetx = love.math.random(LeftLineX, RightLineX)
    -- obj.targety = love.math.random(TopGoalY, BottomGoalY)

    -- player 1 = QB
    if index == 1 then
    	obj.targetx = (CentreLineX)	 -- centre line
    	obj.targety = (ScrimmageY + 8)
    end

	-- player 2 = WR (left closest to centre)
    if index == 2 then
        obj.targetx = (CentreLineX - 14)	 -- left 'wing'
        obj.targety = (ScrimmageY + 2)		-- just behind scrimmage

    end

	-- player 3 = WR (right)
    if index == 3 then
        obj.targetx = (CentreLineX + 18)	 -- left 'wing'
        obj.targety = (ScrimmageY + 2)		-- just behind scrimmage
    end

	-- player 4 = WR (left on outside)
    if index == 4 then
        obj.targetx = (CentreLineX - 18)	 -- left 'wing'
        obj.targety = (ScrimmageY + 2)		-- just behind scrimmage
    end

	-- player 5 = RB
    if index == 5 then
        obj.targetx = (CentreLineX)	 -- left 'wing'
        obj.targety = (ScrimmageY + 14)	-- just behind QB
    end

	-- player 6 = TE (right side)
    if index == 6 then
        obj.targetx = (CentreLineX + 13)	 -- left 'wing'
        obj.targety = (ScrimmageY + 3)
    end

	-- player 7 = Centre
    if index == 7 then
        obj.targetx = (CentreLineX)	 -- left 'wing'
        obj.targety = (ScrimmageY + 2)		-- just behind scrimmage
    end

	-- player 8 = left guard
    if index == 8 then
        obj.targetx = (CentreLineX - 4)	 -- left 'wing'
        obj.targety = (ScrimmageY + 2)		-- just behind scrimmage
    end

	-- player 9 = right guard
    if index == 9 then
        obj.targetx = (CentreLineX + 4)	 -- left 'wing'
        obj.targety = (ScrimmageY +2)		-- just behind scrimmage
    end

	-- player 10 = left tackle
    if index == 10 then
        obj.targetx = (CentreLineX - 7)	 -- left 'wing'
        obj.targety = (ScrimmageY + 3)		-- just behind scrimmage
    end

	-- player 11 = right tackle
    if index == 11 then
        obj.targetx = (CentreLineX + 7)	 -- left 'wing'
        obj.targety = (ScrimmageY + 3)		-- just behind scrimmage
    end

    -- now for the visitors

	-- player 12 = Left tackle (left side of screen)
    if index == 12 then
        obj.targetx = (CentreLineX -2)	 -- centre line
        obj.targety = (ScrimmageY - 2)
    end

	-- player 13 = Right tackle
    if index == 13 then
        obj.targetx = (CentreLineX +2)	 -- left 'wing'
        obj.targety = (ScrimmageY - 2)		-- just behind scrimmage
    end

	-- player 14 = Left end
    if index == 14 then
        obj.targetx = (CentreLineX - 6)	 -- left 'wing'
        obj.targety = (ScrimmageY - 2)		-- just behind scrimmage
    end

	-- player 15 = Right end
    if index == 15 then
        obj.targetx = (CentreLineX + 6)	 -- left 'wing'
        obj.targety = (ScrimmageY - 2)		-- just behind scrimmage
    end

	-- player 16 = Inside LB
    if index == 16 then
        obj.targetx = (CentreLineX)	 -- left 'wing'
        obj.targety = (ScrimmageY - 11)	-- just behind scrimmage
    end

	-- player 17 = Left Outside LB
    if index == 17 then
        obj.targetx = (CentreLineX - 15)	 -- left 'wing'
        obj.targety = (ScrimmageY - 10)
    end

	-- player 18 = Right Outside LB
    if index == 18 then
        obj.targetx = (CentreLineX +15)	 -- left 'wing'
        obj.targety = (ScrimmageY - 10)
    end

	-- player 19 = Left CB
    if index == 19 then
        obj.targetx = (CentreLineX -18)	 -- left 'wing'
        obj.targety = (ScrimmageY -18)
    end

	-- player 20 = right CB
    if index == 20 then
        obj.targetx = (CentreLineX + 18)	 -- left 'wing'
        obj.targety = (ScrimmageY -18)
    end

	-- player 21 = left safety
    if index == 21 then
        obj.targetx = (CentreLineX - 4)	 -- left 'wing'
        obj.targety = (ScrimmageY - 17)
    end

	-- player 22 = right safety
    if index == 22 then
        obj.targetx = (CentreLineX + 4)	 -- left 'wing'
        obj.targety = (ScrimmageY - 17)
    end
end

local function setInPlayTargetRun(obj, index)
	-- the targets for obj[index] players to rush the goal
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
		if enemyindex == 0 then
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

	-- default to carrier and then overwrite below
	obj.targetx = PHYS_PLAYERS[carrierindex].body:getX()
	obj.targety = PHYS_PLAYERS[carrierindex].body:getY()

	local thisindex = obj.fixture:getUserData()

	if obj.positionletters == "DT" or obj.positionletters == "LE" or obj.positionletters == "RE" then
		-- rush the carrier
		obj.targetx = PHYS_PLAYERS[carrierindex].body:getX()
		obj.targety = PHYS_PLAYERS[carrierindex].body:getY()

	elseif obj.positionletters == "CB" then
		local targetindex, targetdist = determineClosestObject(thisindex, "WR", false)
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
	elseif obj.positionletters == "S" then
		-- target TE first and then WR
		local targetindex, targetdist = determineClosestObject(thisindex, "TE", false)
		if targetindex ~= 0 then
			obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
			obj.targety = PHYS_PLAYERS[targetindex].body:getY()
		else
			-- if no TE then target WR
			local targetindex, targetdist = determineClosestObject(thisindex, "WR", false)
			if targetindex ~= 0 then
				obj.targetx = PHYS_PLAYERS[targetindex].body:getX()
				obj.targety = PHYS_PLAYERS[targetindex].body:getY()
			end
		end
	end
end

local function setInPlayTarget(obj, index, runnerindex, dt)
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
			if playcall_offense == enum.playcallRun then
				setInPlayTargetRun(obj, index)		-- sets target for a single index
			else
				--! add more plays here
			end
		else
			if playcall_defense == enum.playcallManOnMan then
				setInPlayTargetManOnMan(obj, runnerindex)
			else
				--! add more plays here
			end
		end
    end
end

local function setAllTargets(dt)
    -- ensure every player has a destination to go to

    local runnerindex = nil     -- this is determined when the first 11 players are iterated over and then used by the next 11 players
    for i = 1, NumberOfPlayers do
        if PHYS_PLAYERS[i].hasBall then runnerindex = i end

        if GAME_STATE == enum.gamestateForming then
            if PHYS_PLAYERS[i].targetx == nil then
                setFormingTarget(PHYS_PLAYERS[i], i)       --! ensure to clear target when game mode shifts
            end
        elseif GAME_STATE == enum.gamestateInPlay then
            setInPlayTarget(PHYS_PLAYERS[i], i, runnerindex, dt)
        end
    end
end

local function moveAllPlayers(dt)

    local fltForceAdjustment = 0.5	-- tweak this to get fluid motion
    local fltMaxVAdjustment = 1		-- tweak this to get fluid motion

    if GAME_STATE ~= enum.gamestateDeadBall then

        setAllTargets(dt)

        for i = 1, NumberOfPlayers do
            local objx = PHYS_PLAYERS[i].body:getX()
            local objy = PHYS_PLAYERS[i].body:getY()

            local targetx = PHYS_PLAYERS[i].targetx
            local targety = PHYS_PLAYERS[i].targety

            if not PHYS_PLAYERS[i].fallen then

                -- get distance to target
                local disttotarget = cf.getDistance(objx, objy, targetx, targety)

                -- see if arrived
                if disttotarget <=  0.1 then
                    -- arrived
                    if PHYS_PLAYERS[i].gamestate == enum.gamestateForming then
                        PHYS_PLAYERS[i].gamestate = enum.gamestateReadyForSnap
                    end
                    --! put other game states here
                else
                    -- player not arrived

                    -- determine actual velocity vs intended velocity based on target
                    local playervelx, playervely = PHYS_PLAYERS[i].body:getLinearVelocity()		-- this is the players velocity vector

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
        			local intendedxforce = PHYS_PLAYERS[i].body:getMass() * acelxvector
        			local intendedyforce = PHYS_PLAYERS[i].body:getMass() * acelyvector

                    -- if target is in front of player and at maxV then discontinue the application of force (intendedforce = 0)
        			-- can't cut aceleration because that is the braking force and we don't want to disallow that
        			if cf.dotVectors(playervelx, playervely,vectorxtotarget,vectorytotarget) > 0 then	-- > 0 means target is in front of player
        				-- if player is exceeding maxV then cancel force
        				if (playervelx > PHYS_PLAYERS[i].maxV * fltMaxVAdjustment) or (playervelx < (PHYS_PLAYERS[i].maxV * -1 * fltMaxVAdjustment)) then
        					-- don't apply any force until vel drops down
        					intendedxforce = 0
        				end
                        -- repeat for y axis vector
        				if (playervely > PHYS_PLAYERS[i].maxV) or (playervely < (PHYS_PLAYERS[i].maxV * -1)) then
        					-- don't apply any force
        					intendedyforce = 0
        				end
        			end

                    -- if i == 1 and GAME_STATE == enum.gamestateForming and intendedxforce == 0 then error() end

                    -- if player intended force is great than the limits for that player then dial that intended force back
        			if intendedxforce > PHYS_PLAYERS[i].maxF then
        				intendedxforce = PHYS_PLAYERS[i].maxF
        			end
        			if intendedyforce > PHYS_PLAYERS[i].maxF then
        				intendedyforce = PHYS_PLAYERS[i].maxF
        			end

                    -- if fallen down then no force
                    --! probably want to fill out the ELSE statements here
                    if PHYS_PLAYERS[i].fallen == true then
                        if GAME_STATE == enum.gamestateForming then
                            PHYS_PLAYERS[i].fallen = false
                        end
                    end

                    --! something about safeties moving at half speed

                    -- now apply dtime to intended force and then apply a game speed factor that works
        			intendedxforce = intendedxforce * fltForceAdjustment
        			intendedyforce = intendedyforce * fltForceAdjustment
        			-- now we can apply force
        			PHYS_PLAYERS[i].body:applyForce(intendedxforce,intendedyforce)
                end
            else
            end
        end
    end
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
    end

    -- draw the QB target
    if PHYS_PLAYERS[1].targetx ~= nil then
        local drawx = PHYS_PLAYERS[1].targetx * SCALE
        local drawy = PHYS_PLAYERS[1].targety * SCALE
        love.graphics.setColor(1,1,0,1) -- yellow
        love.graphics.circle("line", drawx, drawy, 0.75 * SCALE)
    end
end

function stadium.draw()
    -- call this from love.draw()

    drawStadium()
    drawPlayers()

    buttons.drawButtons()
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

local function resetFirstDown(y)
    -- a first down is detected
    -- y = the y value of the new line of scrimmage
    FirstDownMarkerY = ScrimmageY - 10
    if FirstDownMarkerY < TopGoalY then FirstDownMarkerY = TopGoalY end
    downNumber = 1
end

local function checkForStateChange(dt)
    -- looks for key events that will trigger a change in game state
    if GAME_STATE == enum.gamestateForming then
        -- check if everyone is formed up
        for i = 1, NumberOfPlayers do
            if PHYS_PLAYERS[i].gamestate ~= enum.gamestateReadyForSnap then
                -- no state change. Abort.
                return
            end
        end
        -- if above loop didn't abort then all players are ready for snap. Change state
        GAME_STATE = enum.gamestateInPlay
        PHYS_PLAYERS[1].hasBall = true
        for i = 1, NumberOfPlayers do
            PHYS_PLAYERS[i].fixture:setSensor(false)
            PHYS_PLAYERS[i].gamestate = enum.gamestateInPlay
        end
        print("all sensors are now turned on")
    elseif GAME_STATE == enum.gamestateInPlay then
        -- check for a number of conditions

        for i = 1, NumberOfPlayers / 2 do
            if PHYS_PLAYERS[i].hasBall then
                if PHYS_PLAYERS[i].fallen then
                    -- the runner is down/fallen
                    GAME_STATE = enum.gamestateDeadBall     --! need to do things when ball is dead
                    downNumber = downNumber + 1
                    deadBallTimer = 3       -- three second pause before resetting
                    ScrimmageY = PHYS_PLAYERS[i].body:getY()
                    if ScrimmageY <= FirstDownMarkerY then
                        resetFirstDown(ScrimmageY)
                    end
                end

                -- runner is outside the field
                local objx = PHYS_PLAYERS[i].body:getX()
                if objx < LeftLineX or objx > RightLineX then
                    GAME_STATE = enum.gamestateDeadBall     --! need to do things when ball is dead
                    downNumber = downNumber + 1
                    deadBallTimer = 3       -- three second pause before resetting
                    ScrimmageY = PHYS_PLAYERS[i].body:getY()
                    if ScrimmageY <= FirstDownMarkerY then
                        resetFirstDown(ScrimmageY)
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
        end
    end
end

function stadium.update(dt)
    -- called from love.update()

    if REFRESH_DB then
        -- update happens before draw so this bit needs to be placed here to avoid a nil value error
        OFFENSIVE_TIME = 0
    end

    --! fake the ending of the scene
    if GAME_STATE == enum.gamestateInPlay then
        OFFENSIVE_TIME = OFFENSIVE_TIME + dt
    end

    if not REFRESH_DB then
        -- update gets called before draw so do NOT try to move players before they are initialised and drawn.
        moveAllPlayers(dt)
        checkForStateChange(dt)
    end

    world:update(dt) --this puts the world into motion
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
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
