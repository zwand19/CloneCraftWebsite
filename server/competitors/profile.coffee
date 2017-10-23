Mongo = require '../utilities/mongoClient'
Logger = require '../utilities/logger'
Messaging = require '../messaging'

class Profile
	#---------------
	# Public Methods
	#---------------
	updateProfile: (username, data) ->
		Mongo.findAndModifyCompetitor({name: username}, { $set: { blurb: data.blurb } })
		.then (competitor) ->
			if not competitor
				Logger.error "Could not find competitor #{username} in db to update profile"
				throw new Error Messaging.Update.CompetitorNotFound
		.catch (err) ->
			Logger.error "DB ERROR: could not get competitor #{username} to update profile"
			Logger.error err
			throw err

	#----------------
	# Private Methods
	#----------------

module.exports = new Profile()