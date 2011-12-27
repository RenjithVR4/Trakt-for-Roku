Function init()  as Integer
init:
	initTheme()
	screen=preShowPosterScreen("", "")
    	if screen=invalid then
        	print "unexpected error in preShowPosterScreen"
        	return -1
    	end if
	
	registry = CreateObject("roRegistrySection", "account")
	if  not registry.exists("username") then 
		dlg = CreateObject("roMessageDialog")
		dlg.setTitle("Link account before using the app.")
		dlg.setText("Because this app is based on your personal trakt profile and recommendations, it's important to link your account.  This only needs to be done once.")
		dlg.addButton(0, "Link Trakt.tv Account")
		dlg.setMessagePort(CreateObject("roMessagePort"))
		dlg.show()
		while true
			msg = wait(0, dlg.getMessagePort())
			if msg.isButtonPressed() then
				if linkAccount() = 1 then
					showPosterScreen(screen)
					return 0
				else
					END
					return -1
				endif
			endif
		end while
	endif
	
	showPosterScreen(screen)
	return 0
	
end function

function aSyncGetCalendar(t as String) as Integer
	print "Running getCalendar"
	response = ""
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	JSONArray = CreateObject("roAssociativeArray")
	username = registry.read("username")
	password = registry.read("password")
	JSONArray.username = username
	JSONArray.password = password
	urlT = createObject("roURLTransfer")
	dateO = createObject("roDateTime")
	month = dateO.getMonth()
	year = dateO.getYear()
	day = dateO.getDayOfMonth()
	
	calendar_days = "07"
	if registry.exists("calendar_days") then
		'calendar_days = registry.read("calendar_days")
	endif
	url = "http://api.trakt.tv/user/calendar/shows.json/" + getAPIKey() + "/justin/" + year.toStr() + month.toStr() + day.toStr() + "/" + calendar_days
	urlT.setUrl(url)
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	timeout%         = 1500
    num_retries%     = 5
    str = ""
    while num_retries% > 0
    	if (urlT.AsyncPostFromString(SimpleJSONBuilder(JSONArray)))
            event = wait(timeout%, urlT.GetPort())
            if type(event) = "roUrlEvent"
                 respCode = event.GetResponseCode()
                 if respCode = 200 then
                     response = event.GetString()
                         exit while
                 else if respCode = 401 then
                 	print "While updating calendar / shows with url " + url + ", returned 401 error (couldn't authenticate) (init->aSyncGetCalendar(" + t + "))"
                 	  	response = "failed"
						exit while
					else
              		print "While updating calendar / shows with url " + url + ", returned " + respCode.toStr() + " error (unknown error) (init->aSyncGetCalendar(" + t + "))"
					response = "failed"
					exit while
                 end if
            elseif event = invalid

                urlT.AsyncCancel()
                urlT = CreateObject("roUrlTransfer")
                urlT.SetPort(CreateObject("roMessagePort"))
                urlT.SetUrl(url)
                urlT.addHeader("username", username)
				urlT.addHeader("password", password)
                timeout% = 2 * timeout%
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
                response = "failed"
				exit while
            endif
        endif
        num_retries% = num_retries% - 1
    end while
	if response = "" then 
		response = "failed"
	endif
	
	writeASCIIFile("tmp:/cal_" + t + ".txt", response)
	print "Wrote to file: cal_" + t + ".txt:" + response
end function

function aSyncGetTVRecommendations() as Integer
	print "Getting TV recommendations"
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	JSONArray = CreateObject("roAssociativeArray")
	username = registry.read("username")
	password = registry.read("password")
	JSONArray.username = username
	JSONArray.password = password
	urlT = createObject("roURLTransfer")
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	url = "http://api.trakt.tv/recommendations/shows/" + getAPIKey()
	urlT.setUrl(url)
	
		timeout%         = 1500
	    num_retries%     = 5
	    str = ""
	    while num_retries% > 0
	        if (urlT.AsyncPostFromString(SimpleJSONBuilder(JSONArray)))
	            event = wait(timeout%, urlT.GetPort())
	            if type(event) = "roUrlEvent"
	                 respCode = event.GetResponseCode()
	                 if respCode = 200 then
						response = event.getString()
	                     exit while
	                 else if respCode = 401 then
	                 	print "While updating recommendations / shows with url " + url + ", returned 401 error (couldn't authenticate) (init->aSyncGetTVRecommendations)"
						return respCode
	                 else   
	                 	print "While updating recommendations / shows with url " + url + ", returned " + respCode.toStr() + " error (unknown error) (init->aSyncGetTVRecommendations)"
	                 	return respCode
						end if
	            elseif event = invalid
	                urlT.AsyncCancel()
	                urlT = CreateObject("roUrlTransfer")
	                urlT.SetPort(CreateObject("roMessagePort"))
	                urlT.SetUrl(url)
	                urlT.addHeader("username", username)
					urlT.addHeader("password", password)
	                timeout% = 2 * timeout%
	            else
	                print "roUrlTransfer::AsyncPostFromString(): unknown event"
	                return -1
	            endif
	        endif
	        num_retries% = num_retries% - 1
	    end while
		WriteASCIIFile("tmp:/tvrecommendations.txt", response)
		print "Writing to file tvrecommendations.txt:" + response
		
	return 0
end function
function aSyncGetMovieRecommendations() as Integer
	response = ""
	print "Getting Movie recommendations"
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	JSONArray = CreateObject("roAssociativeArray")
	username = registry.read("username")
	password = registry.read("password")
	JSONArray.username = username
	JSONArray.password = password
	urlT = createObject("roURLTransfer")
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	url = "http://api.trakt.tv/recommendations/movies/" + getAPIKey()
	urlT.setUrl(url)
	
		timeout%         = 1500
	    num_retries%     = 5
	    str = ""
	    while num_retries% > 0
	        if (urlT.AsyncPostFromString(SimpleJSONBuilder(JSONArray)))
	            event = wait(timeout%, urlT.GetPort())
	            if type(event) = "roUrlEvent"
	                 respCode = event.GetResponseCode()
	                 if respCode = 200 then
						print "Successful response"
						response = event.getString()
	                     exit while
	                 else if respCode = 401 then
	                 	print "While updating recommendations / movies with url " + url + ", returned 401 error (couldn't authenticate) (init->aSyncGetMovieRecommendations)"
						return respCode
	                 else   
	                 	print "While updating recommendations / movies with url " + url + ", returned " + respCode.toStr() + " error (unknown error) (init->aSyncGetMovieRecommendations)"
						return respCode
	                 end if
	            elseif event = invalid
	                urlT.AsyncCancel()
	                urlT = CreateObject("roUrlTransfer")
	                urlT.SetPort(CreateObject("roMessagePort"))
	                urlT.SetUrl(url)
	                urlT.addHeader("username", username)
					urlT.addHeader("password", password)
	                timeout% = 2 * timeout%
	            else
	                print "roUrlTransfer::AsyncPostFromString(): unknown event"
	                return respCode
					
	            endif
	        endif
	        num_retries% = num_retries% - 1
	    end while
	
		WriteASCIIFile("tmp:/movierecommendations.txt", response)
		print "Writing to file movierecommendations.txt:" + response
		
	return 0
end function
function aSyncGetFriends() as Integer
	response = ""
	print "Getting Friends"
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	JSONArray = CreateObject("roAssociativeArray")
	username = registry.read("username")
	password = registry.read("password")
	JSONArray.username = username
	JSONArray.password = password
	urlT = createObject("roURLTransfer")
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	url = "http://api.trakt.tv/friends/all/" + getAPIKey()
	urlT.setUrl(url)
	
		timeout%         = 1500
	    num_retries%     = 5
	    str = ""
	    while num_retries% > 0
	        if (urlT.AsyncPostFromString(SimpleJSONBuilder(JSONArray)))
	            event = wait(timeout%, urlT.GetPort())
	            if type(event) = "roUrlEvent"
	                 respCode = event.GetResponseCode()
	                 if respCode = 200 then
						print "Successful response"
						response = event.getString()
	                     exit while
	                 else if respCode = 401 then
	                 	print "While updating friends with url " + url + ", returned 401 error (couldn't authenticate) (init->aSyncGetFriends)"
						return respCode
	                 else   
	                 	print "While updating friends with url " + url + ", returned " + respCode.toStr() + " error (unknown error) (init->aSyncGetFriends)"
						return respCode
	                 end if
	            elseif event = invalid
	                urlT.AsyncCancel()
	                urlT = CreateObject("roUrlTransfer")
	                urlT.SetPort(CreateObject("roMessagePort"))
	                urlT.SetUrl(url)
	                urlT.addHeader("username", username)
					urlT.addHeader("password", password)
	                timeout% = 2 * timeout%
	            else
	                print "roUrlTransfer::AsyncPostFromString(): unknown event"
	                return respCode
					
	            endif
	        endif
	        num_retries% = num_retries% - 1
	    end while
	
		WriteASCIIFile("tmp:/friends.txt", response)
		print "Writing to file friends.txt:" + response
		
	return 0
end function
function aSyncGetTrendingMovies() as Integer
	response = ""
	print "Getting Trending Movies"
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	JSONArray = CreateObject("roAssociativeArray")
	username = registry.read("username")
	password = registry.read("password")
	JSONArray.username = username
	JSONArray.password = password
	urlT = createObject("roURLTransfer")
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	url = "http://api.trakt.tv/movies/trending.json/" + getAPIKey()
	urlT.setUrl(url)
	
		timeout%         = 1500
	    num_retries%     = 5
	    str = ""
	    while num_retries% > 0
	        if (urlT.AsyncPostFromString(SimpleJSONBuilder(JSONArray)))
	            event = wait(timeout%, urlT.GetPort())
	            if type(event) = "roUrlEvent"
	                 respCode = event.GetResponseCode()
	                 if respCode = 200 then
						print "Successful response"
						response = event.getString()
	                     exit while
	                 else if respCode = 401 then
	                 	print "While updating trending movies with url " + url + ", returned 401 error (couldn't authenticate) (init->aSyncGetTrendingMovies)"
						return respCode
	                 else   
	                 	print "While updating friends with url " + url + ", returned " + respCode.toStr() + " error (unknown error) (init->aSyncGetTrendingMovies)"
						return respCode
	                 end if
	            elseif event = invalid
	                urlT.AsyncCancel()
	                urlT = CreateObject("roUrlTransfer")
	                urlT.SetPort(CreateObject("roMessagePort"))
	                urlT.SetUrl(url)
	                urlT.addHeader("username", username)
					urlT.addHeader("password", password)
	                timeout% = 2 * timeout%
	            else
	                print "roUrlTransfer::AsyncPostFromString(): unknown event"
	                return respCode
					
	            endif
	        endif
	        num_retries% = num_retries% - 1
	    end while
	
		WriteASCIIFile("tmp:/trending_movies.txt", response)
		print "Writing to file trending_movies.txt:" + response
		
	return 0
end function
function aSyncGetTrendingShows() as Integer
	response = ""
	print "Getting Trending Shows"
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	JSONArray = CreateObject("roAssociativeArray")
	username = registry.read("username")
	password = registry.read("password")
	JSONArray.username = username
	JSONArray.password = password
	urlT = createObject("roURLTransfer")
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	url = "http://api.trakt.tv/shows/trending.json/" + getAPIKey()
	urlT.setUrl(url)
	
		timeout%         = 1500
	    num_retries%     = 5
	    str = ""
	    while num_retries% > 0
	        if (urlT.AsyncPostFromString(SimpleJSONBuilder(JSONArray)))
	            event = wait(timeout%, urlT.GetPort())
	            if type(event) = "roUrlEvent"
	                 respCode = event.GetResponseCode()
	                 if respCode = 200 then
						print "Successful response"
						response = event.getString()
	                     exit while
	                 else if respCode = 401 then
	                 	print "While updating trending shows with url " + url + ", returned 401 error (couldn't authenticate) (init->aSyncGetTrendingShows)"
						return respCode
	                 else   
	                 	print "While updating shows with url " + url + ", returned " + respCode.toStr() + " error (unknown error) (init->aSyncGetTrendingShows)"
						return respCode
	                 end if
	            elseif event = invalid
	                urlT.AsyncCancel()
	                urlT = CreateObject("roUrlTransfer")
	                urlT.SetPort(CreateObject("roMessagePort"))
	                urlT.SetUrl(url)
	                urlT.addHeader("username", username)
					urlT.addHeader("password", password)
	                timeout% = 2 * timeout%
	            else
	                print "roUrlTransfer::AsyncPostFromString(): unknown event"
	                return respCode
					
	            endif
	        endif
	        num_retries% = num_retries% - 1
	    end while
	
		WriteASCIIFile("tmp:/trending_shows.txt", response)
		print "Writing to file trending_shows.txt:" + response
		
	return 0
end function

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