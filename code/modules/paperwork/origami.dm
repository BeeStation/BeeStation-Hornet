/obj/item/origami
	name = "origami"
	desc = "Paper folded to resemble... something."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "scrap"
	throw_range = 1
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/obj/item/paper/internalPaper

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/origami)

/obj/item/origami/Initialize(mapload, obj/item/paper/newPaper)
	. = ..()
	pixel_y = base_pixel_y + rand(-8, 8)
	pixel_x = base_pixel_x + rand(-9, 9)
	if(newPaper)
		internalPaper = newPaper
		flags_1 = newPaper.flags_1
		color = newPaper.color
		newPaper.forceMove(src)
	else
		internalPaper = new(src)
	update_icon()

/obj/item/origami/handle_atom_del(atom/A)
	if(A == internalPaper)
		internalPaper = null
		if(!QDELETED(src))
			qdel(src)
	return ..()

/obj/item/origami/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if (AM == internalPaper)
		internalPaper = null
		if(!QDELETED(src))
			qdel(src)

/obj/item/origami/Destroy()
	QDEL_NULL(internalPaper)
	return ..()

/obj/item/origami/update_icon()
	cut_overlays()
	var/list/stamped = internalPaper.stamp_cache
	if(stamped)
		for(var/S in stamped)
			add_overlay("paper_[S]")

/obj/item/origami/attack_self(mob/user)
	to_chat(user, span_notice("You unfold [src]."))
	var/obj/item/paper/internal_paper_tmp = internalPaper
	internal_paper_tmp.forceMove(loc)
	internalPaper = null
	qdel(src)
	user.put_in_hands(internal_paper_tmp)

/obj/item/origami/attackby(obj/item/P, mob/living/carbon/human/user, params)
	..()
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, span_notice("You should unfold [src] before changing it."))
		return

	else if(istype(P, /obj/item/stamp)) 	//we don't randomize stamps on origami
		internalPaper.attackby(P, user) //spoofed attack to update internal paper.
		update_icon()

	else if(P.is_hot())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message(span_warning("[user] accidentally ignites [user.p_them()]self!"), \
				span_userdanger("You miss [src] and accidentally light yourself on fire!"))
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.ignite_mob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return
		user.dropItemToGround(src)
		user.visible_message(span_danger("[user] lights [src] ablaze with [P]!"), span_danger("You light [src] on fire!"))
		fire_act()

	add_fingerprint(user)

/obj/item/origami/papercrane
	name = "paper crane"
	desc = "Paper folded to look like a majestic crane."
	icon_state = "papercrane"

/obj/item/origami/paperboat
	name = "paper boat"
	desc = "Paper folded to look like a small boat."
	icon_state = "paperboat"

/obj/item/origami/paperfrog
	name = "paper frog"
	desc = "Paper folded to look like a frog."
	icon_state = "paperfrog"

/obj/item/origami/papersyndicate
	name = "paper S"
	desc = "Paper folded into the letter S. Could this be the work of a syndicate agent?"
	icon_state = "papersyndicate"

/obj/item/paper/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to fold it into origami.")

/obj/item/paper/AltClick(mob/living/user, obj/item/I)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return

	var/list/radial_list = list(
		"Paper plane" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperplane"),
		"Paper crane" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "papercrane"),
		"Paper frog" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperfrog"),
		"Paper boat" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperboat")
	)

	var/datum/action/innate/origami/origami_action = locate() in user.actions
	if(origami_action)
		//Origami Master
		radial_list["Syndicate paper plane"] = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paperplanesyndicate")
		radial_list["Paper S"] = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "papersyndicate")

	var/origami_selected = show_radial_menu(user, src, radial_list, require_near = TRUE, tooltips = TRUE)
	if(!origami_selected || !user || user.stat)
		return

	var/origami_type = origami_nametotype(origami_selected)
	if(!origami_type)
		return
	user.temporarilyRemoveItemFromInventory(src)
	I = new origami_type(user, src)
	to_chat(user, span_notice("You fold [src] into the shape of a [I.name]!"))
	user.put_in_hands(I)

//God I wish radial menu just took types. It would clean up rcd code too.
/proc/origami_nametotype(name)
	switch(name)
		if("Paper plane") return /obj/item/origami/paperplane
		if("Paper crane") return /obj/item/origami/papercrane
		if("Paper frog") return /obj/item/origami/paperfrog
		if("Paper boat") return /obj/item/origami/paperboat
		if("Syndicate paper plane") return /obj/item/origami/paperplane/syndicate
		if("Paper S") return /obj/item/origami/papersyndicate
