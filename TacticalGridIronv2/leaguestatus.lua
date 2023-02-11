leaguestatus = {}

local champion_team_name

function leaguestatus.draw()
    -- call this from love.draw()

    if REFRESH_DB then
        -- write result to the league table
        local fbdb = sqlite3.open(DB_FILE)
        local strQuery = "Insert into LEAGUE ('SEASON', 'TEAMID', 'SCORE', 'TIME') values ('" .. CURRENT_SEASON .. "', '" .. CHAMPION_TEAMID .. "', '" .. CHAMPION_SCORE .. "', '" .. CHAMPION_TIME .. "')"
        local dberror = fbdb:exec(strQuery)
        fbdb:close()        --! check that everyone open has a matching close

    end

    if CHAMPION_TEAMID ~= nil and champion_team_name == nil then
        champion_team_name = db.getTeamName(CHAMPION_TEAMID)
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(champion_team_name, 300, 300)
    love.graphics.print(CHAMPION_SCORE, 475, 300)
    love.graphics.print(CHAMPION_TIME, 550, 300)

    -- buttons.drawButtons()
end

return leaguestatus
