Competitor = require '../../server/game/competitor'
Constants = require '../../server/settings/constants'
Match = require '../../server/game/match'

competitor1 = {}
competitor2 = {}
match = {}


describe 'Match', () ->
	beforeEach () ->
		competitor1 = new Competitor(1, 'bob', 'a:100')
		competitor2 = new Competitor(2, 'alan', 'a:101')
		match = new Match({ s: 1, r: 1, m: 1 }, competitor1, competitor2, 5)

	describe 'constructor', () ->
		it 'should render competitors in match', () ->
			expect(competitor1.inMatch).toBeTruthy()
			expect(competitor2.inMatch).toBeTruthy()
		it 'should create games', () ->
			expect(match.games).toBeDefined()
			expect(match.games[0].teams[0].address).toBe competitor1.address
			expect(match.games[0].teams[1].address).toBe competitor2.address