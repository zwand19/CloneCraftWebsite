class GameController
	constructor: ($scope, gameService, authService, socket, $routeParams) ->
		#----------
		# Variables
		#----------
		attackFlashLength = .5
		firstUpdate = true

		$scope.buildingStats = {}
		$scope.cells = []
		$scope.gameFile = ''
		$scope.loadedGameStatuses = []
		$scope.loadedStatusIndex =  0
		$scope.panel =
			title: "CloneCraft"
		$scope.playingGame = false # true if not on main screen
		$scope.runningAIs = false # true if running two non-human teams play
		$scope.runningGame = false # true if running a loaded game
		$scope.team1 =
			base: {}
			minions: []
			name: ''
			type: ''
			port: ''
		$scope.team2 =
			base: {}
			minions: []
			name: ''
			type: ''
			port: ''
		$scope.selectedObject =
			id: null
		$scope.selectedType = null
		$scope.selectedEnemy = false
		$scope.settings =
			cellSize: 20
			showFogOfWar: true
			showCompass: true
			watchSpeed: 700
		$scope.showBoard = false
		$scope.status = {}
		$scope.waitingOnServer = false
		$scope.watchingGame = false
		$scope.winner = null

		$scope.currentTeam = $scope.team1
		$scope.otherTeam = $scope.team2

		#----------------
		# Scope Functions
		#----------------

		document.getElementById('splash-screen').addEventListener('webkitTransitionEnd', hideBoard, false)
		document.getElementById('splash-screen').addEventListener('transitionend', hideBoard, false)
		document.getElementById('splash-screen').addEventListener('oTransitionEnd', hideBoard, false)

		$scope.attack = (minionId) ->
			gameService.attack minionId, $scope.selectedObject, $scope.currentTeam, $scope.settings.showFogOfWar

		$scope.buildMinion = (x, y) ->
			gameService.buildMinion x, y, $scope.buildingStats, $scope.settings.showFogOfWar

		$scope.cellClicked = (x, y) ->
			if not $scope.buildingStats.building
				$scope.clearSelected()
				return
			$scope.buildMinion(x, y)
			$scope.buildingStats.building = false
			$scope.clearSelected()

		$scope.changedFogOfWar = ->
			return if $scope.watchingGame
			# set timeout because showFogOfWar wasn't updated properly
			setTimeout getStatus, 1

		$scope.clearSelected = ->
			$scope.selectedObject = { id: null }
			$scope.selectedType = null
			$scope.selectedEnemy = false
			$scope.panel = { title: "CloneCraft" }
			$scope.buildingStats =
				building: false
				d: 1
				m: 1
				r: 1
				s: 1
				h: 1
				v: 1

		$scope.continue = ->
			return false if $scope.waitingOnServer
			$scope.waitingOnServer = true
			emitContinue()
			
		$scope.continueWatching = ->
			$scope.loadedStatusIndex++
			if $scope.loadedStatusIndex < $scope.loadedGameStatuses.length
				updateStatus $scope.loadedGameStatuses[$scope.loadedStatusIndex]

		$scope.createGame = ->
			return false if $scope.waitingOnServer
			if $scope.team1.name is $scope.team2.name
				return alert 'Team names must be unique.'
			ais = []
			firstUpdate = true
			if $scope.team1.type is 'ai' then ais.push $scope.team1.port
			if $scope.team2.type is 'ai' then ais.push $scope.team2.port
			if ais.length
				gameService.pingAIs ais, aiNotPinged, emitCreateGame
			else emitCreateGame()

		$scope.endTurn = ->
			return false if $scope.waitingOnServer
			$scope.waitingOnServer = true
			socket.emit 'turn over', $scope.settings.showFogOfWar

		$scope.fileChanged = (element) ->
			$scope.gameFile = element.files[0]

		$scope.handoff = (minionId) ->
			gameService.handOff minionId, $scope.selectedObject, $scope.settings.showFogOfWar

		$scope.initializeTeam1 = ->
			if authService.isLoggedIn()
				$scope.team1.type = "submitted"
			else $scope.team1.type = "human"

		$scope.loadGame = ->
			return false if $scope.waitingOnServer
			$scope.waitingOnServer = true
			firstUpdate = true
			reader = new FileReader()
			reader.onload = (e) ->
				try
					loadedGame = JSON.parse e.target.result
					$scope.loadedGameStatuses = loadedGame.statuses
					gameCreated()
					$scope.watchingGame = true
					$scope.waitingOnServer = false
					updateStatus $scope.loadedGameStatuses[0]
					$scope.$apply()
				catch e
					invalidFile()
			reader.readAsText($scope.gameFile)

		$scope.isLoggedIn = ->
			authService.isLoggedIn()

		$scope.mine = (minionId) ->
			gameService.mine minionId, $scope.selectedObject, $scope.settings.showFogOfWar

		$scope.moveMinion = (direction) ->
			gameService.moveMinion direction, $scope.selectedObject, $scope.settings.showFogOfWar

		$scope.quit = ->
			$scope.playingGame = false
			$scope.runningGame = false
			socket.emit 'end game'

		$scope.resetGame = ->
			emitCreateGame()

		$scope.runGame = ->
			$scope.runningGame = true
			watchGame()

		#find the object we selected by its id and set our flags appropriately
		$scope.selectObject = (id, e) ->
			selectFunction = (title, watchingTitle, object, type, enemy) ->
				$scope.panel.title = title
				$scope.panel.title = watchingTitle if $scope.watchingGame
				$scope.selectedObject = angular.copy object
				$scope.selectedType = type
				$scope.selectedEnemy = enemy

			e.stopPropagation()
			if $scope.currentTeam.base.id is id
				return selectFunction "Your Base", "Base", $scope.currentTeam.base, "base", false
			if $scope.otherTeam.base isnt null and $scope.otherTeam.base.id is id
				return selectFunction "Enemy Base", "Base", $scope.otherTeam.base, "base", true
			for resource in $scope.status.resources
				if resource.id is id
					return selectFunction "Resource", "Resource", resource, "resource", false
			for minion in $scope.currentTeam.minions
				if minion.id is id
					return selectFunction "Minion #{id}", "Minion #{id}", minion, "minion", false
			for minion in $scope.otherTeam.minions
				if minion.id is id
					return selectFunction "Enemy Minion #{id}", "Minion #{id}", minion, "minion", true

		$scope.setFoggyAttackRange = ->
			boardCellFunction (x, y) ->
				dist = Math.abs($scope.selectedObject.x - x) + Math.abs($scope.selectedObject.y - y)
				red = 0 < dist <= $scope.selectedObject.r
				setCellClass $scope.cells[y][x], undefined, red

		$scope.setFoggyOneRange = ->
			boardCellFunction (x, y) ->
				dist = Math.abs($scope.selectedObject.x - x) + Math.abs($scope.selectedObject.y - y)
				gold = dist is 1
				setCellClass($scope.cells[y][x], undefined, undefined, undefined, gold)

		$scope.setFoggyBaseRange = ->
			boardCellFunction (x, y) ->
				base = $scope.currentTeam.base
				cyan = getDistFromBase(base, x, y) is 1
				setCellClass($scope.cells[y][x], undefined, undefined, cyan)
			for minion in $scope.currentTeam.minions
				if minion.x > 0
					setCellClass $scope.cells[minion.y][minion.x-1], false, undefined, true
				if minion.x < $scope.status.board.w - 1
					setCellClass $scope.cells[minion.y][minion.x+1], false, undefined, true
				if minion.y > 0
					setCellClass $scope.cells[minion.y-1][minion.x], false, undefined, true
				if minion.y < $scope.status.board.h - 1
					setCellClass $scope.cells[minion.y+1][minion.x], false, undefined, true

		$scope.setFoggyCells = ->
			boardCellFunction (x, y) ->
				foggy = true
				for minion in $scope.currentTeam.minions
					dist = Math.abs(minion.x - x) + Math.abs(minion.y - y)
					foggy = false if dist <= minion.vi
				base = $scope.currentTeam.base
				foggy = false if getDistFromBase(base, x, y) <= base.ui.v
				foggy = false if not $scope.settings.showFogOfWar
				foggy = false if $scope.watchingGame
				setCellClass($scope.cells[y][x], foggy)

		$scope.stopGame = ->
			$scope.runningGame = false
			$scope.runningAIs = false

		$scope.team1Changed = ->
			$scope.team1.name = 'T1 Current King' if $scope.team1.type is 'king'
			$scope.team1.name = "T1 AI Port #{$scope.team1.port}" if $scope.team1.type is 'ai'
			$scope.team1.name = 'T1 Human' if $scope.team1.type is 'human'
			$scope.team1.name = 'T1 Submitted AI' if $scope.team1.type is 'submitted'
			
		$scope.team2Changed = ->
			$scope.team2.name = 'T2 Current King' if $scope.team2.type is 'king'
			$scope.team2.name = "T2 AI Port #{$scope.team2.port}" if $scope.team2.type is 'ai'
			$scope.team2.name = 'T2 Human' if $scope.team2.type is 'human'
			$scope.team2.name = 'T2 Submitted AI' if $scope.team2.type is 'submitted'

		$scope.watchAIs = ->
			$scope.runningAIs = true
			$scope.settings.showFogOfWar = false
			emitContinue()

		#---------------
		# Event Handlers
		#---------------

		# Use arrow keys to move minion
		window.addEventListener "keydown", (e) ->
			return if not $scope.playingGame
			return if $scope.currentTeam.type isnt 'human' or $scope.selectedType isnt 'minion' or $scope.selectedObject.mr is 0
			e = e || window.event
			$scope.moveMinion 'W' if e.keyCode is 37
			$scope.moveMinion 'N' if e.keyCode is 38
			$scope.moveMinion 'E' if e.keyCode is 39
			$scope.moveMinion 'S' if e.keyCode is 40
			e.preventDefault()
					
		#------------------
		# Private Functions
		#------------------
		aiNotPinged = (address) ->
			$scope.waitingOnServer = false
			alert "Could not ping your ai #{address}. Make sure it is up and running on the correct port."
			$scope.$apply()

		# run a function on every cell of the board
		boardCellFunction = (f) ->
			for y in [0...$scope.status.board.h]
				for x in [0...$scope.status.board.w]
					f x, y

		commandFailed = ->
			alert 'You sent an invalid command to the server'

		copyBase = (teamInScope, base) ->
			teamInScope.base = base
			teamInScope.base.id = base.id
			teamInScope.base.cb = base.ui.cb

		copyTeam = (teamInScope, team) ->
			if team.type
				teamInScope.type = team.type
			teamInScope.name = team.name

		#takes updated minion data and sets the properties in the minion in scope
		#we can't copy the object because we lose the animations
		copyToMinionInScope = (minion, minionInScope) ->
			minionInScope.inNewStatus = true
			minionInScope.g = minion.g
			if minion.hp < minionInScope.hp
				flashAttacked "minion-#{minion.id}"
			minionInScope.hp = minion.hp
			minionInScope.x = minion.x
			minionInScope.y = minion.y
			minionInScope.ca = minion.ui.ca
			minionInScope.mr = minion.ui.mr
			if minion.id is $scope.selectedObject.id
				$scope.selectedObject = angular.copy minionInScope
				return true
			return false

		disconnected = ->
			reset()
			$scope.playingGame = false

		emitContinue = ->
			socket.emit 'continue', $scope.settings.showFogOfWar

		emitCreateGame = ->
			$scope.waitingOnServer = true
			teams = [
					name: $scope.team1.name
					type: $scope.team1.type
				,
					name: $scope.team2.name
					type: $scope.team2.type
			]
			$scope.waitingOnServer = true
			data =
				teams: teams
				showFog: $scope.settings.showFogOfWar
			if authService.isLoggedIn()
				data.authToken = authService.getAuthToken()
			socket.emit 'create game', data

		emitTurnOver = ->
			socket.emit 'turn over', $scope.settings.showFogOfWar

		flashAttacked = (elementId) ->
			element = document.getElementById elementId
			if element
				element.className = element.className.replace ' attack-flash', ''
				setTimeout ->
					element.className = element.className.replace ' attack-flash', ''
					element.className = element.className + ' attack-flash'
				, attackFlashLength

		gameCreated = ->
			reset()
			$scope.playingGame = true
			$scope.showBoard = true

		gameDestroyed = ->
			$scope.playingGame = false

		gameNotCreated = ->
			alert 'Server Error.. Could not create game'

		getDistFromBase = (base, x, y) ->
			baseDistX = 0
			baseDistX = base.x - x if x < base.x
			baseDistX = x - (base.x + base.ui.si - 1) if x >= base.x + base.ui.si
			baseDistY = 0
			baseDistY = base.y - y if y < base.y
			baseDistY = y - (base.y + base.ui.si - 1) if y >= base.y + base.ui.si
			baseDistX + baseDistY

		getStatus = ->
			socket.emit 'get status', $scope.settings.showFogOfWar

		hideBoard = ->
			$scope.$apply $scope.showBoard = false if not $scope.playingGame

		invalidFile = ->
			$scope.waitingOnServer = false
			alert 'invalid game file'

		loadedGameOver = (winner) ->
			$scope.waitingOnServer = false
			$scope.runningGame = false
			if winner != ''
				alert 'game over. winner: ' + winner
			else
				alert 'game over. draw.'

		noKing = ->
			alert 'No tournaments have been run, there is no current king!'
			$scope.waitingOnServer = false
			
		postToAI = (status) ->
			if status.ui.teams[0].currentTeam then port = $scope.team1.port else port = $scope.team2.port
			gameService.postToAI "http://localhost:#{port}/api/turn", status, receivedAIError, receivedAICommands

		receivedAICommands = (commands) ->
			try
				commands = JSON.parse commands
			catch
				alert 'Could not parse JSON response from your ai, executing empty command array'
				commands = []
			socket.emit 'execute commands',
				commands: commands
				showFog: $scope.settings.showFogOfWar

		receivedAIError = ->
			alert 'A request to your AI has failed'
			$scope.runningAIs = false
			$scope.$apply()
			emitTurnOver()

		removeOldMinions = (minions) ->
			minionCount = minions.length
			for i in [0...minionCount]
				# if we removed an element we will traverse past new length
				if i >= minions.length then return
				if not minions[i].inNewStatus
					minions.splice i, 1
					i--

		reset = ->
			firstUpdate = true
			$scope.clearSelected()
			$scope.watchingGame = false
			$scope.runningGame = false
			$scope.status =
				board:
					w:0
					h:0
				round: 1
				resources: []

		runningTournament = ->
			reset()
			$scope.playingGame = false
			alert 'Can not play the game while a tournament is running. Please come back later.'

		setCellClass = (cell, foggy, red, cyan, gold) ->
			if foggy is undefined
				cell.foggy = true
			else cell.foggy = foggy
			if red is undefined
				cell.red = false
			else cell.red = red
			if cyan is undefined
				cell.cyan = false
			else cell.cyan = cyan
			if gold is undefined
				cell.gold = false
			else cell.gold = gold

		tryStartGameFromParams = ->
			buildTeamFromParams = (type, name, port) ->
				if type is 'king' or type is 'submitted' or type is 'human'
					return {
						type: type
						name: name
						port: 3000
						base: {}
						minions: []
					}
				if type is 'ai'
					if not port then return null
					port = parseInt port
					return {
						type: type
						name: name
						port: port
						base: {}
						minions: []
					}
				return null
			if $routeParams.t1name then t1name = $routeParams.t1name else t1name = "t1#{$routeParams.t1type}"
			if $routeParams.t2name then t2name = $routeParams.t2name else t2name = "t2#{$routeParams.t2type}"
			team1 = buildTeamFromParams $routeParams.t1type, t1name, $routeParams.t1port
			team2 = buildTeamFromParams $routeParams.t2type, t2name, $routeParams.t2port
			if team1 and team2
				$scope.team1 = team1
				$scope.team2 = team2
				if $routeParams.fog is "false"
					$scope.settings.showFogOfWar = false
				if $routeParams.fog is "true"
					$scope.settings.showFogOfWar = true
				$scope.createGame()


		unauthorized = ->
			if authService.isLoggedIn()
				authService.logout()
				alert 'Could not start game. Session token has expired. Please try logging out and back in'
			else alert 'Could not start game. Must be logged in to play with a submitted AI'

		# need to lookup minions and update their properties instead of just setting new reference so we can see animations
		updateMinions = (oldMinions, newMinions) ->
			for minion in oldMinions
				minion.inNewStatus = false
			#update current team minions
			for minion in newMinions
				minionInScope = null
				for m in oldMinions
					minionInScope = m if minion.id is m.id
				if minionInScope is null
					oldMinions.push minion
					minion.ca = minion.ui.ca
					minion.mr = minion.ui.mr
					minion.inNewStatus = true
				else
					foundSelected = true if copyToMinionInScope(minion, minionInScope)
			foundSelected

		updateStatus = (response) ->
			if response.minions is undefined
				status = JSON.parse response
			else status = response
			$scope.winner = status.ui.winner
			copyTeam $scope.team1, status.ui.teams[0]
			copyTeam $scope.team2, status.ui.teams[1]
			if status.ui.teams[0].currentTeam
				$scope.currentTeam = $scope.team1
				$scope.otherTeam = $scope.team2
			else
				$scope.currentTeam = $scope.team2
				$scope.otherTeam = $scope.team1
			$scope.status.round = status.round
			# if it's our first update we can copy the status, otherwise we need to do updates
			if firstUpdate
				firstUpdate = false
				$scope.status.board = status.board
				$scope.currentTeam.minions = status.minions
				$scope.status.resources = status.vision.resources
				for minion in $scope.currentTeam.minions
					minion.ca = minion.ui.ca
					minion.mr = minion.ui.mr
				$scope.otherTeam.minions = status.vision.minions
				copyBase $scope.currentTeam, status.base
				if status.vision.bases.length is 0
					$scope.otherTeam.base = null
				else
					copyBase $scope.otherTeam, status.vision.bases[0]
				for minion in $scope.otherTeam.minions
					minion.ca = minion.ui.ca
					minion.mr = minion.ui.mr
				$scope.cells = []
				for y in [0...$scope.status.board.h]
					row = []
					$scope.cells.push row
					for x in [0...$scope.status.board.w]
						row.push { foggy: true, red: false, cyan: false, gold: false, x: x, y: y }
			else
				foundSelected = false
				
				# update current team
				if $scope.currentTeam.base and status.base.h < $scope.currentTeam.base.h
					if $scope.currentTeam is $scope.team1 then flashAttacked 'team-1-base' else flashAttacked 'team-2-base'
				copyBase $scope.currentTeam, status.base
				if status.base.id is $scope.selectedObject.id
					$scope.selectedObject = angular.copy status.base
					foundSelected = true

				# update other team base
				if status.vision.bases.length is 0
					$scope.otherTeam.base = null
				else
					if $scope.otherTeam.base and status.vision.bases[0].h < $scope.otherTeam.base.h
						if $scope.otherTeam is $scope.team1 then flashAttacked 'team-1-base' else flashAttacked 'team-2-base'
					copyBase $scope.otherTeam, status.vision.bases[0]
				if $scope.otherTeam.base and $scope.otherTeam.base.id is $scope.selectedObject.id
					$scope.selectedObject = angular.copy $scope.otherTeam.base
					foundSelected = true

				# update resources
				for resource in status.vision.resources
					found = false
					for oldResource in $scope.status.resources
						if resource.id is oldResource.id
							found = true
					if not found then $scope.status.resources.push resource
					if resource.id is $scope.selectedObject.id
						$scope.selectedObject = angular.copy resource
						foundSelected = true
				# delete resources no longer in vision
				resourceLength = $scope.status.resources.length
				for i in [0...resourceLength]
					if i >= $scope.status.resources.length then continue
					inNewStatus = false
					for newResource in status.vision.resources
						if $scope.status.resources[i].id is newResource.id then inNewStatus = true
					if not inNewStatus
						$scope.status.resources.splice i, 1
						i--

				# update minions
				foundSelected = updateMinions($scope.currentTeam.minions, status.minions) || foundSelected
				foundSelected = updateMinions($scope.otherTeam.minions, status.vision.minions) || foundSelected
				removeOldMinions $scope.currentTeam.minions
				removeOldMinions $scope.otherTeam.minions

				$scope.clearSelected() if not foundSelected

			$scope.setFoggyCells()
			if $scope.runningAIs
				if status.ui.finished
					$scope.runningAIs = false
				else
					setTimeout emitContinue, $scope.settings.watchSpeed

		watchGame = ->
			return if not $scope.watchingGame or not $scope.runningGame
			$scope.loadedStatusIndex++
			if $scope.loadedStatusIndex is $scope.loadedGameStatuses.length
				return $scope.stopGame()
			updateStatus $scope.loadedGameStatuses[$scope.loadedStatusIndex]
			setTimeout ->
				watchGame()
				$scope.$apply()
			, $scope.settings.watchSpeed


		socketCallback = (key, callback) ->
			socket.on key, (data) ->
				callback data
				$scope.waitingOnServer = false
				$scope.$apply()

		socketCallback 'disconnect', disconnected
		socketCallback 'failed command', commandFailed
		socketCallback 'game created', gameCreated
		socketCallback 'game destroyed', gameDestroyed
		socketCallback 'game not created', gameNotCreated
		socketCallback 'get ai commands', postToAI
		socketCallback 'no king', noKing
		socketCallback 'running tournament', runningTournament
		socketCallback 'status', updateStatus
		socketCallback 'unauthorized', unauthorized

		reset()

		# set timeout otherwise ng-init overrides scope changes
		setTimeout ->
			tryStartGameFromParams()
			$scope.$apply()
		, 1000

angular.module('app').controller 'gameController', ['$scope', 'gameService', 'authService', 'socket', '$routeParams', GameController]