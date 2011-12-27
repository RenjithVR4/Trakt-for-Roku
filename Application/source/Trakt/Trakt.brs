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
	registry = createObject("roRegistrySection", "account")
	breadcrumbUser = "Not Logged In"
	if registry.exists("fullname") then
		breadcrumbUser = registry.read("fullname")
	endif
	screen.SetTitle("trakt")
    screen.SetContentList(getMainScreenCategories())
    screen.SetBreadcrumbText("trakt.tv", breadcrumbUser)
    screen.Show()
	dlg = CreateObject("roMessageDialog")
	dlg.setTitle("Updating")
	dlg.setText("Updating local information, please wait. (Updates run in background after this point to reduce loading times.)")
	dlg.showBusyAnimation()
	dlg.show()
	aSyncGetCalendar("premieres")
	'aSyncGetTVRecommendations()
	'aSyncGetMovieRecommendations()
	'aSyncGetFriends()
	'aSyncGetTrendingMovies()
	 'aSyncGetTrendingShows()
	dlg.close()
	print mod(7, 22)
	
    while true
        msg = wait(0, screen.getmessageport())
        idx = msg.getIndex()
        if msg.isListItemSelected() then
        	if idx = 0 then
        		runCalendar()
        	
        	else if idx = 1 then
        		runTVRecommendations()
        	
        	else if idx = 2 then 
        		runMovieRecommendations()
        	
        	else if idx = 3 then
        		runTrending()
        	
        	else if idx = 4 then
        		runFriends()
        	
        	else if idx = 5 then
        		runAccount()
        		print "Updating breadcrumbs"
        		breadcrumbUser = "Not Logged In"
				if registry.exists("fullname") then
					breadcrumbUser = registry.read("fullname")
				endif
				print "New user: " + breadcrumbUser
			    screen.SetBreadcrumbText("trakt.tv", breadcrumbUser)

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
'** When a poster on the home screen is selected, we call
'** this function passing an roAssociativeArray with the 
'** ContentMetaData for the selected show.  This data should 
'** be sufficient for the springboard to display
'**********************************************************
Function displayShowDetailScreen(category as Object, showIndex as Integer) As Integer

    'add code to create springboard, for now we do nothing
    return 1

End Function

'**********************************************************
'** Define the categories for the Trakt app main screen.
'** Returns a roArray of roAssociativeArrays containing the
'** meta data for each category.
'**********************************************************
Function getMainScreenCategories() As Object
	print "Running getMainScreenCategories()"
	categories = CreateObject("roArray", 6, true)
	for i=0 to 5
		categories[i] = CreateObject("roAssociativeArray")
	end for
	categories[0].ShortDescriptionLine1 = "Calendar"
	categories[0].ShortDescriptionLine2 = "View upcoming T.V. shows and movies"
	categories[0].hdposterurl = "pkg:/images/screens/home/calendar_hd.png"
	categories[1].ShortDescriptionLine1 = "T.V. Recommendations"
	categories[1].ShortDescriptionLine2 = "Recommendations based on your favorite shows"
	categories[2].ShortDescriptionLine1 = "Movie Recommendations"
	categories[2].ShortDescriptionLine2 = "Recommendations based on your favorite movies"
	categories[3].ShortDescriptionLine1 = "Trending"
	categories[3].ShortDescriptionLine2 = "What the trakt community is watching now"
	categories[4].ShortDescriptionLine1 = "Friends"
	categories[4].ShortDescriptionLine2 = "What your friends are watching"
	categories[5].ShortDescriptionLine1 = "Account"
	categories[5].ShortDescriptionLine2 = "Trakt.tv syncing and account link"
	return categories
end function
