//Splits the text of a file at seperator and returns them in a list.
//returns an empty list if the file doesn't exist
/world/proc/file2list(filename, seperator="\n", trim = TRUE)
	if (trim)
		return splittext(trim(rustg_file_read(filename)),seperator)
	return splittext(rustg_file_read(filename),seperator)

//Turns a direction into text
/proc/dir2text(direction)
	switch(direction)
		if(NORTH)
			return "north"
		if(SOUTH)
			return "south"
		if(EAST)
			return "east"
		if(WEST)
			return "west"
		if(NORTHEAST)
			return "northeast"
		if(SOUTHEAST)
			return "southeast"
		if(NORTHWEST)
			return "northwest"
		if(SOUTHWEST)
			return "southwest"

/// Turns text into proper direction bitmasks
/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return NORTH
		if("SOUTH")
			return SOUTH
		if("EAST")
			return EAST
		if("WEST")
			return WEST
		if("NORTHEAST")
			return NORTHEAST
		if("NORTHWEST")
			return NORTHWEST
		if("SOUTHEAST")
			return SOUTHEAST
		if("SOUTHWEST")
			return SOUTHWEST

/// Converts an angle (degrees) into an ss13 direction bitmask
/proc/angle2dir(degree)
	degree = SIMPLIFY_DEGREES(degree)
	switch(degree)
		if(0 to 22.5) //north requires two angle ranges
			return NORTH
		if(22.5 to 67.5) //each range covers 45 degrees
			return NORTHEAST
		if(67.5 to 112.5)
			return EAST
		if(112.5 to 157.5)
			return SOUTHEAST
		if(157.5 to 202.5)
			return SOUTH
		if(202.5 to 247.5)
			return SOUTHWEST
		if(247.5 to 292.5)
			return WEST
		if(292.5 to 337.5)
			return NORTHWEST
		if(337.5 to 360)
			return NORTH

/// Converts an angle to a cardinal ss13 direction bitmask
/proc/angle2dir_cardinal(degree)
	degree = SIMPLIFY_DEGREES(degree)
	switch(round(degree, 0.1))
		if(315.5 to 360, 0 to 45.5)
			return NORTH
		if(45.6 to 135.5)
			return EAST
		if(135.6 to 225.5)
			return SOUTH
		if(225.6 to 315.5)
			return WEST

/// Returns the north-zero clockwise angle in degrees, given a direction
/proc/dir2angle(D)
	switch(D)
		if(NORTH)
			return 0
		if(SOUTH)
			return 180
		if(EAST)
			return 90
		if(WEST)
			return 270
		if(NORTHEAST)
			return 45
		if(SOUTHEAST)
			return 135
		if(NORTHWEST)
			return 315
		if(SOUTHWEST)
			return 225

///Returns a single dir rotated by x degrees clockwise, adhering to the cardinal directions.
#define turn_cardinal(dir, rotation) ( angle2dir_cardinal ( dir2angle(dir) + rotation ) )

/// Converts a blend_mode constant to one acceptable to icon.Blend()
/proc/blendMode2iconMode(blend_mode)
	switch(blend_mode)
		if(BLEND_MULTIPLY)
			return ICON_MULTIPLY
		if(BLEND_ADD)
			return ICON_ADD
		if(BLEND_SUBTRACT)
			return ICON_SUBTRACT
		else
			return ICON_OVERLAY

/// Converts a rights bitfield into a string
/proc/rights2text(rights, seperator="", prefix = "+")
	seperator += prefix
	if(rights & R_BUILD)
		. += "[seperator]BUILDMODE"
	if(rights & R_ADMIN)
		. += "[seperator]ADMIN"
	if(rights & R_BAN)
		. += "[seperator]BAN"
	if(rights & R_FUN)
		. += "[seperator]FUN"
	if(rights & R_SERVER)
		. += "[seperator]SERVER"
	if(rights & R_DEBUG)
		. += "[seperator]DEBUG"
	if(rights & R_POSSESS)
		. += "[seperator]POSSESS"
	if(rights & R_PERMISSIONS)
		. += "[seperator]PERMISSIONS"
	if(rights & R_STEALTH)
		. += "[seperator]STEALTH"
	if(rights & R_POLL)
		. += "[seperator]POLL"
	if(rights & R_VAREDIT)
		. += "[seperator]VAREDIT"
	if(rights & R_SOUND)
		. += "[seperator]SOUND"
	if(rights & R_SPAWN)
		. += "[seperator]SPAWN"
	if(rights & R_AUTOADMIN)
		. += "[seperator]AUTOLOGIN"
	if(rights & R_DBRANKS)
		. += "[seperator]DBRANKS"
	if(rights & R_SUPPRESS)
		. += "[seperator]SUPPRESS"
	if(!.)
		. = "NONE"
	return .

/// For finding out what body parts a body zone covers, the inverse of the below basically
/proc/body_zone2cover_flags(def_zone)
	switch(def_zone)
		if(BODY_ZONE_CHEST)
			return CHEST|GROIN
		if(BODY_ZONE_HEAD)
			return HEAD
		if(BODY_ZONE_L_ARM)
			return ARM_LEFT|HAND_LEFT
		if(BODY_ZONE_R_ARM)
			return ARM_RIGHT|HAND_RIGHT
		if(BODY_ZONE_L_LEG)
			return LEG_LEFT|FOOT_LEFT
		if(BODY_ZONE_R_LEG)
			return LEG_RIGHT|FOOT_RIGHT

//Turns a Body_parts_covered bitfield into a list of organ/limb names.
//(I challenge you to find a use for this) -I found a use for it!! | So did I!.
/proc/cover_flags2body_zones(bpc)
	var/list/covered_parts = list()

	if(!bpc)
		return 0

	if(bpc == FULL_BODY)
		covered_parts |= list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)

	else
		if(bpc & HEAD)
			covered_parts |= list(BODY_ZONE_HEAD)
		if(bpc & CHEST)
			covered_parts |= list(BODY_ZONE_CHEST)
		if(bpc & GROIN)
			covered_parts |= list(BODY_ZONE_CHEST)

		if(bpc & ARMS)
			covered_parts |= list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM)
		else
			if(bpc & ARM_LEFT)
				covered_parts |= list(BODY_ZONE_L_ARM)
			if(bpc & ARM_RIGHT)
				covered_parts |= list(BODY_ZONE_R_ARM)

		if(bpc & HANDS)
			covered_parts |= list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM)
		else
			if(bpc & HAND_LEFT)
				covered_parts |= list(BODY_ZONE_L_ARM)
			if(bpc & HAND_RIGHT)
				covered_parts |= list(BODY_ZONE_R_ARM)

		if(bpc & LEGS)
			covered_parts |= list(BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)
		else
			if(bpc & LEG_LEFT)
				covered_parts |= list(BODY_ZONE_L_LEG)
			if(bpc & LEG_RIGHT)
				covered_parts |= list(BODY_ZONE_R_LEG)

		if(bpc & FEET)
			covered_parts |= list(BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)
		else
			if(bpc & FOOT_LEFT)
				covered_parts |= list(BODY_ZONE_L_LEG)
			if(bpc & FOOT_RIGHT)
				covered_parts |= list(BODY_ZONE_R_LEG)

/// Very ugly, BYOND doesn't support unix time and rounding errors make it really hard to convert it to BYOND time. returns "YYYY-MM-DD" by default
/proc/unix2date(timestamp, seperator = "-")

	if(timestamp < 0)
		return 0 //Do not accept negative values

	var/year = 1970 //Unix Epoc begins 1970-01-01
	var/dayInSeconds = 86400 //60secs*60mins*24hours
	var/daysInYear = 365 //Non Leap Year
	var/daysInLYear = daysInYear + 1//Leap year
	var/days = round(timestamp / dayInSeconds) //Days passed since UNIX Epoc
	var/tmpDays = days + 1 //If passed (timestamp < dayInSeconds), it will return 0, so add 1
	var/monthsInDays = list() //Months will be in here ***Taken from the PHP source code***
	var/month = 1 //This will be the returned MONTH NUMBER.
	var/day //This will be the returned day number.

	while(tmpDays > daysInYear) //Start adding years to 1970
		year++
		if(isLeap(year))
			tmpDays -= daysInLYear
		else
			tmpDays -= daysInYear

	if(isLeap(year)) //The year is a leap year
		monthsInDays = list(-1,30,59,90,120,151,181,212,243,273,304,334)
	else
		monthsInDays = list(0,31,59,90,120,151,181,212,243,273,304,334)

	var/mDays = 0;
	var/monthIndex = 0;

	for(var/m in monthsInDays)
		monthIndex++
		if(tmpDays > m)
			mDays = m
			month = monthIndex

	day = tmpDays - mDays //Setup the date

	return "[year][seperator][((month < 10) ? "0[month]" : month)][seperator][((day < 10) ? "0[day]" : day)]"

/// Returns whether the specified year is a leap year
/proc/isLeap(y)
	return ((y) % 4 == 0 && ((y) % 100 != 0 || (y) % 400 == 0))

/// Turns a Body_parts_covered bitfield into a list of organ/limb names. (I challenge you to find a use for this)
/proc/body_parts_covered2organ_names(bpc)
	var/list/covered_parts = list()

	if(!bpc)
		return 0

	if(bpc & FULL_BODY)
		covered_parts |= list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)

	else
		if(bpc & HEAD)
			covered_parts |= list(BODY_ZONE_HEAD)
		if(bpc & CHEST)
			covered_parts |= list(BODY_ZONE_CHEST)
		if(bpc & GROIN)
			covered_parts |= list(BODY_ZONE_CHEST)

		if(bpc & ARMS)
			covered_parts |= list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM)
		else
			if(bpc & ARM_LEFT)
				covered_parts |= list(BODY_ZONE_L_ARM)
			if(bpc & ARM_RIGHT)
				covered_parts |= list(BODY_ZONE_R_ARM)

		if(bpc & HANDS)
			covered_parts |= list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM)
		else
			if(bpc & HAND_LEFT)
				covered_parts |= list(BODY_ZONE_L_ARM)
			if(bpc & HAND_RIGHT)
				covered_parts |= list(BODY_ZONE_R_ARM)

		if(bpc & LEGS)
			covered_parts |= list(BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)
		else
			if(bpc & LEG_LEFT)
				covered_parts |= list(BODY_ZONE_L_LEG)
			if(bpc & LEG_RIGHT)
				covered_parts |= list(BODY_ZONE_R_LEG)

		if(bpc & FEET)
			covered_parts |= list(BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)
		else
			if(bpc & FOOT_LEFT)
				covered_parts |= list(BODY_ZONE_L_LEG)
			if(bpc & FOOT_RIGHT)
				covered_parts |= list(BODY_ZONE_R_LEG)

	return covered_parts

/// Returns the body_zone a given slot appears on
/proc/slot2body_zone(slot)
	switch(slot)
		if(ITEM_SLOT_BACK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_BELT, ITEM_SLOT_ID)
			return BODY_ZONE_CHEST

		if(ITEM_SLOT_GLOVES, ITEM_SLOT_HANDS, ITEM_SLOT_HANDCUFFED)
			return pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)

		if(ITEM_SLOT_HEAD, ITEM_SLOT_NECK, ITEM_SLOT_NECK, ITEM_SLOT_EARS)
			return BODY_ZONE_HEAD

		if(ITEM_SLOT_MASK)
			return BODY_ZONE_PRECISE_MOUTH

		if(ITEM_SLOT_EYES)
			return BODY_ZONE_PRECISE_EYES

		if(ITEM_SLOT_FEET)
			return pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)

		if(ITEM_SLOT_LEGCUFFED)
			return pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/**
This is a weird one: It returns a list of all var names found in the string. These vars must be in the [var_name] format
It's only a proc because it's used in more than one place

Takes a string and a datum. The string is well, obviously the string being checked. The datum is used as a source for var names, to check validity. Otherwise every single word could technically be a variable!
*/
/proc/string2listofvars(t_string, datum/var_source)
	if(!t_string || !var_source)
		return list()

	. = list()

	var/var_found = findtext(t_string,"\[") //Not the actual variables, just a generic "should we even bother" check
	if(var_found)
		//Find var names

		// "A dog said hi [name]!"
		// splittext() --> list("A dog said hi ","name]!"
		// jointext() --> "A dog said hi name]!"
		// splittext() --> list("A","dog","said","hi","name]!")

		t_string = replacetext(t_string,"\[","\[ ")//Necessary to resolve "word[var_name]" scenarios
		var/list/list_value = splittext(t_string,"\[")
		var/intermediate_stage = jointext(list_value, null)

		list_value = splittext(intermediate_stage," ")
		for(var/value in list_value)
			if(findtext(value,"]"))
				value = splittext(value,"]") //"name]!" --> list("name","!")
				for(var/A in value)
					if(var_source.vars.Find(A))
						. += A

//word of warning: using a matrix like this as a color value will simplify it back to a string after being set
/proc/color_hex2color_matrix(string)
	var/length = length(string)
	if((length != 7 && length != 9) || length != length_char(string))
		return color_matrix_identity()
	// For runtime safety
	. = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
	var/list/color = rgb2num(string)
	var/r = color[1] / 255
	var/g = color[2] / 255
	var/b = color[3] / 255
	var/a = 1
	if(length(color) == 4)
		a = color[4] / 255
	return list(r,0,0,0, 0,g,0,0, 0,0,b,0, 0,0,0,a, 0,0,0,0)

/// Return html to load a url.
/// for use inside of browse() calls to html assets that might be loaded on a cdn.
/proc/url2htmlloader(url)
	return {"<html><head><meta http-equiv="refresh" content="0;URL='[url]'"/></head><body onLoad="parent.location='[url]'"></body></html>"}
