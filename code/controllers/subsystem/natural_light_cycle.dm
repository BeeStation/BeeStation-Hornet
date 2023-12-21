SUBSYSTEM_DEF(natural_light_cycle)
	name = "Natural Light Cycle"
	wait = 600
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NATURAL_LIGHT
	var/list/cycle_colours = null

/datum/controller/subsystem/natural_light_cycle/Initialize(start_timeofday)
	. = ..()
	if (SSmapping.config.starlight_mode != STARLIGHT_MODE_CYCLE)
		flags |= SS_NO_FIRE
		return
	cycle_colours = SSmapping.config.cycle_colours
	if (!islist(cycle_colours) || !length(cycle_colours))
		to_chat(world, "<span class='boldannounce'>WARNING: Starlight is set to cycle, yet the colours that are set to be cycled is undefined.</span>");
		log_world("WARNING: Starlight is set to cycle, yet the colours that are set to be cycled is undefined.")
		flags |= SS_NO_FIRE
		return

/datum/controller/subsystem/natural_light_cycle/fire(resumed)
	var/time = station_time()
	var/next_proportion = min((((time + wait) % DECISECONDS_IN_DAY) / DECISECONDS_IN_DAY) * length(cycle_colours) + 1, length(cycle_colours))
	var/next_index = FLOOR(next_proportion, 1)
	var/next_offset = next_proportion - next_index
	var/lower_colour = cycle_colours[next_index]
	var/upper_colour = cycle_colours[((next_index - 1) % length(cycle_colours)) + 1]
	var/blended_colour = BlendRGB(lower_colour, upper_colour, next_offset)
	set_starlight_colour(blended_colour, wait)
