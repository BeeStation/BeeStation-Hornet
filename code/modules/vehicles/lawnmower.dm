/obj/vehicle/ridden/lawnmower
	name = "Standard Issue Lawnmower"
	desc = "Developed by Nanotrasen, this lawnmower is equipped with reliable safeties to prevent <i>accidents</i> in the workplace."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "lawnmower"
	max_integrity = 200
	var/emagged_by = null
	var/list/drive_sounds = list('sound/effects/mowermove1.ogg', 'sound/effects/mowermove2.ogg')
	var/list/hurt_sounds = list('sound/effects/mowermovesquish.ogg')
	var/normal_variant = TRUE // This is just so the lawnmower doesn't explode twice on destruction and for initializing.

/obj/vehicle/ridden/lawnmower/add_riding_element()
	if(normal_variant)
		AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lawnmower)
	else
		AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lawnmower/nukie)


/obj/vehicle/ridden/lawnmower/emagged
	obj_flags = CAN_BE_HIT | EMAGGED
	desc = "Equipped with reliable safeties to prevent <i>accidents</i> in the workplace."

/obj/vehicle/ridden/lawnmower/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_warning("The safety lights are <b>off<b>.")
	else
		. += span_notice("The safety lights are <b>on<b>.")

/obj/vehicle/ridden/lawnmower/atom_destruction()
	if(normal_variant)
		explosion(src, -1, 1, 2, 4, flame_range = 3)
		. = ..()
	else
		explosion(src, -1, 3, 5, 7, flame_range = 5)
		. = ..()

/obj/vehicle/ridden/lawnmower/on_emag(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The safety mechanisms on \the [src] are already disabled!"))
		return
	to_chat(user, span_warning("You disable the safety mechanisms on \the [src]."))
	desc = "Equipped with reliable safeties to prevent <i>accidents</i> in the workplace."
	obj_flags |= EMAGGED
	if(user)
		emagged_by = key_name(user)

/obj/vehicle/ridden/lawnmower/Bump(atom/A)
	. = ..()
	if(obj_flags & EMAGGED)
		if(isliving(A))
			var/mob/living/M = A
			M.adjustBruteLoss(10)
			playsound(loc, 'sound/effects/bang.ogg', 50, 1)
			var/atom/newLoc = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
			M.throw_at(newLoc, 2, 1)

/obj/vehicle/ridden/lawnmower/Move()
	. = ..()
	var/gibbed = FALSE
	playsound(loc, pick(drive_sounds), 50, 1)
	var/mob/living/carbon/H

	if(has_buckled_mobs())
		H = buckled_mobs[1]
		H.investigate_log("[H] entered [src] as the driver")
	else
		return .

	if(obj_flags & EMAGGED)
		for(var/mob/living/carbon/human/M in loc)
			if(M == H)
				continue
			if(M.body_position == LYING_DOWN)
				visible_message(span_danger("\the [src] grinds [M.name], into a fine paste!"))
				M.gib() // This is so fucked but you people wanted it
				M.log_message("has been gibbed by an emagged lawnmower that was driven by [(H.ckey || "nobody")] and emagged by [(emagged_by || "nobody")]", LOG_ATTACK, color="red")
				H.log_message("has gibbed [(M.ckey || "none-player")] using an emagged lawnmower that was emagged by [(emagged_by || "nobody")]", LOG_ATTACK, color="red")
				shake_camera(M, 20, 1)
				gibbed = TRUE

	if(gibbed)
		shake_camera(H, 2, 1)
		playsound(loc, pick(hurt_sounds), 75, 1)

	mow_lawn()

/obj/vehicle/ridden/lawnmower/proc/mow_lawn()
	//Nearly copypasted from goats
	var/obj/structure/spacevine/spacevine = locate(/obj/structure/spacevine) in loc
	if(spacevine)
		qdel(spacevine)

	var/obj/structure/glowshroom/glowshroom = locate(/obj/structure/glowshroom) in loc
	if(glowshroom)
		qdel(glowshroom)

	var/obj/structure/alien/weeds/ayy_weeds = locate(/obj/structure/alien/weeds) in loc
	if(ayy_weeds)
		qdel(ayy_weeds)

	var/obj/structure/flora/flora = locate(/obj/structure/flora) in loc
	if(flora)
		if(!istype(flora, /obj/structure/flora/rock))
			qdel(flora)
		else
			take_damage(25)
			visible_message(span_danger("\the [src] makes a awful grinding sound as it drives over [flora]!"))

/obj/vehicle/ridden/lawnmower/nukie
	name = "Syndicate Organism Shredder"
	desc = "A modified Nanotrasen lawnmower with a custom paint job. The safety mechanisms were turned off automatically, rip and tear."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "syndi_lawnmower"
	max_integrity = 150
	obj_flags = CAN_BE_HIT | EMAGGED
	drive_sounds = list('sound/effects/mower_treads.ogg')
	hurt_sounds = list('sound/effects/splat.ogg')
	normal_variant = FALSE

