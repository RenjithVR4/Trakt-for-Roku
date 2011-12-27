'This file contains methods that handle talking back and forth with the Trakt servers.

function get(url as String, showLoading as Boolean) as Object
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	username = registry.read("username")
	password = registry.read("password")
	urlT = createObject("roURLTransfer")
	urlT.setUrl(url)
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	if showLoading then 
		loading = CreateObject("roMessageDialog")
		loading.setTitle("Connecting to Trakt servers")
		loading.setText("Please wait...")
		loading.showBusyAnimation()
		loading.show()
	endif
	timeout%         = 1500
    num_retries%     = 5
    str = ""
    while num_retries% > 0
        if (urlT.AsyncGetToString())
            event = wait(timeout%, urlT.GetPort())
            if type(event) = "roUrlEvent"
                 respCode = event.GetResponseCode()
                 if respCode = 200 then
                     response = event.GetString()
                      if showloading then 
       					 loading.close()
						endif
   					     rsp = createObject("roAssociativeArray")
    					rsp = SimpleJSONParser(response)
   						return rsp
                     exit while
                 else if respCode = 401 then
                 	if showloading then 
                 		loading.close()
                 	endif
                 	dlg = createObject("roMessageDialog")
                 	dlg.setTitle("Couldn't Authenticate")
                 	dlg.setText("Unable to authenticate with trakt servers.  This shouldn't happen!")
                 	dlg.SetMessagePort(createObject("roMessagePort"))
                 	dlg.addButton(1, "Close")
                 	dlg.show()
                 	while true
                 		msg = wait(0, dlg.getMessagePort())
						idx = msg.getIndex()
						if msg.isButtonPressed() then
                 			if idx = 1 then 
                 				dlg.close()
                 				return -1
                 			endif
                 		endif
                 	end while
                 else
                 	if showloading then 
                 		loading.close()
                 	endif
                     print respCode
                     print "URL: " + url
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
                if showloading then 
                 	loading.close()
                 endif
                return -1
            endif
        endif
        num_retries% = num_retries% - 1
    end while
end function

' POST(url as string, jsonarray as roAssociativeArray, showLoading as boolean)
' Crednetials will automatically be attached to all outgoing posts
' Value returned is a roAssociativeArray, not a string.

function post(url as String, JSONArray as Object, showLoading as Boolean) as Object
	registry = createObject("roRegistrySection", "account") 'For validating with trakt servers.
	username = registry.read("username")
	password = registry.read("password")
	JSONArray.username = username
	JSONArray.password = password
	urlT = createObject("roURLTransfer")
	urlT.setUrl(url)
	urlT.setPort(createObject("roMessagePort"))
	urlT.addHeader("username", username)
	urlT.addHeader("password", password)
	if showLoading then 
		loading = CreateObject("roMessageDialog")
		loading.setTitle("Connecting to Trakt servers")
		loading.setText("Please wait...")
		loading.showBusyAnimation()
		loading.show()
	endif
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
                 	if showloading then 
                 		loading.close()
                 	endif
                 	dlg = createObject("roMessageDialog")
                 	dlg.setTitle("Couldn't Authenticate")
                 	dlg.setText("Unable to authenticate with trakt servers.  This shouldn't happen!")
                 	dlg.SetMessagePort(createObject("roMessagePort"))
                 	dlg.addButton(1, "Close")
                 	dlg.show()
                 	while true
                 		msg = wait(0, dlg.getMessagePort())
						idx = msg.getIndex()
						if msg.isButtonPressed() then
                 			if idx = 1 then 
                 				dlg.close()
                 				return -1
                 			endif
                 		endif
                 	end while
                 else
                 	if showloading then 
                 		loading.close()
                 	endif
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
                print "roUrlTransfer::AsyncPostFromString(): unknown event"
                if showloading then 
                 	loading.close()
                 endif
                return -1
            endif
        endif
        num_retries% = num_retries% - 1
    end while
    
    if showloading then 
        loading.close()
	endif
    rsp = createObject("roAssociativeArray")
    rsp = SimpleJSONParser(response)
    return rsp
end function

function getAPIKey() as String
	return "3b6a4155df1177be7bb9db887b42b64b"
end function
