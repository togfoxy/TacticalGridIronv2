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
    return nil
end
return db
