class TournamentController
	constructor: ($scope, socket) ->
		$scope.waitingOnServer = false
		$scope.competitors = []
		$scope.winnersBracket = []
		$scope.losersBracket = []
		$scope.startedTournament = false
		$scope.results = ''
		$scope.competitors.push
			name: 'Craig'
			endpoint: "http://localhost:3131/1"
		$scope.competitors.push
			name: 'Michelangelo and Cathy'
			endpoint: "http://localhost:3131/2"
		$scope.competitors.push
			name: 'Jake'
			endpoint: "http://localhost:3131/3"
		$scope.competitors.push
			name: 'Fletcher'
			endpoint: "http://localhost:3131/4"
		$scope.competitors.push
			name: 'James and Dave'
			endpoint: "http://localhost:3131/5"
		$scope.competitors.push
			name: 'Zack'
			endpoint: "http://localhost:3000"

		$scope.startTournament = () ->
			$scope.startedTournament = true
			socket.emit 'start tournament', $scope.competitors

		$scope.startRound = () ->
			$scope.roundUnderway = true
			socket.emit 'start round'

		$scope.addCompetitor = () ->
			$scope.competitors.push
				name: 'Name'
				endpoint: "http://localhost:3000"

		$scope.removeCompetitor = (index) ->
			$scope.competitors.splice index, 1

		bracketYGap = 60
		bracketXGap = 175
		leftBuffer = 0
		topBuffer = 0

		$scope.getWinnersBracketStyle = () ->
			{'height': getWinnersBracketHeight() + 'px'}

		getWinnersBracketHeight = () ->
			maxY = 0
			for game in $scope.winnersBracket
				maxY = game.y if game.y > maxY
			return getWinnerStyleHelper(0, maxY).y + bracketYGap

		getWinnerStyleHelper = (x, y) ->
			left = leftBuffer + bracketXGap * x
			if x is 0
				top = topBuffer + bracketYGap * y
			else
				top1 = getWinnerStyleHelper(x - 1, 2 * y).y
				top2 = getWinnerStyleHelper(x - 1, 2 * y + 1).y
				top = (top1 + top2) / 2
			return {
				x: left
				y: top
			}
			
		getLoserStyleHelper = (x, y) ->
			left = leftBuffer + bracketXGap * (x + 1)
			if x <= 1
				top = bracketYGap * y
			else if x % 2 == 0 && losersGameExists(x - 1, 2 * y + 1)
				top1 = getLoserStyleHelper(x - 1, 2 * y).y
				top2 = getLoserStyleHelper(x - 1, 2 * y + 1).y
				top = (top1 + top2) / 2
			else top = getLoserStyleHelper(x - 1, y).y
			return {
				x: left
				y: top
			}

		losersGameExists = (x, y) ->
			for game in $scope.losersBracket
				return true if game.x is x and game.y is y
			return false

		$scope.getWinnerStyle = (x, y) ->
			pos = getWinnerStyleHelper(x, y)
			getStyle(pos.x, pos.y)
			
		$scope.getLoserStyle = (x, y) ->
			pos = getLoserStyleHelper(x, y)
			getStyle(pos.x, pos.y)

		getStyle = (x, y) ->
			{'left': x + 'px', 'top': y + 'px'}

		roundOver = () ->
			$scope.roundUnderway = false
			$scope.$apply()

		receivedUpdate = (scoreboard) ->
			$scope.winnersBracket = scoreboard.winnersBracket
			$scope.losersBracket = scoreboard.losersBracket
			$scope.$apply()

		tournamentOver = (results) ->
			$scope.results = results
			$scope.$apply()

		socket.on 'scoreboard', receivedUpdate
		socket.on 'round over', roundOver
		socket.on 'results', tournamentOver

angular.module('app').controller 'tournamentController', ['$scope', 'socket', TournamentController]