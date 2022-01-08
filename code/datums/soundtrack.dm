GLOBAL_LIST_EMPTY(soundtrack_this_round) // A running list of soundtrack songs that have played this round, for credits entries

/datum/soundtrack_song
	var/title
	var/artist
	var/url
	var/album
	var/file

/datum/soundtrack_song/bee
	album = "BeeStation OST"

/datum/soundtrack_song/bee/future_perception
	title = "Future Perception"
	artist = "Merct"
	url = "https://www.youtube.com/watch?v=N9559mSGjKg"
	file = 'sound/soundtrack/future_perception.ogg'

/datum/soundtrack_song/bee/countdown
	title = "Countdown"
	artist = "qwertyquerty"
	url = "https://www.youtube.com/watch?v=G2gVAPKlgqA"
	file = 'sound/soundtrack/countdown.ogg'

/datum/soundtrack_song/bee/mind_crawler
	title = "Mind Crawler"
	artist = "Merct"
	url = "https://www.youtube.com/watch?v=EiLBxoBNsNo"
	file = 'sound/soundtrack/mind_crawler.ogg'
