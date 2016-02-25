define [
	"underscore"
	"js/view/sidebar/SidebarChannelRow"
	"js/view/modal/UserPickerModal"
	"js/view/modal/ChannelPickerModal"
	"js/view/modal/AppPickerModal"
	"js/view/modal/GenericModal"
	], (_, ChannelRow, UserPickerModal, ChannelPickerModal, AppPickerModal, GenericModal) ->
	Backbone.View.extend
		el: ".sidebar_content"
		initialize: ->
			@bouncedRenderSidebar = _.debounce(@renderSidebar, 15)
			@listenTo( swipy.collections.channels, "add reset remove change:is_open change:is_active_menu change:is_member change:is_starred change:unread_count_display", @bouncedRenderSidebar )
			@listenTo( swipy.collections.apps, "add reset remove change:is_user change:is_active change:is_active_menu change:is_starred", @bouncedRenderSidebar)
			@bouncedUpdateNotificationsForMyTasks = _.debounce(@updateNotificationsForMyTasks, 15)
			# Proper render list when projects change/add/remove
			_.bindAll( @, "renderSidebar", "clickedInvite")
			@listenTo( Backbone, "set-active-menu", @setActiveMenu )
			@listenTo( Backbone, "resized-window", @checkAndEnableScrollBars)
			@listenTo( Backbone, "close/channel", @closeChannel, @)
			@listenTo( Backbone, "channel/action", @channelAction, @)
			@listenTo( Backbone, "open/invitemodal", @clickedInvite)
			@listenTo( Backbone, "opened-window", @collapseChannels)
			@listenTo( Backbone, "opened-window", @collapseDM)
			@listenTo( Backbone, "clicked/row", @clickedModel)
			@renderSidebar()
			@expandedDM = false
			@expandedChannels = false
			@expandedApps = false
		events:
			"click .add-project.button-container a": "clickedAddProject"
			"click .invite-link": "clickedInvite"
			"click #sidebar-members-list .more-button-dm": "clickedExpandDM"
			"click #sidebar-apps-list > h1" : "clickedApps"
			"click #sidebar-apps-list .more-button-apps": "clickedExpandApps"
			"click #sidebar-project-list .more-button": "clickedExpandChannels"
			"click #sidebar-members-list > h1,  #sidebar-members-list .add-button": "clickedDM"
			"click #sidebar-project-list .add-button" : "clickedAddChannel"
			"click #sidebar-group-list .add-button" : "clickedAddGroup"
			"click #sidebar-project-list > h1" : "clickedChannels"
			"click #sidebar-group-list .more-button, #sidebar-group-list > h1": "clickedGroups"
		clickedInvite: ->
			modal = @getModal("invite", "Invite your favorite colleagues<br>to work with.", "No more colleagues to invite")
			modal.searchField = true
			modal.selectOne = false
			modal.render()
			modal.presentModal()
			false
		clickedModel: (row, model) ->
			if model.get("is_app")
				route = "app/" + model.get("manifest_id")
			else if model.get("type") is "public" or model.get("type") is "private"
				route = "group/" + model.get("name")
			else if model.get("type") is "direct"
				route = "im/" + row.user.get("name")
			console.log "routing", route
			swipy.router.navigate(route, {trigger:true})
		collapseDM: ->
			@expandedDM = false
			@bouncedRenderSidebar()
		collapseChannels: ->
			@expandedChannels = false
			@bouncedRenderSidebar()

		clickedExpandDM: ->
			@expandedDM = !@expandedDM
			@bouncedRenderSidebar()
			false
		clickedExpandApps: ->
			@expandedApps = !@expandedApps
			@bouncedRenderSidebar()
			false
		clickedExpandChannels: ->
			@expandedChannels = !@expandedChannels
			@bouncedRenderSidebar()
			false
		clickedGroups: ->
			modal = @getChannelModal("groups", "Join a private group you're not part of", "No more groups to join")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
		clickedApps: ->
			modal = @getAppModal("Activate an app", "No more apps to activate")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
		clickedChannels: ->
			modal = @getChannelModal("channels", "Join a channel you're not part of", "No more channels to join")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
		clickedDM: ->
			modal = @getModal("dm", "Direct Message.")
			modal.searchField = true
			modal.render()
			modal.presentModal()
			false
		channelAction: (channel, e) ->
			actions = []

			if channel.get("is_starred")
				return channel.unpin()
				actions.push({name: "Unpin", icon: "dragMenuMove", action: "unpin"})
			else
				return channel.pin()
				actions.push({name: "Pin", icon: "dragMenuInvite", action: "pin"})

			actions.push({name: "Close", icon: "materialClose", action: "close"})
			swipy.modalVC.presentActionList(actions, {centerX: false, centerY: false, left: e.pageX, top: e.pageY}, (result) =>
				if result is "pin"
					channel.pin()
				else if result is "unpin"
					channel.unpin()
				else if result is "close"
					channel.closeChannel()
			)
		getAppModal:(title, emptyMessage) ->
			appPickerModal = new AppPickerModal()
			appPickerModal.dataSource = @
			appPickerModal.delegate = @
			appPickerModal.title = title
			appPickerModal.emptyMessage = emptyMessage
			appPickerModal.loadApps()
			appPickerModal
		getChannelModal: (type, title, emptyMessage) ->
			@modalType = type
			channelPickerModal = new ChannelPickerModal()
			channelPickerModal.dataSource = @
			channelPickerModal.delegate = @
			channelPickerModal.title = title
			channelPickerModal.emptyMessage = emptyMessage
			channelPickerModal.loadChannels()
			channelPickerModal
		getModal: (type, title, emptyMessage) ->
			@modalType = type
			userPickerModal = new UserPickerModal()
			userPickerModal.dataSource = @
			userPickerModal.delegate = @
			userPickerModal.title = title
			userPickerModal.emptyMessage = emptyMessage
			userPickerModal.loadPeople()
			userPickerModal
		appPickerClickedApp: (targetApp) ->
			swipy.swipesSync.apiRequest("users.activateApp", {"app_id": targetApp.id}, (res,error) =>
				console.log "users.activateApp", res, error
				if res and res.ok
					if(targetApp.get("has_main_app"))
						console.log("should navigate!", targetApp.toJSON())
						swipy.router.navigate("app/"+targetApp.get("manifest_id"), {trigger:true})
				else alert("error trying to message " + JSON.stringify(res) + " " + JSON.stringify(error))
			)
		userPickerClickedUser: (targetUser) ->
			if @modalType is "invite"
				console.log("should do invite, functionality killed")
				###
				swipy.api.callAPI("invite/slack", "POST", {invite: {"slackUserId": targetUser.id, "type": "Standard Invite"}}, (res, error) =>
					console.log "res from invite", res, error
					if res and res.ok
						swipy.analytics.logEvent("Invite Sent", {"Hours Since Signup": res.hoursSinceSignup, "From": "Invite Overlay"})
				)###
			else if @modalType is "dm"
				swipy.swipesSync.apiRequest("im.open", {"user_id": targetUser.id}, (res,error) =>
					if res and res.ok
						swipy.router.navigate("im/"+targetUser.get("name"), {trigger:true})
					else alert("error trying to message " + JSON.stringify(res) + " " + JSON.stringify(error))
				)
		channelPickerClickedChannel: (targetChannel) ->
			if @modalType is "channels"
				swipy.swipesSync.apiRequest("channels.join", {"name": targetChannel.get("name") }, (res,error) =>
					if res and res.ok
						swipy.router.navigate("channel/"+targetChannel.get("name"), {trigger:true})
					else alert("error trying to message " + JSON.stringify(res) + " " + JSON.stringify(error))
				)
		appPickerModalApps: ( appPickerModal) ->
			apps = []
			swipy.collections.apps.each( (app) =>
				if !app.get("is_active")
					apps.push(app.toJSON())
				return false
			)
			return apps
		channelPickerModalChannels: (channelPickerModal) ->
			channels = []
			swipy.collections.channels.each( (channel) =>
				if @modalType is "channels"
					if channel.get("type") is "public" and !channel.get("is_archived")
						if !channel.get("is_member")
							channels.push(channel.toJSON())
				return false
			)
			return channels

		userPickerModalPeople: (userPickerModal) ->
			people = []
			me = swipy.collections.users.me()
			users = swipy.collections.users.filter((user) =>
				return false if user.get("deleted") or user.id is me.id
				return false if @modalType is "invite" and user.id is "USLACKBOT"
				return true
			)
			for user in users
				people.push(user.toJSON())
			return people
		closeChannel: (model) ->
			model.closeChannel()
		clickedAddChannel: (e) ->
			createChannelCallback = (() ->
				return (channelName) ->
					if !channelName
						return [{error: "You can't create channel with an empty name"}]
					else if channelName.length > 0
						swipy.swipesSync.apiRequest("channels.create",{name: channelName},(res, error) =>
							if res and res.ok
								swipy.router.navigate("channel/"+res.channel.name)
							else
								console.log("error channel",res, error)
						)
			)()

			genericModal = new GenericModal
				type: 'inputModal'
				submitCallback: createChannelCallback
				inputSelector: 'input'
				tmplOptions:
					title: 'Create new channel'
					cancelText: 'CANCEL'
					submitText: 'CREATE'
					placeholder: 'New channel name'
			false
		renderSidebar: ->

			appsLeft = 0
			hasStarred = false
			filteredApps = []
			activeApp = false
			_.each(swipy.collections.apps.models, (app) =>
				if app.get("is_active") and app.get("main_app")
					if !hasStarred or @expandedApps or app.get("is_active_menu") or app.get("is_starred")	
						if !@expandedApps and !hasStarred and app.get("is_starred")
							hasStarred = true
							appsLeft = filteredApps.length
							filteredApps = []
							if activeApp
								filteredApps.push(app)
								appsLeft-- 
						if @expandedApps and !app.get("is_starred")
							appsLeft++
						activeApp = app if app.get("is_active_menu")
						filteredApps.push(app)
					else
						appsLeft++
			)
			apps = _.sortBy( filteredApps, (app) ->
				if app.get("is_starred")
					return 0 + app.get("name")
				return 1 + app.get("name") 
			)
			@$el.find("#sidebar-apps-list .apps").html("")
			if appsLeft > 0
				buttonText = if @expandedApps then "Hide unstarred" else "+"+ appsLeft + " More..."
				@$el.find("#sidebar-apps-list .more-button").html(buttonText)
			@$el.find("#sidebar-apps-list .more-button").toggleClass("shown", (appsLeft > 0))

			for app in apps
				rowView = new ChannelRow({model: app})
				@$el.find("#sidebar-apps-list .apps").append(rowView.el)
				rowView.render()
			if !apps.length then $("#sidebar-apps-list .apps").html('<li class="empty">No apps installed</li>')





			channelsLeft = 0
			hasStarred = false
			filteredChannels = []
			activeChannel = false
			_.each(swipy.collections.channels.models, (channel) =>
				if channel.get("type") is "public" and !channel.get("is_archived") and channel.get("is_member")
					if !hasStarred or @expandedChannels or channel.get("is_active_menu") or channel.get("is_starred") or channel.get("unread_count_display")
						if !hasStarred and !@expandedChannels and channel.get("is_starred")
							hasStarred = true
							channelsLeft = filteredChannels.length
							filteredChannels = []
							if activeChannel
								filteredChannels.push(activeChannel)
								channelsLeft--
						if @expandedChannels and !channel.get("is_starred")
							channelsLeft++
						activeChannel = channel if channel.get("is_active_menu")
						filteredChannels.push(channel)
					else
						channelsLeft++
			)
			channels = _.sortBy( filteredChannels, (channel) ->
				if channel.get("is_starred")
					return 0 + channel.get("name")
				if channel.get("unread_count_display")
					return 1 + channel.get("name")
				return 2 + channel.get("name")
			)
			@$el.find("#sidebar-project-list .projects").html("")
			if channelsLeft > 0
				buttonText = if @expandedChannels then "Hide unstarred" else "+"+ channelsLeft + " More..."
				@$el.find("#sidebar-project-list .more-button").html(buttonText)
			@$el.find("#sidebar-project-list .more-button").toggleClass("shown", (channelsLeft > 0))

			for channel in channels
				rowView = new ChannelRow({model: channel})
				@$el.find("#sidebar-project-list .projects").append(rowView.el)
				rowView.render()
			if !channels.length then $("#sidebar-project-list .projects").html('<li class="empty">No unread messages</li>')





			imsLeft = 0
			hasStarred = false
			filteredIms = []
			activeIm = false
			_.each(swipy.collections.channels.models, (channel) =>
				if channel.get("type") is "direct" and channel.get("is_open")
					if !hasStarred or @expandedDM or channel.get("is_active_menu") or channel.get("is_starred") or channel.get("unread_count_display")
						if !hasStarred and !@expandedDM and channel.get("is_starred")
							hasStarred = true
							imsLeft = filteredIms.length
							filteredIms = []
							if activeIm
								filteredIms.push(activeIm)
								imsLeft--
						if @expandedDM and !channel.get("is_starred")
							imsLeft++
						activeIm = channel if channel.get("is_active_menu")
						filteredIms.push(channel)
					else
						imsLeft++
				return false
			)

			ims = _.sortBy(filteredIms, (im) ->

				user = swipy.collections.users.get(im.get("user_id"))
				if !user
					console.log("wrong user", im)
				if user
					user = user.toJSON()
				if user.name is "slackbot"
					nameString = 0
				else nameString = user.name
				
				if im.get("is_starred")
					return 0 + nameString
				if im.get("unread_count_display")
					return 1 + nameString

				return 2 + nameString
			)
			if imsLeft > 0
				buttonText = if @expandedDM then "Hide unstarred" else "+"+ imsLeft + " More..."
				@$el.find("#sidebar-members-list .more-button").html(buttonText)
			@$el.find("#sidebar-members-list .more-button").toggleClass("shown", (imsLeft > 0))


			@$el.find("#sidebar-members-list .team-members").html("")
			for im in ims
				user = swipy.collections.users.get(im.get("user_id"))
				rowView = new ChannelRow({model: im})
				rowView.setUser(user)

				@$el.find("#sidebar-members-list .team-members").append(rowView.el)
				rowView.render()
			if !ims.length then $("#sidebar-members-list .team-members").html('<li class="empty">No unread messages</li>')

			@checkAndEnableScrollBars()
			@delegateEvents()
			@setActiveMenu(@activeClass) if @activeClass?


		checkAndEnableScrollBars: ->
			overflow = "hidden"
			if $(".sidebar-controls").outerHeight(true) > $("body").height()
				overflow = "scroll"
			$('.sidebar_content').css("overflowY",overflow)
		setActiveMenu: (activeClass) ->
			@activeClass = activeClass
			$(".sidebar-controls .active").removeClass("active")
			$(".sidebar-controls #"+activeClass).addClass("active")
		destroy: ->
			@stopListening()
