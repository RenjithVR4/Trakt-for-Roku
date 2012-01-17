'*****************************************
'	getDateString()
'	@params:    trace
'	@return:  	current date as trakt-ready string ("YYYYMMDD")
'*****************************************

function getDateString(trace = false) as String

	dateTime = createObject("roDateTime")
	dateTime.toLocalTime()
	
	year = dateTime.getYear()
	month = dateTime.getMonth()
	day = dateTime.getDayOfMonth()
	
	y = year.toStr()
	
	if month < 10 then
		m = "0" + month.toStr()
	else
		m = month.toStr()
	endif
	
	if day < 10 then
		d = "0" + day.toStr()
	else
		d = day.toStr()
	endif
	
	dateString = y + m + d
	if trace then print dateString
	return dateString
	
end function	

'*****************************************
'	conCat()
'	@params:    in as String, length as Integer, trace
'	@return:  	string concatenated to length characters, plus "..."
'*****************************************

function conCat(in as String, len as Integer, trace = false) as String
	if trace then print "Shortening string to " + len + " characters."
	
	if len(in) > len then
		beg = left(in, len)
		return (beg + "...")
	else
		return in
	endif
end function

'*****************************************
'	global(varName as String) as Object
'	@params:    varName as string
'	@return:  	global variable nedded
'*****************************************

function global(varName as String) as Object
	globalVars = {
		
	}
	return false
end function

function createSimpleLoadingScreen(title = "Loading", text = "Please wait...", trace = false) as Object

	if trace then print "Creating simple loading screen.  Title: " + title + ". Text: " + text + "."
	dlg = createObject("roMessageDialog")
	dlg.setTitle(title)
	dlg.setText(text)
	dlg.showBusyAnimation()
	return dlg
	
end function

'*****************************************
'	getResgistry as Object
'	@params:    registry section name
'	@return:  	registry variable
'*****************************************

function getRegistry(sectionName as String, trace = false) as Object

	if trace then print "Getting registry section " + sectionName
	return (createObject("roRegistrySection", sectionName))
	
end function

'*****************************************
'	mod as Object
'	@params:    Two integers (a, b)
'	@return:  	a%b
'*****************************************
function mod(a as Integer, b as Integer) as Integer
	if (b-a) > a then
		return mod(a, (b-a))
	endif
	if (b-a) < 0 then
		return (a-b)+1
	else if (b-a) < 0 then
		return abs((b-a)-1)
	else
		return 0
	endif
end function

function processDateString(in as String) as String
'	@TODO
	return in
end function

function getAPIKey() as String
	return "3b6a4155df1177be7bb9db887b42b64b"
end function

'*****************************************
'	parsePosterImage as String
'	@params:    Full Poster URL, String representing the quality of image desired.
'	@return:  	Parsed URL string
'*****************************************

function parsePosterImage(poster as String, quality as String) as String
	posterURL = left(poster, 41)
	posterRight = right(poster, poster.len()-41)
	posterExtension = right(posterRight, 4)
	imageNumber = left(posterRight, posterRight.len()-4)
	return posterURL + imageNumber + "-" + quality + posterExtension
end function

'*****************************************
'	downloadFanart as void
'	@params:    URL of Fanart
'	@return:  	none (fanart will be saved as "tmp:/fanart.jpg")
'*****************************************

function downloadFanart(url as String)
	urlT = createObject("roURLTransfer")
	urlT.setUrl(url)
	urlT.GetToFile("tmp:/fanart.jpg")
end function

'*****************************************
'	reloadContent as boolean
'	@params:    URL of Content, fileName to save to.
'	@return:  	true or false on success or failure
'*****************************************

function reloadContent(url as String, fileName as String, trace = false) as boolean
	if trace then print "Reloading content (tools.brs > l.147)"
	if trace then print "Downloading from " + url + " to " + fileName
	

	dlg = createObject("roOneLineDialog")
	dlg.setTitle("Talking to trakt.tv...")
	dlg.showBusyAnimation()
	dlg.show()
	
	registry = getRegistry("account")
	if trace then 
		data = aSyncFetch(url, false, "", 0, true)
	else
		data = aSyncFetch(url)
	endif
	dlg.close()
	if data = "failed" then 
		dlg = createObject("roMessageDialog")
		dlg.setTitle("Could not download data.")
		dlg.setText("Sometimes this means trakt didn't respond, or the response timed out.  Try again.  If the problem persists, you can reload the app or even relink your account.")
		dlg.addButton(0, "Ok :(")
		dlg.setMessagePort(createObject("roMessagePort"))
		dlg.show()
		
		while true
			msg = wait(0, dlg.getMessagePort())
			if msg.isButtonPressed() then 
				dlg.close()
				return false
			endif
		end while
	end if
	
	WriteASCIIFile(fileName, data) 'Save the file for future use.
	flagFile(fileName, "false")
	
	return true
end function

'*****************************************
'	checkForLocalContent as boolean
'	@params:    fileName to search for
'	@return:  	true or false on success or failure
'*****************************************

function checkForLocalContent(fileName as String) as boolean

	file = ReadASCIIFile(fileName)
	if file = "failed" then return false
	if type(file) = invalid then return false
	if file = "" then return false

	return true
	
end function

'*****************************************
'	checkForContentAndReload as boolean
'	@params:    fileName to search for, url if not found
'	@return:  	true or false on success or failure
'*****************************************

function checkForContentAndReload(fileName as String, url as String) as boolean

	if NOT isFlagged(fileName) AND checkForLocalContent(fileName)  then return true
	return reloadContent(url, filename)
	
end function

'*****************************************
'	flag as void
'	Flags a file to need to be reloaded for any reason (usually a trakt.tv update.)
'	@params:    fileName to flag, reload (string boolean)
'*****************************************

function flagFile(filename as String, reload = "true") as void
	print "Flagging file: " + filename + "as reload: " + reload
	registry = getRegistry("flags")
	registry.write(filename, reload)
	registry.flush()
end function

function isFlagged(file as String) as boolean
	print "Looking for file: " file
	registry = getRegistry("flags")
	flag = registry.read(file)
	print flag

	if flag = "" or flag = "false" then return false
	if flag = "true" then return true

end function

function getMovieGenres() as Object
	genres = [
		"All Genres",
		"Action", 
		"Adventure", 
		"Animation", 
		"Comedy", 
		"Crime", 
		"Documentary", 
		"Drama", 
		"Family", 
		"Fantasy", 
		"Film Noir", 
		"History", 
		"Horror", 
		"Indie", 
		"Music", 
		"Musical", 
		"Mystery", 
		"Romance", 
		"Science Fiction", 
		"Sport", 
		"Suspence", 
		"Thriller", 
		"War", 
		"Western"
	]

	return genres

end function

function getTVGenres() as Object
	genres = [
		"All Genres",
		"Action", 
		"Adventure", 
		"Animation", 
		"Children",
		"Comedy", 
		"Documentary", 
		"Drama", 
		"Family", 
		"Fantasy", 
		"Game Show",
		"Home and Garden",
		"Mini Series", 
		"News", 
		"Reality", 
		"Science Fiction", 
		"Soap",
		"Sport", 
		"Talk Show",
		"Western"
	]

	return genres

end function

function getGenreIndex(genres as Object, name as String) as Integer
	for i = 0 to genres.count()-1
		if name = genres[i] then return i
	end for
	return 0 'Safety net to avoid out of bounds exceptions.
end function

function spaceEscape(rep as String)
	regex = createObject("roRegex", "\s+", "i")
	return regex.replaceAll(rep, "+")
end function