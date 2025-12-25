
GLOBAL_VAR_INIT(starlight_colour, COLOR_STARLIGHT)

GLOBAL_VAR_INIT(orbital_visual_starlight, COLOR_STARLIGHT)

/// Sets the starlight colour and sends the signal. Used by anything that wants to change starlight colour globally.
/// Override orbital visuals if you also want to touch station-Zs too.
/proc/set_starlight_colour(new_colour, transition_time)
	GLOB.starlight_colour = new_colour
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, new_colour, transition_time)

/// Sets the orbital visuals starlight colour and sends the signal. Used by the orbital visual subsystem itself to update station Z-levels.
/// Make SURE you tell it you are overriding stuff if you call this directly. See Aurora Caelus for example usage.
/proc/set_orbital_starlight_colour(new_colour, transition_time)
	GLOB.orbital_visual_starlight = new_colour
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, new_colour, transition_time)
