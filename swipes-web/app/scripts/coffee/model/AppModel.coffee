define ["underscore"], (_) ->
	Backbone.Model.extend
		className: "App"
		initialize: ->
			@set("is_app", true)
		pin: ->
			swipy.swipesSync.apiRequest("stars.add",{type: "app", id: @id},
				(res, error) =>
					console.log("pinned channel", res, error)
			)
		unpin: ->
			swipy.swipesSync.apiRequest("stars.remove", {type: "app", id: @id}, 
				(res, error) =>
					console.log("unpinned channel", res, error)
			)