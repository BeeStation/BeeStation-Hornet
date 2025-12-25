
GLOBAL_VAR_INIT(starlight_colour, COLOR_STARLIGHT)
/// Starlight colour used by the orbital visual subsystem for station Z-levels. Modified directly by SSorbital_visuals.
GLOBAL_VAR_INIT(orbital_visual_starlight, COLOR_STARLIGHT)

/// Make sure you tell the orbital visuals subsystem you are overriding stuff. See Aurora Caelus for example usage.
/proc/set_starlight_colour(new_colour, transition_time)
	GLOB.starlight_colour = new_colour
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, new_colour, transition_time)

/// Sets the orbital visual starlight colour and sends the signal. Used by SSorbital_visuals only.
/proc/set_orbital_starlight_colour(new_colour, transition_time)
	GLOB.orbital_visual_starlight = new_colour
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, new_colour, transition_time)
