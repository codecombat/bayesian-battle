class BayesianScoring
  constructor: (scoreUncertainty = (25/6),k=0.0001,scoreStandardDeviationCoefficient=1.8) ->
    @scoreUncertainty = scoreUncertainty #set uncertainty in scores
    @k = k #small positive value to avoid negative standard deviations
    @scoreStandardDeviationCoefficient = scoreStandardDeviationCoefficient
  ###sample playerAndScoreObject would be
  {
    playerID: 1,
    meanStrength: 50,
    standardDeviation: 24.3
    gameRanking: 2 #rank in game
  ###
  updatePlayerSkills: (playerAndScoreObjectsArray) ->
    for playerOne in playerAndScoreObjectsArray
      meanStrengthChangePartials = []
      squaredStandardDeviationChangePartials = []
      for playerTwo in (player for player in playerAndScoreObjectsArray when player isnt playerOne) #equality may cause issues
        pairwisePerformanceUncertainty = @calculateTotalPerformanceUncertainty playerOne.standardDeviation, playerTwo.standardDeviation
        chanceOfPlayerOneBeatingPlayerTwo = @calculateChanceOfPlayerOneBeatingPlayerTwo playerOne.meanStrength,
                                            playerTwo.meanStrength, pairwisePerformanceUncertainty
        chanceOfPlayerTwoBeatingPlayerOne = @calculateChanceOfPlayerTwoBeatingPlayerOne playerTwo.meanStrength,
                                            playerOne.meanStrength, pairwisePerformanceUncertainty

        pairwiseGameOutcomeValue = @calculatePairwiseGameOutcomeValue playerOne.gameRanking, playerTwo.gameRanking

        meanStrengthChangePartial = @calculateMeanStrengthChangePartial playerOne.standardDeviation,
                                    pairwisePerformanceUncertainty, pairwiseGameOutcomeValue, chanceOfPlayerOneBeatingPlayerTwo

        squaredDeviationChangePartial = @calculateSquaredStandardDeviationChangePartial playerOne.standardDeviation,
                                        pairwisePerformanceUncertainty, chanceOfPlayerOneBeatingPlayerTwo,
                                        chanceOfPlayerTwoBeatingPlayerOne

        meanStrengthChangePartials.push meanStrengthChangePartial
        squaredStandardDeviationChangePartials.push squaredDeviationChangePartial

      meanStrengthChangePartialSum = @sumArray(meanStrengthChangePartials)
      squaredStandardDeviationChangePartialSum = @sumArray(squaredStandardDeviationChangePartials)
      @updateSkills playerOne, meanStrengthChangePartialSum, squaredStandardDeviationChangePartialSum

  calculatePlayerScoreFromPlayerMetrics: (playerMeanStrength, playerStandardDeviation) ->
    return playerMeanStrength - @scoreStandardDeviationCoefficient * playerStandardDeviation


  validateInputArray:(playerAndScoreObjectsArray) ->
    for playerAndScoreObject in playerAndScoreObjectsArray
      isValid = @validatePlayerAndScoreObject playerAndScoreObject
      throw new Error "Invalid player/score array passed to scoring function" unless isValid

  validatePlayerAndScoreObject: (playerAndScoreObject) ->
    return true

  calculateTotalPerformanceUncertainty: (playerOneStandardDeviation, playerTwoStandardDeviation) ->
    playerOneStandardDeviationSquared = Math.pow playerOneStandardDeviation,2
    playerTwoStandardDeivationSquared = Math.pow playerTwoStandardDeviation,2
    scoreUncertaintySquared = Math.pow @scoreUncertainty, 2
    totalPairwiseUncertaintySquared = playerOneStandardDeviationSquared +
      playerTwoStandardDeivationSquared +
      2 * scoreUncertaintySquared
    return Math.sqrt totalPairwiseUncertaintySquared

  calculateChanceOfPlayerOneBeatingPlayerTwo: (playerOneMeanStrength, playerTwoMeanStrength, performanceUncertainty) ->
    return @calculateMatchSuccessProbability(playerOneMeanStrength, playerTwoMeanStrength, performanceUncertainty)

  calculateChanceOfPlayerTwoBeatingPlayerOne: (playerTwoMeanStrength, playerOneMeanStrength, performanceUncertainty) ->
    return @calculateMatchSuccessProbability playerTwoMeanStrength, playerOneMeanStrength, performanceUncertainty

  calculateMatchSuccessProbability: (playerOneMeanStrength, playerTwoMeanStrength, performanceUncertainty) ->
    playerOneCoefficient = Math.exp (playerOneMeanStrength/performanceUncertainty)
    playerTwoCoefficient = Math.exp (playerTwoMeanStrength/performanceUncertainty)
    return playerOneCoefficient/(playerOneCoefficient+playerTwoCoefficient)

  calculateMeanStrengthChangePartial: (playerOneStandardDeviation, performanceUncertainty, gameOutcomeValue, probabilityOfOneBeatingTwo) ->
    uncertaintyCoefficient = Math.pow(playerOneStandardDeviation,2)/performanceUncertainty
    adjustedOutcomeCoefficient = gameOutcomeValue - probabilityOfOneBeatingTwo
    return uncertaintyCoefficient * adjustedOutcomeCoefficient

  calculateSquaredStandardDeviationChangePartial: (playerOneStandardDeviation,performanceUncertainty,
    probabilityOfOneBeatingTwo,probabilityOfTwoBeatingOne) ->

    uncertaintyCoefficient = playerOneStandardDeviation / performanceUncertainty #this is gamma in the original formula
    probabilityProduct = probabilityOfOneBeatingTwo * probabilityOfTwoBeatingOne
    return uncertaintyCoefficient * Math.pow(uncertaintyCoefficient,2) * probabilityProduct

  calculatePairwiseGameOutcomeValue: (playerOneGameRanking, playerTwoGameRanking) ->
    return 1 if playerOneGameRanking > playerTwoGameRanking
    return 0.5 if playerOneGameRanking == playerTwoGameRanking
    return 0 if playerOneGameRanking < playerTwoGameRanking

  sumArray: (inputArray) ->
    return inputArray.reduce (elementOne, elementTwo) -> elementOne + elementTwo

  updateSkills: (player, meanStrengthChangePartialSum, squaredStandardDeviationPartialSum) ->
    player.meanStrength = player.meanStrength + meanStrengthChangePartialSum
    playerSquaredStandardDeviation = Math.pow player.standardDeviation,2
    updatedPlayerSquaredStandardDeviation =
      playerSquaredStandardDeviation * Math.max((1-squaredStandardDeviationPartialSum),@k)
    player.standardDeviation = Math.sqrt updatedPlayerSquaredStandardDeviation
    return








