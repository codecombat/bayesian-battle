_ = require 'lodash'
class BayesianBattle
  constructor: (scoreUncertainty = (25/6),k=0.0001,scoreStandardDeviationCoefficient=1.8) ->
    @scoreUncertainty ?= scoreUncertainty #set uncertainty in scores
    @k ?= k #small positive value to avoid negative standard deviations
    @scoreStandardDeviationCoefficient ?= scoreStandardDeviationCoefficient
  ###sample playerAndScoreObject would be
  {
    playerID: 1,
    meanStrength: 50,
    standardDeviation: 24.3
    gameRanking: 2 #rank in game
  ###
  updatePlayerSkills: (playerAndScoreObjectsArray) ->
    @validateInputArray playerAndScoreObjectsArray
    returnArray = _.cloneDeep playerAndScoreObjectsArray
    for playerOne in returnArray
      meanStrengthChangePartials = []
      squaredStandardDeviationChangePartials = []
      for playerTwo in (player for player in returnArray when player isnt playerOne) #equality may cause issues
        pairwisePerformanceUncertainty = @calculateTotalPerformanceUncertainty playerOne.standardDeviation,
                                          playerTwo.standardDeviation
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
    return returnArray

  calculatePlayerScoreFromPlayerMetrics: (playerMeanStrength, playerStandardDeviation) ->
    return playerMeanStrength - @scoreStandardDeviationCoefficient * playerStandardDeviation


  validateInputArray:(playerAndScoreObjectsArray) ->
    @validatePlayerArrayLength(playerAndScoreObjectsArray)
    for playerAndScoreObject in playerAndScoreObjectsArray
      @validateRequiredProperties playerAndScoreObject
      @validatePlayerObjectValues playerAndScoreObject, playerAndScoreObjectsArray.length
    @validateUniquePlayerIDs playerAndScoreObjectsArray

  validateRequiredProperties: (playerAndScoreObject) ->
    throw new Error("Player object is missing ID.") unless _.has playerAndScoreObject, 'id'
    throw new Error("Player object is missing mean strength") unless _.has playerAndScoreObject, 'meanStrength'
    throw new Error("Player object is missing standard deviation") unless _.has playerAndScoreObject, 'standardDeviation'
    throw new Error("Player object is missing game ranking") unless _.has playerAndScoreObject, 'gameRanking'

  validateUniquePlayerIDs: (playerAndScoreObjectsArray) ->
    ids = _.pluck(playerAndScoreObjectsArray, 'id')
    uniqueIDs = _.uniq ids
    throw new Error("All IDs must be unique") if uniqueIDs.length isnt ids.length

  validatePlayerArrayLength: (playerAndScoreObjectsArray) ->
    throw new Error("Input array must contain two objects or more") if playerAndScoreObjectsArray.length <=1

  validatePlayerObjectValues: (playerAndScoreObject, arrayLength) ->
    throw new Error("Mean strength must be greater than 0.") if playerAndScoreObject.meanStrength <= 0
    throw new Error("Standard Deviation must be greater than 0") if playerAndScoreObject.standardDeviation <=0
    throw new Error("Game ranking must be greater than or equal to 0") if playerAndScoreObject.gameRanking < 0
    throw new Error("Game ranking must be less than number of players") if playerAndScoreObject.gameRanking >= arrayLength



  calculateTotalPerformanceUncertainty: (playerOneStandardDeviation, playerTwoStandardDeviation) ->
    playerOneStandardDeviationSquared = Math.pow playerOneStandardDeviation,2
    playerTwoStandardDeviationSquared = Math.pow playerTwoStandardDeviation,2
    scoreUncertaintySquared = Math.pow @scoreUncertainty, 2
    totalPairwiseUncertaintySquared = playerOneStandardDeviationSquared +
      playerTwoStandardDeviationSquared +
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
    return 1 if playerOneGameRanking < playerTwoGameRanking
    return 0.5 if playerOneGameRanking == playerTwoGameRanking
    return 0 if playerOneGameRanking > playerTwoGameRanking

  sumArray: (inputArray) ->
    return inputArray.reduce (elementOne, elementTwo) -> elementOne + elementTwo

  updateSkills: (player, meanStrengthChangePartialSum, squaredStandardDeviationPartialSum) ->
    player.meanStrength = player.meanStrength + meanStrengthChangePartialSum
    playerSquaredStandardDeviation = Math.pow player.standardDeviation,2
    updatedPlayerSquaredStandardDeviation =
      playerSquaredStandardDeviation * Math.max((1-squaredStandardDeviationPartialSum),@k)
    player.standardDeviation = Math.sqrt updatedPlayerSquaredStandardDeviation
    return


module.exports = BayesianBattle







