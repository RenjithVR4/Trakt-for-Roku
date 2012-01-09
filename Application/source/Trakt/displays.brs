'*****************************************
'	episodeInformation(metaData, quickLoad = false)
'	@params:    metaData as rowAssociativeArray containing all the current data.
'				quickLoad allows the screen to load the information and display before background has a chance to load.  Reduces wait times, but creates ugly loading screens.
'	@return:  	instruction as String
'				this instruction will tell the caller to refresh the page if important information has changed.
'*****************************************

function episodeInformation(m as Object, quickLoad = false) as String
		
		'	*** Data from Trakt API:
		'		watched
		'		userRating
		'		inWatchlist
		'		show
		'		year
		'		firstAired
		'		country
		'		runtime
		'		network
		'		airday
		'		airtime
		'		certification
		'		imdb
		'		 poster
		'		fanart
		'		banner
		'		season
		'		pisodeNumber
		'		episodeTitle
		'		episodeFirstAired
		'		episodeScreen
	fonts = createObject("roFontRegistry")
	fonts.register("pkg:/fonts/droidsans.tff")
	fonts.register("pkg:/fonts/droidsans-bold.tff")
	
	
	c = createObject("roImageCanvas")
	cUp = createObject("roImageCanvas")
	cr = c.getCanvasRect()
	w = cr.w
	h = cr.h
	print h
	print w
	backgroundBanner = [{
		url:m.fanart
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
		Text:m.show
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans-bold", 36, 5, false), HAlign:"Left", Valign:"Bottom", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:90,y:585,h:45,w:720}
		Text:m.episodeTitle + " » " + m.season.toStr() + "x" + m.episodeNumber.toStr()
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 24, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:90,y:610,h:45,w:360}
		Text:m.date
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 20, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:360, w:450, h:270}
		Text:conCat(m.description, 550)
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 21, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		{
		TargetRect:{x:720, y:630, w:450, h:90}
		Text:m.airDay + "s at " + m.airTime + " on " + m.network + "  •  " + m.certification
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 18, 1, true), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		}
		
	]
	
	canvasActions = getOptionsCanvas(m, fonts)
	c.setLayer(1, backgroundBanner)
	c.setLayer(2, transparentOverlay)
	c.setLayer(3, screenElements)
	if not quickLoad then c.setRequireAllImagesToDraw(true)
	port = createObject("roMessagePort")

	c.setMessagePort(port)
	canvasActions.setMessagePort(port)
	c.show()
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
			
					
				if actionsOpen then
					'Handle actions bar presses.
					if idx = 4  then
						sendRating("hate", m)
						showRatingBar(fonts, "Rating sent:  weak sauce :(")
					else if idx = 5 then
						sendRating("love", m)
						showRatingBar(fonts, "Rating sent:  totally ninja!")
						
					else if idx = 0 OR idx = 2 OR idx = 3 then
 						addOrRemoveFromWatchlist(m)
					endif
				else
					'Open the actions bar, or close the screen.
					if idx = 2 OR idx = 3 OR idx = 6 then
						'Show the action bar!
						actionsOpen = true
						canvasActions.show()
					else if idx = 0 then
						c.close()
						return ""
					endif
				endif
			endif
		endif
	end while
end function

function getOptionsCanvas(m as Object, fonts as Object) as Object
	canvas = createObject("roImageCanvas")
	
	topBar = [{
		targetRect:{x: 0, y: 0, w: 1280, h: 45}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}]
	
	watchListURL = "pkg:/images/icon-watchlist.png"
	
	if m.inwatchlist then watchListURL = "pkg:/images/icon-remove-watchlist.png"
	
	
	watchlist = [{
		targetRect:{x: 640, y:0, w:25, h:40}
		url:watchListURL
	}]
	hate = [{
		targetRect:{x: 491,y:0, w:49, h:45}
		URL:"pkg:/images/icon-hate.png"
	}]
	love = [{
		targetRect:{x: 765,y:0, w:49, h:45}
		URL:"pkg:/images/icon-love.png"
	}]

	canvas.setLayer(0, topBar)
	canvas.setLayer(3, watchlist)
	canvas.setLayer(1, hate)
	canvas.setLayer(2, love)
	
	
	return canvas
end function

function showRatingBar(fonts as Object, text as String)
	canvas = createObject("roImageCanvas")
	elements = [{
		targetRect:{x: 0, y: 45, w: 1280, h: 45}
		url:"pkg:/images/HD_Transparent_Show_BG.png"
	}, 
	{
		targetRect:{x: 640, y:0, w:25, h:40}
		text:text
		TextAttrs:{Color:"#FFFFFF", Font:fonts.get("droidsans", 21, 1, false), HAlign:"Left", Valign:"Left", Direction:"LeftToRight"}
		
	}
	]
end function

function showInformation(m as Object, quickLoad = false) as String
		
	fonts = createObject("roFontRegistry")
	fonts.register("pkg:/fonts/droidsans.tff")
	fonts.register("pkg:/fonts/droidsans-bold.tff")
	
	
	c = createObject("roImageCanvas")
	cUp = createObject("roImageCanvas")
	cr = c.getCanvasRect()
	w = cr.w
	h = cr.h

	backgroundBanner = [{
		url:m.images.fanart
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
	


	
	c.setLayer(1, backgroundBanner)
	c.setLayer(2, transparentOverlay)
	c.setLayer(3, screenElements)
	if not quickLoad then c.setRequireAllImagesToDraw(true)
	port = createObject("roMessagePort")

	c.setMessagePort(port)
	c.show()
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
					if idx = 2 OR idx = 3 OR idx = 6 then
						'Show the action bar!
					else if idx = 0 then
						c.close()
						return ""
					endif
			endif
		endif
	end while
end function

function movieInformation(m as Object, quickLoad = false) as String
		
	fonts = createObject("roFontRegistry")
	fonts.register("pkg:/fonts/droidsans.tff")
	fonts.register("pkg:/fonts/droidsans-bold.tff")
	
	
	c = createObject("roImageCanvas")
	cUp = createObject("roImageCanvas")
	cr = c.getCanvasRect()
	w = cr.w
	h = cr.h

	backgroundBanner = [{
		url:m.images.fanart
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
		TargetRect:{x:90,y:585,h:45,w:540}
		Text:m.tagline
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
	


	
	c.setLayer(1, backgroundBanner)
	c.setLayer(2, transparentOverlay)
	c.setLayer(3, screenElements)
	if not quickLoad then c.setRequireAllImagesToDraw(true)
	port = createObject("roMessagePort")

	c.setMessagePort(port)
	c.show()
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
					if idx = 2 OR idx = 3 OR idx = 6 then
						'Show the action bar!
					else if idx = 0 then
						c.close()
						return ""
					endif
			endif
		endif
	end while
end function


