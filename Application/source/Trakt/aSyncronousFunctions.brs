'*****************************************
'	aSyncFetch(url)
'	@params:    url as String to fetch from, 
'				(optional) writeToFile, if true, must supple filename to write to.
'				(optional) fileName, when writing to a file.
'				(optional) timeout as Integer (in miliseconds)
'	@return:  	response as String
'*****************************************

function aSyncFetch(url as String, writeToFile = false, fileName = "tmp:/aSyncResponseTemp.txt", timeout% = 0, trace = false) as String
	
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
	
'	*** Set URLTransfer Variables ***
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	urlT.setUrl(url)
	urlT.setPort(createObject("roMessagePort"))
	
'	*** Perform the fetch. ***simpleJSONBuilder
	if trace then print "Trace:  Beginning Fetch"
	
	num_retries%     = 5
	str = ""
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

function sendRating(rating as String, m as Object) as void
	response = createObject("roString")
	urlT = createObject("roURLtransfer")
	registry = createObject("roRegistrySection", "account")
	username = registry.read("username")
	password = registry.read("password")
	
	JSONArray = createObject("roAssociativeArray")
	JSONArray.username = username
	JSONArray.password = password
	JSONArray.imdb_id = m.imdb
	JSONArray.title = m.show
	JSONArray.year = m.year
	JSONArray.rating = rating
	
'	*** Set URLTransfer Variables ***
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	urlT.setUrl("http://api.trakt.tv/rate/show/" + getAPIKey())
	
'	*** Perform the send. ***
	urlT.aSyncPostFromString(simpleJSONBuilder(JSONArray))
	print "Sent..."
end function