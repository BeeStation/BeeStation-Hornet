/// 1 tile up
#define UI_HUMANITY_DISPLAY "WEST:6,CENTER+1:0"
/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"
/// 2 tiles down
#define UI_VAMPRANK_DISPLAY "WEST:6,CENTER-2:-5"
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#define UI_SUNLIGHT_DISPLAY "WEST:6,CENTER-0:0"

///Maptext define for Vampire HUDs
#define FORMAT_VAMPIRE_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>")
///Maptext define for Vampire Sunlight HUDs
#define FORMAT_VAMPIRE_SUNLIGHT_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='bottom' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[value]</font></div>")

/atom/movable/screen/vampire
	icon = 'icons/vampires/actions_vampire.dmi'

/atom/movable/screen/vampire/blood_counter
	name = "Vitae"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/vampire/rank_counter
	name = "Vampire Rank"
	icon_state = "rank"
	screen_loc = UI_VAMPRANK_DISPLAY

/atom/movable/screen/vampire/sunlight_counter
	name = "Solar Flare Timer"
	icon_state = "sunlight"
	screen_loc = UI_SUNLIGHT_DISPLAY

/atom/movable/screen/vampire/humanity_counter
	name = "Humanity"
	icon_state = "humanity"
	screen_loc = UI_HUMANITY_DISPLAY

#ifdef VAMPIRE_TESTING
	var/datum/controller/subsystem/sunlight/sunlight_subsystem

/atom/movable/screen/vampire/sunlight_counter/New(loc, ...)
	. = ..()
	sunlight_subsystem = SSsunlight
#endif

/// Update Blood Counter + Rank Counter
/datum/antagonist/vampire/proc/update_hud()
	var/valuecolor
	switch(vampire_blood_volume)
		if(0 to 200)
			valuecolor = "#560808"
		if(201 to 300)
			valuecolor = "#a32a2a"
		if(301 to 500)
			valuecolor = "#d55c5c"
		if(501 to 700)	// This isn't janky, a tiny bit lenience is baked in.
			valuecolor = "#ffc2c2"
		if(701 to INFINITY)
			valuecolor = "#ffffff"

	blood_display?.maptext = FORMAT_VAMPIRE_HUD_TEXT(valuecolor, vampire_blood_volume)

	if(vamprank_display)
		if(vampire_level_unspent > 0)
			vamprank_display.icon_state = "[initial(vamprank_display.icon_state)]_up"
		else
			vamprank_display.icon_state = initial(vamprank_display.icon_state)
		vamprank_display.maptext = FORMAT_VAMPIRE_HUD_TEXT("#ffd8d8", vampire_level)

	if(humanity_display)
		var/humanityvaluecolor
		switch(humanity)
			if(0 to 2)
				humanityvaluecolor = "#600000"
			if(3 to 4)
				humanityvaluecolor = "#a71c1c"
			if(4 to 5)
				humanityvaluecolor = "#db4646"
			if(6 to 8)	// same here
				humanityvaluecolor = "#e8adad"
			if(9 to 10)
				humanityvaluecolor = "#ffffff"

		humanity_display.maptext = FORMAT_VAMPIRE_HUD_TEXT(humanityvaluecolor, humanity)

	if(sunlight_display)
		var/sunlightvaluecolor = "#ffffff"
		if(SSsunlight.sunlight_active)
			sunlightvaluecolor = "#FF5555"
			sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_day"
		else
			switch(round(SSsunlight.time_til_cycle, 1))
				if(0 to 30)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_30"
					sunlightvaluecolor = "#FFCCCC"
				if(31 to 60)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_60"
					sunlightvaluecolor = "#FFE6CC"
				if(61 to 90)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_90"
					sunlightvaluecolor = "#FFFFCC"
				else
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_night"
					sunlightvaluecolor = "#FFFFFF"

		sunlight_display.maptext = FORMAT_VAMPIRE_SUNLIGHT_TEXT( \
			sunlightvaluecolor, \
			(SSsunlight.time_til_cycle >= 60) ? "[round(SSsunlight.time_til_cycle / 60, 1)] m" : "[round(SSsunlight.time_til_cycle, 1)] s" \
		)

/// 1 tile up
#undef UI_HUMANITY_DISPLAY
/// 1 tile down
#undef UI_BLOOD_DISPLAY
/// 2 tiles down
#undef UI_VAMPRANK_DISPLAY
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#undef UI_SUNLIGHT_DISPLAY

///Maptext define for Vampire HUDs
#undef FORMAT_VAMPIRE_HUD_TEXT
///Maptext define for Vampire Sunlight HUDs
#undef FORMAT_VAMPIRE_SUNLIGHT_TEXT
