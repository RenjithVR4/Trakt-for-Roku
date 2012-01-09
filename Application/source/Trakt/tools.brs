'*****************************************
'	getDateString()
'	@params:    trace
'	@return:  	current date as trakt-ready string ("YYYYMMDD")
'*****************************************

function getDateString(trace = false) as String

	dateTime = createObject("roDateTime")
	dateTime.toLocalTime()
	
	year = dateTime.getYear()
	month = dateTime.getMonth()
	day = dateTime.getDayOfMonth()
	
	y = year.toStr()
	
	if month < 10 then
		m = "0" + month.toStr()
	else
		m = month.toStr()
	endif
	
	if day < 10 then
		d = "0" + day.toStr()
	else
		d = d.toStr()
	endif
	
	dateString = y + m + d
	if trace then print dateString
	return dateString
	
end function	

'*****************************************
'	conCat()
'	@params:    in as String, length as Integer, trace
'	@return:  	string concatenated to length characters, plus "..."
'*****************************************

function conCat(in as String, len as Integer, trace = false) as String
	if trace then print "Shortening string to " + len + " characters."
	
	if len(in) > len then
		beg = left(in, len)
		return (beg + "...")
	else
		return in
	endif
end function

'*****************************************
'	global(varName as String) as Object
'	@params:    varName as string
'	@return:  	global variable nedded
'*****************************************

function global(varName as String) as Object
	globalVars = {
		
	}
	return false
end function

function createSimpleLoadingScreen(title = "Loading", text = "Please wait...", trace = false) as Object

	if trace then print "Creating simple loading screen.  Title: " + title + ". Text: " + text + "."
	dlg = createObject("roMessageDialog")
	dlg.setTitle(title)
	dlg.setText(text)
	dlg.showBusyAnimation()
	return dlg
	
end function

'*****************************************
'	getResgistry as Object
'	@params:    registry section name
'	@return:  	registry variable
'*****************************************

function getRegistry(sectionName as String, trace = false) as Object

	if trace then print "Getting registry section " + sectionName
	return (createObject("roRegistrySection", sectionName))
	
end function

'*****************************************
'	mod as Object
'	@params:    Two integers (a, b)
'	@return:  	a%b
'*****************************************
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

function processDateString(in as String) as String
	return in
end function