/// Returns the world time in hh:mm:ss
/proc/worldtime2text()
	return gameTimestamp("hh:mm:ss", world.time)

/// Returns the world time into hh:mm:ss with the option of showing deciseconds
/proc/time_stamp(format = "hh:mm:ss", show_ds)
	var/time_string = time2text(world.timeofday, format)
	return show_ds ? "[time_string]:[world.timeofday % 10]" : time_string

/// Returns timestamp since the server started, for use with world.time
/proc/gameTimestamp(format = "hh:mm:ss", wtime=world.time)
	return time2text(wtime, format, NO_TIMEZONE)

///returns the current IC station time in a world.time format
/proc/station_time(wtime = world.time)
	return (((wtime - SSticker.round_start_time) * SSticker.station_time_rate_multiplier) + SSticker.gametime_offset) % (24 HOURS)

///returns the current IC station time in a human readable format
/proc/station_time_timestamp(format = "hh:mm:ss", wtime)
	return time2text(station_time(wtime), format, NO_TIMEZONE)

/proc/station_time_debug(force_set)
	if(isnum_safe(force_set))
		SSticker.gametime_offset = force_set
		return
	SSticker.gametime_offset = rand(0, 24 HOURS)		//hours in day * minutes in hour * seconds in minute * deciseconds in second
	if(prob(50))
		SSticker.gametime_offset = FLOOR(SSticker.gametime_offset, 3600)
	else
		SSticker.gametime_offset = CEILING(SSticker.gametime_offset, 3600)

/// Returns 1 if it is the selected month and day
/proc/isDay(month, day)
	if(isnum_safe(month) && isnum_safe(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

/// returns timestamp in a sql and a not-quite-compliant ISO 8601 friendly format
/proc/SQLtime(timevar)
	return time2text(timevar || world.timeofday, "YYYY-MM-DD hh:mm:ss")


GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if (world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		GLOB.midnight_rollovers++
	GLOB.rollovercheck_last_timeofday = world.timeofday
	return GLOB.midnight_rollovers

/// Returns which week of the month we are in
/proc/weekdayofthemonth()
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	switch(DD)
		if(8 to 13)
			return 2
		if(14 to 20)
			return 3
		if(21 to 27)
			return 4
		if(28 to INFINITY)
			return 5
		else
			return 1

/// Takes a value of time in deciseconds. Returns a text value of that number in hours, minutes, or seconds.
/proc/DisplayTimeText(time_value, round_seconds_to = 0.1)
	var/second = FLOOR(time_value * 0.1, round_seconds_to)
	if(!second)
		return "right now"
	if(second < 60)
		return "[second] second[(second != 1)? "s":""]"
	var/minute = floor(second / 60)
	second = FLOOR(MODULUS(second, 60), round_seconds_to)
	var/secondT
	if(second)
		secondT = " and [second] second[(second != 1)? "s":""]"
	if(minute < 60)
		return "[minute] minute[(minute != 1)? "s":""][secondT]"
	var/hour = floor(minute / 60)
	minute = MODULUS(minute, 60)
	var/minuteT
	if(minute)
		minuteT = " and [minute] minute[(minute != 1)? "s":""]"
	if(hour < 24)
		return "[hour] hour[(hour != 1)? "s":""][minuteT][secondT]"
	var/day = floor(hour / 24)
	hour = MODULUS(hour, 24)
	var/hourT
	if(hour)
		hourT = " and [hour] hour[(hour != 1)? "s":""]"
	return "[day] day[(day != 1)? "s":""][hourT][minuteT][secondT]"


/// Returns the time in an ISO-8601 friendly format. Used when dumping data into external services such as ElasticSearch
/proc/iso_timestamp(timevar)
	return time2text(timevar || world.timeofday, "YYYY-MM-DDThh:mm:ss")
