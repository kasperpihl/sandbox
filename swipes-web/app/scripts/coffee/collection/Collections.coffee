define [
	"underscore"
	"backbone"
	"js/collection/UserCollection"
	"js/collection/TeamCollection"
	"js/collection/AppCollection"
	"js/collection/ChannelCollection"
	"collectionSubset"
	], (_, Backbone, UserCollection, TeamCollection, AppCollection, ChannelCollection) ->
	class Collections
		constructor: ->
			
			@users = new UserCollection()
			@teams = new TeamCollection()
			@apps = new AppCollection()
			@channels = new ChannelCollection()
			@channels.localStorage = new Backbone.LocalStorage("ChannelCollection")

			@all = [@teams, @users, @apps, @channels]
		fetchAll: ->
			for collection in @all
				collection.fetch()