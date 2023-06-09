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
		if(min <= number && number <= max)
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
/proc/sanitize_hexcolor(color, desired_format=3, include_crunch=0, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// RRGGBB -> RGB but awful
	var/convert_to_shorthand = desired_format == 3 && length_char(color) > 3

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		switch(text2ascii(char))
			if(48 to 57)		//numbers 0 to 9
				. += char
			if(97 to 102)		//letters a to f
				. += char
			if(65 to 70)		//letters A to F
				. += lowertext(char)
			else
				break
		i += length(char)
		if(convert_to_shorthand && i <= len) //skip next one
			i += length(color[i])

	if(length_char(.) != desired_format)
		if(default)
			return default
		return crunch + repeat_string(desired_format, "0")

	return crunch + .

/// Return `color` as a formatted ooc valid hex color
/proc/sanitize_ooccolor(color)
	if(length(color) != length_char(color))
		CRASH("Invalid characters in color '[color]'")
	var/list/HSL = rgb2hsl(hex2num(copytext(color, 2, 4)), hex2num(copytext(color, 4, 6)), hex2num(copytext(color, 6, 8)))
	HSL[3] = min(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"
