baseAPIURL = "http://" + document.location.hostname + ":5000"
apiConnectorUrl = baseAPIURL + "/apps/app-loader/swipes-api-connector.js"
define [
	"jquery"
	"underscore"
	"backbone"
	"localStorage"
	"collectionSubset"
	"js/viewcontroller/MainViewController"
	"js/router/MainRouter"
	"js/collection/Collections"
	"js/viewcontroller/ModalViewController"
	"js/viewcontroller/LeftSidebarViewController"
	"js/viewcontroller/TopbarViewController"
	"js/controller/SwipesSyncController"
	"js/controller/KeyboardController"
	"js/controller/BridgeController"
	"js/controller/SoundController"
	apiConnectorUrl
	"gsap"
	], ($, _, Backbone, BackLocal, ColSubset, MainViewController, MainRouter, Collections, ModalViewController, LeftSidebarViewController, TopbarViewController, SwipesSyncController, KeyboardController, BridgeController, SoundController) ->
	class Swipes
		UPDATE_INTERVAL: 30
		UPDATE_COUNT: 0
		handleQueryString:(queryString) ->
			clean = false
			if queryString and queryString.href
				@href = queryString.href
				if history.pushState
					newurl = window.location.protocol + "//" + window.location.host + window.location.pathname
					if window.location.hash
						newurl += window.location.hash
					window.history.pushState({path:newurl},'',newurl)

		constructor: ->
			##@tags.fetch()
			@isOpened = true
			_.bindAll(@, "openedWindow", "closedWindow")

			@api = new SwipesAPIConnector(baseAPIURL)
			@api.setToken(localStorage.getItem("swipy-token"))
			$(window).focus @openedWindow
			$(window).blur @closedWindow
			$(window).on( "resize", @resizedWindow )

		manualInit: ->
			#@hackParseAPI()
			# Base app data
			@collections = new Collections()

			@bridge = new BridgeController()


			# Synchronization
			
			@swipesSync = new SwipesSyncController()

			# Keyboard/Shortcut handler
			@shortcuts = new KeyboardController()


		start: ->
			@collections.fetchAll()
			@swipesSync.start()
			if localStorage.getItem("slackLastConnected")
				@init()
			else
				Backbone.once( "slack-first-connected", @init, @ )
				#Backbone.once( "sync-complete", @init, @ )
		init: ->
			@cleanUp()

			@leftSidebarVC = new LeftSidebarViewController()
			@topbar1 = new TopbarViewController({el:"#app-view-controller-1 .top-bar-container"})
			@topbar2 = new TopbarViewController({el:"#app-view-controller-2 .top-bar-container"})

			@modalVC = new ModalViewController()

			@mainViewController = new MainViewController()
			@router = new MainRouter()

			@sound = new SoundController()
			
			Backbone.history.start( pushState: no )
			$(".load-indicator").remove()


			$('.search-result a').click( (e) ->
				swipy.filter.clearFilters()
				Backbone.trigger( "remove-filter", "all" )
				return false
			)

			if @href
				switch @href
					when "keyboard" then @sidebar.showKeyboardShortcuts()

				@href = false

		cleanUp: ->
			#@stopAutoUpdate()
			##@tags?.destroy()
			@mainViewController?.destroy?()
			@router?.destroy?()

			@sound?.destroy?()
			@api?.destroy()

			# If we init multiple times, we need to make sure to stop the history between each.
			#if Parse.History.started then Parse.history.stop()
		resizedWindow: ->
			Backbone.trigger("resized-window")
		closedWindow: ->
			Backbone.trigger("closed-window")
			@isWindowOpened = false

		openedWindow: ->
			Backbone.trigger("opened-window")
			@isWindowOpened = true
