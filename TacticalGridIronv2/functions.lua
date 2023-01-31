functions = {}

local function deleteAllTables()

    local fbdb = sqlite3.open(DB_FILE)

    if fbdb then
        local strQuery, intError
        strQuery = "delete from TEAMS"
        intError = fbdb:exec(strQuery)

        strQuery = "delete from SEASON"
        intError = fbdb:exec(strQuery)

        strQuery = "delete from GAMES"
        intError = fbdb:exec(strQuery)

        strQuery = "delete from PLAYERS"
        intError = fbdb:exec(strQuery)

        strQuery = "delete from LEAGUE"
        intError = fbdb:exec(strQuery)
    end
    fbdb:close()
end

local function populateSeasonTable()

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select * from TEAMS"
    for row in fbdb:nrows(strQuery) do
        strQuery = "Insert into SEASON ('TEAMID') values ('" .. row.TEAMID .. "')"
        local dberror = fbdb:exec(strQuery)
        print(dberror, strQuery)
    end
    fbdb:close()
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
        rndteamnum = love.math.random(1, #TEAM_NAMES)
        -- write to table
        local strQuery = "INSERT INTO TEAMS ('TEAMNAME') VALUES ('" .. TEAM_NAMES[rndteamnum] .. "');"
        local dberror = fbdb:exec(strQuery)
        -- remove from array so it is not re-used
        table.remove(TEAM_NAMES, rndteamnum)
        index = index + 1
    until index == 8
    fbdb:close()
end

function functions.createNewGame()

    -- delete all rows in player table
    -- delete all rows in season table
    -- delete all rows in games table
    -- delete all rows in teams table
    -- delete all rows in global table
    deleteAllTables()

    -- populate global table

    -- populate teams table
    populateTeamsTable()

    -- populate player table

    -- populate season table
    populateSeasonTable()


end

function functions.loadGame()


end


return functions
