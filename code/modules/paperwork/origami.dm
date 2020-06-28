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

/obj/item/origami/Initialize(mapload, obj/item/paper/newPaper)
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
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
	var/list/stamped = internalPaper.stamped
	if(stamped)
		for(var/S in stamped)
			add_overlay("paper_[S]")

/obj/item/origami/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You unfold [src].</span>")
	var/obj/item/paper/internal_paper_tmp = internalPaper
	internal_paper_tmp.forceMove(loc)
	internalPaper = null
	qdel(src)
	user.put_in_hands(internal_paper_tmp)

/obj/item/origami/attackby(obj/item/P, mob/living/carbon/human/user, params)
	..()
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, "<span class='notice'>You should unfold [src] before changing it.</span>")
		return

	else if(istype(P, /obj/item/stamp)) 	//we don't randomize stamps on origami
		internalPaper.attackby(P, user) //spoofed attack to update internal paper.
		update_icon()

	else if(P.is_hot())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
				"<span class='userdanger'>You miss [src] and accidentally light yourself on fire!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return
		user.dropItemToGround(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
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

/obj/item/origami/syndicate
	name = "paper S"
	desc = "Paper folded into the letter S. Could this be the work of a syndicate agent?"
	icon_state = "papersyndicate"

/obj/item/paper/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click [src] to fold it into origami.</span>")

/obj/item/paper/AltClick(mob/living/carbon/user, obj/item/I)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	var/list/origami_list = subtypesof(/obj/item/origami)

	var/datum/action/innate/origami/origami_action = locate() in user.actions
	if(!(origami_action))
		//Not Origami Master
		origami_list -= /obj/item/origami/paperplane/syndicate
		origami_list -= /obj/item/origami/syndicate

	var/origami_select = input(user, "Choose what kind of origami to make.", "Origami Folding") as null|anything in sortList(origami_list, /proc/cmp_typepaths_asc)
	if(!origami_select)
		return
	user.temporarilyRemoveItemFromInventory(src)

	I = new origami_select(user, src)
	to_chat(user, "<span class='notice'>You fold [src] into the shape of a [I.name]!</span>")
	user.put_in_hands(I)