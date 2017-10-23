FS = require 'fs-extra'
Logger = require './utilities/logger'
Mkdirp = require 'mkdirp'
Ncp = require('ncp').ncp
Path = require 'path'
Q = require 'q'

Helpers =
	copyDirectoryRecursively: (source, target) ->
		deferred = Q.defer()
		Ncp source, target, (err) ->
			if err
				Logger.error "Could not copy directory recurively from #{source} to #{target}"
				Logger.error err
				deferred.reject err
			else deferred.resolve()
		deferred.promise

	# replace all 'x' in a string with a random char and 'y' with the variant of the UUID
	createRandomString: (template) ->
		return template.replace /[xy]/g, (c) ->
			r = Math.random()*16|0
			if c is 'x'
				r.toString 16
			else (r&0x3|0x8).toString 16

	# return the distance between 2 (x,y) coords
	distanceBetween: (cell1, cell2) ->
		return Math.abs(cell1.x - cell2.x) + Math.abs(cell1.y - cell2.y)

	# ensures that a list of directories exists, creating them if they do not
	ensureDirectories: (directories) ->
		for dir in directories
			dirPath = Path.join __dirname, '../', dir
			FS.ensureDir dirPath, (err) ->
				if err
					Logger.error "Could not create directory #{dirPath} on startup"
					Logger.error err

	# returns the number of minutes between now and a date
	getAgeInMinutes: (date) ->
		msNow = (new Date()).getTime()
		msOld = date.getTime()
		minutesApart = Math.round((msNow - msOld) / (60 * 1000))
		minutesApart

	# get the YYYY/MM/DD string of current date
	getDateStamp: () ->
		now = new Date() 
		year = now.getFullYear()
		month = now.getMonth()+1 
		day = now.getDate()
		if month.toString().length is 1
			month = "0#{month}"
		if day.toString().length is 1
			day = "0#{day}"
		dateTime = "#{year}/#{month}/#{day}"
		return dateTime

	# takes in a number and returns a string in ordinal form
	# e.g. 1 -> 1st, 2 -> 2nd, 3 -> 3rd etc...
	getOrdinal: (n) ->
		if parseFloat(n) is parseInt(n) and !isNaN(n)
			s = ["th","st","nd","rd"]
			v = n%100
			n += s[(v-20)%10]||s[v]||s[0]
		return n

	# get Oct 4th 2014 from 2014/10/04
	getStringFromDateStamp: (stamp) ->
		if not stamp or not stamp.substring then return ''
		year = parseInt stamp.substring 0, 4
		month = parseInt stamp.substring 5, 7
		date = parseInt stamp.substring 8, 10
		date = @getOrdinal date
		months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
		month = months[month - 1]
		"#{month} #{date} #{year}"

	# get YYYY/MM/DD HH/MM/SS string of current time
	getTimeStamp: () ->
		now = new Date() 
		year = now.getFullYear()
		month = now.getMonth()+1 
		day = now.getDate()
		hour = now.getHours()
		minute = now.getMinutes()
		second = now.getSeconds() 
		if month.toString().length is 1
			month = '0'+month
		if day.toString().length is 1
			day = '0'+day
		if hour.toString().length is 1
			hour = '0'+hour
		if minute.toString().length is 1
			minute = '0'+minute
		if second.toString().length is 1
			second = '0'+second
		"#{year}/#{month}/#{day} #{hour}:#{minute}:#{second}"

	makeDirectoryRecursively: (dir) ->
		deferred = Q.defer()
		Mkdirp dir, (err) ->
			if err
				Logger.error "Could not make directory recurively: #{dir}"
				Logger.error err
				deferred.reject err
			else deferred.resolve dir
		deferred.promise

	randomElement: (arr) ->
		arr[Math.floor Math.random() * arr.length]

	promisedData: (data) ->
		deferred = Q.defer()
		process.nextTick () ->
			deferred.resolve data
		deferred.promise

	promisedError: (err) ->
		deferred = Q.defer()
		process.nextTick () ->
			deferred.reject err
		deferred.promise

	sortTournamentsDescending: (a, b) ->
		yearA = parseInt a.date.substring 0, 4
		monthA = parseInt a.date.substring 5, 7
		dateA = parseInt a.date.substring 8, 10
		yearB = parseInt b.date.substring 0, 4
		monthB = parseInt b.date.substring 5, 7
		dateB = parseInt b.date.substring 8, 10
		return 10000 * (yearB - yearA) + 100 * (monthB - monthA) + dateB - dateA

	# writes contents to a txt file and returns the path (without extension) on finish
	writeToTextFile: (path, contents) ->
		Q.nfcall(FS.writeFile, "#{path}.txt", contents)
		.then () ->
			path

	writeToClonecraftFile: (path, contents) ->
		Q.nfcall(FS.writeFile, "#{path}.clonecraft", contents)
		.then () ->
			path
		
module.exports = Helpers