//general stuff
/// Return `number` if it is in the range `min to max`, otherwise `default`
/proc/sanitize_integer(number, min=0, max=1, default=0)
	if(isnum_safe(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/// Return `float` if it is in the range `min to max`, otherwise `default`
/proc/sanitize_float(number, min=0, max=1, accuracy=0.1, default=0)
	if(isnum_safe(number))
		number = round(number, accuracy)
		if(round(min, accuracy) <= number && number <= round(max, accuracy))
			return number
	return default

/// Return `text` if it is text, otherwise `default`
/proc/sanitize_text(text, default="")
	if(istext(text))
		return text
	return default

/// Return `value` if it is a list, otherwise `default`
/proc/sanitize_islist(value, default)
	if(length(value))
		return value
	if(default)
		return default

/// Return `value` if it's in List, otherwise `default`
/proc/sanitize_inlist(value, list/List, default)
	if(value in List)
		return value
	if(default)
		return default
	if(List?.len)
		return pick(List)



//more specialised stuff
/// Return `gender` if it is a valid gender, otherwise `default`. No I did not mean to offend you. -qwerty
/proc/sanitize_gender(gender,neuter=0,plural=0, default="male")
	switch(gender)
		if(MALE, FEMALE, PLURAL)
			return gender
		if(NEUTER)
			if(neuter)
				return gender
			else
				return default
	return default

/// Return `color` if it is a valid hex color, otherwise `default`
/proc/sanitize_hexcolor(color, desired_format = 3, include_crunch = FALSE, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// Used for conversion between RGBA hex formats.
	var/format_input_ratio = "[desired_format]:[length_char(color)-(start-1)]"

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		i += length(char)
		switch(text2ascii(char))
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				char = lowertext(char)
				. += char
			else
				break
		switch(format_input_ratio)
			if("3:8", "4:8", "3:6", "4:6") //skip next one. RRGGBB(AA) -> RGB(A)
				i += length(color[i])
			if("6:4", "6:3", "8:4", "8:3") //add current char again. RGB(A) -> RRGGBB(AA)
				. += char

	if(length_char(.) == desired_format)
		return crunch + .
	switch(format_input_ratio) //add or remove alpha channel depending on desired format.
		if("3:8", "3:4", "6:4")
			return crunch + copytext(., 1, desired_format+1)
		if("4:6", "4:3", "8:3")
			return crunch + . + ((desired_format == 4) ? "f" : "ff")
		else //not a supported hex color format.
			return default ? default : crunch + repeat_string(desired_format, "0")
