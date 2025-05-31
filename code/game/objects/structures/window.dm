/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE //initially is 0 for tile smoothing
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR | IGNORE_DENSITY
	max_integrity = 50
	can_be_unanchored = TRUE
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/structure_window
	can_atmos_pass = ATMOS_PASS_PROC
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	rad_flags = RAD_PROTECT_CONTENTS
	pass_flags_self = PASSTRANSPARENT
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	var/ini_dir = null
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = 30
	var/wtype = "glass"
	var/fulltile = FALSE
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/mutable_appearance/crack_overlay
	var/real_explosion_block	//ignore this, just use explosion_block
	var/breaksound = "shatter"
	var/knocksound = 'sound/effects/glassknock.ogg'
	var/bashsound = 'sound/effects/glassbash.ogg'
	var/hitsound = 'sound/effects/glasshit.ogg'
	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.4
	/// If we added a leaning component to ourselves
	var/added_leaning = FALSE



/datum/armor/structure_window
	fire = 80
	acid = 100

/obj/structure/window/examine(mob/user)
	. = ..()
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += span_notice("The window is <b>screwed</b> to the frame.")
		else if(anchored && state == WINDOW_IN_FRAME)
			. += span_notice("The window is <i>unscrewed</i> but <b>pried</b> into the frame.")
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += span_notice("The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.")
		else if(!anchored)
			. += span_notice("The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.")
	else
		if(anchored)
			. += span_notice("The window is <b>screwed</b> to the floor.")
		else
			. += span_notice("The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.")

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/window)

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = WINDOW_SCREWED_TO_FRAME

	ini_dir = dir
	air_update_turf(TRUE, TRUE)

	if(fulltile)
		setDir()
		obj_flags &= ~BLOCKS_CONSTRUCTION_DIR
		obj_flags &= ~IGNORE_DENSITY

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM, AfterRotation = CALLBACK(src, PROC_REF(AfterRotation)))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	if (flags_1 & ON_BORDER_1)
		AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/window/MouseDrop_T(atom/dropping, mob/user, params)
	. = ..()
	if (flags_1 & ON_BORDER_1)
		return

	//Adds the component only once. We do it here & not in Initialize() because there are tons of windows & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/obj/structure/window/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/atmos_sensitive)
/obj/structure/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/obj/structure/window/rcd_act(mob/user, var/obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_DECONSTRUCT)
		to_chat(user, span_notice("You deconstruct the window."))
		log_attack("[key_name(user)] has deconstructed [src] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		qdel(src)
		return TRUE
	return FALSE

/obj/structure/window/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/window/ratvar_act()
	if(!fulltile)
		new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
	else
		new/obj/structure/window/reinforced/clockwork/fulltile(get_turf(src))
	qdel(src)

/obj/structure/window/singularity_pull(S, current_size)
	..()
	if(anchored && current_size >= STAGE_TWO)
		set_anchored(FALSE)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(fulltile)
		return FALSE

	if(border_dir == dir)
		return FALSE

	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/moved_window = mover
		return valid_build_direction(loc, moved_window.dir, is_fulltile = moved_window.fulltile)

	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_build_direction(loc, mover.dir, is_fulltile = FALSE)

	return TRUE

/obj/structure/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if (leaving.pass_flags & PASSTRANSPARENT)
		return

	if (fulltile)
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("Something knocks on [src]."))
	add_fingerprint(user)
	playsound(src, knocksound, 50, 1)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/window/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return 1
	. = ..()

/obj/structure/window/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)

	if(!user.combat_mode)
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>", \
			"<span class='notice'>You knock on [src].</span>")
		playsound(src, knocksound, 50, TRUE)
	else
		user.visible_message("<span class='warning'>[user] bashes [src]!</span>", \
			"<span class='warning'>You bash [src]!</span>")
		playsound(src, bashsound, 100, TRUE)

/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	..()

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return TRUE //skip the afterattack

	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER)
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount = 0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume = 50))
				atom_integrity = max_integrity
				update_nearby_icons()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

	if(!(flags_1&NODECONSTRUCT_1))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			I.play_tool_sound(src, 75)
			if(reinf)
				if(state == WINDOW_SCREWED_TO_FRAME || state == WINDOW_IN_FRAME)
					to_chat(user, span_notice("You begin to [state == WINDOW_SCREWED_TO_FRAME ? "unscrew the window from":"screw the window to"] the frame..."))
					if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
						state = (state == WINDOW_IN_FRAME ? WINDOW_SCREWED_TO_FRAME : WINDOW_IN_FRAME)
						to_chat(user, span_notice("You [state == WINDOW_IN_FRAME ? "unfasten the window from":"fasten the window to"] the frame."))
				else if(state == WINDOW_OUT_OF_FRAME)
					to_chat(user, span_notice("You begin to [anchored ? "unscrew the frame from":"screw the frame to"] the floor..."))
					if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
						set_anchored(!anchored)
						to_chat(user, span_notice("You [anchored ? "fasten the frame to":"unfasten the frame from"] the floor."))
			else //if we're not reinforced, we don't need to check or update state
				to_chat(user, span_notice("You begin to [anchored ? "unscrew the window from":"screw the window to"] the floor..."))
				if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
					set_anchored(!anchored)
					to_chat(user, span_notice("You [anchored ? "fasten the window to":"unfasten the window from"] the floor."))
			return


		else if(I.tool_behaviour == TOOL_CROWBAR && reinf && (state == WINDOW_OUT_OF_FRAME || state == WINDOW_IN_FRAME))
			to_chat(user, span_notice("You begin to lever the window [state == WINDOW_OUT_OF_FRAME ? "into":"out of"] the frame..."))
			I.play_tool_sound(src, 75)
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = (state == WINDOW_OUT_OF_FRAME ? WINDOW_IN_FRAME : WINDOW_OUT_OF_FRAME)
				to_chat(user, span_notice("You pry the window [state == WINDOW_IN_FRAME ? "into":"out of"] the frame."))
			return

		else if(I.tool_behaviour == TOOL_WRENCH && !anchored)
			I.play_tool_sound(src, 75)
			to_chat(user, span_notice(" You begin to disassemble [src]..."))
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				new glass_type(user.loc, glass_amount, TRUE, user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, span_notice("You successfully disassemble [src]."))
				qdel(src)
			return
	return ..()

/obj/structure/window/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/structure/window/set_anchored(anchorvalue)
	..()
	air_update_turf(TRUE, anchorvalue)
	update_nearby_icons()

/obj/structure/window/proc/check_state(checked_state)
	if(state == checked_state)
		return TRUE

/obj/structure/window/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)

/obj/structure/window/proc/can_be_reached(mob/user)
	if(fulltile)
		return TRUE
	var/checking_dir = get_dir(user, src)
	if(!(checking_dir & dir))
		return TRUE // Only windows on the other side may be blocked by other things.
	checking_dir = REVERSE_DIR(checking_dir)
	for(var/obj/blocker in loc)
		if(!blocker.CanPass(user, checking_dir))
			return FALSE
	return TRUE

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hitsound, 75, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)


/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, 1)
		if(!(flags_1 & NODECONSTRUCT_1))
			for(var/obj/item/shard/debris in spawnDebris(drop_location()))
				transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawnDebris(location)
	. = list()
	. += new /obj/item/shard(location)
	. += new /obj/effect/decal/cleanable/glass(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard(location)

/obj/structure/window/proc/AfterRotation(mob/user, degrees)
	air_update_turf(TRUE, FALSE)

/obj/structure/window/Destroy()
	var/turf/local_turf = get_turf(src)
	update_nearby_icons()
	. = ..()
	local_turf.air_update_turf(TRUE, FALSE)


/obj/structure/window/Move()
	var/turf/T = loc
	. = ..()
	if(anchored)
		move_update_air(T)

/obj/structure/window/can_atmos_pass(turf/T, vertical = FALSE)
	if(!anchored || !density)
		return TRUE
	return !(fulltile || dir == get_dir(loc, T))

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_appearance()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

//merges adjacent full-tile windows into one
/obj/structure/window/update_icon()
	if(!QDELETED(src))
		if(!fulltile)
			return

		var/ratio = atom_integrity / max_integrity
		ratio = CEILING(ratio*4, 1) * 25

		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)

		cut_overlay(crack_overlay)
		if(ratio > 75)
			return
		crack_overlay = mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer+0.1))
		add_overlay(crack_overlay)

/obj/structure/window/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > T0C + heat_resistance

/obj/structure/window/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(round(air.return_volume() / 100), BURN, 0, 0)

/obj/structure/window/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/obj/structure/window/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/passing_atom)
	if(!density)
		return 1
	if(fulltile || (dir == to_dir))
		return 0

	return 1

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/spawner/east
	dir = EAST

/obj/structure/window/spawner/west
	dir = WEST

/obj/structure/window/spawner/north
	dir = NORTH

/obj/structure/window/unanchored
	anchored = FALSE

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window that is reinforced with iron rods."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/window_reinforced
	max_integrity = 100
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass
	rad_insulation = RAD_HEAVY_INSULATION
	ricochet_chance_mod = 0.8


/datum/armor/window_reinforced
	melee = 50
	bomb = 25
	rad = 100
	fire = 80
	acid = 100

/obj/structure/window/reinforced/spawner/east
	dir = EAST

/obj/structure/window/reinforced/spawner/west
	dir = WEST

/obj/structure/window/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/reinforced/unanchored
	anchored = FALSE

/obj/structure/window/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	reinf = FALSE
	heat_resistance = 25000
	armor_type = /datum/armor/window_plasma
	max_integrity = 300
	glass_type = /obj/item/stack/sheet/plasmaglass
	rad_insulation = RAD_NO_INSULATION

/obj/structure/window/plasma/ComponentInitialize()
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive)


/datum/armor/window_plasma
	melee = 75
	bullet = 5
	bomb = 45
	rad = 100
	fire = 99
	acid = 100

/obj/structure/window/plasma/spawnDebris(location)
	. = list()
	. += new /obj/item/shard/plasma(location)
	. += new /obj/effect/decal/cleanable/glass/plasma(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if (fulltile)
		. += new /obj/item/shard/plasma(location)

/obj/structure/window/plasma/spawner/east
	dir = EAST

/obj/structure/window/plasma/spawner/west
	dir = WEST

/obj/structure/window/plasma/spawner/north
	dir = NORTH

/obj/structure/window/plasma/unanchored
	anchored = FALSE

/obj/structure/window/plasma/reinforced
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor_type = /datum/armor/plasma_reinforced
	max_integrity = 500
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/plasmarglass

/datum/armor/plasma_reinforced
	melee = 85
	bullet = 20
	bomb = 60
	rad = 100
	fire = 99
	acid = 100

/obj/structure/window/plasma/reinforced/spawner/east
	dir = EAST

/obj/structure/window/plasma/reinforced/spawner/west
	dir = WEST

/obj/structure/window/plasma/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/plasma/reinforced/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow" //what what, hon hon
	opacity = TRUE
/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "twindow"

/obj/structure/window/depleteduranium
	name = "depleted uranium window"
	desc = "A window made out of depleted uranium. It looks perfect for radiation shielding!"
	icon_state = "duwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor_type = /datum/armor/window_depleteduranium
	max_integrity = 500
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/mineral/uranium
	rad_insulation = RAD_FULL_INSULATION


/datum/armor/window_depleteduranium
	melee = 45
	bullet = 20
	bomb = 60
	rad = 100
	fire = 100
	acid = 100

/obj/structure/window/depleteduranium/spawner/east
	dir = EAST

/obj/structure/window/depleteduranium/spawner/west
	dir = WEST

/obj/structure/window/depleteduranium/spawner/north
	dir = NORTH

/obj/structure/window/depleteduranium/unanchored
	anchored = FALSE

/* Full Tile Windows (more atom_integrity) */

/obj/structure/window/fulltile
	icon = 'icons/obj/smooth_structures/windows/window.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	max_integrity = 100
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	glass_amount = 2

/obj/structure/window/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/depleteduranium/fulltile
	icon = 'icons/obj/smooth_structures/windows/du_window.dmi'
	icon_state = "du_window-0"
	base_icon_state = "du_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	max_integrity = 500
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	rad_insulation = RAD_FULL_INSULATION
	glass_amount = 2

/obj/structure/window/depleteduranium/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/fulltile
	icon = 'icons/obj/smooth_structures/windows/plasma_window.dmi'
	icon_state = "plasma_window-0"
	base_icon_state = "plasma_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	max_integrity = 600
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	glass_amount = 2

/obj/structure/window/plasma/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/windows/rplasma_window.dmi'
	icon_state = "rplasma_window-0"
	base_icon_state = "rplasma_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	max_integrity = 4000
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	glass_amount = 2

/obj/structure/window/plasma/reinforced/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/windows/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	max_integrity = 200
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/obj/smooth_structures/windows/tinted_window.dmi'
	icon_state = "tinted_window-0"
	base_icon_state = "tinted_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	glass_amount = 2

/obj/structure/window/reinforced/tinted/fulltile/nightclub
	color = "#9b1d70"

/obj/structure/window/reinforced/fulltile/ice
	icon = 'icons/obj/smooth_structures/windows/rice_window.dmi'
	icon_state = "rice_window-0"
	base_icon_state = "rice_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE)
	max_integrity = 150
	glass_amount = 2

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/windows/shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE)
	max_integrity = 500
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/window_shuttle
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	ricochet_chance_mod = 0.9


/datum/armor/window_shuttle
	melee = 50
	bomb = 50
	rad = 100
	fire = 80
	acid = 100

/obj/structure/window/shuttle/narsie_act()
	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/shuttle/tinted
	opacity = TRUE

/obj/structure/window/shuttle/unanchored
	anchored = FALSE

/obj/structure/window/plastitanium
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of of plasma and titanium."
	icon = 'icons/obj/smooth_structures/windows/plastitanium_window.dmi'
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM, SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM)
	max_integrity = 200
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/window_plastitanium
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2


/datum/armor/window_plastitanium
	melee = 50
	bomb = 50
	rad = 100
	fire = 80
	acid = 100

/obj/structure/window/plastitanium/unanchored
	anchored = FALSE

/obj/structure/window/paperframe
	name = "paper frame"
	desc = "A fragile separator made of thin wood and paper."
	icon = 'icons/obj/smooth_structures/windows/paperframes.dmi'
	icon_state = "paperframes-0"
	base_icon_state = "paperframes"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_PAPERFRAME)
	canSmoothWith = list(SMOOTH_GROUP_PAPERFRAME)
	opacity = TRUE
	max_integrity = 15
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	glass_amount = 2
	glass_type = /obj/item/stack/sheet/paperframes
	heat_resistance = 233
	decon_speed = 10
	can_atmos_pass = ATMOS_PASS_YES
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/none
	knocksound = "pageturn"
	bashsound = 'sound/weapons/slashmiss.ogg'
	breaksound = 'sound/items/poster_ripped.ogg'
	hitsound = 'sound/weapons/slashmiss.ogg'
	var/static/mutable_appearance/torn = mutable_appearance('icons/obj/smooth_structures/windows/paperframes.dmi',icon_state = "torn", layer = ABOVE_OBJ_LAYER - 0.1)
	var/static/mutable_appearance/paper = mutable_appearance('icons/obj/smooth_structures/windows/paperframes.dmi',icon_state = "paper", layer = ABOVE_OBJ_LAYER - 0.1)

/obj/structure/window/paperframe/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/window/paperframe/examine(mob/user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_info("It looks a bit damaged, you may be able to fix it with some <b>paper</b>.")

/obj/structure/window/paperframe/spawnDebris(location)
	. = list(new /obj/item/stack/sheet/wood(location))
	for (var/i in 1 to rand(1,4))
		. += new /obj/item/paper/natural(location)

/obj/structure/window/paperframe/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(user.combat_mode)
		take_damage(4,BRUTE,MELEE, 0)
		if(!QDELETED(src))
			update_appearance()

/obj/structure/window/paperframe/update_icon()
	if(atom_integrity < max_integrity)
		cut_overlay(paper)
		add_overlay(torn)
		set_opacity(FALSE)
	else
		cut_overlay(torn)
		add_overlay(paper)
		set_opacity(TRUE)
	QUEUE_SMOOTH(src)


/obj/structure/window/paperframe/attackby(obj/item/W, mob/living/user)
	if(W.is_hot())
		fire_act(W.is_hot())
		return
	if(user.combat_mode)
		return ..()
	if(istype(W, /obj/item/paper) && atom_integrity < max_integrity)
		user.visible_message("[user] starts to patch the holes in \the [src].")
		if(do_after(user, 20, target = src))
			atom_integrity = min(atom_integrity+4,max_integrity)
			qdel(W)
			user.visible_message("[user] patches some of the holes in \the [src].")
			if(atom_integrity == max_integrity)
				update_appearance()
			return
	..()
	update_appearance()

/obj/structure/window/bronze
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass. Nevermind, this is just weak bronze!"
	icon = 'icons/obj/smooth_structures/windows/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	glass_type = /obj/item/stack/sheet/bronze

/obj/structure/window/bronze/unanchored
	anchored = FALSE

/obj/structure/window/bronze/fulltile
	icon = 'icons/obj/smooth_structures/windows/clockwork_window.dmi'
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	max_integrity = 50
	glass_amount = 2

/obj/structure/window/bronze/fulltile/unanchored
	anchored = FALSE
