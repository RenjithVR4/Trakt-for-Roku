function checkAccountLink() as void
	registry = getRegistry("account")
	
	
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
					exit while
				else
					END
				endif
			endif
		end while
	endif
end function

Function init()  as Integer
init:
	initTheme()
	
	screen=preShowPosterScreen("", "")
    	if screen=invalid then
        	print "unexpected error in preShowPosterScreen"
        	return -1
    	end if
	
	showPosterScreen(screen)
	
	return 0
	
end function
