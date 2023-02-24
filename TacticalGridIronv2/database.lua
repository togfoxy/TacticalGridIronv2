db = {}

function db.getTeamName(teamid)

    arr_seasonstatus = {}
    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select teams.TEAMNAME, season.TEAMID from season inner join TEAMS on teams.TEAMID = season.TEAMID"
    for row in fbdb:nrows(strQuery) do
        if row.TEAMID == teamid then
            fbdb:close()
            return row.TEAMNAME
        end
    end
    fbdb:close()
    return nil
end

function db.updateLeague(season, teamid, score, time)

    assert(season ~= nil)
    assert(teamid ~= nil)
    assert(score ~= nil)
    assert(time ~= nil)

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "Insert into LEAGUE ('SEASON', 'TEAMID', 'SCORE', 'TIME') values (" .. season .. ", " .. teamid .. ", " .. score .. ", ".. time ..")"
    local dberror = fbdb:exec(strQuery)
    assert(dberror == 0, "Insert failed. Error " .. dberror  .. " : " .. strQuery)
    fbdb:close()
    print("LEAGUE update successful")
end

function db.getCountSeasonTable()
    -- counts number of rows in SEASON. Helps to determine if the season is over.
    -- index < 15 means the season is not over
    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select * from SEASON"
    local index = 0
    for row in fbdb:nrows(strQuery) do
        index = index + 1
    end
    fbdb:close()
    return index
end

function db.populateSeasonTable()

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select * from TEAMS"
    for row in fbdb:nrows(strQuery) do
        local strQuery2 = "Insert into SEASON ('TEAMID') values ('" .. row.TEAMID .. "')"
        local dberror = fbdb:exec(strQuery2)
        assert(dberror == 0, dberror .. strQuery2)
    end
    fbdb:close()
end

return db
