CrossSpawn = require 'cross-spawn'
Proc = require 'child_process'
Logger = require './logger'
Q = require "q"

class ShellCommandRunner
	execute: (command, args, competitorName) ->
		deferred = Q.defer()
		spawn = Proc.spawn
		child = spawn command, args
		child.stdout.setEncoding 'utf8'
		child.stdout.on 'data', (data) -> Logger.competitorLog competitorName, data
		child.stderr.on 'data', (data) -> Logger.competitorLogError competitorName, data
		child.on 'close', (err) ->
			if (err) then deferred.reject err
			deferred.resolve()
		deferred.promise

	spawn: (command, args, competitorName) ->
		deferred = Q.defer()
		child = CrossSpawn command, args
		child.stdout.setEncoding 'utf8'
		child.stdout.on 'data', (data) -> Logger.competitorLog competitorName, data
		child.stderr.on 'data', (data) -> Logger.competitorLogError competitorName, data
		child.on 'close', ->
			Logger.competitorLog competitorName, 'Process closed...'
			deferred.reject()
		setTimeout (-> deferred.resolve()), 1000
		deferred.promise

module.exports = new ShellCommandRunner()