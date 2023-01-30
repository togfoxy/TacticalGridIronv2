functions = {}

local function deleteAllTables()

    local fbdb = sqlite3.open(DB_FILE)
    if fbdb then
        local strQuery
        strQuery = "delete * from TEAMS"
        intError = fbdb:exec(strQuery)

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

local function poputlateTeamsTable()
    -- assumes the teams table is empty
    local tempteamnames = {}

    -- add all the team names to a tempory array
    for i = 1, NUM_OF_TEAMS do
        local rndteamnum = love.math.random(1, #TEAM_NAMES)
        table.insert(tempteamnames, TEAM_NAMES[rndteamnum])
    end

    -- write the temporary array to the database
    local fbdb = sqlite3.open(DB_FILE)
    for i = 1, #tempteamnames do
        --! write to table
    end
    fbdb.close()
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

    -- populate player table

    -- populate season table
    populateSeasonTable()

end

function functions.loadGame()


end


return functions
