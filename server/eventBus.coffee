events = require 'events'

class EventBus
	constructor: () ->
		@eventEmitter = new events.EventEmitter()

	publish: (eventName, data) ->
		@eventEmitter.emit eventName, data

	removeAll: (eventName) ->
		@eventEmitter.removeAllListeners eventName

	subscribe: (eventName, func) ->
		@eventEmitter.on eventName, func

	unsubscribe: (eventName, func) ->
		@eventEmitter.removeListener eventName, func

module.exports = new EventBus()