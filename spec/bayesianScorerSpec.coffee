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
    it "Should check for duplicate IDs", ->
      return
    it "Should check that the required parameters are present in each object", ->
      return
    it "Should enforce that more than 1 object is present to rank", ->
      return
    it "Should enforce that strength and standard deviation are non-negative", ->
      return

  describe "Ranking", ->
    scorer = undefined
    beforeEach ->
      scorer = new Scorer()

    it "Should adjust rankings properly", ->
      return
    it "Shouldn't adjust rankings if two identical players draw against each other", ->
      return

  describe "Outcome value generation", ->
    scorer = undefined
    beforeEach ->
      scorer = new Scorer()
    it "Should generate the proper value for a win", ->
      return
    it "Should generate the proper value for a draw", ->
      return
    it "Should generate the proper value for a loss", ->
      return
  describe "Outcome probability calculation", ->
    it "Should generate a high probability for a higher ranked player beating a lower ranked player", ->
      return
    it "Should generate a low probability for a lower ranked player beating a higher ranked player", ->
      return
    it "Should generate a roughly equal probability for two equal players matching off against each other", ->
      return

  describe "Score calculation", ->
    it "Should calculate a higher score for a player with higher strength", ->
      return





