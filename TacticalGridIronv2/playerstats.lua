playerstats = {}

function playerstats.setCustomStats(obj, index)
    -- sets up the stats for this single object.
    -- index is the number within the array (1 -> 22) and is used to know what position the object is in

    obj.balance = love.math.random(94,96)       -- default value that is overridden below
    obj.balance = 50

    if index == 1 then
        obj.positionletters = "QB"
        obj.body:setMass(love.math.random(91,110))	-- kilograms
        obj.maxpossibleV = 14.8					-- max velocity possible for this position
        obj.maxV = love.math.random(133,148)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1495							-- maximum force (how much force to apply to make them move)
        obj.throwaccuracy = love.math.random(90,100)	-- this distance ball lands from intended target
    elseif index == 2 or index == 3 or index == 4 then
        obj.positionletters = "WR"
        obj.body:setMass(love.math.random(80,100))	-- kilograms
        obj.maxpossibleV = 16.3					-- max velocity possible for this position
        obj.maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1467							-- maximum force (how much force to apply to make them move)
        obj.catchskill = love.math.random(80,90)			-- % chance of catching ball
        -- if catchskill is changed here then need to update coloured boxes
    elseif index == 5 then
        obj.positionletters = "RB"
        obj.body:setMass(love.math.random(86,106))	-- kilograms
        obj.maxpossibleV = 16.3					-- max velocity possible for this position
        obj.maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1565							-- maximum force (how much force to apply to make them move)
        obj.balance = love.math.random(95,97)		-- this is a percentage eg 95% chance of NOT falling down
        obj.catchskill = love.math.random(85,95)	-- RB's get handoffs and not catches so make this high
    elseif index == 6 then
        obj.positionletters = "TE"
        obj.body:setMass(love.math.random(104,124))	-- kilograms
        obj.maxpossibleV = 15.4					-- max velocity possible for this position
        obj.maxV = love.math.random(149,154)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1756							-- maximum force (how much force to apply to make them move)
    elseif index == 7 then
        obj.positionletters = "C"
        obj.body:setMass(love.math.random(131,151))	-- kilograms
        obj.maxpossibleV = 13.8					-- max velocity possible for this position
        obj.maxV = love.math.random(123,138)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1946							-- maximum force (how much force to apply to make them move)
    elseif index == 8 then
        obj.positionletters = "LG"					-- left guard offense
        obj.body:setMass(love.math.random(131,151))	-- kilograms
        obj.maxpossibleV = 13.6					-- max velocity possible for this position
        obj.maxV = love.math.random(121,136)/10	-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1918							-- maximum force (how much force to apply to make them move)
    elseif index == 9 then
        obj.positionletters = "RG"					-- right guard offense
        obj.body:setMass(love.math.random(131,151))	-- kilograms
        obj.maxpossibleV = 13.6					-- max velocity possible for this position
        obj.maxV = love.math.random(121,136)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1918							-- maximum force (how much force to apply to make them move)
    elseif index == 10 then
        obj.positionletters = "LT"					-- left tackle offense
        obj.body:setMass(love.math.random(131,151))	-- kilograms
        obj.maxpossibleV = 13.7					-- max velocity possible for this position
        obj.maxV = love.math.random(122,137)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1932							-- maximum force (how much force to apply to make them move)
    elseif index == 11 then
        obj.positionletters = "RT"					-- left tackle offense
        obj.body:setMass(love.math.random(131,151))	-- kilograms
        obj.maxpossibleV = 13.7					-- max velocity possible for this position
        obj.maxV = love.math.random(122,137)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1932							-- maximum force (how much force to apply to make them move)

    -- opposing team

    elseif index == 12 or index == 13 then
        obj.positionletters = "DT"
        obj.body:setMass(love.math.random(129,149))	-- kilograms
        obj.maxpossibleV = 14.5					-- max velocity possible for this position
        obj.maxV = love.math.random(130,145)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 2016							-- maximum force (how much force to apply to make them move)
    elseif index == 14 then
        obj.positionletters = "LE"
        obj.body:setMass(love.math.random(116,136))	-- kilograms
        obj.maxpossibleV = 15.2					-- max velocity possible for this position
        obj.maxV = love.math.random(137,152)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1915							-- maximum force (how much force to apply to make them move)
    elseif index == 15 then
        obj.positionletters = "RE"
        obj.body:setMass(love.math.random(116,136))	-- kilograms
        obj.maxpossibleV = 15.2					-- max velocity possible for this position
        obj.maxV = love.math.random(137,152)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1915							-- maximum force (how much force to apply to make them move)
    elseif index == 16 then
        obj.positionletters = "ILB"
        obj.body:setMass(love.math.random(100,120))	-- kilograms
        obj.maxpossibleV = 15.6					-- max velocity possible for this position
        obj.maxV = love.math.random(141,156)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1716							-- maximum force (how much force to apply to make them move)
    elseif index == 17 or index == 18 then
        obj.positionletters = "OLB"
        obj.body:setMass(love.math.random(100,120))	-- kilograms
        obj.maxpossibleV = 15.7					-- max velocity possible for this position
        obj.maxV = love.math.random(142,157)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1727							-- maximum force (how much force to apply to make them move)
    elseif index == 19 or index == 20 then
        obj.positionletters = "CB"
        obj.body:setMass(love.math.random(80,100))	-- kilograms
        obj.maxpossibleV = 16.3					-- max velocity possible for this position
        obj.maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1467							-- maximum force (how much force to apply to make them move)
    elseif index == 21 then
        obj.positionletters = "S"
        obj.body:setMass(love.math.random(80,100))	-- kilograms
        obj.maxpossibleV = 16.1					-- max velocity possible for this position
        obj.maxV = love.math.random(146,161)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1449
    elseif index == 22 then
        obj.positionletters = "S"
        obj.body:setMass(love.math.random(80,100))	-- kilograms
        obj.maxpossibleV = 16.1					-- max velocity possible for this position
        obj.maxV = love.math.random(146,161)/10		-- max velocity possible for this player (this persons limitations)
        obj.maxF = 1449
    end
end

return playerstats
