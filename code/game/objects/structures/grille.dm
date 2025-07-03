/// Max number of unanchored items that will be moved from a tile when attempting to add a window to a grille.
#define CLEAR_TILE_MOVE_LIMIT 20

/obj/structure/grille
	desc = "A flimsy framework of iron rods."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	base_icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags_1 = CONDUCT_1
	pass_flags_self = PASSGRILLE
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	armor_type = /datum/armor/structure_grille
	max_integrity = 50
	integrity_failure = 0.4
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = TRUE
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	FASTDMM_PROP(\
		pipe_astar_cost = 1\
	)

/obj/structure/grille/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/atmos_sensitive)


/datum/armor/structure_grille
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10
	rad = 100

/obj/structure/grille/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	update_appearance()

/obj/structure/grille/update_appearance(updates)
	if(QDELETED(src) || broken)
		return

	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

/obj/structure/grille/update_icon_state()
	icon_state = "[base_icon_state][((atom_integrity / max_integrity) <= 0.5) ? "50_[rand(0, 3)]" : null]"
	return ..()

/obj/structure/grille/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("It's secured in place with <b>screws</b>. The rods look like they could be <b>cut</b> through.")
	if(!anchored)
		. += span_notice("The anchoring screws are <i>unscrewed</i>. The rods look like they could be <b>cut</b> through.")

/obj/structure/grille/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
		if(RCD_WINDOWGRILLE)
			var/cost = 8
			var/delay = 2 SECONDS

			if(the_rcd.window_glass == RCD_WINDOW_REINFORCED)
				delay = 4 SECONDS
				cost = 12

			return rcd_result_with_memory(
				list("mode" = RCD_WINDOWGRILLE, "delay" = delay, "cost" = cost),
				get_turf(src), RCD_MEMORY_WINDOWGRILLE,
			)
	return FALSE

/obj/structure/grille/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the grille."))
			log_attack("[key_name(user)] has deconstructed [src] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			qdel(src)
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(!isturf(loc))
				return FALSE
			var/turf/local_turf = loc

			if(repair_grille())
				to_chat(user, span_notice("You rebuild the broken grille."))

			if(!clear_tile(user))
				return FALSE

			if(!ispath(the_rcd.window_type, /obj/structure/window))
				CRASH("Invalid window path type in RCD: [the_rcd.window_type]")
			var/obj/structure/window/window_path = the_rcd.window_type
			if(!valid_build_direction(local_turf, user.dir, is_fulltile = initial(window_path.fulltile)))
				to_chat(user, span_notice("Already a window in this direction!."))
				return FALSE
			to_chat(user, span_notice("You construct the window."))
			log_attack("[key_name(user)] has constructed a window at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/obj/structure/window/WD = new the_rcd.window_type(local_turf, user.dir)
			WD.set_anchored(TRUE)
			return TRUE
	return FALSE

/obj/structure/grille/ratvar_act()
	if(broken)
		new /obj/structure/grille/ratvar/broken(src.loc)
	else
		new /obj/structure/grille/ratvar(src.loc)
	qdel(src)

/obj/structure/grille/proc/clear_tile(mob/user)
	var/at_users_feet = get_turf(user)

	var/unanchored_items_on_tile
	var/obj/item/last_item_moved
	for(var/obj/item/item_to_move in loc.contents)
		if(!item_to_move.anchored)
			if(unanchored_items_on_tile <= CLEAR_TILE_MOVE_LIMIT)
				item_to_move.forceMove(at_users_feet)
				last_item_moved = item_to_move
			unanchored_items_on_tile++

	if(!unanchored_items_on_tile)
		return TRUE

	to_chat(user, span_notice("You move [unanchored_items_on_tile == 1 ? "[last_item_moved]" : "some things"] out of the way."))

	if(unanchored_items_on_tile - CLEAR_TILE_MOVE_LIMIT > 0)
		to_chat(user, span_warning("There's still too much stuff in the way!"))
		return FALSE

	return TRUE

/obj/structure/grille/Bumped(atom/movable/AM)
	if(!ismob(AM))
		return
	var/mob/M = AM
	shock(M, 70)
	if(prob(50))
		take_damage(1, BRUTE, MELEE, FALSE)

/obj/structure/grille/attack_animal(mob/user)
	. = ..()
	if(!.)
		return
	if(!shock(user, 70) && !QDELETED(src)) //Last hit still shocks but shouldn't deal damage to the grille
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/grille/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/grille/hulk_damage()
	return 60

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.combat_mode)
		if(!shock(user, 70))
			..(user, 1)
		return TRUE

/obj/structure/grille/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(span_warning("[user] hits [src]."), null, null, COMBAT_MESSAGE_RANGE)
	log_combat(user, src, "hit", important = FALSE)
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/grille/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_warning("[user] mangles [src]."), null, null, COMBAT_MESSAGE_RANGE)
	if(!shock(user, 70))
		take_damage(20, BRUTE, MELEE, 1)

/obj/structure/grille/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!. && istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/grille/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/passing_atom)
	. = !density
	if(istype(passing_atom))
		. = . || (passing_atom.pass_flags & PASSGRILLE)

/obj/structure/grille/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!shock(user, 100 * W.siemens_coefficient))
			W.play_tool_sound(src, 100)
			deconstruct()
	else if((W.tool_behaviour == TOOL_SCREWDRIVER) && (isturf(loc) || anchored))
		if(!shock(user, 90 * W.siemens_coefficient))
			W.play_tool_sound(src, 100)
			set_anchored(!anchored)
			user.visible_message(span_notice("[user] [anchored ? "fastens" : "unfastens"] [src]."), \
								span_notice("You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor."))
			return
	else if(istype(W, /obj/item/stack/rods) && broken)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90 * W.siemens_coefficient))
			user.visible_message(span_notice("[user] rebuilds the broken grille."), \
								span_notice("You rebuild the broken grille."))
			repair_grille()
			R.use(1)
			return

//window placing begin
	else if(is_glass_sheet(W))
		if (!broken)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				to_chat(user, span_warning("You need at least two sheets of glass for that!"))
				return
			var/dir_to_set = SOUTHWEST
			if(!anchored)
				to_chat(user, span_warning("[src] needs to be fastened to the floor first!"))
				return
			for(var/obj/structure/window/WINDOW in loc)
				to_chat(user, span_warning("There is already a window there!"))
				return
			if(!clear_tile(user))
				return
			to_chat(user, span_notice("You start placing the window..."))
			if(do_after(user,20, target = src))
				if(!src.loc || !anchored) //Grille broken or unanchored while waiting
					return
				for(var/obj/structure/window/WINDOW in loc) //Another window already installed on grille
					return
				if(!clear_tile(user))
					return
				var/obj/structure/window/WD
				if(istype(W, /obj/item/stack/sheet/plasmarglass))
					WD = new/obj/structure/window/plasma/reinforced/fulltile(drop_location()) //reinforced plasma window
				else if(istype(W, /obj/item/stack/sheet/plasmaglass))
					WD = new/obj/structure/window/plasma/fulltile(drop_location()) //plasma window
				else if(istype(W, /obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window/reinforced/fulltile(drop_location()) //reinforced window
				else if(istype(W, /obj/item/stack/sheet/titaniumglass))
					WD = new/obj/structure/window/shuttle(drop_location())
				else if(istype(W, /obj/item/stack/sheet/plastitaniumglass))
					WD = new/obj/structure/window/plastitanium(drop_location())
				else
					WD = new/obj/structure/window/fulltile(drop_location()) //normal window
				WD.setDir(dir_to_set)
				WD.set_anchored(FALSE)
				WD.state = 0
				ST.use(2)
				to_chat(user, span_notice("You place [WD] on [src]."))
			return
//window placing end

	else if(istype(W, /obj/item/shard) || !shock(user, 70 * W.siemens_coefficient))
		return ..()

/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, 1)


/obj/structure/grille/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(!(flags_1&NODECONSTRUCT_1))
		var/drop_loc = drop_location()
		var/obj/R = new rods_type(drop_loc, rods_amount)
		if(QDELETED(R)) // the rods merged with something on the tile
			R = locate(rods_type) in drop_loc
		if(R)
			transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/grille/atom_break()
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		icon_state = "brokengrille"
		set_density(FALSE)
		atom_integrity = 20
		broken = TRUE
		rods_amount = 1
		rods_broken = FALSE
		var/drop_loc = drop_location()
		var/obj/R = new rods_type(drop_loc, rods_amount)
		if(QDELETED(R)) // the rods merged with something on the tile
			R = locate(rods_type) in drop_loc
		if(R)
			transfer_fingerprints_to(R)

/obj/structure/grille/proc/repair_grille()
	if(broken)
		icon_state = "grille"
		set_density(TRUE)
		atom_integrity = max_integrity
		broken = FALSE
		rods_amount = 2
		rods_broken = TRUE
		return TRUE
	return FALSE

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken)		// anchored/broken grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return TRUE
		else
			return FALSE
	return FALSE

/obj/structure/grille/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > T0C + 1500 && !broken

/obj/structure/grille/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(1, BURN, 0, 0)

/obj/structure/grille/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				var/turf/T = get_turf(src)
				var/obj/structure/cable/C = T.get_cable_node()
				if(C)
					playsound(src, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
					tesla_zap(src, 3, C.newavail() * 0.01, TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE | TESLA_MOB_STUN | TESLA_ALLOW_DUPLICATES) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
					C.add_delayedload(C.newavail() * 0.0375) // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
	return ..()

/obj/structure/grille/get_dumping_location(datum/storage/source, mob/user)
	return null

/obj/structure/grille/broken // Pre-broken grilles for map placement
	icon_state = "brokengrille"
	density = FALSE
	broken = TRUE
	rods_amount = 1
	rods_broken = FALSE

/obj/structure/grille/broken/Initialize(mapload)
	. = ..()
	take_damage(max_integrity * 0.6)

/obj/structure/grille/prison //grilles that trigger prison lockdown under some circumstances
	name = "prison grille"
	desc = "a set of rods under current used to protect the prison wing. An alarm will go off if they are breached."
	var/obj/item/assembly/control/device
	var/id = "Prisongate"
	var/initialized_device = FALSE

/obj/structure/grille/prison/proc/setup_device()
	device = new /obj/item/assembly/control
	device.id = id
	initialized_device = 1

/obj/structure/grille/prison/Initialize(mapload)
	. = ..()
	if(!initialized_device)
		setup_device()

/obj/structure/grille/prison/deconstruct()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C?.powernet)
		var/datum/powernet/P = C.powernet
		if(initialized_device && P.avail != 0)
			src.device.activate()
		..()

/obj/structure/grille/prison/atom_break()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C?.powernet)
		var/datum/powernet/P = C.powernet
		if(P)
			if(initialized_device && P.avail != 0)
				src.device.activate()
	..()

/obj/structure/grille/prison/Destroy()
	QDEL_NULL(device)
	return ..()

#undef CLEAR_TILE_MOVE_LIMIT
