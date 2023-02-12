leaguestatus = {}

local champion_team_name

function leaguestatus.draw()
    -- call this from love.draw()

    if REFRESH_DB then
        -- write result to the league table
        REFRESH_DB = false
        db.updateLeague(CURRENT_SEASON, CHAMPION_TEAMID, CHAMPION_SCORE, CHAMPION_TIME)
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

function leaguestatus.update(dt)

    if REFRESH_DB then

    end
end

return leaguestatus
