define [
	"underscore"
	"text!templates/viewcontroller/topbar-view-controller.html"
	], (_, Tmpl) ->
	Backbone.View.extend
		el: ".top-bar-container"
		className: ".top-bar-container"
		events: 
			"click .menu-icon-container" : "sidebarToggle"
		swDropdown: ->
			# Dropdown
			swipesDropdown = @$el.find('.swipes-dropdown')

			swipesDropdown.on 'click', '.init, .dropdown-arrow', ->
				$(this).closest('ul').children('li:not(.init)').toggle()
				return
			allOptions = swipesDropdown.children('li:not(.init)')
			swipesDropdown.on 'click', 'li:not(.init)', ->
				allOptions.removeClass 'selected'
				$(this).addClass 'selected'
				$('ul').children('.init').html $(this).html()
				allOptions.toggle()
				return
			return
		sidebarToggle: (e) ->
			$("body").toggleClass("sidebar-closed")
			$(".menu-icon").toggleClass("open")
		initialize: (options) ->
			@setElement(options.el)
			@foregroundClass = "navigation-foreground-light"
			@swDropdown()
		setForegroundColor: (color) ->
			foregroundClass = "navigation-foreground-light"
			if color is "dark"
				foregroundClass = "navigation-foreground-dark"

			if color isnt @foregroundClass
				@$el.removeClass(@foregroundClass)
				@$el.addClass(foregroundClass)
				@foregroundClass = foregroundClass
		setBackgroundColor: (color, isSecondary) ->
			return if isSecondary
			@$el.css("backgroundColor", "")
			if color
				@$el.css("backgroundColor", color)
		enableBoxShadow: (enable) ->
			enableToggle = false
			enableToggle = true if enable
			@$el.toggleClass("navigation-boxshadow", enableToggle)
		setTitle: (title, isSecondary) ->

			@$el.find("li.init").html("<span>" + title + "</span>")
			@$el.find(".title").html(title)
			@$el.find(".swipes-dropdown").css("width", "100%")
			newWidth = @$el.find("li.init span").outerWidth() + 60;
			newWidth = 150 if newWidth < 150
			@$el.find(".swipes-dropdown").css("width", newWidth)
		reset: ->
			@setForegroundColor()
			@setBackgroundColor()