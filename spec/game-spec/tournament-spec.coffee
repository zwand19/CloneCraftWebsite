Competitor = require '../../server/game/competitor'
Constants = require '../../server/settings/constants'
Tournament = require '../../server/game/tournament'

competitor1 = {}
competitor2 = {}
competitor3 = {}
competitor4 = {}
competitor5 = {}
tournament = {}

describe 'Bracket Tournament', () ->
	beforeEach () ->
		competitor1 = new Competitor 1, 'comp', 'http://127.0.0.1:3000'
		competitor2 = new Competitor 2, 'comp2', 'http://127.0.0.1:3001'
		competitor3 = new Competitor 3, 'comp3', 'http://127.0.0.1:3002'
		competitor4 = new Competitor 4, 'comp4', 'http://127.0.0.1:3003'
		competitor5 = new Competitor 5, 'comp5', 'http://127.0.0.1:3004'
		tournament = new Tournament.BracketTournament [competitor1, competitor2, competitor3, competitor4, competitor5], 'test tournament'
	describe 'constructor', () ->
		it 'should set number of rounds', () ->
			#tournament = new Tournament.BracketTournament [competitor1, competitor2, competitor3, competitor4, competitor5, competitor5, competitor5, competitor5, competitor5], 'test tournament'
			#expect(tournament.rounds.length).toBe 4
			#tournament = new Tournament.BracketTournament [competitor1, competitor2, competitor3, competitor4, competitor5, competitor5, competitor5, competitor5], 'test tournament'
			#expect(tournament.rounds.length).toBe 3
			#tournament = new Tournament.BracketTournament [competitor1, competitor2, competitor3, competitor4, competitor5], 'test tournament'
			#expect(tournament.rounds.length).toBe 3
			#tournament = new Tournament.BracketTournament [competitor1, competitor2, competitor3, competitor4], 'test tournament'
			#expect(tournament.rounds.length).toBe 2
			#tournament = new Tournament.BracketTournament [competitor1, competitor2, competitor3], 'test tournament'
			#expect(tournament.rounds.length).toBe 2
			#tournament = new Tournament.BracketTournament [competitor1, competitor2], 'test tournament'
			#expect(tournament.rounds.length).toBe 1

describe 'Round Robin Tournament', () ->
	beforeEach () ->
		competitor1 = new Competitor 1, 'comp', 'http://127.0.0.1:3000'
		competitor2 = new Competitor 2, 'comp2', 'http://127.0.0.1:3001'
		competitor3 = new Competitor 3, 'comp3', 'http://127.0.0.1:3002'
		competitor4 = new Competitor 4, 'comp4', 'http://127.0.0.1:3003'
		competitor5 = new Competitor 5, 'comp5', 'http://127.0.0.1:3004'
		tournament = new Tournament.RoundRobinTournament()

	describe 'addMatches', () ->
		it 'should add the correct number of total matches', () ->
			tournament.competitors = [competitor1, competitor2, competitor3, competitor4, competitor5]
			tournament.addMatchesForCompetitors()
			numMatches = 0
			for competitor in tournament.competitors
				numMatches += competitor.matches.length
			expect(numMatches).toBe tournament.competitors.length * (tournament.competitors.length - 1) / 2
		it 'should have everyone play each other once', () ->
			tournament.competitors = [competitor1, competitor2, competitor3, competitor4, competitor5]
			tournament.addMatchesForCompetitors()
			for competitor1 in tournament.competitors
				for competitor2 in tournament.competitors
					matchesPlaying = 0
					for match in competitor1.matches
						if match.id is competitor2.id then matchesPlaying++
					for match in competitor2.matches
						if match.id is competitor1.id then matchesPlaying++
					if competitor1.id isnt competitor2.id then expect(matchesPlaying).toBe(1)
		it 'should add the correct number of matches for each competitor', () ->
			tournament.competitors = [competitor1, competitor2, competitor3, competitor4, competitor5]
			tournament.addMatchesForCompetitors()
			expectedNumMatches = tournament.competitors.length - 1
			for invitee in tournament.competitors
				matches = 0
				for inviter in tournament.competitors
					for invitation in inviter.matches
						matches++ if invitation.id is invitee.id
					for invitation in invitee.matches
						matches++ if invitation.id is inviter.id
				expect(matches).toBe expectedNumMatches
				
	###
	describe 'executeTournament', () ->
		it 'should run all of the matches', () ->
			runs ->
				tournament.executeTournament()

			waitsFor (->
				tournamentOver = true
				for c in tournament.competitors
					tournamentOver = false if c.stillHasGames()
				return tournamentOver
			), "executing the tournament took too long", 150000

			runs ->
				expect(tournament.matches.length).toBe Constants.tournament.gamesPerMatchup * tournament.competitors.length * (tournament.competitors.length - 1)
	###