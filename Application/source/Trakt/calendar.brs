
function runCalendar(trace = false) as Integer
	if trace then print "Running calendar screen."
	
'	*** Try and load the file in the tmp:/ directory
	premieres = ReadASCIIFile("tmp:/calendar.txt")
	if premieres = "failed" then goto reload
	if type(premieres) = invalid then goto reload
	if premieres = "" then goto reload
	
	goto display

'	*** If the file is not found or is invalid, try to create it again.
reload:

	dlg = createSimpleLoadingScreen("Loading Content", "Calendar data will take longer to load if there are many items in your watchlist.")
	dlg.show()
	
	registry = getRegistry("account")
	premieres = aSyncFetch("http://api.trakt.tv/user/calendar/shows.json/" + getAPIKey() + "/" + registry.read("username") + "/" + getDateString() + "/" + registry.read("calendar_days"), true)
	dlg.close()
	
	if premieres = "failed" then 
		dlg = createObject("roMessageDialog")
		dlg.setTitle("Could not load calendar data")
		dlg.setText("Please try again.  If the problem persists, try unlinking and re-linking your account.")
		dlg.addButton(0, "Ok :(")
		dlg.setMessagePort(createObject("roMessagePort"))
		dlg.show()
		
		while true
			msg = wait(0, dlg.getMessagePort())
			if msg.isButtonPressed then 
				dlg.close()
				return -1
			endif
		end while
	end if
	
	WriteASCIIFile("tmp:/calendar.txt", premieres) 'Save the file for future use.
	
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
			
			
			'	*** Data from Trakt API:
			'		watched
			'		userRating
			'		inWatchlist
			'		show
			'		year
			'		firstAired
			'		country
			'		runtime
			'		network
			'		airday
			'		airtime
			'		certification
			'		imdb
			'		 poster
			'		fanart
			'		banner
			'		season
			'		pisodeNumber
			'		episodeTitle
			'		episodeFirstAired
			'		episodeScreen
			
			curMeta.watched = episode.watched
			'curMeta.userRating = premieresArray[i].episodes[i].rating
			curMeta.inWatchlist = show.in_watchlist
			curMeta.show = show.title
			curMeta.year = show.year
			curMeta.firstAired = show.firstAired
			curMeta.country = show.country
			curMeta.runtime = show.runtime
			curMeta.network = show.network
			curMeta.airDay = show.air_day
			curMeta.airTime = show.air_time
			curMeta.certification = show.certification
			curMeta.imdb = show.imdb_id
			curMeta.poster = show.images.poster
			curMeta.fanart = show.images.fanart
			curMeta.banner = show.images.banner
			curMeta.season = episode.season
			curMeta.episodeNumber = episode.number
			curMeta.episodeTitle = episode.title
			curMeta.episodeFirstAired = episode.firstAired
			curMeta.episodeScreen = episode.images.screen

			'	***	Data stored for Roku:
			'		contentType
			'		title
			'		titleSeason
			'		overview
			'		HDPosterURL
			'		SHPosterURL
			'		episodeNumber
			
			curMeta.contentType = "episode"
			curMeta.title = episode.title
			curMeta.titleSeason = show.title + " Season " +  episode.season.toStr()
			if episode.overview = "" then
				curMeta.description = show.overview
			else
				curMeta.description = episode.overview
			endif
			curMeta.HDPosterURL = show.images.poster
			curMeta.SHPosterURL = show.images.poster
			
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
	
	dlg.close()
	calendarScreen.show()
	m.port = CreateObject("roMessagePort") 'Grid screen must use a separate message port variable
	calendarScreen.setMessagePort(m.port)

'	***	Set content list for all rows (each row is a date)

	for i = 0 to dateLabels.count()-1
		calendarScreen.setContentListSubset(i, dates[i], 0, dates[i].count())
	end for	
	
	calendarScreen.setUpBehaviorAtTopRow("stop")
	calendarScreen.setDescriptionVisible(true)
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
				pURL.aSyncCancel()
				selectedRow = dates[msg.getIndex()]
				selectedCol = selectedRow[msg.getData()]
				pURL.setURL(selectedCol.fanart)
				print "Fetching fanart at " + selectedCol.fanart
				fanart = pURL.aSyncGetToFile("tmp:/fanart/current.jpg")
				'print "Focused: " + msg.getContent()
			elseif msg.isListItemSelected()
			
				selectedRow = dates[msg.getIndex()]
				selectedCol = selectedRow[msg.getData()]
				selectedCol.date = dateLabels[msg.getIndex()]
				hold = wait(300, m.port)
					if type(hold) = "roGridScreenEvent" then 
						showQuickPopup(selectedCol)
					else
						if type(selectedRow[msg.getData()-1]) = invalid then
							selectedCol.left = false
						else
							selectedCol.left = selectedRow[msg.getData()-1]
						endif

						if type(selectedRow[msg.getData()+1]) = invalid then 
							selectedCol.right = false
						else
							selectedCol.right = selectedRow[msg.getData()+1]
						endif

						'Sends the curMeta containing all the show and episode information to the showInformation function.
						episodeInformation(selectedCol)
					endif
					
				
				
			endif
		endif
	end while
end function

