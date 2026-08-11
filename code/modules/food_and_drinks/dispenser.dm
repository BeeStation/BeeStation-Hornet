//Sponsored by big overlay
/obj/item/candydispenser
	name = "gumball dispenser"
	desc = "A whimsical device with a glass globe on top, which can be operated to dispense various candies."
	icon = 'icons/obj/food/containers.dmi'
	inhand_icon_state = "deliverypackage"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "dispenser"
	hitsound = 'sound/weapons/smash.ogg'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ISWEAPON

	var/variant = "default"

	//Its a cheaply made sheetmetal, glass and plastic thingy. Hefty and unwieldy.
	force = 7
	throwforce = 10
	throw_speed = 3
	throw_range = 4
	//File down the edges? No. What do you think this is? You're in a sweatshop!
	bleed_force = BLEED_TINY
	sharpness = BLUNT

	var/obj/candy_type = /obj/item/food/gumball
	var/const/max_candies = 50
	var/total_candies = 50

/obj/item/candydispenser/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	update_icon()

/obj/item/candydispenser/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || M.incapacitated || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)

	add_fingerprint(M)

/obj/item/candydispenser/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/candydispenser/attack_hand(mob/user, list/modifiers)
	update_icon()
	add_fingerprint(user)
	dispense(user)
	return ..()

/obj/item/candydispenser/examine(mob/user)
	. = ..()
	if(total_candies)
		. += "It contains [total_candies] candies."
	else
		. += "It is empty."

/obj/item/candydispenser/proc/dispense(mob/user, danger = FALSE)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return

	if(danger)
		var/dispense_count = rand(1,5)
		playsound(src,'sound/machines/locktoggle.ogg',80,TRUE)
		playsound(src,'sound/effects/glass_step.ogg',80,FALSE)
		for(var/i in 1 to dispense_count)
			if(total_candies >= 1)
				total_candies--
				var/obj/candy
				candy = new candy_type(src)
				candy.forceMove(get_turf(src))
				candy.pixel_x = rand(-8,8)
				candy.pixel_y = rand(-8,8)
	else
		if(total_candies >= 1)
			total_candies--
			playsound(src,'sound/machines/locktoggle.ogg',80,TRUE)
			var/obj/candy
			candy = new candy_type(src)
			candy.forceMove(src)
			candy.add_fingerprint(user)
			user.put_in_hands(candy)
			to_chat(user, span_notice("You take a [candy.name] out of \the [src]."))
		else
			to_chat(user, span_warning("[src] is empty!"))
	return

/obj/item/candydispenser/update_icon()
	cut_overlays()
	if(variant)
		add_overlay("[icon_state]_[variant]")
	switch(total_candies)
		if(max_candies * 0.75 to max_candies)
			add_overlay("[icon_state]_100")
			desc = "A [candy_type.name] machine. It is full!"
		if(max_candies * 0.50 to max_candies * 0.75)
			add_overlay("[icon_state]_75")
			desc = "A [candy_type.name] machine. Some candy is missing."
		if(max_candies * 0.25 to max_candies * 0.50)
			add_overlay("[icon_state]_50")
			desc = "A [candy_type.name] machine. It's half full!"
		if(1 to max_candies * 0.25)
			add_overlay("[icon_state]_25")
			desc = "A [candy_type.name] machine. There are a few candies left."
		if(0)
			desc = "A [candy_type.name] machine. It's empty!"
	add_overlay("[icon_state]_bulb")


/obj/item/candydispenser/attack_self(mob/user)
	. = ..()
	dispense(user)

/obj/item/candydispenser/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	dispense(danger = TRUE)

/obj/item/candydispenser/attack(mob/living/target_mob, mob/living/user)
	. = ..()
	dispense(danger = TRUE)

/obj/item/candydispenser/attack_atom(atom/attacked_atom, mob/living/user, params)
	. = ..()
	dispense(danger = TRUE)

/obj/item/candydispenser/attack_turf(turf/T, mob/living/user)
	. = ..()
	dispense(danger = TRUE)

/obj/item/candydispenser/lollipop
	name = "lollipop dispenser"
	variant = "lollipop"
	candy_type = /obj/item/food/lollipop

/obj/item/candydispenser/syndie
	candy_type = /obj/item/food/gumball/syndicate
	force = 18
	throwforce = 23
	bleed_force = BLEED_SCRATCH

/obj/item/candydispenser/engineering
	name = "engineering gumball dispenser"
	desc = "A whimsical device with a glass globe on top, which can be operated to dispense various candies."
	variant = "engineering"
	candy_type = /obj/item/food/gumball/engineering
