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

  


