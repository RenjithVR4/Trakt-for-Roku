
function runTvRecommendations(trace = false) as Integer
	if trace then print "Running T.V. Recommendations screen."
	
	loading = createObject("roOneLineDialog")
	loading.setTitle("Downloading Content from Trakt.tv")
	loading.showBusyAnimation()
	loading.show()
	
	if checkForContentAndReload("tmp:/tv.txt", "http://api.trakt.tv/recommendations/shows/" + getAPIKey()) then
		tv = ReadASCIIFile("tmp:/tv.txt")
	else
		return -1
	endif

	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing recommendation data")
	dlg.showBusyAnimation()
	loading.close()
	dlg.show()
	
	
	tv = rdJSONParser(tv)
	
	content = createObject("roArray", 0, true)
	
	screen = createObject("roPosterScreen")
	screen.setListStyle("arced-portrait")
	screen.setbreadCrumbText("trakt.tv", "T.V. Recommendations")
	screen.setBreadCrumbEnabled(true)
	
	len = tv.count()
		
	for i = 0 to (len-1)
		curMeta = tv[i]
		curMeta.contentType = "series"
		curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
		
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = curMeta.ratings.percentage.toStr() + "% loved"
		curMeta.country = curMeta.country + " •"
		content.push(curMeta)
	end for
	
	screen.setContentList(content)
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()
	
	while true
		msg = wait(0, screen.getMessagePort())
			if msg.isListItemSelected() then
				showInformation(content[msg.getIndex()])
			else if msg.isScreenClosed() then
				exit while
			endif
	end while
	
	screen.close()
	return 0
end function

function runMovieRecommendations(trace = true) as Integer
	
	if trace then print "Running Movie Recommendations screen."
	
	loading = createObject("roOneLineDialog")
	loading.setTitle("Downloading Content from Trakt.tv")
	loading.showBusyAnimation()
	loading.show()
	
	if checkForContentAndReload("tmp:/movies.txt", "http://api.trakt.tv/recommendations/movies/" + getAPIKey()) then
		movies = ReadASCIIFile("tmp:/movies.txt")
	else
		return -1
	endif
	
	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing recommendation data")
	dlg.showBusyAnimation()
	loading.close()
	
	dlg.show()
	
	movies = rdJSONParser(movies)
	
	content = createObject("roArray", 0, true)
	
	m_screen = createObject("roPosterScreen")
	m_screen.setListStyle("arced-portrait")
	m_screen.setbreadCrumbText("trakt.tv", "Movie Recommendations")
	m_screen.setBreadCrumbEnabled(true)
	
	len = movies.count()
		
	for i = 0 to (len-1)
		curMeta = movies[i]
		curMeta.contentType = "movie"
		curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
		
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = curMeta.ratings.percentage.toStr() + "% loved"
		curMeta.country = ""
		'print curMeta
		content.push(curMeta)
	end for
	
	print type(content)
	m_screen.setContentList(content)
	m_screen.setMessagePort(createObject("roMessagePort"))
	m_screen.show()
	
	while true
		msg = wait(0, m_screen.getMessagePort())
		print msg.getIndex()
			if msg.isListItemSelected() then
				movieInformation(content[msg.getIndex()])
			else if msg.isScreenClosed() then
				return 0
			endif
	end while
	return 0
end function

