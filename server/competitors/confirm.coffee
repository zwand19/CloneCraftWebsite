Mongo = require '../utilities/mongoClient'
Logger = require '../utilities/logger'
MailService = require '../utilities/emailService'
Messaging = require '../messaging'

class Confirm
	confirm: (confirmationString) ->
		# confirm the competitor
		Mongo.findAndModifyCompetitor({ confirmation_string: confirmationString, confirmed: false }, { $set: { confirmed: true } })
		.then (competitor) ->
			if not competitor
				Logger.info "could not find unconfirmed user with confirmation string #{confirmationString}"
				throw new Error Messaging.Confirmation.NotFoundOrAlreadyConfirmed
			Logger.log "confirmed competitor #{competitor.name}. Sending email"
			MailService.sendConfirmationEmail(competitor)
			.then () ->
				return {
					uploadId: competitor.upload_id
					msg: ''
				}
			.catch (err) ->
				Logger.error "Could not send confirmation email to #{competitor.name}"
				Logger.error err
				return {
					uploadId: competitor.upload_id
					msg: Messaging.Confirmation.EmailNotSent
				}
						
module.exports = new Confirm()