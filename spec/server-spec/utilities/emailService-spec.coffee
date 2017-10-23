Q = require "q"
NodeMailer = require "nodemailer"
Logger = require "../../../server/utilities/logger"
Emailer = require "../../../server/utilities/emailService"

describe "EmailService", ->
	#----------
	# Test Data
	#----------
	confirmationStr = "12345"
	email = "test@test.com"
	sendMailCalled = false
	
	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		sendMailCalled = false
		mockTransport =	sendMail: (msg, fn) -> 
			sendMailCalled = true
			fn(null, msg)
		spyOn(Logger, "info").andReturn()
		spyOn(Logger, "log").andReturn()
		spyOn(Logger, "error").andReturn()
		spyOn(NodeMailer, "createTransport").andReturn(mockTransport)
		# Note - checking if the mockTransport spy gets called always results in a timeout for some reason
		# spyOn(mockTransport, "sendMail").andCallThrough()
		
	#-----------
	# Unit Tests
	#-----------
	describe 'sendRegistrationEmail', ->
		it "calls createTransport method of NodeMailer when calling sendRegistrationEmail", (done) ->
			Emailer.sendRegistrationEmail(confirmationStr, email)
				.then (result) ->
					expect(NodeMailer.createTransport).toHaveBeenCalled()
					done()
				, (err) ->
					console.error err

		it "returns a message with text containing the word 'registering' when calling sendRegistrationEmail", (done) ->
			Emailer.sendRegistrationEmail(confirmationStr, email)
				.then (result) ->
					expect(result.text).toBeTruthy()
					expect(result.text).toContain("registering")
					done()
				, (err) ->
					console.error err

		it "returns a message with subject containing the word 'Registration' when calling sendRegistrationEmail", (done) ->
			Emailer.sendRegistrationEmail(confirmationStr, email)
				.then (result) ->
					expect(result.subject).toBeTruthy()
					expect(result.subject).toContain("Registration")
					done()
				, (err) ->
					console.error err

		it "calls transport.sendMail when calling sendRegistrationEmail", (done) ->
			expect(sendMailCalled).toBeFalsy()
			Emailer.sendRegistrationEmail(confirmationStr, email)
				.then (result) ->
					expect(sendMailCalled).toBeTruthy()
					done()
				, (err) ->
					console.error err