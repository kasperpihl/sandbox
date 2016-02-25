###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "jquery", "js/utility/Utility"], (_, $, Utility) ->
	class AppSyncHandler
		constructor: ->
			@util = new Utility()
			@listeners = {}
			_.bindAll( @, "connectorHandleResponseReceivedFromListener" )
			Backbone.on("websocket_event", @onWebSocketEvent, @)
		setTopbar: (topbar) ->
			@topbar = topbar
		setIsSecondaryApp:(isSecondary) ->
			@isSecondary = false
			@isSecondary = true if isSecondary
		onWebSocketEvent:(data) ->
			if @listeners[data.type]
				@listeners[data.type].callListener("event", data)
		connectorHandleResponseReceivedFromListener: (connector, message, callback) ->
			if message and message.command
				data = message.data
				if message.command is "navigation.setTitle"
					@topbar.setTitle(data.title) if data.title
				else if message.command is "navigation.setBackgroundColor"
					@topbar.setBackgroundColor(data.color, @isSecondary)
				else if message.command is "navigation.setForegroundColor"
					@topbar.setForegroundColor(data.color, @isSecondary)
				else if message.command is "navigation.enableBoxShadow"
					@topbar.enableBoxShadow(data.enable)
				else if message.command is "getData"
					@performGetQuery(data.query, callback)
				else if message.command is "listenTo"
					@listeners[data.event] = connector
		performGetQuery: (query, callback) ->
			if query.table is "users"
				collection = swipy.collections.users
			else if query.table is "channels"
				collection = swipy.collections.channels
			else if query.table is "apps"
				collection = swipy.collections.apps
			return callback(false, "Query must include valid table") if !collection

			if query.id
				resModel = collection.get(query.id)
				if resModel then callback(resModel, false)
				else callback(false, "No model found")
				return
			console.log "collection", collection
			callback(collection.models)
		destroy: ->
			Backbone.off("websocket_event", null, @)
