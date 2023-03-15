GLOBAL_VAR(current_soundtrack)
GLOBAL_LIST_EMPTY(soundtrack_this_round) // A running list of soundtrack songs that have played this round, for credits entries

/datum/soundtrack_song
	var/title
	var/artist
	var/url
	var/album
	var/file
	/// Length, in deciseconds, of this soundtrack. Used for determining when to stop playing soundtrack stuff after the initial run if someone toggles the preference.
	var/length
	/// If this should only play to the station (typically)
	var/station_only = FALSE
	/// Volume to send the track at. Can be used to normalize the volume for particularly loud or busy tracks.
	var/volume = 80

/datum/soundtrack_song/bee
	album = "BeeStation OST"

/datum/soundtrack_song/bee/future_perception
	title = "Future Perception"
	artist = "Merct"
	url = "https://www.youtube.com/watch?v=N9559mSGjKg"
	file = 'sound/soundtrack/future_perception.ogg'
	length = (3 MINUTES) + (20 SECONDS)

/datum/soundtrack_song/bee/countdown
	title = "Countdown"
	artist = "qwertyquerty"
	url = "https://www.youtube.com/watch?v=G2gVAPKlgqA"
	file = 'sound/soundtrack/countdown.ogg'
	length = (1 MINUTES) + (51 SECONDS)
	station_only = TRUE

/datum/soundtrack_song/bee/mind_crawler
	title = "Mind Crawler"
	artist = "Merct"
	url = "https://www.youtube.com/watch?v=EiLBxoBNsNo"
	file = 'sound/soundtrack/mind_crawler.ogg'
	length = (2 MINUTES) + (50 SECONDS)
	station_only = TRUE
