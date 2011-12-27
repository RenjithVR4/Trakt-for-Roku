function runTvRecommendations() as Integer
	result = post("http://api.trakt.tv/recommendations/shows/" + getAPIKey(), createObject("roAssociativeArray"), true)
	contentMeta = createObject("roArray", result.count(), true)
	for n = 0 TO result.count()-1
		o = createObject("roAssociativeArray")
		o.contentType = "movie"
		o.title = result[n].title
		o.description = result[n].overview
		o.hdposterutl = result[n].poster
		o.sdposterutl = result[n].poster
		o.url = result[n].poster

		ratings = result[n].ratings
		o.starrating = ratings.percentage
		o.releasedate = result[n].year
		contentMeta.push(o)
	end for
	
	
	gridScreen = CreateObject("roGridScreen")
	gridScreen.setUpLists(1)
	gridScreen.setlistname(0, "T.V. Recommendations")
	gridScreen.setContentList(0,contentMeta)
	gridScreen.setGridStyle("flat-landscape")
	gridScreen.setDisplayMode("scale-to-fill")
	gridscreen.show()
	while true
	
	end while
end function
