Constants = require '../../server/settings/constants'
Competitor = require '../../server/game/competitor'

competitor = {}
opponent1 = {}
opponent2 = {}
opponent3 = {}
opponent4 = {}

beforeEach () ->
	competitor = new Competitor 1, 'comp', 'abcd:1000'
	opponent1 = new Competitor 2, 'comp2', 'abcd:1001'
	opponent2 = new Competitor 3, 'comp3', 'abcd:1002'
	opponent3 = new Competitor 4, 'comp4', 'abcd:1003'
	opponent4 = new Competitor 5, 'comp5', 'abcd:1004'

describe 'Competitor', () ->
	describe 'constructor', () ->
		it 'should initialize properties', () ->
			expect(competitor.inGame).toBeFalsy()
			expect(competitor.matches.length).toBe 0
			expect(competitor.matchIndex).toBe 0

	describe 'addMatch', () ->
		it 'should add the first match to the list', () ->
			competitor.addMatch opponent2
			expect(competitor.matches.length).toBe 1
		it 'should add multiple matches', () ->
			competitor.addMatch opponent2
			competitor.addMatch opponent3
			competitor.addMatch opponent2
			expect(competitor.matches.length).toBe 3

	describe 'finishedMatch', () ->
		it 'should set the flag', () ->
			competitor.inMatch = true
			competitor.finishedMatch()
			expect(competitor.inMatch).toBeFalsy()

	describe 'foundMatch', () ->
		it 'should increase the match index', () ->
			competitor.addMatch opponent2
			competitor.foundMatch()
			expect(competitor.matchIndex).toBe 1

	describe 'getOpponent', () ->
		it 'should return a valid opponent', () ->
			competitor.addMatch opponent2
			expect(competitor.getOpponent()).toBe opponent2
		it 'should return null if in game', () ->
			competitor.addMatch opponent2
			competitor.startedMatch()
			expect(competitor.getOpponent()).toBeNull()
		it 'should return null if opponent is in game', () ->
			competitor.addMatch opponent2
			competitor.addMatch opponent3
			opponent2.startedMatch()
			expect(competitor.getOpponent()).toBeNull()
		it 'should return null if finished all matches', () ->
			competitor.addMatch opponent2
			competitor.addMatch opponent3
			competitor.addMatch opponent3
			competitor.addMatch opponent2
			competitor.foundMatch()
			competitor.foundMatch()
			competitor.foundMatch()
			competitor.foundMatch()
			expect(competitor.getOpponent()).toBeNull()

	describe 'shuffleMatches', () ->
		it 'should not delete or create any matches', () ->
			competitor.addMatch opponent2
			competitor.addMatch opponent2
			competitor.addMatch opponent3
			competitor.addMatch opponent3
			competitor.addMatch opponent4
			competitor.addMatch opponent4
			competitor.shuffleMatches()
			expect(competitor.matches.length).toBe 6
		it 'should still play each opponent the same amount of times', () ->
			competitor.addMatch opponent2
			competitor.addMatch opponent2
			competitor.addMatch opponent3
			competitor.addMatch opponent3
			competitor.addMatch opponent4
			competitor.addMatch opponent4
			competitor.shuffleMatches()
			playing2 = 0
			playing3 = 0
			playing4 = 0
			for opponent in competitor.matches
				if opponent.id is opponent2.id
					playing2++
				if opponent.id is opponent3.id
					playing3++
				if opponent.id is opponent4.id
					playing4++
			expect(playing2).toBe 2
			expect(playing3).toBe 2
			expect(playing4).toBe 2
		it 'should not keep the matches in the same order (could unluckily fail this test)', () ->
			competitor.addMatch opponent1
			competitor.addMatch opponent1
			competitor.addMatch opponent1
			competitor.addMatch opponent2
			competitor.addMatch opponent2
			competitor.addMatch opponent2
			competitor.addMatch opponent3
			competitor.addMatch opponent3
			competitor.addMatch opponent3
			competitor.addMatch opponent4
			competitor.addMatch opponent4
			competitor.addMatch opponent4
			competitor.shuffleMatches()
			notInSameSpot = false
			notInSameSpot = true if competitor.matches[0].id isnt opponent1.id
			notInSameSpot = true if competitor.matches[1].id isnt opponent1.id
			notInSameSpot = true if competitor.matches[2].id isnt opponent1.id
			notInSameSpot = true if competitor.matches[3].id isnt opponent2.id
			notInSameSpot = true if competitor.matches[4].id isnt opponent2.id
			notInSameSpot = true if competitor.matches[5].id isnt opponent2.id
			notInSameSpot = true if competitor.matches[6].id isnt opponent3.id
			notInSameSpot = true if competitor.matches[7].id isnt opponent3.id
			notInSameSpot = true if competitor.matches[8].id isnt opponent3.id
			notInSameSpot = true if competitor.matches[9].id isnt opponent4.id
			notInSameSpot = true if competitor.matches[10].id isnt opponent4.id
			notInSameSpot = true if competitor.matches[11].id isnt opponent4.id
			expect(notInSameSpot).toBeTruthy()

	describe 'startedMatch', () ->
		it 'should set the flag', () ->
			competitor.inMatch = false
			competitor.startedMatch()
			expect(competitor.inMatch).toBeTruthy()