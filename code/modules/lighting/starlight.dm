
GLOBAL_VAR_INIT(starlight_colour, COLOR_STARLIGHT)

/// Make sure you tell the orbital visuals subsystem you are overriding stuff. See Aurora Caelus for example usage.
/proc/set_starlight_colour(new_colour, transition_time)
	GLOB.starlight_colour = new_colour
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, new_colour, transition_time)
