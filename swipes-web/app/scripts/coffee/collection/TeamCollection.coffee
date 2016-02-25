define [ "underscore", "js/model/TeamModel", "localStorage"], ( _, TeamModel) ->
	Backbone.Collection.extend
		model: TeamModel
		localStorage: new Backbone.LocalStorage("TeamCollection")