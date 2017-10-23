class DocsController
	constructor: ($scope) ->
		$scope.currentMenu = "overview"
		$scope.currentDoc = "overview"
		$scope.currentSubmenu = ""
		$scope.submenus = [
				# Overview
				title: "Game Basics"
				description: "How a single game works"
				parent: "overview"
				view: "basics"
			,
				title: "The Game Board"
				description: "Where the action happens"
				parent: "overview"
				view: "board"
			,
				title: "The Base"
				description: "Your base starts with 120 health"
				parent: "overview"
				view: "base"
			,
				title: "The Tournament"
				description: "Overview of the competition"
				parent: "overview"
				view: "tournament"
			,
				title: "Random Info"
				description: "FAQ and pro tips"
				parent: "overview"
				view: "tips"
			,	# End Overview

				# Minions
				title: "Minions"
				description: "These guys do your bidding"
				parent: "minions"
				view: "overview"
			,
				title: "Stats"
				description: "Beefing up your minions"
				parent: "minions"
				view: "stats"
			,
				title: "Movement"
				description: "Getting around the map"
				parent: "minions"
				view: "movement"
			,
				title: "Attacking"
				description: "Inflicting damage on minions and bases"
				parent: "minions"
				view: "attacking"
			,
				title: "Mining"
				description: "Getting more gold"
				parent: "minions"
				view: "mining"
			,
				title: "Handing Off Gold"
				description: "Passing the buck"
				parent: "minions"
				view: "handing"
			,
				title: "Graphics"
				description: "Icons used in game visuals"
				parent: "minions"
				view: "graphics"
			,	# End Minions

				# Playing
				title: "Playing The Game"
				description: "Learn to play"
				parent: "playing"
				view: "overview"
			,
				title: "Main Screen"
				description: "Your home view"
				parent: "playing"
				view: "main"
			,
				title: "Action Panels"
				description: "Triggering actions on objects"
				parent: "playing"
				view: "panels"
			,
				title: "Settings Panel"
				description: "Controlling game visualizations"
				parent: "playing"
				view: "settings"
			,	# End Playing

				# Building an AI
				title: "Starting Package"
				description: "What's in the box?"
				parent: "building"
				view: "package"
			,
				title: "API"
				description: "The interface"
				parent: "building"
				view: "api"
			,
				title: "Game Status Object"
				description: "Checking status after each round"
				parent: "building"
				view: "status"
			,
				title: "Testing Your AI"
				description: "Seeing how well you do"
				parent: "building"
				view: "testing"
			,
				title: "Submitting Your AI"
				description: "As an entrant in the competition"
				parent: "building"
				view: "submitting"
			,	# End Building

				# Commands
				title: "Command Object"
				description: "Actions your base and minions can do"
				parent: "commands"
				view: "object"
			,
				title: "Attack Command"
				description: "Attack other minions or bases"
				parent: "commands"
				view: "attack"
			,
				title: "Build Command"
				description: "Make moar minions!"
				parent: "commands"
				view: "build"
			,
				title: "Hand Off Command"
				description: "Take this and run!"
				parent: "commands"
				view: "hand"
			,
				title: "Mine Command"
				description: "Get some gold"
				parent: "commands"
				view: "mine"
			,
				title: "Move Command"
				description: "Get around the board"
				parent: "commands"
				view: "move"
			]

		$scope.showView = (submenu) ->
			$scope.currentSubmenu = submenu.title
			$scope.currentDoc = submenu.parent + "-" + submenu.view

		$scope.showMenu = (menu) ->
			$scope.currentMenu = menu
			$scope.showView(firstSubmenu(menu))

		$scope.showBoard = () ->
			$scope.currentDoc = 'board'
			
		$scope.showUI = () ->
			$scope.currentDoc = 'ui'

		$scope.showStatus = () ->
			$scope.currentDoc = 'status'

		$scope.showTesting = () ->
			$scope.currentDoc = 'testing'

		$scope.showSubmitting = () ->
			$scope.currentDoc = 'submitting'

		firstSubmenu = (menuName) ->
			for sub in $scope.submenus
				return sub if sub.parent == menuName
			return null

		$scope.showMenu('overview')

angular.module('app').controller 'docsController', ['$scope', DocsController]