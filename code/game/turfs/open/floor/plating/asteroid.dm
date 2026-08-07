
/**********************Asteroid**************************/

/turf/open/floor/plating/asteroid //floor piece
	gender = PLURAL
	name = "asteroid sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	resistance_flags = INDESTRUCTIBLE
	postdig_icon_change = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	damage_deflection = 0
	var/environment_type = "asteroid"
	var/turf_type = /turf/open/floor/plating/asteroid //Because caves do whacky shit to revert to normal
	attachment_holes = FALSE
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	var/dug
	variant_probability = 30
	variant_states = 12

/turf/open/floor/plating/asteroid/proc/getDug()
	new digResult(src, 5)
	if(postdig_icon_change)
		if(!postdig_icon)
			icon_plating = "[environment_type]_dug"
			icon_state = "[environment_type]_dug"
	dug = TRUE

/turf/open/floor/plating/asteroid/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, span_notice("Looks like someone has dug here already."))

/turf/open/floor/plating/asteroid/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/asteroid/burn_tile()
	return

/turf/open/floor/plating/asteroid/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/plating/asteroid/MakeDry()
	return

/turf/open/floor/plating/asteroid/crush()
	return

/turf/open/floor/plating/asteroid/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(!.)
		if(W.tool_behaviour == TOOL_SHOVEL || W.tool_behaviour == TOOL_MINING)
			if(!can_dig(user))
				return TRUE

			if(!isturf(user.loc))
				return

			to_chat(user, span_notice("You start digging..."))

			if(W.use_tool(src, user, 40, volume=50))
				if(!can_dig(user))
					return TRUE
				to_chat(user, span_notice("You dig a hole."))
				getDug()
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, W.type)
				return TRUE
		else if(istype(W, /obj/item/storage/bag/ore))
			for(var/obj/item/stack/ore/O in src)
				SEND_SIGNAL(W, COMSIG_ATOM_ATTACKBY, O)

/turf/open/floor/plating/asteroid/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf)
		return ..()


/turf/open/floor/plating/asteroid/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(the_rcd.canRturf)
		return ..()

/turf/open/floor/plating/asteroid/planetary
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/lavaland_baseturf
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface

/turf/open/floor/plating/asteroid/basalt
	name = "volcanic floor"
	baseturfs = /turf/open/floor/plating/asteroid/basalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	icon_plating = "basalt"
	environment_type = "basalt"
	variant_states = 12
	digResult = /obj/item/stack/ore/glass/basalt

/turf/open/floor/plating/asteroid/basalt/lava //lava underneath
	baseturfs = /turf/open/lava/smooth

/turf/open/floor/plating/asteroid/basalt/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light(src)

/turf/open/floor/plating/asteroid/getDug()
	set_light(0)
	return ..()

/proc/set_basalt_light(turf/open/floor/B)
	switch(B.icon_state)
		if("basalt1", "basalt2", "basalt3")
			B.set_light(2, 0.6, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			B.set_light(1.4, 0.6, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/floor/plating/asteroid/basalt/iceland_surface
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/cold

/turf/open/floor/plating/asteroid/basalt/planetary
	resistance_flags = INDESTRUCTIBLE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	baseturfs = /turf/open/floor/plating/asteroid/airless
	turf_type = /turf/open/floor/plating/asteroid/airless

/turf/open/floor/plating/asteroid/frozengrass
	name = "frozen grass"
	desc = "Looks cold."
	icon = 'icons/turf/floors.dmi'
	variant_states = 0
	variant_probability = 0
	icon_state = "fairygrass"
	icon_plating = "fairygrass"
	environment_type = "snow_cavern"
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS

/turf/open/floor/plating/asteroid/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturfs = /turf/open/floor/plating/asteroid/snow
	icon_state = "snow"
	icon_plating = "snow"
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	environment_type = "snow"
	flags_1 = NONE
	planetary_atmos = TRUE
	use_burnt_literal = TRUE
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	digResult = /obj/item/stack/sheet/snow

/turf/open/floor/plating/asteroid/snow/burnt_states()
	return list("snow_dug")

/turf/open/floor/plating/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message(span_danger("[src] melts away!."))
		slowdown = 0
		burnt = TRUE
		icon_state = "snow_dug"
		return TRUE
	return FALSE

/turf/open/floor/plating/asteroid/snow/ice
	name = "icy snow"
	desc = "Looks colder."
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = "n2=82;plasma=24;TEMP=120"
	variant_states = 0
	variant_probability = 0
	icon_state = "snow-ice"
	icon_plating = "snow-ice"
	environment_type = "snow_cavern"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/asteroid/snow/ice/burn_tile()
	return FALSE

/turf/open/floor/plating/asteroid/snow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/asteroid/snow/temperate
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/floor/plating/asteroid/snow/atmosphere
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = FALSE

/turf/open/floor/plating/asteroid/snow/planetary
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE
