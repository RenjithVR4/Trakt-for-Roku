'*****************************************
'	aSyncFetch(url)
'	@params:    url as String to fetch from, 
'				(optional) writeToFile, if true, must supple filename to write to.
'				(optional) fileName, when writing to a file.
'				(optional) timeout as Integer (in miliseconds)
'				(optional) trace, boolean
'				(optional) addVars as roAssociativeArray (variables to be added to the JSON Post.)
'	@return:  	response as String
'*****************************************

function aSyncFetch(url as String, writeToFile = false, fileName = "tmp:/aSyncResponseTemp.txt", timeout% = 0, trace = false, addVars = "") as String
	
'	*** Define necessary variables ***
	if trace then print "Trace:  Entering aSyncFetch"
	if trace then print "Trace:  URL: " + url + ", Timeout: " + timeout%.toStr()
	
	response = createObject("roString")
	urlT = createObject("roURLtransfer")
	registry = createObject("roRegistrySection", "account")
	username = registry.read("username")
	password = registry.read("password")
	
	JSONArray = createObject("roAssociativeArray")
	JSONArray.username = username
	JSONArray.password = password
	
	if type(addVars) = "roAssociativeArray" then
		for each n in addVars
			JSONArray[n] = addVars[n]
		end for
	endif

	if trace then print "JSONArray: " 
	if trace then print JSONArray
'	*** Set URLTransfer Variables ***
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	urlT.setUrl(url)
	urlT.setPort(createObject("roMessagePort"))
	
'	*** Perform the fetch. ***simpleJSONBuilder
	if trace then print "Trace:  Beginning Fetch"
	
	num_retries%     = 5
	str = ""
	print simpleJSONBuilder(JSONArray)
	while num_retries% > 0
	    if (urlT.AsyncPostFromString(simpleJSONBuilder(JSONArray)))
	        event = wait(timeout%, urlT.GetPort())
	        if type(event) = "roUrlEvent"
	            respCode = event.GetResponseCode()
	            if respCode = 200 then
					if trace then print "Url Transfer with url " + url + " successful"
			        response = event.GetString()
	                exit while
	            else if respCode = 401 then
	                if trace then print "While updating trending shows with url " + url + ", returned 401 error (couldn't authenticate)"
					return "failed"
	            else   
	                if trace then print "While updating shows with url " + url + ", returned " + respCode.toStr() + " error (unknown error)"
					return "failed"
	        end if
	        elseif event = invalid
	            urlT.AsyncCancel()
	            urlT = CreateObject("roUrlTransfer")
	            urlT.SetPort(CreateObject("roMessagePort"))
	            urlT.SetUrl(url)
	            urlT.addHeader("username", username)
				urlT.addHeader("password", password)
	            timeout% = 4 * timeout%'
				if trace then print "retrying with timeout of: " + timeout%.toStr()
	        else
	            if trace then print "roUrlTransfer::AsyncPostFromString(): unknown event"
	            return "failed"	
	        endif
	        endif
	        num_retries% = num_retries% - 1
	    end while
	
	if trace then print "Response from server: "
	if trace then print response
	if response = "" then return "failed"
	
	if writeToFile then WriteASCIIFile(fileName, response)
	
	return response
	
end function

'*****************************************
'	sendRating()
'	@params:    String rating ("love" or "hate")
'				Object to rate (m)
'	
'*****************************************

function sendRating(m as Object, rating as String, trace = true) as boolean
	
	print m.show
	if type(m.contentType) = "invalid" OR type(m) = "invalid" then
		return false
	endif

	if m.contentType = "movie" then
		response = aSyncFetch("http://api.trakt.tv/rate/movie/" + getAPIKey(), false, "", 0, true,  {
			imdb_id : m.imdb_id
			title : m.title
			year : m.year.toStr()
			rating: rating
		})
		if response = "failed" then return false
		
		response = rdJSONParser(response)

		if response.status = "success" then
			print "Succeeded"
			return true
		else
			return false
		endif
	else if m.contentType = "show" OR m.contentType = "series" then
		print "Sending rating of show..."
		print m
		response = aSyncFetch("http://api.trakt.tv/rate/show/" + getAPIKey(), false, "", 0, false, {
			imdb_id : m.imdb_id
			title : m.title
			year : m.year.toStr()
			rating: rating
		})

		if response = "failed" then return false

		response = rdJSONParser(response)
		if response.status = "success" then
			return true
		else
			return false
		endif
	else if m.contentType = "episode" then
		response = aSyncFetch("http://api.trakt.tv/rate/episode/" + getAPIKey(), false, "", 0, true,  {
			tvdb_id : m.show.tvdb_id
			title : m.show.title
			year : m.show.year.toStr()
			rating: rating
			episode: m.episode.number.toStr()
			season : m.episode.season.toStr()
		})

		print response
		if response = "failed" then return false
		
		response = rdJSONParser(response)
		print response
		if response.status = "success" then
			return true
		else
			return false
		endif
	endif
end function


'*****************************************
'	addToWatchList(m)
'	@params:   
'				Object to add (m)
'	
'*****************************************

function addToWatchList(m as Object, trace = true) as boolean

	if trace then print m


	if type(m.contentType) = "invalid" OR type(m) = "invalid" then
		return false
	endif

	if m.contentType = "movie" then
		movies = [{
			imdb_id : m.imdb_id
			title: m.title
			year : m.year.toStr()
		}]
		response = aSyncFetch("http://api.trakt.tv/movie/watchlist/" + getAPIKey(), false, "", 0, true,  {
			movies : movies
		})
		if response = "failed" then
			return false
		endif

		response = rdJSONParser(response)

		if response.status = "success" then
			print "Succeeded"
			return true
		else
			return false
		endif
	else if m.contentType = "show" OR m.contentType = "series" then

		shows = [{
			imdb_id : m.imdb_id
			title : m.title
			year : m.year.toStr()
		}]

		response = rdJsonParser(aSyncFetch("http://api.trakt.tv/show/watchlist/" + getAPIKey(), false, "", 0, false, {
			shows : shows
		}))
		if response.status = "success" then
			return true
		else
			return false
		endif
	else if m.contentType = "episode" then

		episodes = [{
			season : m.episode.season.toStr()
			episode : m.episode.number.toStr()
		}]

		response = rdJsonParser(aSyncFetch("http://api.trakt.tv/show/episode/watchlist/" + getAPIKey(), false, "", 0, false,  {
			tvdb_id : m.show.imdb_id
			title : m.show.title
			year : m.show.year.toStr()
			episodes : episodes
		}))
		if response.status = "success" then
			return true
		else
			return false
		endif
	endif
end function

'*****************************************
'	removeFromWatchList(m)
'	@params:   
'				Object to add (m)
'	
'*****************************************

function removeFromWatchList(m as Object, trace = true) as boolean

	if trace then print m


	if type(m.contentType) = "invalid" OR type(m) = "invalid" then
		return false
	endif

	if m.contentType = "movie" then
		movies = [{
			imdb_id : m.imdb_id
			title: m.title
			year : m.year.toStr()
		}]
		response = aSyncFetch("http://api.trakt.tv/movie/unwatchlist/" + getAPIKey(), false, "", 0, true,  {
			movies : movies
		})
		if response = "failed" then
			return false
		endif

		response = rdJSONParser(response)

		if response.status = "success" then
			print "Succeeded"
			return true
		else
			return false
		endif
	else if m.contentType = "show" OR m.contentType = "series" then

		shows = [{
			imdb_id : m.imdb_id
			title : m.title
			year : m.year.toStr()
		}]

		response = rdJsonParser(aSyncFetch("http://api.trakt.tv/show/unwatchlist/" + getAPIKey(), false, "", 0, false, {
			shows : shows
		}))
		if response.status = "success" then
			return true
		else
			return false
		endif
	else if m.contentType = "episode" then

		episodes = [{
			season : m.episode.season.toStr()
			episode : m.episode.number.toStr()
		}]

		response = rdJsonParser(aSyncFetch("http://api.trakt.tv/show/episode/unwatchlist/" + getAPIKey(), false, "", 0, false,  {
			tvdb_id : m.show.imdb_id
			title : m.show.title
			year : m.show.year.toStr()
			episodes : episodes
		}))
		if response.status = "success" then
			return true
		else
			return false
		endif
	endif
end function

'*****************************************
'	addToCollection(m)
'	@params:   
'				Object to add (m)
'	
'*****************************************

function addToCollection(m as Object, trace = true) as boolean

	if trace then print m

	print 
	if type(m.contentType) = "invalid" OR type(m) = "invalid" then
		return false
	endif

	if m.contentType = "movie" then
		movies = [{
			imdb_id : m.imdb_id
			title: m.title
			year : m.year.toStr()
		}]
		response = aSyncFetch("http://api.trakt.tv/movie/library/" + getAPIKey(), false, "", 0, true,  {
			movies : movies
		})
		if response = "failed" then
			return false
		endif

		response = rdJSONParser(response)

		if response.status = "success" then
			print "Succeeded"
			return true
		else
			return false
		endif
	else if m.contentType = "show" OR m.contentType = "series" then
		print m
		

		response = aSyncFetch("http://api.trakt.tv/show/library/" + getAPIKey(), false, "", 0, true, {
			imdb_id : m.imdb_id
			title : m.title
			year : m.year.toStr()
		})
		if response = "failed" then return false

		print response
		response = rdJSONParser(response)

		if response.status = "success" then
			return true
		else
			return false
		endif
	else if m.contentType = "episode" then

		episodes = [{
			season : m.episode.season.toStr()
			episode : m.episode.number.toStr()
		}]

		response = rdJsonParser(aSyncFetch("http://api.trakt.tv/show/episode/library/" + getAPIKey(), false, "", 0, false,  {
			tvdb_id : m.show.tvdb_id
			title : m.show.title
			year : m.show.year.toStr()
			episodes : episodes
		}))
		if response.status = "success" then
			return true
		else
			return false
		endif
	endif
end function