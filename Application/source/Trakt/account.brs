'Account management functions
Function runAccount() as Integer
	port = CreateObject("roMessagePort")
	accountScreen = CreateObject("roSpringboardScreen")
	accountScreen.setDescriptionStyle("generic")

	registry = getRegistry("account")
	if registry.exists("username") then
		unlink = true
		accountScreen.addButton(0, "Unlink Trakt Account")
	else
		unlink = false
		accountScreen.addButton(0, "Link Trakt Account")
	endif
	
	accountScreen.addButton(1, "Set up Trakt Syncing")
	accountScreen.addButton(2, "Manage Trending Stream")
	accountScreen.addButton(3, "Calendar Settings")
	accountScreen.setBreadCrumbText("trakt.tv", "Account Settings")
	accountScreen.SetMessagePort(port)
	accountScreen.setStaticRatingEnabled(false)
	accountScreen.allowNavLeft(false)
	accountScreen.allowNavRight(false)
	accountScreen.allowNavRewind(false)
	accountScreen.allowNavFastForward(false)
	accountScreen.setPosterStyle("rounded-square-generic")
	accountScreen.show()
	while true
        msg = wait(0, accountScreen.getmessageport())
        idx = msg.getIndex()
        if msg.isScreenClosed() then
         return 0
        else if msg.isButtonPressed() then
        	if idx = 0 then
        		if unlink then
        			dlg = CreateObject("roMessageDialog")
					dlg.setTitle("Register a different account?")
					dlg.setText("An account must be linked at all times to use this application.  If you choose to link a new account later, the app will close and ask for new credentials during startup.")
					dlg.addButton(0, "Unlink Existing Account and quit.")
					dlg.addButton(2, "Replace existing account with different account")
					dlg.addButton(1, "Cancel")
					dlg.setFocusedMenuItem(1)
					dlg.setMessagePort(CreateObject("roMessagePort"))
					dlg.show()
						msg = wait(0, dlg.getMessagePort())
						idx = msg.getIndex()
						if msg.isButtonPressed() then
							if idx = 2 then
								if linkAccount() = 1 then
									accountScreen.allowUpdates(false)
									accountScreen.clearButtons()
									accountScreen.addButton(0, "Unlink Trakt Account")
									accountScreen.addButton(1, "Set up Trakt Syncing")
									accountScreen.addButton(2, "Manage Trending Stream")
									accountScreen.addButton(3, "Calendar Settings")
									accountScreen.allowUpdates(true)
									unlink = true
								
								endif
								dlg.close()
								
							else if idx = 1 then
								dlg.close()
							else if idx = 0 then
								registry.delete("username")
								registry.delete("password")
								registry.delete("fullname")
								registry.flush()
								END
							dlg.close()
						endif
					endif
        		else
        			if linkAccount() = 1 then
									accountScreen.allowUpdates(false)
									accountScreen.clearButtons()
									accountScreen.addButton(0, "Unlink Trakt Account")
									accountScreen.addButton(1, "Set up Trakt Syncing")
									accountScreen.addButton(2, "Manage Trending Stream")
									accountScreen.addButton(3, "Calendar Settings")
									accountScreen.allowUpdates(true)

									unlink = true
								endif
        		endif
        	
        	else if idx = 1 then
        		syncSetup()
        	
        	else if idx = 2 then 
        		trendingSetup()
        	
        	else if idx = 3 then
        		calendarSetup()
        	
        	endif
        endif
    end while
end function

function linkAccount() as Integer
	registry = getRegistry("account")

	restartAuth:
	kbd = CreateObject("roKeyboardScreen")
	kbd.setDisplayText("Enter your trakt.tv username")
	kbd.setTitle("Username")
	kbd.setMessagePort(CreateObject("roMessagePort"))
	kbd.addButton(0, "Next...")
	kbd.addButton(1, "Cancel")
	kbd.show()
	while true 
		msg = wait(0, kbd.getMessagePort())
		idx = msg.getIndex()
		if msg.isButtonpressed() then
			if idx = 0 then
				username = kbd.getText()
				print "username accepted as" + username

				exit while
			else if idx = 1 then
				kbd.close()
				return -1
			endif
		endif
	end while
	kbd = CreateObject("roKeyboardScreen")
	kbd.setDisplayText("Enter your trakt.tv password")
	kbd.addButton(2, "Display Password")
	kbd.addButton(0, "Finish")
	kbd.addButton(1, "Cancel")
	kbd.setSecureText(true)
	kbd.setTitle("Password")
	kbd.setMessagePort(CreateObject("roMessagePort"))

	kbd.show()
	showtext = false
	while true
		msg = wait(0, kbd.getMessagePort())
		idx = msg.getIndex()
		if msg.isButtonpressed() then
			if idx = 0 then
				password = kbd.getText()
				'kbd.close()
				exit while
			else if idx = 1 then
				kbd.close()
				return -1
			else if idx = 2 then
				if showtext = false then
					kbd.setSecureText(false)
					kbd.clearButtons()
					kbd.addButton(2, "Hide Password")
					kbd.addButton(0, "Finish")
					kbd.addButton(1, "Cancel")
					showtext = true
				else 
					kbd.setSecureText(true)
					kbd.clearButtons()
					kbd.addButton(2, "Display Password")
					kbd.addButton(0, "Finish")
					kbd.addButton(1, "Cancel")
					showtext = false
				endif	
			endif
		endif
	end while
	
	dig = CreateObject("roEVPDigest")
	pbyte = CreateObject("roByteArray")
	pbyte.fromASCIIString(password)
	dig.setup("sha1")
	dig.update(pbyte)
	password = dig.final()

	'Now, communicate with Trakt to verify the username / password combination.
	APIKEY = getAPIKey()
	url = "http://api.trakt.tv/account/test/" + APIKEY
	urlT = createObject("roURLTransfer")
	urlT.setUrl(url)
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	authArray = CreateObject("roAssociativeArray")
	authArray.username = username
	authArray.password = password
	print SimpleJSONBuilder(authArray)
	loading = CreateObject("roMessageDialog")
	loading.setTitle("Connecting to Trakt servers")
	loading.setText("Please wait...")
	loading.showBusyAnimation()
	loading.show()
	timeout%         = 1500
    num_retries%     = 5
    str = ""
    while num_retries% > 0
        if (urlT.AsyncPostFromString(SimpleJSONBuilder(authArray)))
            event = wait(timeout%, urlT.GetPort())
            if type(event) = "roUrlEvent"
                 respCode = event.GetResponseCode()
                 if respCode = 200 then
                     response = event.GetString()
                     exit while
                 else if respCode = 401 then
                 	loading.close()
                 	dlg = createObject("roMessageDialog")
                 	dlg.setTitle("Invalid username or password")
                 	dlg.setText("Trakt was unable to verify your username and password.  Please try again.")
                 	dlg.SetMessagePort(createObject("roMessagePort"))
                 	dlg.addButton(0, "Try Again")
                 	dlg.addButton(1, "Cancel")
                 	dlg.show()
                 	while true
                 		msg = wait(0, dlg.getMessagePort())
						idx = msg.getIndex()
						if msg.isButtonPressed() then
                 			if idx = 0 then 
                 				goto restartAuth
                 			else 
                 				dlg.close()
                 				return -1
                 			endif
                 		endif
                 	end while
                 else
                 	 loading.close()
                     print respCode
                     print event.GetString()
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
                loading.close()
                return -1
            endif
        endif
        num_retries% = num_retries% - 1
    end while
	responseAss = createObject("roAssociativeArray")
	responseAss = SimpleJSONParser(response)
	if responseAss.status = "success" then
		registry.write("username", username)
		registry.write("password", password)
		url = "http://api.trakt.tv/user/profile.json/" + getAPIKey() + "/" + username
		accountInfo = aSyncFetch(url)

		if accountInfo <> "failed" then accountInfo = rdJSONParser(accountInfo)

		if type(accountInfo) = "roAssociativeArray" then
			if accountInfo.fullName = "invalid" OR type(accountInfo.fullName) = "invalid" OR accountInfo.fullName = "" then
				registry.write("fullname", username)
			else
				registry.write("fullname", accountInfo.full_name)
			endif
		endif
		registry.write("calendar_days", "03")
		
		'Set up auto-loading:
		autoLoad = createObject("roAssociativeArray")
		autoLoad.calendar = true
		autoLoad.tv = false
		autoLoad.movies = false
		autoLoad.friends = false
		autoLoad.trending = false
		registry.write("autoLoad", SimpleJSONBuilder(autoLoad))
		
		
		registry.flush()

		dlg = CreateObject("roMessageDialog")
		dlg.setTitle("Sucess!")
		dlg.setText("Your Trakt.tv account has been successfully linked to this Roku Player.  Enjoy!")
		dlg.addButton(0, "Close")
		dlg.setMessagePort(createObject("roMessagePort"))
		loading.close()

		dlg.show()
		while true	
			msg = wait(0, dlg.getMessagePort())
			if msg.isButtonPressed()
				dlg.close()
				exit while
			endif
		end while
		return 1
	endif
	return -1
end function

function syncSetup(trace = false) as Integer
	reg = createObject("roRegistrySection", "account")
	autoLoad = SimpleJSONParser(reg.read("autoLoad"))
	if trace then print "Trace: autoLoad: " + autoload
	syncScreen = CreateObject("roParagraphScreen")
	syncScreen.setTitle("Trakt Sync Setup")
	dfm = 0
	syncScreen.addParagraph("Choose which items will load when the Trakt app starts up.  If you turn an item off, it will only load when that menu item is chosen from the main menu.")
	goto create
reset:
	syncScreen.close()
	syncScreen = CreateObject("roParagraphScreen")
	syncScreen.setTitle("Trakt Sync Setup")
	syncScreen.addParagraph("Choose which items will load when the Trakt app starts up.  If you turn an item off, it will only load when that menu item is chosen from the main menu.")
create:
	if autoLoad.calendar then 
		syncScreen.addButton(0, "Calendar [ON]")
	else
		syncScreen.addButton(0, "Calendar [OFF]") 
 	endif
	if autoLoad.tv then 
		syncScreen.addButton(1, "T.V. Recommendations [ON]")
	else
		syncScreen.addButton(1, "T.V. Recommendations [OFF]")
 	endif
	if autoLoad.movies then 
		syncScreen.addButton(2, "Movie Recommendations [ON]")
	else
		syncScreen.addButton(2, "Movie Recommendations [OFF]")
 	endif
	if autoLoad.friends then 
		syncScreen.addButton(3, "Friends [ON]")
	else
		syncScreen.addButton(3, "Friends [OFF]")
 	endif
	if autoLoad.trending then 
		syncScreen.addButton(4, "Trending [ON]")
	else
		syncScreen.addButton(4, "Trending [OFF]")
 	endif
	syncScreen.setDefaultMenuItem(dfm)
	syncScreen.addButton(5, "Save")
	syncScreen.setMessagePort(createObject("roMessagePort"))
	syncScreen.show()
	
	while true
		msg = wait(0, syncScreen.getMessagePort())
		if msg.isButtonPressed() then
			idx = msg.getIndex()
			if idx = 0 then
				if autoLoad.calendar then 
					if trace then print "Calendar set to OFF"
					autoLoad.calendar = false
					goto reset
				else
					if trace then print "Calendar set to ON"
					autoLoad.calendar = true
					goto reset
				endif
			else if idx = 1 then 
				dfm = 1
				if autoLoad.tv then 
					if trace then print "tv set to OFF"
					autoLoad.tv = false
					
					goto reset
				else
					if trace then print "tv set to ON"
					autoLoad.tv = true
					goto reset
				endif
			else if idx = 2 then 
				dfm = 2
				if autoLoad.movies then 
					if trace then print "movies set to OFF"
					autoLoad.movies = false
					goto reset
				else
					if trace then print "movies set to ON"
					autoLoad.movies = true
					goto reset
				endif
			else if idx = 3 then
			 	dfm = 3
				if autoLoad.friends then 
					if trace then print "friends set to OFF"
					autoLoad.friends = false
					goto reset
				else
					if trace then print "friends set to ON"
					autoLoad.friends = true
					goto reset
				endif
			else if idx = 4 then 
				dfm = 4
				if autoLoad.trending then 
					if trace then print "trending set to OFF"
					autoLoad.trending = false
					goto reset
				else
					if trace then print "trending set to ON"
					autoLoad.trending = true
					goto reset
				endif
			else
				reg.write("autoLoad", SimpleJSONBuilder(autoLoad))
				reg.flush()
				syncScreen.close()
				return 0
			endif
		else if (msg.isScreenClosed()) then
			return 0
		
		end if
	end while
end function

function calendarSetup(trace = false) as boolean
	calScreen = createObject("roParagraphScreen")
	registry = createObject("roRegistrySection", "account")
	days = registry.read("calendar_days")
	
	calScreen.setTitle("Calendar Settings")
	calScreen.addHeaderText("Days to view")
	calScreen.addParagraph("Select how far into the future you would like to see shows in your watchlist premieres.")
	calScreen.addButton(0, "Three days")
	calScreen.addButton(1, "Five days")
	calScreen.addButton(2, "One week")
	calScreen.addButton(3, "Two weeks")
	calScreen.addButton(4, "One month")
	calScreen.setMessagePort(createObject("roMessagePort"))
	calScreen.show()
	
	while true
		msg = wait(0, calScreen.getMessagePort())
		if msg.isButtonPressed() then
			idx = msg.getIndex()
			if idx = 0 then
				days = "03"
				exit while
			else if idx = 1 then
				days = "05"
				exit while
				
			else if idx = 2 then
				days = "07"
				exit while
			
			else if idx = 3 then
				days = "14"
				exit while
			
			else if idx = 4 then
				days = "30"
				exit while
	
			endif
		

		else if msg.isScreenClosed() then
			return true
		end if
	end while
	
	registry.write("calendar_days", days)
	registry.flush()
	calScreen.close()
	return true
end function
