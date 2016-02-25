define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/modal/picker-modal.html"
		"text!templates/modal/app-picker-row.html"], (_, ModalView, Tmpl, RowTmpl) ->
	ModalView.extend
		className: 'picker-modal'
		initialize: ->
			@setTemplates()
			@bouncedRender = _.debounce(@render, 5)
			_.bindAll(@, "clickedApp", "render", "bouncedRender")
			@searchField = false
			@title = "Select app"
			@emptyMessage = "No apps found"
			@selectOne = true
		events:
			"blur input": "test"
			"keyup input": "search"
			"change input": "search"
		test: (e) ->
			true
		setTemplates: ->
			@template = _.template Tmpl, {variable: "data"}
			@rowTemplate = _.template RowTmpl, {variable: "data"}
		loadApps: ->
			@apps = @dataSource.appPickerModalApps(@)
			@filteredApps = @apps
		search: (e) ->
			if e.keyCode is 27
				@$el.find("input").blur()
				return
			searchString = @$el.find("input").val()
			if !searchString? or !searchString.length
				@filteredApps = @apps
				@renderApps()
				return
			searchString = searchString.toLowerCase()
			newFilter = []
			for app in @apps
				if app.name.toLowerCase().startsWith(searchString)
					newFilter.push(person)
					continue
			@filteredApps = newFilter
			@renderApps()
		render: ->
			throw new Error("UserPickerModal must have dataSource") if !@dataSource?
			throw new Error("UserPickerModal dataSource must implement userPickerModalPeople") if !_.isFunction(@dataSource.userPickerModalPeople)

			html = @template({ searchField: @searchField, title: @title})
			@$el.html html
			@renderApps()
			return @
		didPresentModal: ->
			@$el.find("input").focus()
		renderApps: ->
			@$el.find(".picker-list-container").html @rowTemplate({apps: @filteredApps, emptyMessage: @emptyMessage })
			@$el.find(".picker-list-container .row").on("click", @clickedApp)
		clickedApp: (e) ->
			$el = $(e.currentTarget)
			appId = $el.attr("data-href")
			targetApp = swipy.collections.apps.get(appId)

			if @delegate? and _.isFunction(@delegate.appPickerClickedApp)
				val = @delegate.appPickerClickedApp(targetApp)
			if @selectOne
				@dismissModal()
			else
				i = 0
				for app in @apps
					if app? and app.id is appId
						@apps.splice(i, 1)
						break
					i++
				@removeApp(userId)
		removeApp: (href, callback) ->
			dfd = new $.Deferred()
			el = @$el.find('li[data-href='+href+']')
			el.addClass('animated-short')
			el.addClass('fadeOut')
			setTimeout(->
				el.remove()
				dfd.resolve()
			, 300)
			return dfd.promise()
