define [ "underscore", "js/model/AppModel", "localStorage"], ( _, AppModel) ->
	Backbone.Collection.extend
		model: AppModel
		localStorage: new Backbone.LocalStorage("AppCollection")
		clearActiveMenu: ->
			activeApps = @where({"is_active_menu": true})
			for app in activeApps
				app.set("is_active_menu", false)