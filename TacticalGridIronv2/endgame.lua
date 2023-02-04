endgame = {}

local offensiveteamname, defensiveteamname

function endgame.draw()


    if REFRESH_DB then
        local fbdb = sqlite3.open(DB_FILE)
        local strQuery = "select * from TEAMS"

        for row in fbdb:nrows(strQuery) do
            if row.TEAMID == OFFENSIVE_TEAMID then
                offensiveteamname = row.TEAMNAME
            end
            if row.TEAMID == DEFENSIVE_TEAMID then
                defensiveteamname = row.TEAMNAME
            end
        end
        REFRESH_DB = false
    end

    love.graphics.setColor(1,1,1,1)
    -- print team name and score
    love.graphics.print(offensiveteamname, 100, 100)
    love.graphics.print(OFFENSIVE_SCORE, 100, 200)

    -- print team name and score
    love.graphics.print(defensiveteamname, 750, 100)
    love.graphics.print(DEFENSIVE_SCORE, 750, 200)

end

return endgame
