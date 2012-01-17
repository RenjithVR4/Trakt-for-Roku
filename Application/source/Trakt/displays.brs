'*****************************************
'	episodeInformation(metaData, quickLoad = false)
'	@params:    metaData as rowAssociativeArray containing all the current data.
'				quickLoad allows the screen to load the information and display before background has a chance to load.  Reduces wait times, but creates ugly loading screens.
'	@return:  	instruction as String
'				this instruction will tell the caller to refresh the page if important information has changed.
'*****************************************

function episodeInformation(m as Object, quickLoad = false) as String
	m.contentType = "episode"

	if m.episode.overview <> "" then 
		m.description = m.episode.overview
	else
		m.description = m.show.overview
	endif

	if NOT type(m.episode.episode) = "invalid" then m.episode.number = m.episode.episode
	fonts = createObject("roFontRegistry")
	fonts.register("pkg:/fonts/droidsans.tff")
	fonts.register("pkg:/fonts/droidsans-bold.tff")
	
	load = createSimpleLoadingScreen("Preparing episode screen.", m.show.title + " - " + m.episode.title)
	load.show()
	c = createObject("roImageCanvas")
	cUp = createObject("roImageCanvas")
	cr = c.getCanvasRect()
	w = cr.w
	h = cr.h
	print h
	print w
	backgroundBanner = [{
		url:parsePosterImage(m.show.images.fanart, "940")
		TargetRect:{x:0,y:0,w:w,h:h}
	}]
	backgroundSolid = [{
		color:"#000000"
		TargetRect:{x:0,y:0,w:w,h:h}
		
	}]
	transparentOverlay = [{
		TargetRect:{x:0,y:270,w:w,h:450}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}]
	upwardTransparency = [{
		TargetRect:{x:0,y:0,w:w,h:450}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}]
	screenElements = [
		{
		TargetRect:{x:90,y:495,h:90,w:540}
		Text:m.show.title
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans-bold", 36, 5, false), HAlign:"Left", Valign:"Bottom", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:90,y:585,h:45,w:720}
		Text:m.episode.title + " » " + m.episode.season.toStr() + "x" + m.episode.number.toStr()
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 24, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:90,y:610,h:45,w:360}
		Text:""
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 20, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:360, w:450, h:270}
		Text:conCat(m.description, 550)
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 21, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:630, w:450, h:90}
		Text:m.show.air_Day + "s at " + m.show.air_Time + " on " + m.show.network + "  •  " + m.show.certification
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 18, 1, true), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		
	]
	
	c.setLayer(0, backgroundSolid)
	c.setLayer(1, backgroundBanner)
	c.setLayer(2, transparentOverlay)
	c.setLayer(3, screenElements)
	'if not quickLoad then c.setRequireAllImagesToDraw(true)
	c.setRequireAllImagesToDraw(false)
	port = createObject("roMessagePort")

	c.setMessagePort(port)
	c.show()
'	load.close()
'	*** Remote button indices:
'	UP: 2
'	LEFT: 4
'	DOWN: 3
'	RIGHT: 5
'	OK: 6
'	REWIND: 8
'	FF: 9
'	STAR: 10
'	BACK: 0

	actionsOpen = false
	while true
		msg = wait(0, port)
		if type(msg) = "roImageCanvasEvent" then
			if (msg.isRemoteKeyPressed()) then
			idx = msg.getIndex()
					'Open the actions bar, or close the screen.
					if idx = 3 OR idx = 6 then
						if actionsBar(m) = true then
						if m.in_watchlist then 
							m.in_watchlist = false
						else
							m.in_watchlist = true
						endif
					endif
					else if idx = 0 or idx = 2 then
						c.close()
						return ""
					endif
			endif
		endif
	end while
end function



function showInformation(m as Object, quickLoad = false) as String
	m.contentType = "show"

	load = createSimpleLoadingScreen("Preparing show screen.", m.title)
	load.show()
	
	
	fonts = createObject("roFontRegistry")
	fonts.register("pkg:/fonts/droidsans.tff")
	fonts.register("pkg:/fonts/droidsans-bold.tff")
	
	
	c = createObject("roImageCanvas")
	cUp = createObject("roImageCanvas")
	cr = c.getCanvasRect()
	w = cr.w
	h = cr.h

	backgroundBanner = [{
		url:parsePosterImage(m.images.fanart, "218")
		TargetRect:{x:0,y:0,w:w,h:h}
	}]
	backgroundSolid = [{
		color:"#000000"
		TargetRect:{x:0,y:0,w:w,h:h}
		
	}]
	transparentOverlay = [{
		TargetRect:{x:0,y:270,w:w,h:450}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}]
	upwardTransparency = [{
		TargetRect:{x:0,y:0,w:w,h:450}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}]
	screenElements = [
		{
		TargetRect:{x:90,y:495,h:90,w:540}
		Text:m.title + "(" + m.year.toStr() + ")"
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans-bold", 36, 5, false), HAlign:"Left", Valign:"Bottom", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:90,y:585,h:45,w:720}
		Text:m.ratings.percentage.toStr() + "% Loved. (" + m.ratings.loved.toStr() + " / " + m.ratings.votes.toStr() + ")"
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 24, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:360, w:450, h:270}
		Text:conCat(m.overview, 550)
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 21, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:630, w:450, h:90}
		Text:m.runtime.toStr() + " minutes • " + m.country + " " + m.certification
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 18, 1, true), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		
	]
	


	c.setLayer(0, backgroundSolid)
	c.setLayer(1, backgroundBanner)
	c.setLayer(2, transparentOverlay)
	c.setLayer(3, screenElements)
	c.setRequireAllImagesToDraw(false)
	port = createObject("roMessagePort")

	c.setMessagePort(port)
	c.show()
	load.close()
	
	urlT = createObject("roURLTransfer")
	urlT.setUrl(m.images.fanart)
	urlT.setPort(port)
	fin = urlT.ASyncGetToFile("tmp:/fanart.jpg")
	
	
'	*** Remote button indices:
'	UP: 2
'	LEFT: 4
'	DOWN: 3
'	RIGHT: 5
'	OK: 6
'	REWIND: 8
'	FF: 9
'	STAR: 10
'	BACK: 0

	while true
		msg = wait(0, port)
		print fin
		print type(msg)
		if type(msg) = "roImageCanvasEvent" then
			if (msg.isRemoteKeyPressed()) then
			idx = msg.getIndex()
					'Open the actions bar, or close the screen.
					if  idx = 3 OR idx = 6 then
						if actionsBar(m) = true then
						if m.in_watchlist then 
							m.in_watchlist = false
						else
							m.in_watchlist = true
						endif
					endif
					else if idx = 0 OR idx = 2 then
						urlT.aSyncCancel()
						c.close()
						return ""
					endif
			endif
		else if type(msg) = "roUrlEvent" then
			if msg.getInt() = 1 AND msg.getResponseCode() = 200 AND fin = true then
				print "Updating background."
				'Transfer complete, change the background image
				backgroundBanner = [{
					url:"tmp:/fanart.jpg"
					TargetRect:{x:0,y:0,w:w,h:h}
				}]
				c.setLayer(1, backgroundBanner)
			endif
		endif		
	end while
end function

function movieInformation(m as Object, quickLoad = false) as String
	m.contentType = "movie"
	load = createSimpleLoadingScreen("Preparing movie screen.",(m.title + " - " + m.tagline))
	load.show()
	fonts = createObject("roFontRegistry")
	fonts.register("pkg:/fonts/droidsans.tff")
	fonts.register("pkg:/fonts/droidsans-bold.tff")
	
	
	c = createObject("roImageCanvas")
	cUp = createObject("roImageCanvas")
	cr = c.getCanvasRect()
	w = cr.w
	h = cr.h

	backgroundBanner = [{
		url:parsePosterImage(m.images.fanart, "940")
		TargetRect:{x:0,y:0,w:w,h:h}
	}]
	backgroundSolid = [{
		color:"#000000"
		TargetRect:{x:0,y:0,w:w,h:h}
		
	}]
	transparentOverlay = [{
		TargetRect:{x:0,y:270,w:w,h:450}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}]
	upwardTransparency = [{
		TargetRect:{x:0,y:0,w:w,h:450}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}]
	screenElements = [
		{
		TargetRect:{x:90,y:495,h:90,w:540}
		Text:m.title
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans-bold", 36, 5, false), HAlign:"Left", Valign:"Bottom", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:90,y:585,h:45,w:540}
		Text:m.tagline
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 24, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:360, w:450, h:270}
		Text:conCat(m.overview, 525)
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 21, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:630, w:450, h:90}
		Text:m.runtime.toStr() + " minutes • " + m.certification
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 18, 1, true), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		
	]
	


	c.setLayer(0, backgroundSolid)
	c.setLayer(1, backgroundBanner)
	c.setLayer(2, transparentOverlay)
	c.setLayer(3, screenElements)
	c.setRequireAllImagesToDraw(false)
	port = createObject("roMessagePort")

	c.setMessagePort(port)
	c.show()
	load.close()

	actionsOpen = false

'	*** Remote button indices:
'	UP: 2
'	LEFT: 4
'	DOWN: 3
'	RIGHT: 5
'	OK: 6
'	REWIND: 8
'	FF: 9
'	STAR: 10
'	BACK: 0

	while true
		msg = wait(0, port)
		if type(msg) = "roImageCanvasEvent" then
			if (msg.isRemoteKeyPressed()) then
			idx = msg.getIndex()
			
					
				
				'Open the actions bar, or close the screen.
				if idx = 3 OR idx = 6 then
					if actionsBar(m) = true then
						if m.in_watchlist then 
							m.in_watchlist = false
						else
							m.in_watchlist = true
						endif
					endif
				else if idx = 0 OR idx = 2 then
					c.close()
					return ""
				endif
			endif
		endif
	end while
end function

function addList() as boolean
	kbd = createObject("roKeyboardScreen")
	kbd.setDisplayText("New List Name")
	kbd.setTitle("New List")
	kbd.setMessagePort(createObject("roMessagePort"))
	kbd.addButton(0, "Save List as Public")
	kbd.addButton(1, "Save List as Friends Only")
	kbd.addButton(2, "Save List as Private")
	kbd.addButton(3, "Cancel")
	kbd.show()

	while true
		msg = wait(0, kbd.getMessagePort())
		if (msg.isScreenClosed()) then
			return -1
		else if msg.isButtonPressed() then
			idx = msg.getIndex()
			if idx = 0 OR 1 OR 2 then
				listName = kbd.getText()
				if listName.len() = 0 then
					return false
				else
					privacyLevel = "public"

					if idx = 1 then
						privacyLevel = "friends"
					else if idx = 2 then
						privacyLevel = "private"
					endif

					dlg = createObject("roOneLineDialog")
					dlg.setTitle("Talking to trakt.tv...")
					dlg.showBusyAnimation()
					dlg.show()
					result = aSyncFetch("http://api.trakt.tv/lists/add/" + getAPIKey(), false, "", 0, true, {name:listName, privacy:privacyLevel})
					result = rdJSONParser(result)
					if NOT result.status = "success" then
						'Create fail dialog.
					else 
						print "Success!"
						return true
					endif
				endif
			else 
				return false
			endif
		endif
	end while
end function

function actionsBar(m as Object, trace = false) as boolean

	currentIndex = 2

	canvasItems = createObject("roArray", 0, true)

		wl = "2"
		if type(m.in_watchlist) <> "invalid" AND m.in_watchlist = true then wl = "5"

		ci = [{
			url:"pkg:/images/actions/actions-0-1.png"
			TargetRect:{x: 0, y:270, w:256, h:45}
		}, 
		{
			url:"pkg:/images/actions/actions-1-0.png"
			TargetRect:{x: 256, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-" + wl + "-0.png"
			TargetRect:{x: 512, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-3-0.png"
			TargetRect:{x: 768, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-4-0.png"
			TargetRect:{x: 1024, y:270, w:256, h:45}
		}
		]
		bb = [
		{
			color:"#000000"
			TargetRect:{x: 0, y:270, w:1280, h:45}

		}]
		tmp = createObject("roImageCanvas")
		tmp.setLayer(1, ci)
		tmp.setLayer(0, bb)
		canvasItems.push(tmp)
		ci = [{
			url:"pkg:/images/actions/actions-0-0.png"
			TargetRect:{x: 0, y:270, w:256, h:45}
		}, 
		{
			url:"pkg:/images/actions/actions-1-1.png"
			TargetRect:{x: 256, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-" + wl + "-0.png"
			TargetRect:{x: 512, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-3-0.png"
			TargetRect:{x: 768, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-4-0.png"
			TargetRect:{x: 1024, y:270, w:256, h:45}
		}
		]
		bb = [
		{
			color:"#000000"
			TargetRect:{x: 0, y:270, w:1280, h:45}

		}]
		tmp = createObject("roImageCanvas")
		tmp.setLayer(1, ci)
		tmp.setLayer(0, bb)
		canvasItems.push(tmp)
		ci = [{
			url:"pkg:/images/actions/actions-0-0.png"
			TargetRect:{x: 0, y:270, w:256, h:45}
		}, 
		{
			url:"pkg:/images/actions/actions-1-0.png"
			TargetRect:{x: 256, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-" + wl + "-1.png"
			TargetRect:{x: 512, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-3-0.png"
			TargetRect:{x: 768, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-4-0.png"
			TargetRect:{x: 1024, y:270, w:256, h:45}
		}
		]
		bb = [
		{
			color:"#000000"
			TargetRect:{x: 0, y:270, w:1280, h:45}

		}]
		tmp = createObject("roImageCanvas")
		tmp.setLayer(1, ci)
		tmp.setLayer(0, bb)
		canvasItems.push(tmp)
		ci = [{
			url:"pkg:/images/actions/actions-0-0.png"
			TargetRect:{x: 0, y:270, w:256, h:45}
		}, 
		{
			url:"pkg:/images/actions/actions-1-0.png"
			TargetRect:{x: 256, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-" + wl + "-0.png"
			TargetRect:{x: 512, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-3-1.png"
			TargetRect:{x: 768, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-4-0.png"
			TargetRect:{x: 1024, y:270, w:256, h:45}
		}
		]
		bb = [
		{
			color:"#000000"
			TargetRect:{x: 0, y:270, w:1280, h:45}

		}]
		tmp = createObject("roImageCanvas")
		tmp.setLayer(1, ci)
		tmp.setLayer(0, bb)
		canvasItems.push(tmp)
		ci = [{
			url:"pkg:/images/actions/actions-0-0.png"
			TargetRect:{x: 0, y:270, w:256, h:45}
		}, 
		{
			url:"pkg:/images/actions/actions-1-0.png"
			TargetRect:{x: 256, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-" + wl + "-0.png"
			TargetRect:{x: 512, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-3-0.png"
			TargetRect:{x: 768, y:270, w:256, h:45}
		},
		{
			url:"pkg:/images/actions/actions-4-1.png"
			TargetRect:{x: 1024, y:270, w:256, h:45}
		}
		]
		bb = [
		{
			color:"#000000"
			TargetRect:{x: 0, y:270, w:1280, h:45}

		}]
		tmp = createObject("roImageCanvas")
		tmp.setLayer(1, ci)
		tmp.setLayer(0, bb)
		canvasItems.push(tmp)

	port = createObject("roMessagePort")

	canvas = canvasItems[currentIndex]
	canvas.setRequireAllImagesToDraw(true)
	canvas.setMessagePort(port)
	canvas.show()

'	*** Remote button indices:
'	UP: 2
'	LEFT: 4
'	DOWN: 3
'	RIGHT: 5
'	OK: 6
'	REWIND: 8
'	FF: 9
'	STAR: 10
'	BACK: 0

	while true
		msg = wait(0, port)
		if (msg.isRemoteKeyPressed()) then
			idx = msg.getIndex()
			if idx = 2 OR idx = 3 OR idx = 8 OR idx = 0 then
				canvas.close()
				return false
			else if idx = 4 then
				currentIndex = currentIndex - 1
				if currentIndex < 0 then currentIndex = 4
				canvas = canvasItems[currentIndex]
				canvas.setMessagePort(port)
				canvas.show()
			else if idx = 5  then
				currentIndex = currentIndex + 1
				if currentIndex > 4 then currentIndex = 0
				canvas = canvasItems[currentIndex]
				canvas.setMessagePort(port)
				canvas.show()
			else if idx = 6 then
				if currentIndex = 0 then
					waitCanvas = waitMessageCanvas("Adding to list... ")
					waitCanvas.setMessagePort(port)
					waitCanvas.show()
					if addToList(m) then 
						flagFile("tmp:/lists.txt")
						return false
					else
						print "Failed!"
					endif
					
					return false
				else if currentIndex = 1 then
					waitCanvas = waitMessageCanvas("Sending Rating... ")
					waitCanvas.setMessagePort(port)
					waitCanvas.show()
					if sendRating(m, "hate") then 
						return false
					else
						print "Failed!"
					endif

					return false
					
				else if currentIndex = 2 then
					if wl = "2" then
						waitCanvas = waitMessageCanvas("Adding to watchlist...")
						waitCanvas.setMessagePort(port)
						waitCanvas.show()
						if addToWatchlist(m) then 
							flagFile("tmp:/tv_watchlist.txt")
							flagFile("tmp:/movie_watchlist.txt")
							return true
						else 
							print "Failed!"
						endif

						return false
					else if wl = "5" then
						waitCanvas = waitMessageCanvas("Removing from watchlist...")
						waitCanvas.setMessagePort(port)
						waitCanvas.show()
						if removeFromWatchList(m) then 
							flagFile("tmp:/watchlist_tv.txt")
							flagFile("tmp:/watchlist_movies.txt")
							return true
						else 
							print "Failed!"
						endif

						return false
					endif
				else if currentIndex = 3 then
					waitCanvas = waitMessageCanvas("Sending Rating... ")
					waitCanvas.setMessagePort(port)
					waitCanvas.show()
					if sendRating(m, "love") then return false

					return false
				else 
					waitCanvas = waitMessageCanvas("Adding to collection... ")
					waitCanvas.setMessagePort(port)
					waitCanvas.show()
					if addToCollection(m) then 
						flagFile("tmp:/tv_collection.txt")
						flagFile("tmp:/movie_collection.txt")

						return false
					else 
						print "Failed!"
					endif

					return false
				endif
			end if
		else if (msg.isScreenClosed()) then
			return false
		end if
	end while


end function

function createErrorMessage(title as String, para as String) as boolean
	err = createObject("roMessageDialog")
	err.setMessagePort(createObject("roMessagePort"))
	err.setTitle(title)
	err.setText(para)
	err.addButton(0, "Ok. :(")
	err.show()


	while true
		msg = wait(0, err.getMessagePort())
		if msg.isScreenClosed() then
			return false
		else if msg.isButtonPressed() then
			return false
		endif
	end while
end function

function waitMessageCanvas(text as String) as Object

	fonts = createObject("roFontRegistry")
	fonts.register("pkg:/fonts/droidsans.tff")
	fonts.register("pkg:/fonts/droidsans-bold.tff")
	canvas = createObject("roImageCanvas")
	canvas.setLayer(0, [{
		text: text
		targetRect: {x:0, y: 315, w: 1280, h: 45}
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans-bold", 24, 5, true), HAlign:"Center", Valign:"Center", Direction:"LeftToRight"}
	}])
	canvas.allowUpdates(true)
	return canvas
end function

function addToList(m) as boolean
	screen = createObject("roPosterScreen")
	registry = getRegistry("account")

	if checkForContentAndReload("tmp:/lists.txt", "http://api.trakt.tv/user/lists.json/" + getAPIKey() + "/" + registry.read("username")) then
		lists = ReadASCIIFile("tmp:/lists.txt")
	else
		return -1
	endif

	lists = rdJSONParser(lists)

	for i = 0 to lists.count()-1
		lists[i].shortDescriptionLine1 = lists[i].name
		print lists[i].shortDescriptionLine1
		lists[i].shortDescriptionLine2 = lists[i].description
	end for

	screen.setMessagePort(createObject("roMessagePort"))
	screen.setListStyle("flat-category")
	screen.setBreadCrumbEnabled(false)
	screen.setTitle("Select a list")
	screen.setContentList(lists)
	screen.show()

	m.type = m.contentType

	while true
		msg = wait(0, screen.getMessagePort())
			if msg.isScreenClosed() then
				return false
			else if msg.isListItemSelected() then
				dlg = createObject("roOneLineDialog")
				dlg.setTitle("Talking to trakt.tv")
				dlg.showBusyAnimation()
				dlg.show()

				if m.contentType = "movie" then 
					aSyncFetch("http://api.trakt.tv/lists/items/add/" + getAPIKey(), false, "", 0, true, {
						slug : lists[msg.getIndex()].slug,
						items : [{
							imdb_id:m.imdb_id
							title:m.title
							year:m.year.toStr()
							type:m.type

						}]
					})
					print "Trying to add to list: " + lists[msg.getIndex()].slug + " data:"
				
					print m.imdb_id
					print m.title
					print m.year.toStr()
					return true

				else if m.contentType = "show" OR m.contentType = "series" then 
					aSyncFetch("http://api.trakt.tv/lists/items/add/" + getAPIKey(), false, "", 0, true, {
						slug : lists[msg.getIndex()].slug,
						items : [{
							imdb_id:m.imdb_id
							tvdb_id:m.tvdb_id
							title:m.title
							year:m.year.toStr()
							type:m.type

						}]
					})
					print "Trying to add to list: " + lists[msg.getIndex()].slug + " data:"
				
					print m.imdb_id
					print m.title
					print m.year.toStr()
					return true
				else 
					print m.show
					aSyncFetch("http://api.trakt.tv/lists/items/add/" + getAPIKey(), false, "", 0, true, {
						slug : lists[msg.getIndex()].slug
						items : [{
							tvdb_id:m.show.tvdb_id
							title:m.show.title
							year:m.show.year.toStr()
							episode:m.episode.number.toStr()
							season:m.episode.season.toStr()
							type:m.type
						}]
					})
					return true

				endif
			endif
	end while

end function

function showSearchResults(m as Object, t as String, query as String) as boolean
	if t = "movies" then
		content = createObject("roArray", 0, true)
		genres = getMovieGenres()

		for i = 0 to genres.count()-1
			content.push(createObject("roArray", 0, true)) 
		end for

		for i = 0 to m.count()-1
			cur = m[i]

			cur.shortDescriptionLine1 = cur.title
			cur.shortDescriptionLine2 = cur.tagline
			cur.HDPosterURL = parsePosterImage(cur.images.poster, "138")
			cur.in_watchlist = false 'There isn't a way to know, this needs to be addressed.

			content[0].push(cur)

			for x = 0 to cur.genres.count()-1
				if type(cur.genres[x]) = "Invalid" then
					'Do Nothing
				else if type(cur.genres[x]) <> "Invalid" 
					print type(cur.genres[x])
					idx = getGenreIndex(genres, cur.genres[x])
					content[idx].push(cur)
				endif
				
			end for

		end for

	screen = createObject("roPosterScreen")
	screen.setBreadCrumbText("search", query)
	screen.setListNames(genres)
	screen.setFocusedList(0)
	screen.setContentList(content[0])
	screen.setListStyle("arced-portrait")
	screen.setTitle("Search Results")
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()

	while true
		msg = wait(0, screen.getMessagePort())
		if msg.isScreenClosed() then
			return false
		else if msg.isListFocused() then
			screen.setContentList(content[msg.getIndex()])
		else if msg.isListItemSelected() then
			list = screen.getContentList()
			movieInformation(list[msg.getIndex()])
		endif
	end while

	else if t = "shows" then
		content = createObject("roArray", 0, true)
		genres = getTVGenres()

		for i = 0 to genres.count()-1
			content.push(createObject("roArray", 0, true)) 
		end for

		for i = 0 to m.count()-1
			cur = m[i]

			cur.shortDescriptionLine1 = cur.title
			cur.shortDescriptionLine2 = cur.ratings.percentage.toStr() + "% loved"
			cur.country = cur.country + " •"
			cur.HDPosterURL = parsePosterImage(cur.images.poster, "138")
			cur.in_watchlist = false 'There isn't a way to know, this needs to be addressed.

			content[0].push(cur)

			for x = 0 to cur.genres.count()-1
				if type(cur.genres[x]) = "Invalid" then
					'Do Nothing
				else if type(cur.genres[x]) <> "Invalid" 
					print type(cur.genres[x])
					idx = getGenreIndex(genres, cur.genres[x])
					content[idx].push(cur)
				endif
				
			end for

		end for

	screen = createObject("roPosterScreen")
	screen.setBreadCrumbText("search", query)
	screen.setListNames(genres)
	screen.setFocusedList(0)
	screen.setContentList(content[0])
	screen.setListStyle("arced-portrait")
	screen.setTitle("Search Results")
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()

	while true
		msg = wait(0, screen.getMessagePort())
		if msg.isScreenClosed() then
			return false
		else if msg.isListFocused() then
			screen.setContentList(content[msg.getIndex()])
		else if msg.isListItemSelected() then
			list = screen.getContentList()
			showInformation(list[msg.getIndex()])
		endif
	end while

	else if t = "episodes" then
		content = createObject("roArray", 0, true)
		genres = getTVGenres()

		for i = 0 to genres.count()-1
			content.push(createObject("roArray", 0, true)) 
		end for

		for i = 0 to m.count()-1
			cur = m[i]

			cur.shortDescriptionLine1 = cur.show.title
			cur.shortDescriptionLine2 = cur.episode.title
			if cur.show.country = "null" OR cur.show.country =  "invalid" then
				cur.show.country = ""
			end if

			cur.HDPosterURL = parsePosterImage(cur.show.images.poster, "138")
			cur.in_watchlist = false 'There isn't a way to know, this needs to be addressed.

			content[0].push(cur)

			for x = 0 to cur.show.genres.count()-1
				if type(cur.show.genres[x]) = "Invalid" then
					'Do Nothing
				else if type(cur.show.genres[x]) <> "Invalid" 
					print type(cur.show.genres[x])
					idx = getGenreIndex(genres, cur.show.genres[x])
					content[idx].push(cur)
				endif
				
			end for

		end for

	screen = createObject("roPosterScreen")
	screen.setBreadCrumbText("search", query)
	screen.setListNames(genres)
	screen.setFocusedList(0)
	screen.setContentList(content[0])
	screen.setListStyle("arced-portrait")
	screen.setTitle("Search Results")
	screen.setMessagePort(createObject("roMessagePort"))
	screen.show()

	while true
		msg = wait(0, screen.getMessagePort())
		if msg.isScreenClosed() then
			return false
		else if msg.isListFocused() then
			screen.setContentList(content[msg.getIndex()])
		else if msg.isListItemSelected() then
			list = screen.getContentList()
			print list[msg.getIndex()].show
			print list[msg.getIndex()].episode
			episodeInformation(list[msg.getIndex()])
		endif
	end while

	end if

end function