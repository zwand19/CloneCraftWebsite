Config = require "../config.json"
NodeMailer = require "nodemailer"
Logger = require "./logger"
Q = require "q"

# ****************************
# Constants
# ****************************
codewarsEmail = "geneca.codewars@gmail.com"
contributorsEmail = "zack.wand@geneca.com, jack.morrissey@geneca.com, mike.reyes@geneca.com"

class EmailService
	#---------------
	# Public Methods
	#---------------
	sendConfirmationEmail: (competitor) ->
		targets = "#{codewarsEmail}, #{competitor.email}"
		subject = "CloneCraft Confirmation"
		text = "Your account is confirmed! You can now upload your bot!"
		html = "<h2>Your account is confirmed!</h2><div>You can now upload your bot!</div>"
		sendEmail targets, subject, text, html, []

	sendRegistrationEmail: (confirmationStr, email) ->
		confirmationUrl = Config.confirmation_base_url + confirmationStr
		targets = "#{codewarsEmail}, #{email}"
		subject = "CloneCraft Registration"
		text = "Thanks for registering for Clonecraft. Please use the following url to confirm your email: #{confirmationUrl}."
		html = "<h2>Thanks for registering for CloneCraft</h2><div>
				Please use the following url to confirm your email: <a href=#{confirmationUrl}>#{confirmationUrl}</a></div>"
		sendEmail targets, subject, text, html, []

	#---------------
	# Private Methods
	#---------------
	createSmtpTransport = () ->
		NodeMailer.createTransport "Gmail",
			greetingTimeout: 4000
			connectionTimeout: 4000
			auth:
				user: Config.gmail_user_name
				pass: Config.gmail_password

	createMessage = (targets, subject, text, html, attachments) ->
		from: Config.emails_sender
		to: targets
		subject: subject
		text: text
		html: html
		attachments: attachments

	sendEmail = (targets, subject, text, html, attachments) ->
		Logger.info "sending email to #{targets}", html
		transport = createSmtpTransport()
		msg = createMessage(targets, subject, text, html, attachments)
		Q.nfcall(transport.sendMail, msg)

module.exports = new EmailService()