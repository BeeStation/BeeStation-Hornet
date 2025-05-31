CREATION_TEST_IGNORE_SELF(/turf/open)

/turf/open
	plane = FLOOR_PLANE
	can_hit = FALSE
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

	var/broken_icon = 'icons/turf/turf_damage.dmi'
	var/broken = FALSE
	var/burnt = FALSE

	//Do we just swap the state to one of the damage states
	var/use_broken_literal = FALSE
	//Do we just swap the state to one of the damage states
	var/use_burnt_literal = FALSE

	//Refs to filters, for later removal
	var/list/damage_overlays

	///Is this floor no-slip?
	var/traction = FALSE

/turf/open/ComponentInitialize()
	. = ..()
	if(wet)
		AddComponent(/datum/component/wet_floor, wet, INFINITY, 0, INFINITY, TRUE)

/turf/open/examine_descriptor(mob/user)
	return "floor"

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

/turf/open/update_icon()
	. = ..()
	update_visuals()

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = TRUE
	resistance_flags = INDESTRUCTIBLE

/turf/open/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

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

	if(istype(arrived) && !(arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
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
	planetary_atmos = TRUE
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/indestructible/boss/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/hierophant
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	planetary_atmos = TRUE
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
	can_atmos_pass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/binary
	icon_state = "binary"
	footstep = FOOTSTEP_PLATING
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	slowdown = 3

/turf/open/indestructible/airblock
	icon_state = "bluespace"
	blocks_air = TRUE
	init_air = FALSE
	baseturfs = /turf/open/indestructible/airblock
	init_air = FALSE

/turf/open/Initalize_Atmos(time)
	excited = FALSE
	update_visuals()

	current_cycle = time
	init_immediate_calculate_adjacent_turfs()

/turf/open/get_heat_capacity()
	. = air.heat_capacity()

/turf/open/get_temperature()
	. = air.temperature

/turf/open/take_temperature(temp)
	air.temperature += temp
	air_update_turf(FALSE, FALSE)

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

	wash(CLEAN_WASH)
	for(var/am in src)
		var/atom/movable/movable_content = am
		if(ismopable(movable_content)) // Will have already been washed by the wash call above at this point.
			continue
		movable_content.wash(CLEAN_WASH)
	return TRUE

/turf/open/handle_slip(mob/living/carbon/slipper, knockdown_amount, obj/O, lube, paralyze_amount, force_drop)
	if(slipper.movement_type & (FLOATING|FLYING))
		return FALSE
	if(has_gravity(src))
		var/obj/buckled_obj
		if(slipper.buckled)
			buckled_obj = slipper.buckled
			if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return FALSE
		else
			if(!(lube & SLIP_WHEN_CRAWLING) && slipper.body_position == LYING_DOWN || !(slipper.status_flags & CANKNOCKDOWN)) // can't slip unbuckled mob if they're lying or can't fall.
				return FALSE
			if(slipper.m_intent == MOVE_INTENT_WALK && (lube&NO_SLIP_WHEN_WALKING))
				return FALSE
		if(!(lube&SLIDE_ICE))
			to_chat(slipper, span_notice("You slipped[ O ? " on the [O.name]" : ""]!"))
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
	if(traction)
		return
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/open/get_dumping_location()
	return src

/turf/open/proc/ClearWet()//Nuclear option of immediately removing slipperyness from the tile instead of the natural drying over time
	qdel(GetComponent(/datum/component/wet_floor))

/turf/open/rad_act(pulse_strength)
	. = ..()
	if (air.gases[/datum/gas/carbon_dioxide] && air.gases[/datum/gas/oxygen] && air.temperature <= PLUOXIUM_TEMP_CAP)
		pulse_strength = min(pulse_strength,air.gases[/datum/gas/carbon_dioxide][MOLES]*1000,air.gases[/datum/gas/oxygen][MOLES]*2000) //Ensures matter is conserved properly
		REMOVE_MOLES(/datum/gas/carbon_dioxide, air, (pulse_strength/1000))
		REMOVE_MOLES(/datum/gas/oxygen, air, (pulse_strength/2000))
		ADJUST_MOLES(/datum/gas/pluoxium, air, pulse_strength/4000)

/turf/open/proc/break_tile(force, allow_base)
	LAZYINITLIST(damage_overlays)
	var/list/options = list()
	if(islist(baseturfs)) //Somehow
		options = baseturfs.Copy() //This is weird
	else
		options += baseturfs
	if(broken && !force || use_broken_literal || !length(options - GLOB.turf_underlay_blacklist) && !allow_base)
		if(use_broken_literal)
			icon_state = pick(broken_states())
		return
	var/damage_state
	if(length(broken_states()))
		damage_state = pick(broken_states())
		//Damage mask
		var/icon/mask = icon(broken_icon, "broken_[damage_state]")
		add_filter("damage_mask", 1, alpha_mask_filter(icon = mask))
		damage_overlays += "damage_mask"
		//Build under-turf icon
		var/turf/base = pick(options - (allow_base ? null : GLOB.turf_underlay_blacklist))
		var/icon/under_turf = icon(initial(base.icon), initial(base.icon_state))
		//Underlay turf icon
		add_filter("turf_underlay", 2, layering_filter(icon = under_turf, flags = FILTER_UNDERLAY))
		damage_overlays += "turf_underlay"
	//Add some dirt 'n shit
	if(length(broken_states()) && damage_state)
		var/icon/dirt = icon(broken_icon, "dirt_[damage_state]")
		add_filter("dirt_overlay", 3, layering_filter(icon = dirt, blend_mode = BLEND_MULTIPLY))
		damage_overlays += "dirt_overlay"
	broken = TRUE

/turf/open/burn_tile(force)
	LAZYINITLIST(damage_overlays)
	if(burnt && !force || use_burnt_literal)
		if(use_burnt_literal)
			icon_state = pick(burnt_states())
		return
	if(length(burnt_states()))
		var/burnt_state = pick(burnt_states())
		//Add some burnt shit
		var/icon/burnt_overlay = icon(broken_icon, "burnt_[burnt_state]")
		add_filter("brunt_overlay", 4, layering_filter(icon = burnt_overlay))
		damage_overlays += "brunt_overlay"
	burnt = TRUE

/turf/open/proc/broken_states()
	return GLOB.default_turf_damage

/turf/open/proc/burnt_states()
	return GLOB.default_burn_turf

/turf/open/proc/make_traction(add_visual = TRUE)
	if(add_visual)
		//Add overlay
		var/mutable_appearance/MA = mutable_appearance('icons/turf/floors.dmi', "no_slip")
		MA.blend_mode = BLEND_OVERLAY
		add_overlay(MA)
	traction = TRUE
