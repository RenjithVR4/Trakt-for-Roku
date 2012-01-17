' *********************************************************
' **  Trakt.tv Unofficial Roku Application
' **  December, 2011
' **  Created By Aaron Smith @ greenpizza13@gmail.com
' *********************************************************

'************************************************************
'** Application startup
'************************************************************
Sub Main()
	init()
End Sub


'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** These attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()
    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "25"
    theme.OverhangSliceSD = "pkg:/images/overhang_slice_sd.png"
    theme.OverhangLogoSD  = "pkg:/images/logo_overhang_sd.png"

    theme.OverhangOffsetHD_X = "50"
    theme.OverhangOffsetHD_Y = "5"
    theme.OverhangSliceHD = "pkg:/images/overhang_slice_hd.png"
    theme.OverhangLogoHD  = "pkg:/images/logo_overhang_hd.png"
	theme.BackgroundColor = "#EEEEEE"
	
	theme.girdscreenOverhangSlideSD = "pkg:/images/overhang_slice_sd.png"
	theme.gridscreenOverhangSliceHD = "pkg:/images/overhang_slice_hd.png"
	theme.gridScreenLogoSD = "pkg:/images/logo_overhang_sd.png"
	theme.gridscreenLogoHD = "pkg:/images/logo_overhang_hd.png"
	theme.GridScreenLogoOffsetSD_X = "72"
    theme.GridScreenLogoOffsetSD_Y = "25"
	theme.GridScreenLogoOffsetHD_X = "50"
    theme.GridScreenLogoOffsetHD_Y = "5"
	theme.gridscreenBackgroundColor = "#EEEEEE"
	theme.gridScreenRetrievingColor = "#008FBB"
	theme.gridScreenListNameColor = "#008FBB"
	theme.gridScreenOverhangHeightHD = "125"
	
	
    app.SetTheme(theme)

End Sub

'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowPosterScreen(breadA=invalid, breadB=invalid) As Object

    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    screen.SetListStyle("flat-category")
    return screen

End Function


'******************************************************
'** Display the poster screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the show posters
'******************************************************

Function showPosterScreen(screen As Object) As Integer
	registry = getRegistry("account")
	checkAccountLink()
	
	breadcrumbUser = "Not Logged In"
	if registry.exists("fullname") then
		breadcrumbUser = registry.read("fullname")
	endif
	
	username = registry.read("username")
	categories = getMainScreenCategories()
	
	screen.SetTitle("trakt")
    screen.SetContentList(categories[0])
    screen.SetBreadcrumbText("trakt.tv", breadcrumbUser)
	screen.setListNames(mainScreenlists())
    screen.Show()

	
	dlg = createSimpleLoadingScreen("Loading Content", "Startup loading can be customized in the account menu to speed up your experience.")
	dlg.show()
	autoLoad = rdJSONParser(registry.read("autoLoad"))
	
'	*** Load data and save into text files based on account autoload settings ***

	if autoLoad.calendar then aSyncFetch("http://api.trakt.tv/user/calendar/shows.json/" + getAPIKey() + "/" + username + "/" + getDateString() + "/" + registry.read("calendar_days"), true, "tmp:/calendar.txt")
	if autoLoad.tv then aSyncFetch("http://api.trakt.tv/recommendations/shows/" + getAPIKey(), true, "tmp:/tv.txt", 0, true)
	if autoLoad.movies then aSyncFetch("http://api.trakt.tv/recommendations/movies/" + getAPIKey(), true, "tmp:/movies.txt")
	if autoLoad.friends then aSyncFetch("http://api.trakt.tv/user/friends.json/" + getAPIKey() + "/" + username + "/extended", true, "tmp:/friends.txt")
	if autoLoad.trending then aSyncFetch("http://api.trakt.tv/activity/community.json/" + getAPIKey() + "/movie,show/watching,scrobble,checkin/20120102", true, "tmp:/trending.txt")
	
	dlg.close()

    while true
        msg = wait(0, screen.getmessageport())
		if type(msg) = "roPosterScreenEvent" then 
			
			 if msg.isListSelected() then
		
					screen.setContentList(categories[msg.getIndex()])
					screen.setFocusedListItem(0)
        		else if msg.isListItemSelected() then
        			currentList = screen.getContentList()
					command = currentList[msg.getIndex()].function
					if command = "runCalendar" then
						runCalendar()
					else if command = "runTVRecommendations" 
						runTVRecommendations()
					else if command = "runMovieRecommendations"
						runMovieRecommendations()
					else if command = "runWatchlist"
						runWatchlist()
					else if command = "runMovieCollection"
						runMovieCollection()
					else if command = "runTVCollection"
						runTVCollection()
					else if command = "runLists"
						runLists()
					else if command = "runTrending"
						runTrending()
					else if command = "runAllActivity"
						runAllActivity()
					else if command = "runFriends"
						runFriends()
					else if command = "runAccount"
						runAccount()
					else if command = "searchMovies"
						searchMovies()
					else if command = "searchShows"
						searchShows()
					else if command = "searchEpisodes"
						searchEpisodes()
					endif
						
        	endif
		endif
    end while


End Function

Function displayBase64()
    ba = CreateObject("roByteArray")
    str = "Aladdin:open sesame"
    ba.FromAsciiString(str)
    result = ba.ToBase64String() 
    print result

    ba2 = CreateObject("roByteArray")
    ba2.FromBase64String(result)
    result2 = ba2.ToAsciiString()
    print result2
End Function


'**********************************************************
'** Define the categories for the Trakt app main screen.
'** Returns a roArray of roAssociativeArrays containing the
'** meta data for each category.
'**********************************************************
Function getMainScreenCategories() As Object
	print "Running getMainScreenCategories()"
	categories = CreateObject("roArray", 4, true)
	
	whatson = [
		{
			ShortDescriptionLine1 : "Calendar"
			ShortDescriptionLine2 : "View upcoming shows in your watchlist."
			hdposterurl : "pkg:/images/screens/home/calendar_hd.png"
			function: "runCalendar"
		}
		{
			ShortDescriptionLine1 : "T.V. Recommendations"
			ShortDescriptionLine2 : "Recommendations based on your favorite shows"
			hdposterurl : "pkg:/images/screens/home/tv_recs_hd.png"
			function: "runTVRecommendations"
			
		}
		{
			ShortDescriptionLine1 : "Movie Recommendations"
			ShortDescriptionLine2 : "Recommendations based on your favorite movies"
			hdposterurl : "pkg:/images/screens/home/movies_recs_hd.png"

			function: "runMovieRecommendations"
			
		}
	]
		
	mycollection = [	
		{
			ShortDescriptionLine1 : "Watchlist"
			ShortDescriptionLine2 : "View and edit shows and movies in your watchlist"
			function: "runWatchlist"
			
		}
		{
			ShortDescriptionLine1 : "My Movie Collection"
			ShortDescriptionLine2 : "All of the movies you own."
			function: "runMovieCollection"
			
		}
		{
			ShortDescriptionLine1 : "My T.V. Show Collection"
			ShortDescriptionLine2 : "All of the shows you own."
			function: "runTVCollection"
			
		}
		{
			ShortDescriptionLine1 : "My Lists"
			ShortDescriptionLine2 : "View and edit your lists"
			function: "runLists"
			
		}
	]
	'activity = 	[
	''	{
	''		ShortDescriptionLine1 : "What's Trending?"
	''		ShortDescriptionLine2 : "Trending movies and t.v. shows"
	''		function: "runTrending"
	''		
	''	}
	''	{
	''		ShortDescriptionLine1 : "The trakt.tv community"
	''		ShortDescriptionLine2 : "All trakt activity"
	''		function: "runAllActivity"
	''		
	''	}
	''	{
	''		ShortDescriptionLine1 : "Friends"
	''		ShortDescriptionLine2 : "What your friends are up to "
	''		function: "runFriends"
	''		
	''	}
	'']
	search = [
		{
			ShortDescriptionLine1 : "Movies"
			function : "searchMovies"
		}
		{
			ShortDescriptionLine1 : "Shows"
			function : "searchShows"
		}
		{
			ShortDescriptionLine1 : "Episodes"
			function : "searchEpisodes"
		}
	]
	account = [
		{
			ShortDescriptionLine1 : "Application Settings"
			ShortDescriptionLine2 : "Manage the way this app works"
			function: "runAccount"
			
		}
		]

	categories.push(whatson)
	categories.push(mycollection)
	'categories.push(activity)
	categories.push(search)
	categories.push(account)
	return categories
	
	
end function

function mainScreenLists() as Object
	categoryList = createObject("roArray", 4, true)
	'categoryList = ["What's On?", "My Collection", "Trakt Activity", "My Account"]
	categoryList = ["What's On?", "My Collection", "Search",  "My Account"]

	return categoryList
end function