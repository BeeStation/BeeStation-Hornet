/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag
	var/obj/item/mop/mymop
	var/obj/item/pushbroom/mybroom
	var/obj/item/reagent_containers/spray/cleaner/myspray
	var/obj/item/lightreplacer/myreplacer
	var/signs = 0
	var/max_signs = 4
	var/list/fill_icon_thresholds = list(1, 20, 30, 40, 50, 70, 90)

/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)
	GLOB.janitor_devices += src
	update_icon()

/obj/structure/janitorialcart/Destroy()
	GLOB.janitor_devices -= src
	return ..()

/obj/structure/janitorialcart/on_reagent_change(changetype)
	update_icon()

/obj/structure/janitorialcart/proc/wet_mop(obj/item/mop, mob/user)
	if(reagents.total_volume < 1)
		balloon_alert(user, "Out of water!")
		return 0
	else
		var/obj/item/mop/M = mop
		reagents.trans_to(mop, M.mopcap, transfered_by = user)
		balloon_alert(user, "Wet \the [mop]")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return 1

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	if(!user.transferItemToLoc(I, src))
		return
	updateUsrDialog()
	balloon_alert(user, "Put \the [I] into \the [src]")
	return

/obj/structure/janitorialcart/AltClick(mob/user)
	if(!mymop)
		return
	balloon_alert(user, "Removed \the [mymop]")
	user.put_in_hands(mymop)
	mymop = null
	update_icon()

/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/mop))
		var/obj/item/mop/m=I
		if(m.reagents.total_volume < m.reagents.maximum_volume)
			if (wet_mop(m, user))
				return
		if(!mymop)
			m.janicart_insert(user, src)
		else
			balloon_alert(user, "Already has \a [mymop]!")
		return
	if(istype(I, /obj/item/pushbroom))
		if(!mybroom)
			var/obj/item/pushbroom/b=I
			b.janicart_insert(user,src)
		else
			balloon_alert(user, "Already has \a [mybroom]!")
		return
	if(istype(I, /obj/item/storage/bag/trash))
		if(!mybag)
			var/obj/item/storage/bag/trash/t=I
			t.janicart_insert(user, src)
		else
			balloon_alert(user, "Already has \a [mybag]!")
		return
	if(istype(I, /obj/item/reagent_containers/spray/cleaner))
		if(!myspray)
			put_in_cart(I, user)
			myspray=I
			update_icon()
		else
			balloon_alert(user, "Already has \a [myspray]!")
	else if(istype(I, /obj/item/lightreplacer))
		if(!myreplacer)
			var/obj/item/lightreplacer/l=I
			l.janicart_insert(user,src)
		else
			balloon_alert(user, "Already has \a [myreplacer]!")
		return
	if(istype(I, /obj/item/clothing/suit/caution))
		if(signs < max_signs)
			put_in_cart(I, user)
			signs++
			update_icon()
		else
			balloon_alert(user, "The sign rack is full!")
		return
	if(I.tool_behaviour == TOOL_CROWBAR)
		user.balloon_alert_to_viewers("Starts dumping [src]...", "Started dumping [src]...")
		user.visible_message("[user] begins to dump the contents of [src].", "<span class='notice'>You begin to dump the contents of [src]...</span>")
		if(I.use_tool(src, user, 30))
			balloon_alert(user, "Dumped [src]")
			reagents.reaction(src.loc)
			src.reagents.clear_reagents()
		return
	if(istype(I, /obj/item/stack/rods))
		if(user.a_intent == INTENT_HARM)
			return ..()
		if(obj_integrity >= max_integrity)
			balloon_alert(user, "Doesn't need repairs!")
			return
		else
			var/obj/item/stack/rods/rocks_stack = I
			if(rocks_stack.amount < 1) //If that somehow happens
				balloon_alert(user, "Not enough rods!")
				return ..()
			balloon_alert(user, "Repairing...")
			if(do_after(user, 2 SECONDS, src))
				balloon_alert(user, "Repaired")
				obj_integrity += 25
				if(obj_integrity > max_integrity)
					obj_integrity = max_integrity
				rocks_stack.use(1)
		return
	if(mybag)
		mybag.attackby(I, user)
		return
	else
		return ..()

/obj/structure/janitorialcart/proc/check_menu(mob/living/user)
	return istype(user) && !user.incapacitated()

/obj/structure/janitorialcart/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	var/list/items = list()
	if(mybag)
		items += list("Trash bag" = image(icon = mybag.icon, icon_state = mybag.icon_state))
	if(mymop)
		items += list("Mop" = image(icon = mymop.icon, icon_state = mymop.icon_state))
	if(mybroom)
		items += list("Broom" = image(icon = mybroom.icon, icon_state = mybroom.icon_state))
	if(myspray)
		items += list("Spray bottle" = image(icon = myspray.icon, icon_state = myspray.icon_state))
	if(myreplacer)
		items += list("Light replacer" = image(icon = myreplacer.icon, icon_state = myreplacer.icon_state))
	if(signs > 0)
		var/obj/item/clothing/suit/caution/sign = locate() in src
		items += list("Sign" = image(icon = sign.icon, icon_state = sign.icon_state))

	if(!length(items))
		return

	var/pick = items[1]
	if(length(items) > 1)
		items = sort_list(items)
		pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 38, require_near = TRUE)
	if(!pick)
		return
	switch(pick)
		if("Trash bag")
			if(!mybag)
				return
			balloon_alert(user, "Detached \the [mybag]")
			user.put_in_hands(mybag)
			mybag = null
		if("Mop")
			if(!mymop)
				return
			balloon_alert(user, "Removed \the [mymop]")
			user.put_in_hands(mymop)
			mymop = null
		if("Broom")
			if(!mybroom)
				return
			balloon_alert(user, "Removed \the [mybroom]")
			user.put_in_hands(mybroom)
			mybroom = null
		if("Spray bottle")
			if(!myspray)
				return
			balloon_alert(user, "Removed \the [myspray]")
			user.put_in_hands(myspray)
			myspray = null
		if("Light replacer")
			if(!myreplacer)
				return
			balloon_alert(user, "Removed \the [myreplacer]")
			user.put_in_hands(myreplacer)
			myreplacer = null
		if("Sign")
			if(signs <= 0)
				return
			var/obj/item/clothing/suit/caution/Sign = locate() in src
			if(signs > 1)
				balloon_alert(user, "Removed \a [Sign]")
				user.put_in_hands(Sign)
				signs--
			else
				balloon_alert(user, "Removed \the [Sign]")
				user.put_in_hands(Sign)
				signs = 0
		else
			return
	update_icon()

/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(mybag)
		if(istype(mybag, /obj/item/storage/bag/trash/bluespace))
			. += "cart_garbage_bluespace"
		else
			. += "cart_garbage"
	if(mymop)
		. += "cart_mop"
	if(mybroom)
		. += "cart_broom"
	if(myspray)
		. += "cart_spray"
	if(myreplacer)
		. += "cart_replacer"
	if(signs)
		. += "cart_sign[signs]"
	if(reagents.total_volume > 0)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/janitor.dmi', "cart_water[fill_icon_thresholds[1]]")

		var/percent = round((reagents.total_volume / reagents.maximum_volume) * 100)
		for(var/i in 1 to length(fill_icon_thresholds))
			var/threshold = fill_icon_thresholds[i]
			var/threshold_end = (i == length(fill_icon_thresholds)) ? INFINITY : fill_icon_thresholds[i+1]
			if(threshold <= percent && percent < threshold_end)
				filling.icon_state = "cart_water[fill_icon_thresholds[i]]"
		//var/mutable_appearance/filling = mutable_appearance('icons/obj/janitor.dmi', "cart_water")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/structure/janitorialcart/examine(mob/user)
	. = ..()
	if((obj_integrity/max_integrity) < 1)//If it's damaged
		. += "<span class='notice'>It can be repaired with some iron rods.</span>"
	if(contents.len)
		. += "<span class='notice'><b>\nIt is carrying:</b></span>"
		for(var/thing in sort_names(contents))
			if(istype(thing, /obj/item/clothing/suit/caution))
				continue //we'll do this after.
			. += "\t[icon2html(thing, user)] \a [thing]"
		if(signs > 0)
			var/obj/item/clothing/suit/caution/object = locate() in src
			if(signs > 1)
				. += "\t[icon2html(object, user)] [signs] [object.name]\s"
			else
				. += "\t[icon2html(object, user)] \a [object]"
		. += "<span class='notice'>\n<b>Left-click</b> to [contents.len > 1 ? "search [src]" : "remove [contents[1]]"].</span>"
		if(mymop)
			. += "<span class='notice'><b>Alt-click</b> to quickly remove [mymop].</span>"

