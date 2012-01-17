
function runCalendar(trace = false) as Integer
	if trace then print "Running calendar screen."
	
	registry = getRegistry("account")

	if checkForContentAndReload("tmp:/calendar.txt", "http://api.trakt.tv/user/calendar/shows.json/" + getAPIKey() + "/" + registry.read("username") + "/" + getDateString() + "/" + registry.read("calendar_days")) then
		premieres = ReadASCIIFile("tmp:/calendar.txt")
	else
		return -1
	endif
	
display:
	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing show data")
	dlg.showBusyAnimation()
	dlg.show()
	
	premieresArray = rdJSONParser(premieres)
	dates = CreateObject("roArray", 0, true)
	dateLabels = CreateObject("roArray", 0, true)
	listCount = premieresArray.count()
	for i = 0 to listCount-1
		dateLabels.push(ProcessDateString(premieresArray[i].date))
		
		newDate = CreateObject("roArray", 0, true)
		for j = 0 to premieresArray[i].episodes.count()-1
'	*** Necessary Variables:
			show = premieresArray[i].episodes[j].show
			episode = premieresArray[i].episodes[j].episode
			curMeta = CreateObject("roAssociativeArray")
			
			curMeta.in_watchlist = episode.in_watchlist
			curMeta.show = show
			curMeta.episode = episode
			
			
			curMeta.contentType = "episode"
			curMeta.title = episode.title
			curMeta.titleSeason = show.title + " Season " +  episode.season.toStr()
			if episode.overview = "" then
				curMeta.description = show.overview
			else
				curMeta.description = episode.overview
			endif
			curMeta.HDPosterURL = parsePosterImage(show.images.poster, "138")
			curMeta.SHPosterURL = parsePosterImage(show.images.poster, "138")
			
			'	*** Data stored for application:
			'		breakCrumbLeft, right
			
			curMeta.breadCrumbLeft = "Calendar"
			curMeta.breadCrumbRight = show.title
			



'	***	Some data is stored redundantly to make the display() functionality the same across this platform.

'	***	Push the new associative array onto the Array.
 
			newDate.push(curMeta)
		
		end for
		dates.push(newDate)
		
	end for
	
	calendarScreen = CreateObject("roGridScreen")
	calendarScreen.setUpLists(dates.count())
	calendarScreen.setListNames(dateLabels)
	calendarScreen.setDescriptionVisible(true)
	
	calendarScreen.show()
	dlg.close()
	
	m.port = CreateObject("roMessagePort") 'Grid screen must use a separate message port variable
	calendarScreen.setMessagePort(m.port)

'	***	Set content list for all rows (each row is a date)

	for i = 0 to dateLabels.count()-1
		calendarScreen.setContentListSubset(i, dates[i], 0, dates[i].count())
	end for	
	
	calendarScreen.setUpBehaviorAtTopRow("stop")
	calendarScreen.setDescriptionVisible(true)
	calendarScreen.setBreadCrumbText("trakt.tv", "Calendar")
	calendarScreen.setGridStyle("flat-portrait")
	calendarScreen.setDisplayMode("scale-to-fill")
	calendarScreen.show()
	pURL = createObject("roURLTransfer")
	
	
	while true
		msg = wait(0, m.port)
		idx = msg.GetIndex()
		if type(msg) = "roGridScreenEvent" then
			if msg.isScreenClosed() then
				return -1
			elseif msg.isListItemFocused()
				'Do Nothing
			elseif msg.isListItemSelected()
				selectedRow = dates[msg.getIndex()]
				selectedCol = selectedRow[msg.getData()]
				selectedCol.date = dateLabels[msg.getIndex()]
				episodeInformation(selectedCol)
					
			endif
		endif
	end while
end function

