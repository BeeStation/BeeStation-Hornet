//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "evidenceobj"
	inhand_icon_state = ""
	w_class = WEIGHT_CLASS_TINY

/obj/item/evidencebag/afterattack(obj/item/I, mob/user,proximity)
	. = ..()
	if(!proximity || loc == I)
		return
	evidencebagEquip(I, user)

/obj/item/evidencebag/attackby(obj/item/I, mob/user, params)
	if(evidencebagEquip(I, user))
		return 1

/obj/item/evidencebag/handle_atom_del(atom/A)
	cut_overlays()
	w_class = initial(w_class)
	icon_state = initial(icon_state)
	desc = initial(desc)

/obj/item/evidencebag/proc/evidencebagEquip(obj/item/I, mob/user)
	if(!istype(I) || I.anchored)
		return

	if(loc.atom_storage && I.atom_storage)
		to_chat(user, "<span class='warning'>No matter what way you try, you can't get [I] to fit inside [src].</span>")
		return TRUE //now this is podracing

	if(HAS_TRAIT(I, TRAIT_NO_STORAGE_INSERT))
		to_chat(user, "<span class='warning'>No matter what way you try, you can't get [I] to fit inside [src].</span>")
		return TRUE

	if(istype(I, /obj/item/evidencebag))
		to_chat(user, span_notice("You find putting an evidence bag in another evidence bag to be slightly absurd."))
		return TRUE //now this is podracing

	if(loc in I.GetAllContents()) // fixes tg #39452, evidence bags could store their own location, causing I to be stored in the bag while being present inworld still, and able to be teleported when removed.
		to_chat(user, "<span class='warning'>You find putting [I] in [src] while it's still inside it quite difficult!</span>")
		return

	if(I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, span_notice("[I] won't fit in [src]."))
		return

	if(contents.len)
		to_chat(user, span_notice("[src] already has something inside it."))
		return

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(I.loc.atom_storage) //in a container.
			I.loc.atom_storage.remove_single(user, I, src)
		if(!user.dropItemToGround(I))
			return

	user.visible_message("[user] puts [I] into [src].", span_notice("You put [I] inside [src]."),\
	"<span class='hear'>You hear a rustle as someone puts something into a plastic bag.</span>")

	icon_state = "evidence"

	var/mutable_appearance/in_evidence = new(I)
	in_evidence.plane = FLOAT_PLANE
	in_evidence.layer = FLOAT_LAYER
	in_evidence.pixel_x = 0
	in_evidence.pixel_y = 0
	add_overlay(in_evidence)
	add_overlay("evidence")	//should look nicer for transparent stuff. not really that important, but hey.

	desc = "An evidence bag containing [I]. [I.desc]"
	I.forceMove(src)
	w_class = I.w_class
	return 1

/obj/item/evidencebag/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src].", span_notice("You take [I] out of [src]."),\
		span_italics("You hear someone rustle around in a plastic bag, and remove something."))
		cut_overlays()	//remove the overlays
		user.put_in_hands(I)
		w_class = WEIGHT_CLASS_TINY
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."

	else
		to_chat(user, "[src] is empty.")
		icon_state = "evidenceobj"
	return

/obj/item/storage/box/evidence
	name = "evidence box"
	desc = "A small box specially designed for carrying evidence bags."
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/evidence/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6
	atom_storage.set_holdable(list(/obj/item/evidencebag))

/obj/item/storage/box/evidence/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/evidencebag(src)
