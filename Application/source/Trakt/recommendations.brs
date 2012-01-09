function runTvRecommendations(trace = false) as Integer
	if trace then print "Running T.V. Recommendations screen."
	
'	*** Try and load the file in the tmp:/ directory
	tv = ReadASCIIFile("tmp:/tv.txt")
	if tv = "failed" then goto reload
	if type(tv) = invalid then goto reload
	if tv = "" then goto reload
	
	goto display

'	*** If the file is not found or is invalid, try to create it again.
reload:

	dlg = createSimpleLoadingScreen("Loading Content", "Recommendations generally take a little longer to load.")
	dlg.show()
	
	registry = getRegistry("account")
	tv = aSyncFetch("http://api.trakt.tv/recommendations/shows/" + getAPIKey())
	dlg.close()
	
	if tv = "failed" then 
		dlg = createObject("roMessageDialog")
		dlg.setTitle("Could not load recommendation data")
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
	
	WriteASCIIFile("tmp:/tv.txt", tv) 'Save the file for future use.
	
display:
	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing recommendation data")
	dlg.showBusyAnimation()
	dlg.show()
	tv = rdJSONParser(tv)
	print type(tv)
	
	content = createObject("roArray", 0, true)
	
	screen = createObject("roPosterScreen")
	screen.setListStyle("arced-portrait")
	screen.setbreadCrumbText("trakt.tv", "T.V. Recommendations")
	screen.setBreadCrumbEnabled(true)
	
	len = tv.count()
		
	for i = 0 to (len-1)
		curMeta = tv[i]
		curMeta.contentType = "series"
		poster = curMeta.images.poster
		posterURL = left(poster, 41)
		posterRight = right(poster, poster.len()-41)
		posterExtension = right(posterRight, 4)
		imageNumber = left(posterRight, posterRight.len()-4)
		
		curMeta.HDPosterURL = posterURL + imageNumber + "-138" + posterExtension
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = curMeta.ratings.percentage.toStr() + "% loved"
		curMeta.country = curMeta.country + " •"
		'print curMeta
		content.push(curMeta)
	end for
	
	print type(content)
	screen.setContentList(content)
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()
	
	while true
		msg = wait(0, screen.getMessagePort())
			if msg.isListItemSelected() then
				showInformation(content[msg.getIndex()])
			else if msg.isScreenClosed() then
				screen.close()
				return 0
			endif
	end while
	return 0
end function

function runMovieRecommendations(trace = false) as Integer
	if trace then print "Running Movie Recommendations screen."
	
'	*** Try and load the file in the tmp:/ directory
	movies = ReadASCIIFile("tmp:/movies.txt")
	if movies = "failed" then goto reload
	if type(movies) = invalid then goto reload
	if movies = "" then goto reload
	
	goto display

'	*** If the file is not found or is invalid, try to create it again.
reload:

	dlg = createSimpleLoadingScreen("Loading Content", "Recommendations generally take a little longer to load.")
	dlg.show()
	
	registry = getRegistry("account")
	movies = aSyncFetch("http://api.trakt.tv/recommendations/movies/" + getAPIKey())
	dlg.close()
	
	if movies = "failed" then 
		dlg = createObject("roMessageDialog")
		dlg.setTitle("Could not load recommendation data")
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
	
	WriteASCIIFile("tmp:/movies.txt", movies) 'Save the file for future use.
	
display:
	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing recommendation data")
	dlg.showBusyAnimation()
	dlg.show()
	movies = rdJSONParser(movies)
	print type(movies)
	
	content = createObject("roArray", 0, true)
	
	screen = createObject("roPosterScreen")
	screen.setListStyle("arced-portrait")
	screen.setbreadCrumbText("trakt.tv", "Movie Recommendations")
	screen.setBreadCrumbEnabled(true)
	
	len = movies.count()
		
	for i = 0 to (len-1)
		curMeta = movies[i]
		curMeta.contentType = "movie"
		poster = curMeta.images.poster
		posterURL = left(poster, 41)
		posterRight = right(poster, poster.len()-41)
		posterExtension = right(posterRight, 4)
		imageNumber = left(posterRight, posterRight.len()-4)
		
		curMeta.HDPosterURL = posterURL + imageNumber + "-138" + posterExtension
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = curMeta.ratings.percentage.toStr() + "% loved"
		curMeta.country = ""
		'print curMeta
		content.push(curMeta)
	end for
	
	print type(content)
	screen.setContentList(content)
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()
	
	while true
		msg = wait(0, screen.getMessagePort())
		print msg.getIndex()
			if msg.isListItemSelected() then
				movieInformation(content[msg.getIndex()])
			else if msg.isScreenClosed() then
				return 0
			endif
	end while
	return 0
end function

