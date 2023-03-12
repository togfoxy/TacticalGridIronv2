functions = {}

function functions.loadAudio()

    AUDIO[enum.soundGo] = love.audio.newSource("assets/audio/go.wav", "static")
    AUDIO[enum.soundWhistle] = love.audio.newSource("assets/audio/whistle.wav", "static")

end

function functions.loadImages()
    IMAGE[enum.imageFootball] = love.graphics.newImage("assets/images/football.png")


end

function functions.playAudio(audionumber, isMusic, isSound)
    if isMusic and MUSIC_TOGGLE then
        AUDIO[audionumber]:play()
    end
    if isSound and SOUND_TOGGLE then
        AUDIO[audionumber]:play()
    end
    -- print("playing music/sound #" .. audionumber)
end

local function deleteAllTables()

    local fbdb = sqlite3.open(DB_FILE)

    if fbdb then
        local strQuery, intError
        strQuery = "delete from TEAMS"
        intError = fbdb:exec(strQuery)

        if intError ~= 0 then
            error("DB error: " .. intError)
        end

        strQuery = "delete from SEASON"
        intError = fbdb:exec(strQuery)

        strQuery = "delete from PLAYERS"
        intError = fbdb:exec(strQuery)

        strQuery = "delete from LEAGUE"
        intError = fbdb:exec(strQuery)

        strQuery = "delete from GLOBALS"
        intError = fbdb:exec(strQuery)
    end
    fbdb:close()

    print("DB reset")
end

function resetGlobalTeamNames()
    -- this is called during each "new game"
    TEAM_NAMES = {}
    TEAM_NAMES[1] = "Badgers"
    TEAM_NAMES[2] = "Buccaneers"
    TEAM_NAMES[3] = "Geckos"
    TEAM_NAMES[4] = "Commandos"
    TEAM_NAMES[5] = "Sonics"
    TEAM_NAMES[6] = "Tanks"
    TEAM_NAMES[7] = "Ninjas"
    TEAM_NAMES[8] = "Wasps"
end

local function populateTeamsTable()
    -- resets the global constants and then draws from that to populate the TEAMS table

    local fbdb = sqlite3.open(DB_FILE)
    local index = 0
    resetGlobalTeamNames()
    repeat
        local red = love.math.random(0, 255)
        local green = love.math.random(0, 100)      -- green is intentionally reduced so no conflict with grass
        local blue = love.math.random(0, 255)

        rndteamnum = love.math.random(1, #TEAM_NAMES)
        -- write to table
        local strQuery = "INSERT INTO TEAMS ('TEAMNAME', 'PLAYERCONTROLLED', 'RED', 'GREEN', 'BLUE') VALUES ('" .. TEAM_NAMES[rndteamnum] .. "', 0, " .. red ..", " .. green ..", " .. blue .. ");"
        local dberror = fbdb:exec(strQuery)
        if dberror ~= 0 then
            print(strQuery)
            error()
        end
        -- remove from array so it is not re-used
        table.remove(TEAM_NAMES, rndteamnum)
        index = index + 1
    until index == 8
    fbdb:close()
end

local function populateGlobalsTable()
    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "Insert into GLOBALS ('CURRENTSEASON') values (1)"
    local dberror = fbdb:exec(strQuery)
    fbdb:close()
end

local function createNewPlayer(fbdb, index, teamid)
    -- given index (1 -> 11) write a new row into the players table
    -- fbdb = the database passed into this subprocedure

    local firstname = "Joe"
    local familyname = "Blow"       --!

    local positionletters, mass, maxpossibleV, maxV, maxF
    local throwaccuracy = 0
    local catchskill = 0
    local balance = love.math.random(75,85)

    if index == 1 then
        positionletters = "QB"
        mass = (love.math.random(91,110))	-- kilograms
        maxpossibleV = 14.8					-- max velocity possible for this position
        maxV = love.math.random(133,148)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1495							-- maximum force (how much force to apply to make them move)
        throwaccuracy = love.math.random(90,100)	-- this distance ball lands from intended target
    elseif index == 2 then
        positionletters = "WR1"
        mass = (love.math.random(80,100))	-- kilograms
        maxpossibleV = 16.3					-- max velocity possible for this position
        maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1467							-- maximum force (how much force to apply to make them move)
        catchskill = love.math.random(80,90)			-- % chance of catching ball
    elseif index == 3 then
        positionletters = "WR2"
        mass = (love.math.random(80,100))	-- kilograms
        maxpossibleV = 16.3					-- max velocity possible for this position
        maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1467							-- maximum force (how much force to apply to make them move)
        catchskill = love.math.random(80,90)			-- % chance of catching ball
    elseif index == 4 then
        positionletters = "WR3"
        mass = (love.math.random(80,100))	-- kilograms
        maxpossibleV = 16.3					-- max velocity possible for this position
        maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1467							-- maximum force (how much force to apply to make them move)
        catchskill = love.math.random(80,90)			-- % chance of catching ball
    elseif index == 5 then
        positionletters = "RB"
        mass = (love.math.random(86,106))	-- kilograms
        maxpossibleV = 16.3					-- max velocity possible for this position
        maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1565							-- maximum force (how much force to apply to make them move)
        local balance = love.math.random(90,95)		-- this is a percentage eg 95% chance of NOT falling down
        local catchskill = love.math.random(85,95)	-- RB's get handoffs and not catches so make this high
    elseif index == 6 then
        positionletters = "TE"
        mass = (love.math.random(104,124))	-- kilograms
        maxpossibleV = 15.4					-- max velocity possible for this position
        maxV = love.math.random(149,154)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1756							-- maximum force (how much force to apply to make them move)
    elseif index == 7 then
        positionletters = "C"
        mass = (love.math.random(131,151))	-- kilograms
        maxpossibleV = 13.8					-- max velocity possible for this position
        maxV = love.math.random(123,138)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1946							-- maximum force (how much force to apply to make them move)
    elseif index == 8 then
        positionletters = "LG"					-- left guard offense
        mass = (love.math.random(131,151))	-- kilograms
        maxpossibleV = 13.6					-- max velocity possible for this position
        maxV = love.math.random(121,136)/10	-- max velocity possible for this player (this persons limitations)
        maxF = 1918							-- maximum force (how much force to apply to make them move)
    elseif index == 9 then
        positionletters = "RG"					-- right guard offense
        mass = (love.math.random(131,151))	-- kilograms
        maxpossibleV = 13.6					-- max velocity possible for this position
        maxV = love.math.random(121,136)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1918							-- maximum force (how much force to apply to make them move)
    elseif index == 10 then
        positionletters = "LT"					-- left tackle offense
        mass = (love.math.random(131,151))	-- kilograms
        maxpossibleV = 13.7					-- max velocity possible for this position
        maxV = love.math.random(122,137)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1932							-- maximum force (how much force to apply to make them move)
    elseif index == 11 then
        positionletters = "RT"					-- left tackle offense
        mass = (love.math.random(131,151))	-- kilograms
        maxpossibleV = 13.7					-- max velocity possible for this position
        maxV = love.math.random(122,137)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1932							-- maximum force (how much force to apply to make them move)

    -- opposing team

    elseif index == 12 then
        positionletters = "DT1"
        mass = (love.math.random(129,149))	-- kilograms
        maxpossibleV = 14.5					-- max velocity possible for this position
        maxV = love.math.random(130,145)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 2016							-- maximum force (how much force to apply to make them move)
    elseif index == 13 then
        positionletters = "DT2"
        mass = (love.math.random(129,149))	-- kilograms
        maxpossibleV = 14.5					-- max velocity possible for this position
        maxV = love.math.random(130,145)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 2016							-- maximum force (how much force to apply to make them move)
    elseif index == 14 then
        positionletters = "LE"
        mass = (love.math.random(116,136))	-- kilograms
        maxpossibleV = 15.2					-- max velocity possible for this position
        maxV = love.math.random(137,152)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1915							-- maximum force (how much force to apply to make them move)
    elseif index == 15 then
        positionletters = "RE"
        mass = (love.math.random(116,136))	-- kilograms
        maxpossibleV = 15.2					-- max velocity possible for this position
        maxV = love.math.random(137,152)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1915							-- maximum force (how much force to apply to make them move)
    elseif index == 16 then
        positionletters = "ILB"
        mass = (love.math.random(100,120))	-- kilograms
        maxpossibleV = 15.6					-- max velocity possible for this position
        maxV = love.math.random(141,156)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1716							-- maximum force (how much force to apply to make them move)
    elseif index == 17 then
        positionletters = "OLB1"
        mass = (love.math.random(100,120))	-- kilograms
        maxpossibleV = 15.7					-- max velocity possible for this position
        maxV = love.math.random(142,157)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1727							-- maximum force (how much force to apply to make them move)
    elseif index == 18 then
        positionletters = "OLB2"
        mass = (love.math.random(100,120))	-- kilograms
        maxpossibleV = 15.7					-- max velocity possible for this position
        maxV = love.math.random(142,157)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1727							-- maximum force (how much force to apply to make them move)
    elseif index == 19 then
        positionletters = "CB1"
        mass = (love.math.random(80,100))	-- kilograms
        maxpossibleV = 16.3					-- max velocity possible for this position
        maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1467							-- maximum force (how much force to apply to make them move)
    elseif index == 20 then
        positionletters = "CB2"
        mass = (love.math.random(80,100))	-- kilograms
        maxpossibleV = 16.3					-- max velocity possible for this position
        maxV = love.math.random(148,163)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1467							-- maximum force (how much force to apply to make them move)
    elseif index == 21 then
        positionletters = "S1"
        mass = (love.math.random(80,100))	-- kilograms
        maxpossibleV = 16.1					-- max velocity possible for this position
        maxV = love.math.random(146,161)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1449
    elseif index == 22 then
        positionletters = "S2"
        mass = (love.math.random(80,100))	-- kilograms
        maxpossibleV = 16.1					-- max velocity possible for this position
        maxV = love.math.random(146,161)/10		-- max velocity possible for this player (this persons limitations)
        maxF = 1449
    end

    -- local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "Insert into PLAYERS ('TEAMID', 'FIRSTNAME', 'FAMILYNAME', 'POSITION', 'MASS', 'MAXPOSSIBLEV', 'MAXV', 'MAXF', 'BALANCE', 'THROWACCURACY', 'CATCHSKILL') "
    strQuery = strQuery .. "values ('" .. teamid .. "', '" .. firstname .."', '" .. familyname .. "', '" .. positionletters .. "', '" .. mass .. "', '"
    strQuery = strQuery .. maxpossibleV .. "', '" .. maxV .. "', '" .. maxF .. "', '" .. balance .. "', '" .. throwaccuracy .. "', '" .. catchskill .. "')"
    local dberror = fbdb:exec(strQuery)
    assert(dberror == 0, dberror)
end

local function populatePlayersTable()
    -- there are eight teams

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select TEAMID from TEAMS"
    for row in fbdb:nrows(strQuery) do
        -- eleven players
        for j = 1, 22 do
            createNewPlayer(fbdb, j, row.TEAMID)
        end
    end
    fbdb:close()
end

local function loadGlobals()

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select * from GLOBALS"
    for row in fbdb:nrows(strQuery) do
        CURRENT_SEASON = row.CURRENTSEASON
    end
    fbdb:close()
end

local function loadPlayers()
    -- load players into the global table for later use
    local fbdb = sqlite3.open(DB_FILE)
    PLAYERS = {}
    strQuery = "Select * from PLAYERS"
    for row in fbdb:nrows(strQuery) do
        local thisplayer = {}
        thisplayer.TEAMID = row.TEAMID
        thisplayer.FIRSTNAME = row.FIRSTNAME
        thisplayer.FAMILYNAME = row.FAMILYNAME
        thisplayer.POSITION = row.POSITION
        thisplayer.MASS = row.MASS
        thisplayer.MAXPOSSIBLEV = row.MAXPOSSIBLEV
        thisplayer.MAXV = row.MAXV
        thisplayer.MAXF = row.MAXF
        thisplayer.BALANCE = row.BALANCE
        thisplayer.THROWACCURACY = row.THROWACCURACY
        thisplayer.CATCHSKILL = row.CATCHSKILL
        table.insert(PLAYERS, thisplayer)
    end
    fbdb:close()
end

function functions.loadGame()
    loadGlobals()
    loadPlayers()       -- load players into the global table for later use
end

function functions.createNewGame()

    deleteAllTables()

    -- populate global table
    populateGlobalsTable()
    CURRENT_SEASON = 1

    -- populate teams table
    populateTeamsTable()

    -- populate player table
    populatePlayersTable()

    -- assign players to teams

    -- populate season table
    db.populateSeasonTable()

    -- after populating the database, load them into tables
    fun.loadGame()

end



return functions
