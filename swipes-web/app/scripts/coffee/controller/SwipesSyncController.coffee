###
	Everytime on save call saveToSync with objects

	saveToSync:
	sync:attributes:forIdentifier
	sync

###

define ["underscore", "jquery", "js/utility/Utility", "plugins/socket.io"], (_, $, Utility) ->
	class SwipesSyncController
		constructor: ->
			@token = localStorage.getItem("swipy-token")
			@baseURL = "http://" + document.location.hostname + ":5000/v1/"
			@util = new Utility()
			@currentIdCount = 0
			@sentMessages = {}

			_.bindAll(@, "onOpenedWindow")
			Backbone.on("opened-window", @onOpenedWindow, @)
		start: ->
			return if @isStarting?
			@isStarting = true
			@apiRequest("rtm.start", {simple_latest: false}, (data, error) =>
				@isStarting = null
				if data and data.ok
					@handleTeam(data.team) if data.team
					@handleSelf(data.self) if data.self
					@handleUsers(data.users) if data.users

					@_appsById = {}
					@handleApps(data.apps) if data.apps

					@_channelsById = {}
					
					@handleChannels(data.channels) if data.channels
					@handleChannels(data.groups) if data.groups
					@handleChannels(data.ims) if data.ims
					# Only enable threaded conversations for Swipes Team
					#if data.team.id is "T02A53ZUJ"
						# T_TODO disabling threds. There are still comments when you try to type from the edit view
						#localStorage.setItem("EnableThreadedConversations", true)
					@clearDeletedChannelsAndApps()
					@openWebSocket(data.url)
					localStorage.setItem("slackLastConnected", new Date())
					Backbone.trigger('slack-first-connected')
			)
		handleTeam: (team) ->
			collection = swipy.collections.teams
			model = collection.get(team.id)
			model = collection.create(team) if !model
			model.save(team)
		handleSelf:(self) ->
			collection = swipy.collections.users
			model = collection.get(self.id)
			model = collection.create(self) if !model
			model.set("me",true)
			model.save(self)
		handleUsers:(users) ->
			collection = swipy.collections.users
			for user in users
				model = collection.get(user.id)
				model = collection.create(user) if !model
				model.save(user)
		handleApps: (apps) ->
			collection = swipy.collections.apps
			for app in apps
				@_appsById[app.id] = app
				model = collection.get(app.id)
				model = collection.create(app) if !model
				model.save(app)
				if !app.is_starred
					model.save("is_starred", false)
		handleChannels: (channels) ->
			collection = swipy.collections.channels
			for channel in channels
				@_channelsById[channel.id] = channel

				model = collection.get(channel.id)
				model = collection.create(channel) if !model
				model.save(channel)
				if !channel.is_starred
					model.save("is_starred", false)

		clearDeletedChannelsAndApps: ->
			channelsToDelete = []
			appsToDelete = []
			for app in swipy.collections.apps.models
				if !@_appsById[app.id]
					appsToDelete.push app
			for app in appsToDelete
				swipy.collections.apps.remove(app)
				app.localStorage = swipy.collections.apps.localStorage
				app.destroy()
			for channel in swipy.collections.channels.models
				if !@_channelsById[channel.id]
					channelsToDelete.push(channel)
			for channel in channelsToDelete
				swipy.collections.channels.remove(channel)
				channel.localStorage = swipy.collections.channels.localStorage
				channel.destroy()
		handleReceivedMessage: (message, incrementUnread) ->
			channel = swipy.collections.channels.get(message.channel)
			channel.addMessage(message, incrementUnread)

		openWebSocket: (url) ->
			#@webSocket = new WebSocket(url)
			@webSocket = io.connect(urlbase, {query: 'token=' + @token});
			@webSocket.on('message', (data) =>
				console.log "message", data
				if data.type is "message"
					message = data.message
					channel = swipy.collections.channels.get(message.channel_id)
					channel.addMessage(message, true)
				else if data.type is "star_added" or data.type is "star_removed"
					if data.data.type is "channel" or data.data.type is "im" or data.data.type is "group"
						targetObj = swipy.collections.channels.get(data.data.id)
					else if data.data.type is "app"
						targetObj = swipy.collections.apps.get(data.data.id)
					targetObj.save("is_starred", (data.type is "star_added")) if targetObj
				else if data.type is "app_installed"
					targetObj = swipy.collections.apps.get(data.data.id)
					targetObj = swipy.collections.apps.create(data.data) if !targetObj
					targetObj.save(data.data)
				else if data.type is "app_uninstalled"
					targetObj = swipy.collections.apps.get(data.data.id)
					if targetObj
						swipy.collections.apps.remove(targetObj)
						targetObj.localStorage = swipy.collections.apps.localStorage
						targetObj.destroy()
				else if data.type is "app_activated"
					targetObj = swipy.collections.apps.get(data.data.app_id)
					if targetObj
						targetObj.save("is_active", true)
				Backbone.trigger("websocket_event", data)
			)

		doSocketSend: (message, dontSave) ->
			if _.isObject(message)
				message.id = ++@currentIdCount
				@sentMessages[""+message.id] = message if !dontSave
				message = JSON.stringify(message)
			@webSocket?.send(message)
		onOpenedWindow: ->
			if !@webSocket?
				@start()
		sendMessage:(message, channel, callback) ->
			self = @
			console.log channel
			options = {text: message, "channel_id": channel, "user_id":swipy.collections.users.me().id}
			@apiRequest("chat.send", options, (res, error) ->
				if res and res.ok
					console.log res if res.fuckyou
				callback?(res, error)
			)
		uploadFile: (channels, file, callback, initialComment) ->
			formData = new FormData()
			formData.append("token", @token)
			formData.append("channels", channels)
			formData.append("filename", file.name)
			formData.append("file", file);
			swipy.analytics.logEvent("[Engagement] Upload File Started", {})
			@apiRequest("files.upload", 'POST', {}, (res, error) ->
				if res and res.ok
					swipy.analytics.logEvent("[Engagement] Uploaded File", {} )
					swipy.analytics.sendEventToIntercom( 'Uploaded File', {} )
				callback?(res,error)
			, formData)

		apiRequest: (options, data, callback, formData) ->
			swipy.api.callSwipesApi(options, data, callback, formData)
