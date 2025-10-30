/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"
/// 0 tile down
#define UI_HUMANITY_DISPLAY "WEST:6,CENTER1:0"
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
	desc = "How much life essence you have gathered. ~700 is considered average, try to keep above that."
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/vampire/humanity_counter
	name = "Humanity"
	desc = "Your closeness to humanity, or to the beast. A higher score means you are more in-tune with humanity, and might even feign being one."
	icon_state = "blood_display"
	screen_loc = UI_HUMANITY_DISPLAY

/atom/movable/screen/vampire/rank_counter
	name = "Vampire Rank"
	desc = "An abstract way to measure mastery of your vampiric disciplines."
	icon_state = "rank"
	screen_loc = UI_VAMPRANK_DISPLAY

/atom/movable/screen/vampire/sunlight_counter
	name = "Solar Flare Timer"
	desc = "The time until Sol rises, when this happens solar flares will bombard the station heavily weakening you. Sleep in a coffin to avoid this!"
	icon_state = "sunlight"
	screen_loc = UI_SUNLIGHT_DISPLAY

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
		if(0 - 200)
			valuecolor = "#500000"
		if(201 - 300)
			valuecolor = "#850a0a"
		if(301 - 500)
			valuecolor = "#a72d2d"
		if(501 - 700)	// This isn't a janky, a tiny bit lenience is baked in.
			valuecolor = "#ba5e5e"
		if(701 - INFINITY)
			valuecolor = "#f1cece"

	blood_display?.maptext = FORMAT_VAMPIRE_HUD_TEXT(valuecolor, vampire_blood_volume)

	if(vamprank_display)
		if(vampire_level_unspent > 0)
			vamprank_display.icon_state = "[initial(vamprank_display.icon_state)]_up"
		else
			vamprank_display.icon_state = initial(vamprank_display.icon_state)
		vamprank_display.maptext = FORMAT_VAMPIRE_HUD_TEXT(valuecolor, vampire_level)

	if(sunlight_display)
		if(SSsunlight.sunlight_active)
			valuecolor = "#FF5555"
			sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_day"
		else
			switch(round(SSsunlight.time_til_cycle, 1))
				if(0 to 30)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_30"
					valuecolor = "#FFCCCC"
				if(31 to 60)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_60"
					valuecolor = "#FFE6CC"
				if(61 to 90)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_90"
					valuecolor = "#FFFFCC"
				else
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_night"
					valuecolor = "#FFFFFF"
		sunlight_display.maptext = FORMAT_VAMPIRE_SUNLIGHT_TEXT( \
			valuecolor, \
			(SSsunlight.time_til_cycle >= 60) ? "[round(SSsunlight.time_til_cycle / 60, 1)] m" : "[round(SSsunlight.time_til_cycle, 1)] s" \
		)

	var/humanitycolor
	if(humanity_display)
		switch(humanity)
			if(0 - 1)
				humanitycolor = "#500000"
			if(2 - 3)
				humanitycolor = "#850a0a"
			if(4 - 5)
				humanitycolor = "#a72d2d"
			if(6 - 8)	// This isn't a janky, a tiny bit lenience is baked in.
				humanitycolor = "#ba5e5e"
			if(9 - 10)
				humanitycolor = "#f1cece"

		humanity_display.maptext = FORMAT_VAMPIRE_HUD_TEXT(humanitycolor, humanity)

/// 1 tile down
#undef UI_BLOOD_DISPLAY
/// 0 tiles down
#undef UI_HUMANITY_DISPLAY
/// 2 tiles down
#undef UI_VAMPRANK_DISPLAY
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#undef UI_SUNLIGHT_DISPLAY

///Maptext define for Vampire HUDs
#undef FORMAT_VAMPIRE_HUD_TEXT
///Maptext define for Vampire Sunlight HUDs
#undef FORMAT_VAMPIRE_SUNLIGHT_TEXT
