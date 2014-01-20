class BayesianScoring
  constructor: (scoreUncertainty = (25/6),k=0.0001) ->
    @scoreUncertainty = scoreUncertainty #set uncertainty in scores
    @k = k #small positive value to avoid negative standard deviations
  ###sample playerAndScoreObject would be
  {
    playerID: 1,
    meanStrength: 50,
    standardDeviation: 24.3
    gameRanking: 2 #rank in game
  ###
  scoreGame: (playerAndScoreObjectsArray) ->
    for playerOne in playerAndScoreObjectsArray
      for playerTwo in (player for player in playerAndScoreObjectsArray when player isnt playerOne) #equality may cause issues
        pairwisePerformanceUncertainty = @calculateTotalPerformanceUncertainty playerOne.standardDeviation, playerTwo.standardDeviation
        chanceOfPlayerOneBeatingPlayerTwo = @calculateChanceOfPlayerOneBeatingPlayerTwo playerOne.meanStrength,
          playerTwo.meanStrength, pairwisePerformanceUncertainty



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
    playerOneCoefficient = Math.exp (playerOneMeanStrength/performanceUncertainty)
    playerTwoCoefficient = Math.exp (playerTwoMeanStrength/performanceUncertainty)
    return playerOneCoefficient/(playerOneCoefficient+playerTwoCoefficient)

  calculateMeanStrengthChangePartial: (playerOneStandardDeviation, performanceUncertainty, gameOutcomeValue, probabilityOfOneBeatingTwo) ->
    uncertaintyCoefficient = Math.pow(playerOneStandardDeviation,2)/performanceUncertainty
    adjustedOutcomeCoefficient = gameOutcomeValue - probabilityOfOneBeatingTwo
    return uncertaintyCoefficient*adjustedOutcomeCoefficient









