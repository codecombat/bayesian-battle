Scorer = require '../src/bayesianScorer'

describe "Bayesian Scorer Class", ->
  describe "Constructor tests", ->
    it "Should construct with default values", ->
      scorer = new Scorer()
      expect(scorer.scoreUncertainty).toEqual(25/6)
      expect(scorer.k).toEqual(0.0001)
      expect(scorer.scoreStandardDeviationCoefficient).toEqual(1.8)
    it "Should allow the scoreUncertainty to be overriden", ->
      scorer = new Scorer(30)
      expect(scorer.scoreUncertainty).toEqual 30
      expect(scorer.k).toEqual(0.0001)
      expect(scorer.scoreStandardDeviationCoefficient).toEqual(1.8)
    it "Should allow the k value to be overridden", ->
      scorer = new Scorer(undefined, 5)
      expect(scorer.scoreUncertainty).toEqual(25/6)
      expect(scorer.k).toEqual 5
      expect(scorer.scoreStandardDeviationCoefficient).toEqual(1.8)
    it "Should allow the standard deviation score to be overridden", ->
      scorer = new Scorer(undefined,undefined,2)
      expect(scorer.scoreUncertainty).toEqual(25/6)
      expect(scorer.k).toEqual(0.0001)
      expect(scorer.scoreStandardDeviationCoefficient).toEqual 2
  describe "Utility functions", ->
    scorer = undefined
    beforeEach ->
      scorer = new Scorer()
    it "Should sum arrays correctly", ->
      array = [1..5]
      expect(scorer.sumArray array).toEqual 15

  describe "Input object validation", ->
    scorer = playerOne = playerTwo = playerThree = undefined
    beforeEach ->
      scorer = new Scorer()
      playerOne = {
        id: "125012f315",
        meanStrength: 530,
        standardDeviation:6.5
        gameRanking:2
      }
      playerTwo = {
        id:"21fa350f931",
        meanStrength:230,
        standardDeviation:35,
        gameRanking:1
      }
      playerThree = {
        id:"as359012f3521",
        meanStrength:25,
        standardDeviation:(25/3),
        gameRanking:0
      }
    it "should check for duplicate IDs", ->
      playerTwo.id = "125012f315"
      playerObjectArray = [playerOne,playerTwo,playerThree]
      expect(scorer.updatePlayerSkills.bind(scorer,playerObjectArray)).toThrow(new Error("All IDs must be unique"))
    it "should check that the required parameters are present in each object", ->
      playerOne = {
        meanStrength: 530,
        standardDeviation:6.5
        gameRanking:3
      }
      playerObjectArray = [playerOne,playerTwo,playerThree]
      expect(scorer.updatePlayerSkills.bind(scorer,playerObjectArray)).toThrow(new Error("Player object is missing ID."))
    it "should enforce that more than 1 object is present to rank", ->
      playerObjectArray = [playerOne]
      expect(scorer.updatePlayerSkills.bind(scorer,playerObjectArray)).toThrow(new Error("Input array must contain two objects or more"))

    it "should enforce that mean strength is greater than 0", ->
      playerThree = {
        id:"as359012f3521",
        meanStrength:-5,
        standardDeviation:5,
        gameRanking:1
      }
      playerObjectArray = [playerOne,playerTwo,playerThree]
      expect(scorer.updatePlayerSkills.bind(scorer,playerObjectArray)).toThrow(new Error("Mean strength must be greater than 0."))

    it "should enforce that standard deviation is greater than 0", ->
      playerThree = {
        id:"as359012f3521",
        meanStrength:300,
        standardDeviation:0,
        gameRanking:1
      }
      playerObjectArray = [playerOne,playerTwo,playerThree]
      expect(scorer.updatePlayerSkills.bind(scorer,playerObjectArray)).toThrow(new Error("Standard Deviation must be greater than 0"))

    it "should enforce that game ranking is greater than or equal to 0", ->
      playerThree = {
        id:"as359012f3521",
        meanStrength:300,
        standardDeviation:0,
        gameRanking:1
      }
      playerObjectArray = [playerOne,playerTwo,playerThree]
      expect(scorer.updatePlayerSkills.bind(scorer,playerObjectArray)).toThrow(new Error("Standard Deviation must be greater than 0"))

    it "should enforce that the game ranking is less than the total amount of players", ->
      playerThree = {
        id:"as359012f3521",
        meanStrength:300,
        standardDeviation:1,
        gameRanking:3
      }
      playerObjectArray = [playerOne,playerTwo,playerThree]
      expect(scorer.updatePlayerSkills.bind(scorer,playerObjectArray)).toThrow(new Error("Game ranking must be less than number of players"))


  describe "Ranking", ->
    scorer = playerOne = playerTwo = playerThree = undefined
    beforeEach ->
      scorer = new Scorer()
      playerOne = {
        id: "125012f315",
        meanStrength: 28,
        standardDeviation:6.5
        gameRanking:2
      }
      playerTwo = {
        id:"21fa350f931",
        meanStrength:22,
        standardDeviation:8.0,
        gameRanking:1
      }
      playerThree = {
        id:"as359012f3521",
        meanStrength:23,
        standardDeviation:(25/3),
        gameRanking:0
      }
    it "Should adjust rankings properly", ->
      oldPlayerArray = [playerOne, playerTwo,playerThree]
      updatedPlayerArray = scorer.updatePlayerSkills oldPlayerArray
      #TODO: manually calculate the correct values and check against the program
      console.log "Player One Old Score:#{oldPlayerArray[0].meanStrength}, New Score:#{updatedPlayerArray[0].meanStrength}"
      console.log "Player One Old stddev:#{oldPlayerArray[2].standardDeviation}, New stddev:#{updatedPlayerArray[2].standardDeviation}"
      expect(updatedPlayerArray[0].meanStrength).toBeLessThan oldPlayerArray[0].meanStrength
    it "Shouldn't adjust rankings if two identical players draw against each other", ->
      return

  describe "Outcome value generation", ->
    scorer = undefined
    beforeEach ->
      scorer = new Scorer()
    it "Should generate the proper value for a win", ->
      expect(scorer.calculatePairwiseGameOutcomeValue 0,1).toEqual 1
    it "Should generate the proper value for a draw", ->
      expect(scorer.calculatePairwiseGameOutcomeValue 1,1).toEqual 0.5
    it "Should generate the proper value for a loss", ->
      expect(scorer.calculatePairwiseGameOutcomeValue 1,0).toEqual 0

  describe "Outcome probability calculation", ->
    scorer = playerOne = playerTwo = playerThree = undefined
    beforeEach ->
      scorer = new Scorer()
      playerOne = {
        id: "125012f315",
        meanStrength: 35,
        standardDeviation:10
        gameRanking:2
      }
      playerTwo = {
        id:"21fa350f931",
        meanStrength:23,
        standardDeviation:2,
        gameRanking:1
      }
      playerThree = {
        id:"as359012f3521",
        meanStrength:25,
        standardDeviation:(25/3),
        gameRanking:0
      }

    it "Should generate a high probability for a higher ranked player beating a lower ranked player", ->
      performanceUncertainty = scorer.calculateTotalPerformanceUncertainty(playerOne.standardDeviation, playerTwo.standardDeviation)
      chanceOfPlayerOneBeatingPlayerTwo = scorer.calculateChanceOfPlayerOneBeatingPlayerTwo(playerOne.meanStrength,playerTwo.meanStrength,performanceUncertainty)
      expect(chanceOfPlayerOneBeatingPlayerTwo).toBeGreaterThan 0.5
    it "Should generate a low probability for a lower ranked player beating a higher ranked player", ->
      performanceUncertainty = scorer.calculateTotalPerformanceUncertainty(playerOne.standardDeviation, playerTwo.standardDeviation)
      chanceOfPlayerOneBeatingPlayerTwo = scorer.calculateChanceOfPlayerTwoBeatingPlayerOne(playerTwo.meanStrength,playerOne.meanStrength,performanceUncertainty)
      expect(chanceOfPlayerOneBeatingPlayerTwo).toBeLessThan 0.5
    it "Should generate a roughly equal probability for two equal players matching off against each other", ->
      performanceUncertainty = scorer.calculateTotalPerformanceUncertainty(playerOne.standardDeviation, playerOne.standardDeviation)
      chanceOfPlayerDefeatingSelf = scorer.calculateChanceOfPlayerOneBeatingPlayerTwo(playerOne.meanStrength,playerOne.meanStrength,performanceUncertainty)
      expect(chanceOfPlayerDefeatingSelf).toEqual 0.5

  describe "Score calculation", ->
    it "Should calculate a higher score for a player with higher strength", ->
      return





