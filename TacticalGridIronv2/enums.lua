enums = {}

function enums.load()
    enum = {}
    enum.sceneMainMenu = 1
    enum.sceneCredits = 2
    enum.sceneDisplaySeasonStatus = 3
    enum.sceneStadium = 4
    enum.sceneEndGame = 5
    enum.sceneDisplayLeagueStatus = 6
    enum.sceneTradePlayers = 7
    enum.sceneTrainPlayers = 8

    enum.buttonMainMenuExit = 1
    enum.buttonMainMenuCredits = 2
    enum.buttonCreditsExit = 3
    enum.buttonMainMenuNewGame = 4
    enum.buttonSeasonStatusExit = 5
    enum.buttonSeasonStatusNextGame = 6
    enum.buttonStadiumQuit = 7
    enum.buttonEndGameContinue = 8
    enum.buttonEndGameQuit = 9
    enum.buttonMainMenuLoad = 10
    enum.buttonLeagueStatusContinue = 11
    enum.buttonTradePlayersContinue = 12
    enum.buttonTrainNextSeason = 13

    enum.gamestateForming = 1
    enum.gamestateReadyForSnap = 2
    enum.gamestateInPlay = 3
    enum.gamestateDeadBall = 4
    enum.gamestateGameOver = 5

    enum.playcallRun = 1
    enum.playcallManOnMan = 2

    enum.soundGo = 1

end
return enums
