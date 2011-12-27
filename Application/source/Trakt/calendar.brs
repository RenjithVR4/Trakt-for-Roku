
function runCalendar() as Integer
	print "Running calendar screen."
	dlg = CreateObject("roMessagedialog")
	dlg.setTitle("Parsing show data")
	dlg.setText("Please wait.")
	dlg.showBusyAnimation()
	dlg.show()
	print listDir("tmp:/")
	
	premieres = ReadASCIIFile("tmp:/cal_premieres.txt")
	
		

	premieresArray = rdJSONParser(premieres)
	dates = CreateObject("roArray", 0, true)
	dateLabels = CreateObject("roArray", 0, true)
	listCount = premieresArray.count()
	for i = 0 to listCount-1
		dateLabels.push(ProcessDateString(premieresArray[i].date))
		
		newDate = CreateObject("roArray", 0, true)
		for j = 0 to premieresArray[i].episodes.count()-1
			show = premieresArray[i].episodes[j].show
			episode = premieresArray[i].episodes[j].episode
			curMeta = CreateObject("roAssociativeArray")
			curMeta.contentType = "episode"
			curMeta.title = episode.title
			curMeta.titleSeason = show.title + " Season " +  episode.season.toStr()
			if episode.overview = "" then
				curMeta.description = show.overview
			else
				curMeta.description = episode.overview
			endif
			curMeta.watched = episode.watched
			curMeta.HDPosterURL = show.images.poster
			curMeta.SHPosterURL = show.images.poster
			curMeta.episodeNumber = episode.number.toStr()
			newDate.push(curMeta)
		
		end for
		dates.push(newDate)
		
	end for
	calendarScreen = CreateObject("roGridScreen")
	print dates.count()
	calendarScreen.setUpLists(dates.count())
	calendarScreen.setListNames(dateLabels)
	
	calendarScreen.setDescriptionVisible(true)
	dlg.close()
	calendarScreen.show()
	m.port = CreateObject("roMessagePort")
	calendarScreen.setMessagePort(m.port)
	'print type(dateLabels)
	'print type(dateLabels[0])
	'print dateLabels.count()
	for i = 0 to dateLabels.count()-1
		calendarScreen.setContentListSubset(i, dates[i], 0, dates[i].count())
	end for	
	calendarScreen.setUpBehaviorAtTopRow("stop")
	calendarScreen.setDescriptionVisible(true)
	calendarScreen.setGridStyle("flat-portrait")
	calendarScreen.setDisplayMode("scale-to-fill")
	calendarScreen.show()
	while true
		msg = wait(0, m.port)
		idx = msg.GetIndex()
		if type(msg) = "roGridScreenEvent" then
			if msg.isScreenClosed() then
				return -1
			elseif msg.isListItemFocused()
				'print "Focused: " + msg.getContent()
			elseif msg.isListItemSelected()
				print "Selected: "  + msg.getMessage()
			endif
		endif
	end while
end function

function ProcessDateString(in as String) as Object
	dateO = createObject("roDateTime")
	dateO.toLocalTime()
	day = dateO.getDayOfMonth()
	month = dateO.getMonth()
	inMonth = Mid(in, 6, 2)
	inDay = Mid(in, 9, 2)
	inYear = Mid(in, 0, 4)
	weekDay = dateO.getWeekday()
	inMonthVal = Val(inMonth)
	inDayVal = Val(inDay)
	
	months = CreateObject("roArray", 13, true)
	months[1] = 31 'Jan
	months[2] = 28 'Feb
	months[3] = 31 'march
	months[4] = 30 'April
	months[5] = 31 'May
	months[6] = 30 ' June
	months[7] = 31 'July
	months[8] = 31 'August
	months[9] = 30 'September
	months[10] = 31 'October
	months[11] = 30 'November
	months[12] = 31 'December
	
	diffDays = CreateObject("roArray", 14, true)
	diffDays[0] = "Today"
	diffDays[1] = "Tomorrow"
	diffDays[2] = "The day after tomorrow"
	diffDays[3] = "This "
	diffDays[4] = "This "
	diffDays[5] = "This "
	diffDays[6] = "This "
	diffDays[7] = "Next "
	diffDays[8] = "Next "
	diffDays[9] = "Next "
	diffDays[10] = "Next "
	diffDays[11] = "Next "
	diffDays[12] = "Next "
	diffDays[13] = "Next "
	
	days = createObject("roArray", 7, true)
	days[0] = "Sunday"
	days[1] = "Monday"
	days[2] = "Tuesday"
	days[3] = "Wednesday"
	days[4] = "Thursday"
	days[5] = "Friday"
	days[6] = "Saturday"
	
	
	dayIndex = 0
	for i=1 to 6
		if days[i] = weekDay then
			print "Changing dayinddex"
			print days[i]
			print weekDay
			dayIndex = i
			exit for
		endif
	end for
	print "day index=" + dayIndex.toStr()
	if (inDayVal) > months[month] then 'Are we spilling into the next month?
		print "We Are changing the inDayVal"
		inDayVal = months[month] + inDayVal 
	endif
	
	out = ""
	difference = inDayVal - day 'For 2 days in the future, this is 2.
	print difference
	print (mod(7, difference))
	
	'print "Day of month today: " + day.toStr()
	'print "Weekday today: " + weekDay
	'print "Day of air " + inDay
	'print difference
	'print days[(mod(7, difference))]
	'print val(inDay) - day
	if difference < 14 then
	
		if difference < 3 then
			out = diffDays[difference]
		else
			if difference > 6 then
				difference = difference + 7
			endif
			
			out = diffDays[difference] + "" +  days[(mod(7, difference))]
		endif
	
	else
		out = inMonth + "/" + inDay + "/" + inYear
	endif
	print out
	return in
end function