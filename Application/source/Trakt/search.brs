function searchMovies() as boolean
	screen = createObject("roSearchScreen")
	screen.setSearchTermHeaderText("Recent Searches:")
	screen.setSearchButtonText("Search")
	screen.setClearButtonText("Clear")
	screen.setBreadCrumbText("trakt.tv","Movie Search")
	screen.setMessagePort(createObject("roMessagePort"))

	history = createObject("roArray", 0, true)

	screen.show()

	while true
		msg = wait(0, screen.getMessagePort())
		if msg.isScreenClosed() then
			return false
		else if msg.isFullResult() then
			history.push(msg.getMessage())
			screen.addSearchTerm(msg.getMessage())
			print "Searching for " msg.getMessage()
			dlg = createObject("roOneLineDialog")
			dlg.setTitle("Seaching...")
			dlg.showBusyAnimation()
			dlg.show()

			result = aSyncFetch("http://api.trakt.tv/search/movies.json/" + getAPIKey() + "/" + spaceEscape(msg.getMessage()), false, "", 0, true)

			if not result = "failed" then
				result = rdJSONParser(result)
				showSearchResults(result, "movies", msg.getMessage())
				dlg.close()
			else
				error = createErrorMessage("Search Failed", "Could not contact trakt.tv.  Try again.")
				dlg.close()
			endif

		endif
	end while


end function

function searchShows() as boolean
	screen = createObject("roSearchScreen")
	screen.setSearchTermHeaderText("Recent Searches:")
	screen.setSearchButtonText("Search")
	screen.setClearButtonText("Clear")
	screen.setBreadCrumbText("trakt.tv","Show Search")
	screen.setMessagePort(createObject("roMessagePort"))

	history = createObject("roArray", 0, true)

	screen.show()

	while true
		msg = wait(0, screen.getMessagePort())
		if msg.isScreenClosed() then
			return false
		else if msg.isFullResult() then
			history.push(msg.getMessage())
			screen.addSearchTerm(msg.getMessage())
			print "Searching for " msg.getMessage()
			dlg = createObject("roOneLineDialog")
			dlg.setTitle("Seaching...")
			dlg.showBusyAnimation()
			dlg.show()

			result = aSyncFetch("http://api.trakt.tv/search/shows.json/" + getAPIKey() + "/" + spaceEscape(msg.getMessage()), false, "", 0, true)
			

			if not result = "failed" then
				result = rdJSONParser(result)
				showSearchResults(result, "shows", msg.getMessage())
				dlg.close()
			else
				error = createErrorMessage("Search Failed", "Could not contact trakt.tv.  Try again.")
				dlg.close()
			endif

		endif
	end while


end function

function searchEpisodes() as boolean
	screen = createObject("roSearchScreen")
	screen.setSearchTermHeaderText("Recent Searches:")
	screen.setSearchButtonText("Search")
	screen.setClearButtonText("Clear")
	screen.setBreadCrumbText("trakt.tv","Show Search")
	screen.setMessagePort(createObject("roMessagePort"))

	history = createObject("roArray", 0, true)

	screen.show()

	while true
		msg = wait(0, screen.getMessagePort())
		if msg.isScreenClosed() then
			return false
		else if msg.isFullResult() then
			history.push(msg.getMessage())
			screen.addSearchTerm(msg.getMessage())
			print "Searching for " msg.getMessage()
			dlg = createObject("roOneLineDialog")
			dlg.setTitle("Seaching...")
			dlg.showBusyAnimation()
			dlg.show()

			result = aSyncFetch("http://api.trakt.tv/search/episodes.json/" + getAPIKey() + "/" + spaceEscape(msg.getMessage()), false, "", 0, true)

			if not sesult = "failed" then
				
				result = rdJSONParser(result)
				showSearchResults(result, "episodes", msg.getMessage())
				dlg.close()
			else

				error = createErrorMessage("Search Failed", "Could not contact trakt.tv.  Try again.")
				dlg.close()

			endif

		endif
	end while


end function
