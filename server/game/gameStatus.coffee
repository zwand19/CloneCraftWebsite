Board = require '../entities/board'
GameRules = require '../settings/gameRules'

class GameStatus
	
	trimBase = (base) ->
		return {
			ui:
				si: GameRules.base.size
				v:  GameRules.base.vision
				cb: base.canBuild
			g: base.gold
			h: base.health
			x: base.x
			y: base.y
			id: base.id
		}
	trimMinion = (minion) ->
		return {
			ui:
				h: minion.h
				s: minion.s
				d: minion.d
				r: minion.r
				m: minion.m
				v: minion.v
				mr: minion.movesRemaining
				ca: minion.canAct
			g: minion.carrying
			sp: minion.speed
			mi: minion.mining
			vi: minion.vision
			hp: minion.health
			r: minion.range
			d: minion.damage
			x: minion.x
			y: minion.y
			id: minion.id
		}
	trimResource = (resource) ->
		return {
			id: resource.id
			x: resource.x
			y: resource.y
		}
	trimTeam = (team, currentTeamId) ->
		return null if team is null
		return {
			currentTeam: team.id is currentTeamId
			color: team.color
			type: team.type
			name: team.name
			id: team.id
		}

	constructor: (team, game, showFog) ->
		minions = []
		for id, minion of team.minions
			minions.push trimMinion minion

		vision = if showFog then game.board.getVision(team) else game.board.getFullVision(team)
		
		enemyMinions = []
		for id, minion of vision.minions
			enemyMinions.push trimMinion minion
		vision.minions = enemyMinions

		enemyBases = []
		for id, base of vision.bases
			enemyBases.push trimBase base
		vision.bases = enemyBases

		teams = []
		for t in game.teams
			teams.push trimTeam t, team.id

		resources = []
		for r in vision.resources
			resources.push trimResource r
		vision.resources = resources

		winner = trimTeam game.getWinner(), team.id
		winner = null if not game.isOver()

		status = 
			ui: 
				fog: showFog
				teams: teams
				winner: winner
				finished: game.isOver()
			base: trimBase team.base
			board:
				h: game.board.height
				w: game.board.width
			gameId: game.id
			minions: minions
			nextMinionId: game.board.nextId
			round: game.round
			vision: vision

		return status

module.exports = GameStatus