define [
	"underscore"
	"gsap"
	"js/handler/AppSyncHandler"
	"js/viewcontroller/ChannelViewController"
	], (_, TweenLite, AppSyncHandler, ChannelViewController) ->
	Backbone.View.extend
		el: "#main"
		events: 
			"click .icon-open-dual-view-container": "openDualView"
			"click .icon-close-dual-view-container": "closeDualView"
		initialize: ->
			Backbone.on("resized-window", @onResize, @)
			Backbone.on( 'open/viewcontroller', @open, @)

			@$appView1 = @$el.find("#app-view-controller-1 .app-content-container")
			@$appView2 = @$el.find("#app-view-controller-2 .app-content-container")
			@channelVC = new ChannelViewController()

		open: (options) ->
			type = options.type
			# Clear states 
			swipy.collections.channels.clearActiveMenu()
			swipy.collections.apps.clearActiveMenu()
			swipy.topbar1.reset()
			swipy.topbar2.reset()
			@$appView1.html("")
			@$appView2.html("")
			@noSecondApp = false
			if type is "app"
				@app2 = null
				@app1 = swipy.collections.apps.findWhere({manifest_id: options.app_id})
				if @app1
					@app1.set("is_active_menu", true)
					@loadApp(@app1.toJSON(), options, 1)
					@noSecondApp = true

			else if type is "channel" or type is "im"
				@app1 = swipy.collections.apps.findWhere({manifest_id: options.app_id})

				@app1.set("is_active_menu", true)
				@loadApp(@app1.toJSON(), options, 1)
				#@loadChat(type, options.channel_id, 1)
				@noSecondApp = true


			@determineSplitscreen()

			swipy.activeId = options.app_id if options?.app_id
			swipy.activeId = options.channel_id if options?.channel_id

			activeMenuDet = type
			if type is "im"
				activeMenuDet = "member"
			activeMenu = "sidebar-"+activeMenuDet + "-" + swipy.activeId if swipy.activeId?

			Backbone.trigger("set-active-menu", activeMenu)


		loadChat: (type, channel_id, number) ->
			number = 1 if !number or number isnt 2
			@channelVC.open(type, {id: channel_id}, number)
		loadApp:(app, options, number) ->
			number = 1 if !number or number isnt 2
			syncHandler = new AppSyncHandler()
			syncHandler.setTopbar(swipy["topbar"+number])

			@["api"+number]?.destroy()

			apiRef = swipy.api.copyConnector()
			

			@["api"+number] = apiRef
			appView = @["$appView" + number]

			# Set the file identifier for loading files as text (manual parse)
			apiUrl = apiRef.getBaseURL()
			manifestId = app.manifest_id
			apiRef.setAppId(manifestId)

			initObj = {
				type: "init",
				data: {
					manifest: app,
					token: localStorage.getItem('swipy-token'),
					target_url: document.location.protocol + "//" + document.location.host,
					user_id: swipy.collections.users.me().id
				}
			};
			if options.channel_id
				if options.type is "channel"
					channel = swipy.collections.channels.findWhere({"name": options.channel_id})
				if options.type is "im"
					user = swipy.collections.users.findWhere({name: options.channel_id})
					channel = swipy.collections.channels.findWhere({type: "direct", user_id: user.id})
				initObj.data.default_scope = channel.id
				initObj.data.channel_id = channel.id
				url = app.channel_view_url
			else
				url = app.main_app_url

			$iframe = $("<iframe src=\"" + url + "\" class=\"app-frame-class\" frameborder=\"0\">")
			appView.html($iframe)

			syncHandler.topbar.setTitle(app.name);
			doc = $iframe[0].contentWindow
			apiRef.setListener(doc, apiUrl)

			$iframe.on("load", =>
				apiRef.callListener("event", initObj);
			)
			

			if number > 1
				syncHandler.setIsSecondaryApp(true)

			apiRef.setDelegate(syncHandler)

		openDualView: ->
			@dualView = true
			@determineSplitscreen()
		closeDualView: ->
			@dualView = false
			@determineSplitscreen()
		determineSplitscreen: ->
			# Determine whether or not it CAN split, Assume that it can
			canSplit = true
			# Can't split if too little width of container
			if @$el.outerWidth() < 1000
				canSplit = false
			# Can't split if there is no secondary app available
			if @noSecondApp
				canSplit = false

			# Determine whether or not it IS splitted, assume that it is, unless it can't
			isSplit = canSplit

			# Won't split If the dual view isn't open
			if !@dualView
				isSplit = false

			@isDualScreen = isSplit

			# Hide the button for splitting if it can't split or already is splitted
			@$el.find(".icon-open-dual-view-container").toggleClass("hidden", (isSplit or !canSplit))
			# Activate the split view
			@$el.toggleClass("dual-apps", isSplit)

			# Hide second view controller if it isn't splitted
			@$el.find("#app-view-controller-2").toggleClass("hidden", !isSplit)
		onResize: ->
			@determineSplitscreen()
		destroy: ->
			Backbone.off(null, null, @)
			console.log("destroying app view controller")
