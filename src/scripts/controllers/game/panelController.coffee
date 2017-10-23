class PanelController
	constructor: ($scope) ->
		$scope.attacking = false
		$scope.handing = false
		$scope.mining = false
		$scope.minionId = null
		$scope.showSettings = false
		openingSettings = false

		$scope.panelOpen = false

		$scope.beginAttack = () ->
			$scope.attacking = true
			$scope.minionId = $scope.selectedObject.id
			$scope.setFoggyAttackRange()

		$scope.cancel = () ->
			$scope.attacking = false
			$scope.handing = false
			$scope.mining = false
			$scope.minionId = null
			$scope.showSettings = false
			$scope.buildingStats.building = false
			$scope.setFoggyCells()

		$scope.beginMine = () ->
			$scope.mining = true
			$scope.minionId = $scope.selectedObject.id
			$scope.setFoggyOneRange()

		$scope.beginHandOff = () ->
			$scope.handing = true
			$scope.minionId = $scope.selectedObject.id
			$scope.setFoggyOneRange()

		$scope.beginBuild = () ->
			$scope.buildingStats.building = true
			$scope.setFoggyBaseRange()

		$scope.closePanel = () ->
			#setting the object to null doesn't update parent scope so we must do this
			$scope.selectedObject.id = null
			$scope.panel.title = "CloneCraft"
			$scope.panelOpen = false
			$scope.showSettings = false

		$scope.openPanel = () ->
			$scope.panelOpen = true
			$scope.showSettings = false

		$scope.openSettings = () ->
			$scope.clearSelected()
			$scope.openPanel()
			$scope.showSettings = true
			$scope.panel.title = "Settings Menu"
			openingSettings = true

		$scope.pauseAutoContinue = () ->
			$scope.settings.autoContinuing = false #inherits from main controller

		objectSelected = (newValue, oldValue) ->
			if $scope.attacking
				if $scope.selectedType is 'minion' or $scope.selectedType is 'base'
					$scope.attack($scope.minionId)
				$scope.cancel()
			if $scope.mining
				if $scope.selectedType is 'resource'
					$scope.mine($scope.minionId)
				$scope.cancel()
			if $scope.handing
				if $scope.selectedType is 'minion'
					$scope.handoff($scope.minionId)
				$scope.cancel()
				
			$scope.buildingStats.building = false
			$scope.setFoggyCells()
			$scope.showSettings = false if not openingSettings
			openingSettings = false

			if document.getElementById('minion-stats-panel') isnt null
				if $scope.selectedType is 'minion'
					document.getElementById('minion-stats-panel').style.visibility = ""
				else document.getElementById('minion-stats-panel').style.visibility = "hidden"

			$scope.openPanel() if $scope.selectedObject.id isnt null and not $scope.panelOpen
			$scope.closePanel() if $scope.selectedObject.id is null and $scope.panelOpen and not $scope.showSettings

		$scope.$watch('selectedObject', objectSelected)

angular.module('app').controller 'panelController', ['$scope', PanelController]