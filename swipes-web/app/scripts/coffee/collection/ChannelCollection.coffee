define [ "underscore", "js/model/ChannelModel", "localStorage"], ( _, ChannelModel) ->
	Backbone.Collection.extend
		model: ChannelModel
		slackApiType: "channels"
		localStorage: new Backbone.LocalStorage("ChannelCollection")
		slackbot: ->
			@findWhere({user: "USLACKBOT"})
		activeChannels: ->
			filteredChannels = _.filter(@models, (channel) ->
				if channel.get("is_channel") and !channel.get("is_archived")
					return true
				return false
			)

			return filteredChannels
		clearActiveMenu: ->
			activeChannels = @where({"is_active_menu": true})
			for channel in activeChannels
				channel.set("is_active_menu", false)