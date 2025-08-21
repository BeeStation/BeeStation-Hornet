/obj/structure/plasticflaps
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps. Definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	armor_type = /datum/armor/structure_plasticflaps
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	can_atmos_pass = ATMOS_PASS_NO


/datum/armor/structure_plasticflaps
	melee = 100
	bullet = 80
	laser = 80
	energy = 100
	bomb = 50
	rad = 100
	fire = 50
	acid = 50

/obj/structure/plasticflaps/opaque
	opacity = TRUE

/obj/structure/plasticflaps/Initialize(mapload)
	. = ..()
	alpha = 0
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA) //you see mobs under it, but you hit them like they are above it

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("[src] are <b>screwed</b> to the floor.")
	else
		. += span_notice("[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>cut</b> apart.")

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	add_fingerprint(user)
	var/action = anchored ? "unscrews [src] from" : "screws [src] to"
	var/uraction = anchored ? "unscrew [src] from " : "screw [src] to"
	user.visible_message(span_warning("[user] [action] the floor."), span_notice("You start to [uraction] the floor..."), "You hear rustling noises.")
	if(W.use_tool(src, user, 100, volume=100, extra_checks = CALLBACK(src, PROC_REF(check_anchored_state), anchored)))
		set_anchored(!anchored)
		to_chat(user, span_notice(" You [anchored ? "unscrew" : "screw"] [src] from the floor."))
		return TRUE
	else
		return TRUE

/obj/structure/plasticflaps/wirecutter_act(mob/living/user, obj/item/W)
	if(!anchored)
		user.visible_message(span_warning("[user] cuts apart [src]."), span_notice("You start to cut apart [src]."), "You hear cutting.")
		if(W.use_tool(src, user, 50, volume=100))
			if(anchored)
				return TRUE
			to_chat(user, span_notice("You cut apart [src]."))
			new /obj/item/stack/sheet/plastic/five(loc, null, TRUE, user)
			qdel(src)
			return TRUE
		else
			return TRUE

/obj/structure/plasticflaps/proc/check_anchored_state(check_anchored)
	if(anchored != check_anchored)
		return FALSE
	return TRUE

/obj/structure/plasticflaps/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/passing_atom)
	if(isliving(passing_atom))
		if(isbot(passing_atom))
			return TRUE

		var/mob/living/living_pass = passing_atom
		if(!living_pass.ventcrawler && living_pass.mob_size != MOB_SIZE_TINY)
			return FALSE

	if(passing_atom?.pulling)
		return CanAStarPass(ID, to_dir, passing_atom.pulling)
	return TRUE //diseases, stings, etc can pass

/obj/structure/plasticflaps/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(mover.pass_flags & PASSTRANSPARENT)
		return prob(60)

	if(istype(mover, /obj/structure/bed))
		var/obj/structure/bed/bed_mover = mover
		if(bed_mover.density || bed_mover.has_buckled_mobs())//if it's a bed/chair and is dense or someone is buckled, it will not pass
			return FALSE

	else if(istype(mover, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/cardboard_mover = mover
		if(cardboard_mover.move_delay)
			return FALSE

	else if(ismecha(mover))
		return FALSE

	else if(isliving(mover)) // You Shall Not Pass!
		var/mob/living/living_mover = mover
		if(isbot(mover)) //Bots understand the secrets
			return TRUE
		if(istype(living_mover.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return TRUE

		if(living_mover.body_position == STANDING_UP && living_mover.mob_size != MOB_SIZE_TINY && !living_mover.ventcrawler)	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return FALSE

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

/obj/structure/plasticflaps/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf(TRUE, FALSE)
