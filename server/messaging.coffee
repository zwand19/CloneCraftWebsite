Logger = require './utilities/logger'

# List of all messaging that is sent back to the client
Messaging =
	Confirmation:
		EmailNotSent: 'CLIENTERROR:Your account is confirmed but we could not send out the confirmation email with your competitor id. Please contact Zack Wand, Mike Reyes, or Jack Morrissey from the CodeWars team if you lose/forget this id'
		NotFoundOrAlreadyConfirmed: 'CLIENTERROR:Could not find an unconfirmed competitor with given confirmation string'
	handleErrorMessage: (msg) ->
		if msg and msg.substring and msg.indexOf and msg.indexOf('CLIENTERROR:') isnt -1 
			return msg.substring(12 + msg.indexOf 'CLIENTERROR:')
		if msg then Logger.error msg
		return 'Server Error'
	Registration:
		EmailExists: 'CLIENTERROR:A competitor already exists with that email'
		EmailNotSent : 'CLIENTERROR:ERROR: Competitor registered but confirmation email failed to send. Please contact Zack Wand, Mike Reyes, or Jack Morrissey from the CodeWars team'
		ApiUrl: 'CLIENTERROR:Invalid API URL, please see documentation'
		PasswordContainsSpace: 'CLIENTERROR:Passwords cannot contain spaces'
		PasswordInvalidCharacter: 'CLIENTERROR:Invalid character in password'
		PasswordLength: 'CLIENTERROR:Password must be 6-20 characters long'
		ProvideEmail: 'CLIENTERROR:Please provide an email'
		UploadIdNotUnique: 'CLIENTERROR:Unable to generate unique competitor id for you, please try again'
		UsernameContainsSpace: 'CLIENTERROR:Usernames cannot contain spaces'
		UsernameExists: 'CLIENTERROR:A competitor already exists with that username'
		UsernameInvalidCharacter: 'CLIENTERROR:Invalid character in username'
		UsernameLength: 'CLIENTERROR:Username must be 3-20 characters long'
		UsernameReserved: 'CLIENTERROR:Username is reserved'
	ServerError: 'CLIENTERROR:Server Error'
	Standings:
		CompetitorNotFound: 'CLIENTERROR:Could not find competitor with given name'
		TournamentNotFound: 'CLIENTERROR:Could not find tournament with given id'
	Update:
		CompetitorNotFound: 'CLIENTERROR:Could not find your profile in the database. Please try logging out and back in'
	Upload:
		AttachCode: 'CLIENTERROR:Please attach your code'
		BadUpload: 'CLIENTERROR:Upload failed. Could not make a request to your newly uploaded code. Please confirm you zipped up your project correctly.'
		ConfirmEmail: 'CLIENTERROR:You must confirm your email before you can upload'
		InvalidUser: 'CLIENTERROR:Invalid authentication token. Please try logging out and back in'
		NodeFailure: 'CLIENTERROR:Could not bounce your node server with new code. Make sure you uploaded the correct zip folder containing your server.js file'
		TournamentRunning: 'CLIENTERROR:Cannot upload code while a tournament is running. Please try again later.'
		
module.exports = Messaging