Bayesian Battle
==============================
[![Build Status](https://travis-ci.org/codecombat/bayesian-battle.png?branch=master)](https://travis-ci.org/codecombat/bayesian-battle)

An implementation of the Bayesian-approximation based game ranking system described by
[Weng and Lin](http://jmlr.org/papers/volume12/weng11a/weng11a.pdf) and
[used by HackerRank](https://www.hackerrank.com/scoring). This algorithm has powered CodeCombat's coding esports match rankings since 2014.

This system is similar to Elo or an MMR system. Here's how we explain it in CodeCombat:

> In each arena, scoring is as follows: your code will play constantly in the background against other players to determine how strong it is. The number of points you earn for a match are determined by a Bayesian calculation predicting how likely you were to win that match. So if you beat a player ranked more highly than you, you gain more points. Beat a player lower than you, gain fewer points. Lose to a weaker player, lose more points. Lose to a stronger player, lose fewer points.

## Usage

API format is below. See also some usage examples in [the tests](https://github.com/codecombat/bayesian-battle/blob/master/spec/bayesianBattleSpec.coffee).

### `constructor`

#### `scoreUncertainty`

This parameter controls the fixed amount of uncertainty between the two players. This is used along with the
standard deviation of each player's strength to calculate the total performance uncertainty of the game.

#### `k`
This parameter is the minimum value of a user's mean strength standard deviation (more specifically, to ensure
that standard deviation is never negative.)

#### `scoreStandardDeviationCoefficient`
This parameter is used to calculate a player's score from their mean strength and standard deviation
(the calculation is `meanStrength` - `scoreStandardDeviationCoefficient` * `standardDeviation`)

---

### `updatePlayerSkills`

#### Input Data Format

The input data format consists of an array of objects that have four properties:

1. `id` : a unique value to identify the given player object.
1. `meanStrength` : the mean strength metric of the player(μ). For new players, this should be 25.
1. `standardDeviation` : the standard deviation of the mean strength of the player(σ). For new players, this should be 25/3.
1. `gameRanking` : A zero-based ranking of the player in the game. Lower is better. Two players draw if they have the same ranking.

The object may have other properties; they will not be modified.

#### Output Data Format

The output data is a copy of the input data with updated `meanStrength` and `standardDeviation` properties.

---

### `calculatePlayerScoreFromPlayerMetrics`

This function calculates a user's score from their mean strength and standard deviation. Lower standard deviation
results in higher scores.

---

## Contributions

If you want to contribute, fantastic! You can file issues and PRs in this repository.

## License

The MIT License (MIT)

Copyright (c) 2014-2023 CodeCombat Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
