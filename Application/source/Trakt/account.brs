'Account management functions
Function runAccount()
	port = CreateObject("roMessagePort")
	accountScreen = CreateObject("roSpringboardScreen")
	accountScreen.setDescriptionStyle("generic")

	registry = createObject("roRegistrySection", "account")
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
         return -1
        else if msg.isButtonPressed() then
        	if idx = 0 then
        		if unlink = true then
        			dlg = CreateObject("roMessageDialog")
					dlg.setTitle("Account is already linked")
					dlg.setText("Are you sure you wish to unlink the current trakt account?")
					dlg.addButton(0, "Unlink Existing Account")
					dlg.addButton(2, "Replace existing account with new account")
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
								accountScreen.allowUpdates(false)
								accountScreen.clearButtons()
								accountScreen.addButton(0, "Link Trakt Account")
								accountScreen.addButton(1, "Set up Trakt Syncing")
								accountScreen.addButton(2, "Manage Trending Stream")
								accountScreen.addButton(3, "Calendar Settings")
								accountScreen.allowUpdates(true)
								unlink = false
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
	registry = CreateObject("roRegistrySection", "account")

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

				'kbd.close()
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
		accountInfo = get(url, false)
		if type(accountInfo) = "roAssociativeArray" then
			registry.write("fullname", accountInfo.full_name)
		endif
		registry.write("calendar_days", "03")
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

	endif
end function
