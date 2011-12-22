' *********************************************************
' **  Trakt.tv Unofficial Roku Application
' **  December, 2011
' **  Created By Aaron Smith @ greenpizza13@gmail.com
' *********************************************************

'************************************************************
'** Application startup
'************************************************************
Sub Main()

    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    'prepare the screen for display and get ready to begin
   screen=preShowPosterScreen("", "")
    if screen=invalid then
        print "unexpected error in preShowPosterScreen"
        return
    end if

	'createHomeScreen()
    'set to go, time to get started
    showPosterScreen(screen)

End Sub

Sub createHomeScreen()
	port = CreateObject("roMessagePort")
	poster = createObject("roPosterScreen")
	poster.setTitle("Trakt.tv")
	poster.SetBreadcrumbEnable(false)
	poster.SetListStyle("flat-category")

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
	
	screen.SetTitle("trakt")
    screen.SetContentList(getMainScreenCategories())
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            print "showPosterScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                'get the list of shows for the currently selected item
                screen.SetContentList(getShowsForCategoryItem(categoryList[msg.GetIndex()]))
                print "list focused | current category = "; msg.GetIndex()
            else if msg.isListItemFocused() then
                print"list item focused | current show = "; msg.GetIndex()
            else if msg.isListItemSelected() then
                print "list item selected | current show = "; msg.GetIndex() 
                'if you had a list of shows, the index of the current item 
                'is probably the right show, so you'd do something like this
                'm.curShow = displayShowDetailScreen(showList[msg.GetIndex()])
                displayBase64()
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
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

Function accountSettings() as Integer
	port = CreateObject("roMessagePort")
	accountScreen = CreateObject("roSpringboardScreen")
	accountScreen.setDescriptionStyle("generic")
	accountScreen.addButton(0, "Link Trakt Account")
	accountScreen.addButton(1, "Set up Trakt Syncing")
	accountScreen.addButton(2, "Manage Trending Stream")
	accountScreen.addButton(3, "Calendar Settings")
	accountScreen.setBreadCrumbText("trakt.tv", "Account Settings")
	accountScreen.SetMessagePort(port)
	accountScreen.show()
	
	while true
	msg = wait(0, port)
		if msg.isScreenClosed() then
			return -1
	end while
end function
