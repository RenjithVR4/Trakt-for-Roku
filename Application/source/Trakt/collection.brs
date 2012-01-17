Function runWatchlist(trace = false) as Integer
	if trace then print "Running watchlist screen."
	
	registry = getRegistry("account")
	
	if checkForContentAndReload("tmp:/watchlist_tv.txt", "http://api.trakt.tv/user/watchlist/shows.json/" + getAPIKey() + "/" + registry.read("username")) then
		watchlist_tv = ReadASCIIFile("tmp:/watchlist_tv.txt")
	else
		return -1
	endif
	
	if checkForContentAndReload("tmp:/watchlist_movies.txt", "http://api.trakt.tv/user/watchlist/movies.json/" + getAPIKey() + "/" + registry.read("username")) then
		watchlist_movies = ReadASCIIFile("tmp:/watchlist_movies.txt")
	else
		return -1
	endif
	
	if trace then print "Displaying..."
	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing watchlist data")
	dlg.showBusyAnimation()
	dlg.show()
	
	tv = rdJSONParser(watchlist_tv)
	movies = rdJSONParser(watchlist_movies)
	
	content = createObject("roArray", 2, true)
	content[0] = createObject("roArray", 0, true) 	'Tv
	content[1] = createObject("roArray", 0, true)	'Movies
	
	for i = 0 to (tv.count()-1)
		curMeta = tv[i]
		curMeta.contentType = "series"
		curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = curMeta.ratings.percentage.toStr() + "% loved"
		curMeta.country = curMeta.country + " •"
		curMeta.functionPrefix = "show"
		'print curMeta
		content[0].push(curMeta)
	end for
	for i = 0 to (movies.count()-1)
		curMeta = movies[i]
		curMeta.contentType = "movie"
		curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = curMeta.tagline
		curMeta.country = ""'
		curMeta.functionPrefix = "movie"
		'print curMeta
		content[1].push(curMeta)
	end for
	
	if trace then print content[0][0]
	if trace then print content[1]
	screen = createObject("roPosterScreen")
	screen.SetTitle("My Watchlist")
    screen.SetContentList(content[0])
    screen.SetBreadcrumbText("My Collection", "My Watchlist")
	screen.setListNames(["T.V. Watchlist", "Movie Watchlist"])
	screen.setMessagePort(createObject("roMessagePort"))
	dlg.close()
    screen.Show()

	while true
        msg = wait(0, screen.getmessageport())
        if msg.isScreenClosed() then
        	return 0
        
		else if msg.isListFocused() then
			screen.setContentList(content[msg.getIndex()])
			screen.setFocusedListItem(0)
			
        else if msg.isListItemSelected() then
        	currentList = screen.getContentList()
        	print currentList[msg.getIndex()]
			if currentList[msg.getIndex()].contentType = "series" OR currentList[msg.getIndex()].contentType = "show" then 
				showInformation(currentList[msg.getIndex()])
			else 
				movieInformation(currentList[msg.getIndex()])
			endif
        endif
    end while
end function

function runMovieCollection(trace = false) as Integer
	if trace then print "Loading movie collection"
	
	registry = getRegistry("account")
	
	if checkForContentAndReload("tmp:/movie_collection.txt", "http://api.trakt.tv/user/library/movies/collection.json/" + getAPIKey() + "/" + registry.read("username")) then
		movie_collection = ReadASCIIFile("tmp:/movie_collection.txt")
	else
		return -1
	endif
	

	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Loading Movie Collection")
	dlg.showBusyAnimation()
	dlg.show()
	movie_collection = rdJSONParser(movie_collection)
	print type(movie_collection)
	
	content = createObject("roArray", 0, true)
	
	screen = createObject("roPosterScreen")
	screen.setListStyle("arced-portrait")
	screen.setbreadCrumbText("trakt.tv", "Movie Collection")
	screen.setBreadCrumbEnabled(true)
	
	len = movie_collection.count()
		
	for i = 0 to (len-1)
		curMeta = movie_collection[i]
		curMeta.contentType = "movie"
		curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = curMeta.tagline
		curMeta.country = ""
		'print curMeta
		content.push(curMeta)
	end for
	
	print type(content)
	screen.setContentList(content)
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()
	dlg.close()
	
	while true
		msg = wait(0, screen.getMessagePort())
		print msg.getIndex()
			if msg.isListItemSelected() then
				movie = content[msg.getIndex()]
				dlg = CreateObject("roOneLineDialog")
				dlg.setTitle("Talking to trakt.tv.  Getting movie data.")
				dlg.showBusyAnimation()
				dlg.show()			
				m = aSyncFetch("http://api.trakt.tv/movie/summary.json/" + getAPIKey() + "/" + movie.imdb_id)
				m = rdJSONParser(m)
				dlg.close()
				m.country = ""
				movieInformation(m)
			else if msg.isScreenClosed() then
				return 0
			endif
	end while
	return 0
end function

function runTVCollection(trace = false) as Integer
	if trace then print "Loading movie collection"
	
	registry = getRegistry("account")
	
	if checkForContentAndReload("tmp:/tv_collection.txt", "http://api.trakt.tv/user/library/shows/collection.json/" + getAPIKey() + "/" + registry.read("username")) then
		tv_collection = ReadASCIIFile("tmp:/tv_collection.txt")
	else
		return -1
	endif
	

	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing collection data (For large collections this will take a long time.)")
	dlg.showBusyAnimation()
	dlg.show()
	tv_collection = rdJSONParser(tv_collection)
	print type(tv_collection)
	
	content = createObject("roArray", 0, true)
	
	screen = createObject("roPosterScreen")
	screen.setListStyle("arced-portrait")
	screen.setbreadCrumbText("trakt.tv", "T.V. Collection")
	screen.setBreadCrumbEnabled(true)
	
	len = tv_collection.count()
		
	for i = 0 to (len-1)
		curMeta = tv_collection[i]
		curMeta.contentType = "series"
		curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
		curMeta.shortDescriptionLine1 = curMeta.title
		curMeta.shortDescriptionLine2 = ""
		curMeta.country = ""
		curMeta.functionPrefix = "show"
		content.push(curMeta)
	end for
	
	print type(content)
	screen.setContentList(content)
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()
	dlg.close()
	
	while true
		msg = wait(0, screen.getMessagePort())
		print msg.getIndex()
			if msg.isListItemSelected() then
				show = content[msg.getIndex()]
				dlg = CreateObject("roOneLineDialog")
				dlg.setTitle("Talking to trakt.tv.  Getting show data.")
				dlg.showBusyAnimation()
				dlg.show()			
				m = aSyncFetch("http://api.trakt.tv/show/summary.json/" + getAPIKey() + "/" + show.imdb_id)
				m = rdJSONParser(m)
				dlg.close()
				showInformation(m)
			else if msg.isScreenClosed() then
				return 0
			endif
	end while
	return 0
end function

function runLists(trace = false) as Integer
	if trace then print "Loading movie collection"
	
	registry = getRegistry("account")
	
	if checkForContentAndReload("tmp:/lists.txt", "http://api.trakt.tv/user/lists.json/" + getAPIKey() + "/" + registry.read("username")) then
		lists = ReadASCIIFile("tmp:/lists.txt")
	else
		return -1
	endif
	
	dlg = CreateObject("roOneLineDialog")
	dlg.setTitle("Parsing List Data")
	dlg.showBusyAnimation()
	dlg.show()
	lists = rdJSONParser(lists)
	
	'Lists is an array of associative arrays.  We need to make an array of the names.
	listNames = createObject("roArray", 0, true)
	
	for i = 0 to lists.count()-1
		listNames.push(concat(lists[i].name, 15))
	end for
	
	listNames.push("New List")
	
	screen = createObject("roPosterScreen")
	screen.SetTitle("My Lists")
    'screen.SetContentList(content[0])
    screen.SetBreadcrumbText("My Collection", "My Lists")
	screen.setListNames(listNames)
	screen.setMessagePort(createObject("roMessagePort"))
	blankPoster = createObject("roArray", 0, true)
	blankPoster.push({shortDescriptionLine1:"Choose a list."})
	emptyList = createObject("roArray", 0, true)
	emptyList.push({shortDescriptionLine1:"List Is Empty"})
	
	screen.setContentList(blankPoster) 'Uncomment this line to load list 1 first.
    screen.Show()
    dlg.close()
	while true

		msg = wait(0, screen.getMessagePort())
		if type(msg) = "roPosterScreenEvent" then 
			if (msg.isListSelected()) then
				if msg.getIndex() = (listNames.count()-1) then
					print "Trying to add list..."
					if addList() then
						print "Addlist Succeeded"
						dlg = createObject("roOneLineDialog")
						dlg.setTitle("Refreshing Lists...")
						dlg.showBusyAnimation()
						dlg.show()
						aSyncFetch("http://api.trakt.tv/user/lists.json/" + getAPIKey() + "/" + registry.read("username"), true, "tmp:/lists.txt")
						dlg.close()
						screen.close()
						runLists()
					endif
				else 
					print "list Selected"
					'Load the list into existence
					dlg = createObject("roOneLineDialog")
					dlg.setTitle("Fetching List...")
					dlg.showBusyAnimation()
					dlg.show()
					list = aSyncFetch("http://api.trakt.tv/user/list.json/" + getapikey() + "/" + registry.read("username") + "/" + lists[msg.getIndex()].slug, false, "", 0, true)
					dlg.close()
					dlg = createObject("roOneLineDialog")
					dlg.setTitle("Parsing List Data...")
					dlg.showBusyAnimation()
					dlg.show()
					list = rdJSONParser(list)
					posterContent = parseList(list)

					if posterContent.count() = 0 then
						screen.setContentList(emptyList)
					else
						screen.setContentList(posterContent)
					endif
					dlg.close()

				endif
			else if (msg.isListFocused()) then
				screen.setContentList(blankPoster)
			else if (msg.isListItemSelected()) then
				selected = screen.getContentList()
				selected = selected[msg.getIndex()]
				print selected
				if selected.type = "show" OR selected.type = "season" then
					showInformation(selected)
				else if selected.type = "movie" then
					movieInformation(selected)
				else if selected.type = "episode" then
					episodeInformation(selected)
				else if selected.type = "new" then
					
						
				endif
			
			else if (msg.isScreenClosed()) then
				return 0
			
			end if
		end if
	end while
end function
	
function parseList(list as Object) as Object
	posterContent = createObject("roArray", 0, true)
	listItems = list.items
	for i = 0 to listItems.count()-1
		curMeta = listItems[i]
		'Handle all the types of data in the lists.
		if curMeta.type = "show" then
			curMeta = listItems[i].show
			curMeta.in_watchlist = listItems[i].in_watchlist
			curMeta.type = "show"
			
			curMeta.shortDescriptionLine1 = curMeta.title
			curMeta.shortDescriptionLine2 = curMeta.ratings.percentage.toStr() + "% loved"
			curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
		else if curMeta.type = "movie" then
			curMeta = curMeta.movie
			curMeta.type = "movie"
			curMeta.shortDescriptionLine1 = curMeta.title
			curMeta.shortDescriptionLine2 = curMeta.tagline
			curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
			
		else if curMeta.type = "season" then
			curMeta = listItems[i].show
			curMeta.in_watchlist = listItems[i].in_watchlist
			curMeta.type = "show"
			curMeta.shortDescriptionLine1 = curMeta.title
			curMeta.shortDescriptionLine2 = curMeta.ratings.percentage.toStr() + "% loved"
			curMeta.HDPosterURL = parsePosterImage(curMeta.images.poster, "138")
			
		else if curMeta.type = "episode" then
			curMeta.type = "episode"
			curMeta = listItems[i]
			curMeta.episode.number = curmeta.episode.episode
			curMeta.shortDescriptionLine1 = curMeta.episode.title
			curMeta.shortDescriptionLine2 = curMeta.episode.ratings.percentage.toStr() + "% loved"
			curmeta.description = curMeta.episode.overview
			curMeta.HDPosterURL = parsePosterImage(curMeta.show.images.poster, "138")
		end if
		posterContent.push(curMeta)
	end for
	
	return posterContent
end function