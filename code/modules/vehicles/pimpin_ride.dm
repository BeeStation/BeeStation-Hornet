//PIMP-CART
/obj/vehicle/ridden/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	var/obj/item/storage/bag/trash/mybag = null
	var/floorbuffer = FALSE
	var/datum/action/cleaning_toggle/autoclean_toggle

/obj/vehicle/ridden/janicart/Initialize(mapload)
	. = ..()
	update_icon()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/janicart)
	GLOB.janitor_devices += src
	if(floorbuffer)
		AddElement(/datum/element/cleaning)

/obj/vehicle/ridden/janicart/Destroy()
	GLOB.janitor_devices -= src
	if(mybag)
		qdel(mybag)
		mybag = null
	. = ..()

/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"

/obj/vehicle/ridden/janicart/examine(mob/user)
	. += ..()
	if(floorbuffer)
		. += "It has been upgraded with a floor buffer."

/obj/vehicle/ridden/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash))
		if(mybag)
			to_chat(user, span_warning("[src] already has a trashbag hooked!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, span_notice("You hook the trashbag onto [src]."))
		mybag = I
		update_icon()
	else if(istype(I, /obj/item/janiupgrade))
		if(floorbuffer)
			to_chat(user, span_warning("[src] already has a floor buffer!"))
			return
		floorbuffer = TRUE
		qdel(I)
		to_chat(user, span_notice("You upgrade [src] with the floor buffer."))
		AddElement(/datum/element/cleaning)
		update_icon()
	else
		return ..()

/obj/vehicle/ridden/janicart/update_icon()
	cut_overlays()
	if(mybag)
		add_overlay("cart_garbage")
	if(floorbuffer)
		add_overlay("cart_buffer")

/obj/vehicle/ridden/janicart/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	else if(mybag)
		mybag.forceMove(get_turf(user))
		user.put_in_hands(mybag)
		mybag = null
		update_icon()

/obj/vehicle/ridden/janicart/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	if(floorbuffer)
		autoclean_toggle = new()
		autoclean_toggle.toggle_target = src
		autoclean_toggle.Grant(M)

/obj/vehicle/ridden/janicart/unbuckle_mob(mob/living/buckled_mob, force)
	. = ..()
	if(floorbuffer)
		autoclean_toggle.Remove(buckled_mob)
		QDEL_NULL(autoclean_toggle)

/obj/vehicle/ridden/janicart/Destroy()
	. = ..()
	if(floorbuffer)
		autoclean_toggle.toggle_target = null
		QDEL_NULL(autoclean_toggle)

/obj/vehicle/ridden/janicart/upgraded
	floorbuffer = TRUE

/obj/vehicle/ridden/janicart/upgraded/keyless
	floorbuffer = TRUE
	key_type = null

/obj/vehicle/ridden/lawnmower
	name = "John J. Jimbler Ultra-Mega-Mower"
	desc = "Equipped with reliable safeties to prevent <i>accidents</i> in the workplace. The safety light is <b>on</b>."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "lawnmower"
	var/emagged = FALSE
	var/list/drive_sounds = list('sound/effects/mowermove1.ogg', 'sound/effects/mowermove2.ogg')
	var/list/gib_sounds = list('sound/effects/mowermovesquish.ogg')
	var/driver

/obj/vehicle/ridden/lawnmower/Initialize()
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lawnmower)

/obj/vehicle/ridden/lawnmower/emagged
	emagged = TRUE
	desc = "Equipped with reliable safeties to prevent <i>accidents</i> in the workplace. The safety light is off"

/obj/vehicle/ridden/lawnmower/on_emag(mob/user)
	. = ..()
	if(emagged)
		to_chat(user, span_warning("The safety mechanisms on \the [src] are already disabled!"))
		return
	to_chat(user, span_warning("You disable the safety mechanisms on \the [src]."))
	desc = "Equipped with reliable safeties to prevent <i>accidents</i> in the workplace. The safety light is <b>off</b>."
	emagged = TRUE

/obj/vehicle/ridden/lawnmower/Bump(atom/A)
	. = ..()
	if(emagged)
		if(isliving(A))
			var/mob/living/M = A
			M.adjustBruteLoss(25)
			playsound(loc, 'sound/effects/bang.ogg', 50, 1)
			var/atom/newLoc = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
			M.throw_at(newLoc, 4, 1)

/obj/vehicle/ridden/lawnmower/Move()
	. = ..()
	var/gibbed = FALSE
	playsound(loc, 'sound/effects/mowerstep.ogg', 25, 1)
	var/mob/living/carbon/H

	if(has_buckled_mobs())
		H = buckled_mobs[1]
	else
		return .

	if(emagged)
		for(var/mob/living/carbon/human/M in loc)
			if(M == H)
				continue
			if(M.body_position == LYING_DOWN)
				visible_message(span_danger("\the [src] grinds [M.name] into a fine paste!"))
				M.gib()
				shake_camera(M, 20, 1)
				gibbed = TRUE

	if(gibbed)
		shake_camera(H, 10, 1)
		playsound(loc, pick(gib_sounds), 75, 1)

	mow_lawn()

/obj/vehicle/ridden/lawnmower/proc/mow_lawn()
	//Nearly copypasted from goats
	var/mowed = FALSE
	var/obj/structure/spacevine/spacevine = locate(/obj/structure/spacevine) in loc
	if(spacevine)
		qdel(spacevine)
		mowed = TRUE

	var/obj/structure/glowshroom/glowshroom = locate(/obj/structure/glowshroom) in loc
	if(glowshroom)
		qdel(glowshroom)
		mowed = TRUE

	var/obj/structure/alien/weeds/ayy_weeds = locate(/obj/structure/alien/weeds) in loc
	if(ayy_weeds)
		qdel(ayy_weeds)
		mowed = TRUE

	var/obj/structure/flora/flora = locate(/obj/structure/flora) in loc
	if(flora)
		if(!istype(flora, /obj/structure/flora/rock))
			qdel(flora)
			mowed = TRUE
		else
			take_damage(25)
			visible_message(span_danger("\the [src] makes a awful grinding sound as it drives over [flora]!"))

	if(mowed)
		playsound(loc, pick(drive_sounds), 50, 1)
