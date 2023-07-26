/turf/open
	plane = FLOOR_PLANE
	FASTDMM_PROP(\
		pipe_astar_cost = 1.5\
	)
	var/slowdown = 0 //negative for faster, positive for slower

	var/postdig_icon_change = FALSE
	var/postdig_icon
	var/wet

	var/footstep = null
	var/barefootstep = null
	var/clawfootstep = null
	var/heavyfootstep = null

/turf/open/ComponentInitialize()
	. = ..()
	if(wet)
		AddComponent(/datum/component/wet_floor, wet, INFINITY, 0, INFINITY, TRUE)

//direction is direction of travel of A
/turf/open/zPassIn(atom/movable/A, direction, turf/source, falling = FALSE)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.z_flags & Z_BLOCK_IN_DOWN)
				return FALSE
		return TRUE
	return FALSE

//direction is direction of travel of A
/turf/open/zPassOut(atom/movable/A, direction, turf/destination, falling = FALSE)
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.z_flags & Z_BLOCK_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

//direction is direction of travel of air
/turf/open/zAirIn(direction, turf/source)
	return (direction == DOWN)

//direction is direction of travel of air
/turf/open/zAirOut(direction, turf/source)
	return (direction == UP)

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = TRUE

/turf/open/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/indestructible/singularity_act()
	return

/turf/open/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/open/indestructible/sound
	name = "squeaky floor"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	var/sound

/turf/open/indestructible/sound/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	if(istype(arrived) && !(arrived.movement_type & (FLYING|FLOATING)))
		playsound(src,sound,50,1)

/turf/open/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturfs = /turf/open/indestructible/necropolis
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	tiled_dirt = FALSE

/turf/open/indestructible/necropolis/Initialize(mapload)
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/necropolis/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/boss //you put stone tiles on this and use it as a base
	name = "necropolis floor"
	icon = 'icons/turf/boss_floors.dmi'
	icon_state = "boss"
	baseturfs = /turf/open/indestructible/boss
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/indestructible/boss/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/hierophant
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	baseturfs = /turf/open/indestructible/hierophant
	tiled_dirt = FALSE
	smoothing_flags = SMOOTH_CORNERS

/turf/open/indestructible/hierophant/two

/turf/open/indestructible/hierophant/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/open/indestructible/paper
	name = "notebook floor"
	desc = "A floor made of invulnerable notebook paper."
	icon_state = "paperfloor"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	tiled_dirt = FALSE

/turf/open/indestructible/binary
	name = "tear in the fabric of reality"
	CanAtmosPass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/binary
	icon_state = "binary"
	footstep = FOOTSTEP_PLATING
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	slowdown = 3

/turf/open/indestructible/airblock
	icon_state = "bluespace"
	baseturfs = /turf/open/indestructible/airblock
	CanAtmosPass = ATMOS_PASS_NO

/turf/open/Initalize_Atmos(times_fired)
	if(!istype(air, /datum/gas_mixture/turf))
		air = new(2500,src)
	air.copy_from_turf(src)
	update_air_ref(planetary_atmos ? 1 : 2)

	update_visuals()

	ImmediateCalculateAdjacentTurfs()


/turf/open/proc/GetHeatCapacity()
	. = air.heat_capacity()

/turf/open/proc/GetTemperature()
	. = air.return_temperature()

/turf/open/proc/TakeTemperature(temp)
	air.set_temperature(air.return_temperature() + temp)
	air_update_turf()

/turf/open/proc/freeze_turf()
	for(var/obj/I in contents)
		if(!HAS_TRAIT(I, TRAIT_FROZEN) && !(I.obj_flags & FREEZE_PROOF))
			I.AddElement(/datum/element/frozen)
			
	for(var/mob/living/L in contents)
		if(L.bodytemperature <= 50)
			L.apply_status_effect(/datum/status_effect/freon)
	MakeSlippery(TURF_WET_PERMAFROST, 50)
	return TRUE

/turf/open/proc/water_vapor_gas_act()
	MakeSlippery(TURF_WET_WATER, min_wet_time = 100, wet_time_to_add = 50)

	for(var/mob/living/simple_animal/slime/M in src)
		M.apply_water()

	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	for(var/obj/effect/O in src)
		if(is_cleanable(O))
			qdel(O)
	return TRUE

/turf/open/handle_slip(mob/living/carbon/slipper, knockdown_amount, obj/O, lube, paralyze_amount, force_drop)
	if(slipper.movement_type & FLYING)
		return 0
	if(has_gravity(src))
		var/obj/buckled_obj
		if(slipper.buckled)
			buckled_obj = slipper.buckled
			if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return 0
		else
			if(!(lube & SLIP_WHEN_CRAWLING) && (!(slipper.mobility_flags & MOBILITY_STAND) || !(slipper.status_flags & CANKNOCKDOWN))) // can't slip unbuckled mob if they're lying or can't fall.
				return 0
			if(slipper.m_intent == MOVE_INTENT_WALK && (lube&NO_SLIP_WHEN_WALKING))
				return 0
		if(!(lube&SLIDE_ICE))
			to_chat(slipper, "<span class='notice'>You slipped[ O ? " on the [O.name]" : ""]!</span>")
			playsound(slipper.loc, 'sound/misc/slip.ogg', 50, 1, -3)

		SEND_SIGNAL(slipper, COMSIG_ADD_MOOD_EVENT, "slipped", /datum/mood_event/slipped)
		if(force_drop)
			for(var/obj/item/I in slipper.held_items)
				slipper.accident(I)

		var/olddir = slipper.dir
		slipper.moving_diagonally = 0 //If this was part of diagonal move slipping will stop it.
		if(!(lube & SLIDE_ICE))
			slipper.Knockdown(knockdown_amount)
			slipper.drop_all_held_items()
			slipper.Paralyze(paralyze_amount)
			slipper.stop_pulling()
		else
			slipper.Knockdown(15)
			slipper.drop_all_held_items()

		if(buckled_obj)
			buckled_obj.unbuckle_mob(slipper)
			lube |= SLIDE_ICE

		var/turf/target = get_ranged_target_turf(slipper, olddir, 4)
		if(lube & SLIDE)
			slipper.AddComponent(/datum/component/force_move, target, TRUE)
		else if(lube&SLIDE_ICE)
			slipper.AddComponent(/datum/component/force_move, target, FALSE)//spinning would be bad for ice, fucks up the next dir
		return TRUE

/turf/open/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent)
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/open/get_dumping_location()
	return src

/turf/open/proc/ClearWet()//Nuclear option of immediately removing slipperyness from the tile instead of the natural drying over time
	qdel(GetComponent(/datum/component/wet_floor))

/turf/open/rad_act(pulse_strength)
	. = ..()
	if (air.get_moles(GAS_CO2) && air.get_moles(GAS_O2))
		pulse_strength = min(pulse_strength,air.get_moles(GAS_CO2)*1000,air.get_moles(GAS_O2)*2000) //Ensures matter is conserved properly
		air.set_moles(GAS_CO2, max(air.get_moles(GAS_CO2)-(pulse_strength/1000),0))
		air.set_moles(GAS_O2, max(air.get_moles(GAS_O2)-(pulse_strength/2000),0))
		air.adjust_moles(GAS_PLUOXIUM, pulse_strength/4000)
