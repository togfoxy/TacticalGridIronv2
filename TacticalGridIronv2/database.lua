db = {}

function db.getTeamName(teamid)

    arr_seasonstatus = {}
    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "select teams.TEAMNAME, season.TEAMID from season inner join TEAMS on teams.TEAMID = season.TEAMID"
    for row in fbdb:nrows(strQuery) do
        if row.TEAMID == teamid then
            return row.TEAMNAME
        end
    end
    fbdb:close()
    return nil
end

function db.updateLeague(season, teamid, score, time)

    if season == nil then season = 1 end
    if teamid == nil then teamid = 2 end
    if score == nil then score = 3 end
    if time == nil then time = 4 end

    local fbdb = sqlite3.open(DB_FILE)
    local strQuery = "Insert into LEAGUE ('SEASON', 'TEAMID', 'SCORE', 'TIME') values (" .. season .. ", " .. teamid .. ", " .. score .. ", ".. time ..")"
    local dberror

    dberror = fbdb:exec(strQuery)
    assert(dberror == 0, "Insert failed. Error " .. dberror  .. " : " .. strQuery)
    fbdb:close()
    print("LEAGUE update successful")
end

return db
