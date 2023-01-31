/obj/structure/big_delivery
	name = "large parcel"
	desc = "A large delivery parcel."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = TRUE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/giftwrapped = FALSE
	var/sortTag = 0
	var/faked = FALSE

/obj/structure/big_delivery/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, .proc/disposal_handling)

/obj/structure/big_delivery/interact(mob/user)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)

/obj/structure/big_delivery/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)
	return ..()

/obj/structure/big_delivery/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/structure/big_delivery/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, 1)

	else if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on the side of [src]!</span>")
			return
		var/str = stripped_input(user, "Label text?", "Set label", "", MAX_NAME_LEN)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(!str || !length(str))
			to_chat(user, "<span class='warning'>Invalid text!</span>")
			return
		user.visible_message("[user] labels [src] as [str].")
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(3))
			user.visible_message("[user] wraps the package in festive paper!")
			giftwrapped = TRUE
			icon_state = "gift[icon_state]"
		else
			to_chat(user, "<span class='warning'>You need more paper!</span>")
	else
		return ..()

/obj/structure/big_delivery/relay_container_resist(mob/living/user, obj/O)
	if(ismovable(loc))
		var/atom/movable/AM = loc //can't unwrap the wrapped container if it's inside something.
		AM.relay_container_resist(user, O)
		return
	to_chat(user, "<span class='notice'>You lean on the back of [O] and start pushing to rip the wrapping around it.</span>")
	if(do_after(user, 50, target = O))
		if(!user || user.stat != CONSCIOUS || user.loc != O || O.loc != src )
			return
		to_chat(user, "<span class='notice'>You successfully removed [O]'s wrapping !</span>")
		O.forceMove(loc)
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
		qdel(src)
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, "<span class='warning'>You fail to remove [O]'s wrapping!</span>")


/obj/structure/big_delivery/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob || faked)
		disposal_holder.destinationTag = sortTag

/obj/item/small_delivery
	name = "parcel"
	desc = "A brown paper delivery parcel."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverypackage3"
	item_state = "deliverypackage"
	var/giftwrapped = 0
	var/sortTag = 0

/obj/item/small_delivery/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/item/small_delivery/attack_self(mob/user)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/X in contents)
		var/atom/movable/AM = X
		user.put_in_hands(AM)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)

/obj/item/small_delivery/attack_self_tk(mob/user)
	if(ismob(loc))
		var/mob/M = loc
		M.temporarilyRemoveItemFromInventory(src, TRUE)
		for(var/X in contents)
			var/atom/movable/AM = X
			M.put_in_hands(AM)
	else
		for(var/X in contents)
			var/atom/movable/AM = X
			AM.forceMove(src.loc)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)

/obj/item/small_delivery/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, 1)

	else if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on the side of [src]!</span>")
			return
		var/str = stripped_input(user, "Label text?", "Set label", "", MAX_NAME_LEN)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(!str || !length(str))
			to_chat(user, "<span class='warning'>Invalid text!</span>")
			return
		user.visible_message("[user] labels [src] as [str].")
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(1))
			icon_state = "gift[icon_state]"
			giftwrapped = 1
			user.visible_message("[user] wraps the package in festive paper!")
		else
			to_chat(user, "<span class='warning'>You need more paper!</span>")

/obj/item/small_delivery/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, .proc/disposal_handling)

/obj/item/small_delivery/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sortTag

/obj/item/dest_tagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/device.dmi'
	icon_state = "cargotagger"
	var/currTag = 0 //Destinations are stored in code\globalvars\lists\flavor_misc.dm
	var/locked_destination = FALSE //if true, users can't open the destination tag window to prevent changing the tagger's current destination
	w_class = WEIGHT_CLASS_TINY
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

/obj/item/dest_tagger/borg
	name = "cyborg destination tagger"
	desc = "Used to fool the disposal mail network into thinking that you're a harmless parcel. Does actually work as a regular destination tagger as well."

/obj/item/dest_tagger/syndicate
	name = "hacked destination tagger"
	desc = "Used to set the destination of properly wrapped packages. This one was tampered with to allow for self-wrapping and tagging."
	var/uses = 2
	var/max_uses = 4
	var/autowrap = TRUE

/obj/item/dest_tagger/syndicate/proc/status_string()
	var/return_string
	if(uses > 0)
		return_string = "The internal wrapping paper compartment holds enough paper for [uses] automatic wrappings."
	else
		return_string = "The internal wrapping paper compartment is empty!"
	return return_string

/obj/item/dest_tagger/syndicate/AltClick(mob/user)
	if(autowrap)
		autowrap = FALSE
	else
		autowrap = TRUE
	to_chat(user, "<span class='notice'>You turn the autowrap function [autowrap ? "on" : "off"]</span>")
	. = ..()

/obj/item/dest_tagger/syndicate/examine(mob/user)
	. = ..()
	. += status_string()
	. += "The autowrap function is [autowrap ? "on" : "off"]"

/obj/item/dest_tagger/syndicate/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/package_wrap))
		Refill(W, user)

/obj/item/dest_tagger/syndicate/proc/Refill(obj/item/W, mob/user)
	var/obj/item/stack/wrapping_paper/G = W
	if(uses >= max_uses)
		to_chat(user, "<span class='warning'>[src.name]'s internal wrapping paper compartment is full.</span>")
		return
	else if(G.use(1))
		AddUses(1)
		to_chat(user, "<span class='notice'>You insert a sheet of wrapping paper into \the [src.name]. It now holds [uses] paper\s.</span>")
		return
	else
		to_chat(user, "<span class='warning'>You need at least one sheet of paper to insert it!</span>")


/obj/item/dest_tagger/syndicate/proc/AddUses(amount = 1)
	uses = CLAMP(uses + amount, 0, max_uses)

/obj/item/dest_tagger/syndicate/attack(mob/living/M, mob/living/user)
	if(user != M)
		to_chat(user, "<span class='warning'>You cannot tag other people with [src]!</span>")
		return
	if(!autowrap)
		to_chat(user, "<span class='warning'>You need to turn on the autowrap function!</span>")
		return
	if(uses <= 0)
		to_chat(user, "<span class='warning'>The [src]'s internal wrapping paper compartment is empty!</span>")
		return
	AddUses(-1)
	var/obj/structure/big_delivery/P = new /obj/structure/big_delivery(get_turf(user.loc))
	P.icon_state = "deliverycrate"
	P.faked = TRUE
	user.forceMove(P)
	P.add_fingerprint(user)
	if(P.sortTag != currTag)
		P.sortTag = currTag
		playsound(loc, 'sound/machines/twobeep_high.ogg', 100, 1)

/obj/item/dest_tagger/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins tagging [user.p_their()] final destination!  It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if (islizard(user))
		to_chat(user, "<span class='notice'>*HELL*</span>")//lizard nerf
	else
		to_chat(user, "<span class='notice'>*HEAVEN*</span>")
	playsound(src, 'sound/machines/twobeep_high.ogg', 100, 1)
	return BRUTELOSS

/obj/item/dest_tagger/proc/openwindow(mob/user)
	var/dat = "<tt><center><h1><b>TagMaster 2.2</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for (var/i = 1, i <= GLOB.TAGGERLOCATIONS.len, i++)
		dat += "<td><a href='?src=[REF(src)];nextTag=[i]'>[GLOB.TAGGERLOCATIONS[i]]</a></td>"

		if(i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? GLOB.TAGGERLOCATIONS[currTag] : "None"]</tt>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/item/dest_tagger/attack_self(mob/user)
	if(!locked_destination)
		openwindow(user)
		return

/obj/item/dest_tagger/Topic(href, href_list)
	add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		currTag = n
	openwindow(usr)
