SUBSYSTEM_DEF(natural_light_cycle)
	name = "Natural Light Cycle"
	wait = 600
	flags = SS_KEEP_TIMING
	var/list/cycle_colours = null

/datum/controller/subsystem/natural_light_cycle/Initialize()
	. = ..()
	if (SSmapping.current_map.starlight_mode != STARLIGHT_MODE_CYCLE)
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED
	cycle_colours = SSmapping.current_map.cycle_colours
	if (!islist(cycle_colours) || !length(cycle_colours))
		to_chat(world, span_boldannounce("WARNING: Starlight is set to cycle, yet the colours that are set to be cycled is undefined."));
		log_world("WARNING: Starlight is set to cycle, yet the colours that are set to be cycled is undefined.")
		flags |= SS_NO_FIRE
		return SS_INIT_FAILURE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/natural_light_cycle/fire(resumed)
	var/time = station_time()
	var/next_proportion = min((((time + wait) % DECISECONDS_IN_DAY) / DECISECONDS_IN_DAY) * length(cycle_colours) + 1, length(cycle_colours))
	var/next_index = FLOOR(next_proportion, 1)
	var/next_offset = next_proportion - next_index
	var/lower_colour = cycle_colours[next_index]
	var/upper_colour = cycle_colours[((next_index - 1) % length(cycle_colours)) + 1]
	var/blended_colour = BlendRGB(lower_colour, upper_colour, next_offset)
	set_starlight_colour(blended_colour, wait)
