class Routes
	constructor: ($routeProvider) ->
		$routeProvider
		.when '/',
			templateUrl: './public/views/splash.html'
		.when '/about',
			templateUrl: './public/views/about.html'
		.when '/warriors',
			templateUrl: './public/views/warriors.html'
		.when '/register',
			templateUrl: './public/views/register.html'
			controller: 'registerController'
		.when '/confirm/:id',
			templateUrl: './public/views/confirm.html'
			controller: 'confirmController'
		.when '/CloneCraft/docs',
			templateUrl: './public/views/docs.html'
			controller: 'docsController'
		.when '/CloneCraft/standings',
			templateUrl: './public/views/standings.html'
			controller: 'standingsController'
		.when '/CloneCraft/competitor/:name',
			templateUrl: './public/views/competitor.html'
			controller: 'competitorController'
		.when '/CloneCraft/game',
			templateUrl: './public/views/game/site.html'
			controller: 'gameController'
		.when '/CloneCraft/upload',
			templateUrl: './public/views/upload.html',
			controller: 'uploadController'
		.when '/CloneCraft',
			templateUrl: './public/views/getting-started.html'
			controller: 'gettingStartedController'
		.otherwise
			redirectTo: '/'

angular.module('app').config ['$routeProvider', Routes]