//!!CURRENTLY UNUSED!!//

///Returns a random color picked from a list, has 2 modes (0 and 1), mode 1 doesn't pick white, black or gray
/proc/random_color_roll(mode = 0)	//if 1 it doesn't pick white, black or gray
	switch(mode)
		if(0)
			return pick("white","black","gray","red","green","blue","brown","yellow","orange","darkred",
						"crimson","lime","darkgreen","cyan","navy","teal","purple","indigo")
		if(1)
			return pick("red","green","blue","brown","yellow","orange","darkred","crimson",
						"lime","darkgreen","cyan","navy","teal","purple","indigo")
		else
			return "white"

/// Inverts the colour of an HTML string
/proc/invert_HTML_color(HTMLstring)
	if(!istext(HTMLstring))
		CRASH("Given non-text argument!")
	else if(length(HTMLstring) != 7)
		CRASH("Given non-HTML argument!")
	else if(length_char(HTMLstring) != 7)
		CRASH("Given non-hex symbols in argument!")
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	return rgb(255 - hex2num(textr), 255 - hex2num(textg), 255 - hex2num(textb))

///Flash a color on the client
/proc/flash_color(mob_or_client, flash_color="#960000", flash_time=20)
	var/client/C
	if(ismob(mob_or_client))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(istype(mob_or_client, /client))
		C = mob_or_client

	if(!istype(C))
		return

	var/animate_color = C.color
	C.color = flash_color
	animate(C, color = animate_color, time = flash_time)

/// Ensures that the lightness value of a colour must be greater than the provided
/// minimum.
/proc/color_lightness_max(colour, min_lightness)
	var/list/rgb = rgb2num(colour)
	var/list/hsl = rgb2hsl(rgb[1], rgb[2], rgb[3])
	// Ensure high lightness (Minimum of 90%)
	hsl[3] = max(hsl[3], min_lightness)
	var/list/transformed_rgb = hsl2rgb(hsl[1], hsl[2], hsl[3])
	return rgb(transformed_rgb[1], transformed_rgb[2], transformed_rgb[3])

/// Ensures that the lightness value of a colour must be less than the provided
/// maximum.
/proc/color_lightness_min(colour, max_lightness)
	var/list/rgb = rgb2num(colour)
	var/list/hsl = rgb2hsl(rgb[1], rgb[2], rgb[3])
	// Ensure high lightness (Minimum of 90%)
	hsl[3] = min(hsl[3], max_lightness)
	var/list/transformed_rgb = hsl2rgb(hsl[1], hsl[2], hsl[3])
	return rgb(transformed_rgb[1], transformed_rgb[2], transformed_rgb[3])

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))
