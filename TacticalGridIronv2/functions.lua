functions = {}

local function deleteAllTables()

    local fbdb = sqlite3.open(DB_FILE)
    if fbdb then
        local strQuery
        strQuery = "delete from TEAMS"
        intError = fbdb:exec(strQuery)

print("Delete result: " .. intError)

        strQuery = "delete * from SEASON"
        intError = fbdb:exec(strQuery)

        strQuery = "delete * from GAMES"
        intError = fbdb:exec(strQuery)

        strQuery = "delete * from PLAYERS"
        intError = fbdb:exec(strQuery)

        strQuery = "delete * from LEAGUE"
        intError = fbdb:exec(strQuery)
    end
end

local function populateSeasonTable()

    if REFRESH_DB then	-- load up array and then render from array

        local fbdb = sqlite3.open(DB_FILE)
        local strQuery
        local intError

        if fbdb then
            -- load the teams table into a temporary array so can step through it
            strQuery = "select * from TEAMS"
            i = 1
            for row in fbdb:nrows(strQuery) do
                tempteams[i] = row.teamname
                i = i + 1
            end

            -- take two teams and put them into the season table
            local seasonindex = 1
            for i = 1, NUM_OF_TEAMS, 2 do
                local t1, t2 = tempteams[i], tempteams[i+1]
                SEASON[seasonindex].TEAM1 = t1
                SEASON[seasonindex].TEAM2 = t2
                seasonindex = seasonindex + 1
            end
        end
        REFRESH_DB = false
        fbdb.close()
    end
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


    local fbdb = sqlite3.open(DB_FILE)

    local index = 0
    resetGlobalTeamNames()
    repeat
        rndteamnum = love.math.random(1, #TEAM_NAMES)
        -- write to table
        local strQuery = "INSERT INTO TEAMS ('TEAMNAME') VALUES ('" .. TEAM_NAMES[rndteamnum] .. "');"

print(strQuery)

        local dberror = fbdb:exec(strQuery)

print(dberror)

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
    -- populateSeasonTable()

end

function functions.loadGame()


end


return functions
