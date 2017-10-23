class UploadController
	constructor: ($scope, $http, authService) ->
		$scope.uploading = false
		$scope.loggedIn = authService.isLoggedIn()

		$scope.upload = ->
			$scope.uploading = true
			file = document.getElementById('code').files[0]
			fd = new FormData(file)
			fd.append('code', file)
			try
				headers = authService.getAuthHeader()
			catch
				return alert "You must be logged in to upload code"
			headers['Content-Type'] = undefined
			$http.post('/upload', fd,
					transformRequest: angular.identity
					headers: headers
				)
				.success((result) ->
					$scope.uploading = false
					if result.success
						alert 'Code uploaded!'
					else alert result.msg
				)
				.error((error, code) ->
					$scope.uploading = false
					if code is 401
						alert 'Invalid Session Token. Please try logging out and back in'
					else alert 'Server Error'
				)

		authService.onLoggedIn ->
			$scope.loggedIn = true

		authService.onLoggedOut ->
			$scope.loggedIn = false

angular.module('app').controller 'uploadController', ['$scope', '$http', 'authService', UploadController]