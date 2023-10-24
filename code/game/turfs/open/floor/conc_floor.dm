/turf/open/floor/concrete
	name = "concrete floor"
	desc = "Cold, bare concrete flooring."
	icon_state = "conc_smooth"
	tiled_dirt = FALSE
	footstep = FOOTSTEP_CONCRETE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	var/smash_time = 3 SECONDS

/turf/open/floor/concrete/Initialize()
	. = ..()

/turf/open/floor/concrete/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[p_they(TRUE)] look[p_s()] like you could <b>smash</b> [p_them()].</span>"

/turf/open/floor/concrete/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(.)
		return
	if(C.tool_behaviour == TOOL_MINING)
		to_chat(user, "<span class='notice'>You start smashing [src]...</span>")
		var/adj_time = (broken || burnt) ? smash_time/2 : smash_time
		if(C.use_tool(src, user, adj_time, volume=30))
			to_chat(user, "<span class='notice'>You break [src].</span>")
			playsound(src, 'sound/effects/break_stone.ogg', 30, TRUE)
			remove_tile()
			return TRUE
	return FALSE

/turf/open/floor/concrete/slab
	icon_state = "conc_slab"

/turf/open/floor/concrete/tiles
	icon_state = "conc_tiles"
