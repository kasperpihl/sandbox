define ["underscore"], (_) ->
	MainRouter = Backbone.Router.extend
		routes:
			"app/:id": "app"
			"group/:id": "channel"
			"group/:id/:app": "channel"
			"im/:id": "im"
			"im/:id/:app": "im"
			"*all": "root"
		root: ->
			@navigate( "group/general", { trigger: yes, replace: yes } )
		app: (id) ->
			options = { type: "app", app_id: id }
			Backbone.trigger( "open/viewcontroller", options )

		channel: ( id, appId ) ->
			if !appId
				return @navigate( "group/" + id + "/chat", { trigger: yes, replace: yes } ) 

			options = { type: "channel", channel_id: id, app_id: appId }
			Backbone.trigger( "open/viewcontroller",  options )
		im: ( id, appId ) ->
			if !appId
				return @navigate( "im/" + id + "/chat", { trigger: yes, replace: yes } ) 
			options = { type: "im", channel_id: id, app_id: appId }
			Backbone.trigger( "open/viewcontroller", options )
		destroy: ->
			Backbone.history.off( null, null, @ )
