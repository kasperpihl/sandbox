define ["momentjs"], (Moment)->
	class TimeUtility
		###
			Time based Helpers
		###
		isAmPm: ->
			return true #return if swipy.settings.get("Setting24HourClock") then false else true
		getTimeStr: (date) ->
			format = if @isAmPm() then "h:mma" else "H:mm"
			moment( date ).format format
		getFormattedTime: (hour, minute, amPm, html) ->
			if minute < 10 then minute = "0" + minute
			return hour + ":" + minute if !amPm? or !amPm
			amPmString = "AM"

			if hour is 0 or hour is 24
				timeString =  "12:" + minute
			else if hour <= 11
				timeString = hour + ":" + minute
			else if hour is 12
				timeString = "12:" + minute
				amPmString = "PM"
			else 
				timeString = hour - 12 + ":" + minute
				amPmString = "PM"

			if html
				amPmString = "<small>" + amPmString + "</small>"

			return timeString + " " + amPmString
		getFormattedTimeFromSeconds: ( seconds, html ) ->
			hours = Math.floor(@hourForSeconds(seconds))
			minutes = Math.floor(@minutesForSeconds(seconds))
			seconds = seconds % 60

			timeString = ""
			if hours > 0
				if hours < 10
					timeString += "0"
				timeString += hours + ":"

			if minutes < 10
				timeString += "0"
			timeString += minutes + ":"

			if seconds < 10
				timeString += "0"
			timeString += seconds

			timeString
		hourForSeconds: ( seconds ) ->
			return seconds / 3600
		minutesForSeconds: ( seconds ) ->
			return ( seconds % 3600 ) / 60
		daysToNextDayFromDay: (fromDay, toDay) ->
			return 0 if fromDay is toDay
			deltaDay = fromDay
			for number in [1...6]
				deltaDay++
				deltaDay = 0 if deltaDay > 6
				return number if deltaDay is toDay
		nextDayFromDay: (day) ->
			nextDay = day + 1
			nextDay = 0 if nextDay > 6
			nextDay
		isWeekend: (schedule) ->
			weekendStartDay = swipy.settings.get "SettingWeekendStart"
			weekendSecondDay = @nextDayFromDay(weekendStartDay)
			if schedule.getDay() is weekendStartDay or schedule.getDay() is weekendSecondDay then return yes
			else return no

		isWeekday: (schedule) ->
			return !@isWeekend schedule

		secondsSinceStartOfDay: ( date ) ->
			compareMoment = moment(date)
			startDayMomentDate = moment(date).startOf("day")
			parseInt(Math.abs(compareMoment.diff(startDayMomentDate) / 1000), 10)

		getMonFriSatSunFromDate: ( schedule ) ->
			if @isWeekday schedule
				@getNextWeekDay moment schedule
			else
				@getNextWeekendDay moment schedule



		getDayWithoutTime: (day) ->
			fullStr = day.calendar()
			timeIndex = fullStr.indexOf( " at " )

			# Date is within the next week, so just sat the day name — calendar() returns something like "Tuesday at 3:30pm",
			# and we only want "Tuesday", so use this little RegEx to select everything before the first space.
			if timeIndex isnt -1
				return fullStr.slice( 0, timeIndex )
			else
				return fullStr
		dayStringForDate:(date) ->
			now = moment()
			parsedDate = moment date
			dayDiff =  Math.abs parsedDate.diff( now, "days" )

			if dayDiff >= 6 or dayDiff <= -6
				# If it's next or previous years, add year suffix
				if parsedDate.year() isnt now.year() then result = parsedDate.format "MMM Do 'YY"
				else result = parsedDate.format "MMM Do"
				return result
			# Else return day string ("Today, Tomorrow, Monday etc")
			else return @getDayWithoutTime parsedDate

		getNextWeekDay: (date) ->
			# If date is friday, go to next monday, else go to tomorrow
			return date.add( "days", if date.day() is 5 then 3 else 1 ).toDate()

		getNextWeekendDay: (date) ->
			# If date is sunday, go to next saturday, else go to tomorrow (Which will always be sunday)
			return date.add( "days", if date.day() is 0 then 6 else 1 ).toDate()
		getNextDateFrom: ( date, repeatOption ) ->
			now = new Date().getTime()
			nextDate = date
			loop
				nextDate = moment nextDate
				switch repeatOption
					when "every day" then nextDate = nextDate.add( "days", 1 ).toDate()
					when "every week", "every month", "every year"
						type = repeatOption.replace( "every ", "" ) + "s"
						diff = 1
						nextDate = nextDate.add( type, Math.ceil diff ).toDate()
					when "mon-fri or sat+sun"
						nextDate = @getMonFriSatSunFromDate( nextDate.toDate() )
					# "never" + catch-all
					else return null
				break if nextDate.getTime() > now
			return nextDate