/mob/living/basic/pet/gondola/gondolapod
	name = "gondola"
	real_name = "gondola"
	desc = "The silent walker. This one seems to be part of a delivery agency."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "gondola"
	icon_living = "gondola"
	SET_BASE_PIXEL(-16, -5) //2x2 sprite
	layer = TABLE_LAYER //so that deliveries dont appear underneath it

	loot = list(
		/obj/effect/decal/cleanable/blood/gibs = 1,
		/obj/item/stack/sheet/animalhide/gondola = 2,
		/obj/item/food/meat/slab/gondola = 2,
	)

	///Boolean on whether the pod is currently open, and should appear such.
	var/opened = FALSE
	///The supply pod attached to the gondola, that actually holds the contents of our delivery.
	var/obj/structure/closet/supplypod/centcompod/linked_pod
	///Static list of actions the gondola is given on creation, and taken away when it successfully delivers.

/mob/living/basic/pet/gondola/gondolapod/Initialize(mapload, pod)
	linked_pod = pod || new(src)
	name = linked_pod.name
	desc = linked_pod.desc
	return ..()

/mob/living/basic/pet/gondola/gondolapod/death()
	QDEL_NULL(linked_pod) //Will cause the open() proc for the linked supplypod to be called with the "broken" parameter set to true, meaning that it will dump its contents on death
	return ..()

/mob/living/basic/pet/gondola/gondolapod/create_gondola()
	return

/mob/living/basic/pet/gondola/gondolapod/update_overlays()
	. = ..()
	if(opened)
		. += "[icon_state]_open"

/mob/living/basic/pet/gondola/gondolapod/examine(mob/user)
	. = ..()
	if (contents.len)
		. += span_notice("It looks like it hasn't made its delivery yet.")
	else
		. += span_notice("It looks like it has already made its delivery.")

/mob/living/basic/pet/gondola/gondolapod/setOpened()
	opened = TRUE
	layer = initial(layer)
	update_appearance()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, setClosed)), 5 SECONDS)

/mob/living/basic/pet/gondola/gondolapod/setClosed()
	opened = FALSE
	layer = BELOW_MOB_LAYER
	update_appearance()

/mob/living/basic/pet/gondola/gondolapod/verb/deliver()
	set name = "Release Contents"
	set category = "Gondola"
	set desc = "Release any contents stored within your vast belly."
	linked_pod.open_pod(src, forced = TRUE)

/mob/living/basic/pet/gondola/gondolapod/examine(mob/user)
	. = ..()
	if (contents.len)
		. += span_notice("It looks like it hasn't made its delivery yet.</b>")
	else
		. += span_notice("It looks like it has already made its delivery.</b>")

/mob/living/basic/pet/gondola/gondolapod/verb/check()
	set name = "Count Contents"
	set category = "Gondola"
	set desc = "Take a deep look inside youself, and count up what's inside"
	var/total = contents.len
	if (total)
		to_chat(src, span_notice("You detect [total] object\s within your incredibly vast belly."))
	else
		to_chat(src, span_notice("A closer look inside yourself reveals... nothing."))

/mob/living/basic/pet/gondola/gondolapod/setOpened()
	opened = TRUE
	update_icon()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, setClosed)), 50)

/mob/living/basic/pet/gondola/gondolapod/setClosed()
	opened = FALSE
	update_icon()

/mob/living/basic/pet/gondola/gondolapod/death()
	qdel(linked_pod) //Will cause the open() proc for the linked supplypod to be called with the "broken" parameter set to true, meaning that it will dump its contents on death
	qdel(src)
	..()
