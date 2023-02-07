leaguestatus = {}

local champion_team_name

function leaguestatus.draw()
    -- call this from love.draw()
print("Champ id = " .. CHAMPION_TEAMID, champion_team_name)
    if CHAMPION_TEAMID ~= nil and champion_team_name == nil then
        champion_team_name = db.getTeamName(CHAMPION_TEAMID)

        love.graphics.setColor(1,1,1,1)
        love.graphics.print(champion_team_name, 300, 300)
    end
    -- buttons.drawButtons()
end
return leaguestatus
