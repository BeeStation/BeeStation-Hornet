/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.9
	slot_flags = ITEM_SLOT_ICLOTHING
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	var/fitted = FEMALE_UNIFORM_FULL // For use in alternate clothing styles for women
	var/has_sensor = HAS_SENSORS // For the crew computer
	var/random_sensor = TRUE
	var/sensor_mode = NO_SENSORS
	var/can_adjust = TRUE
	var/adjusted = NORMAL_STYLE
	var/alt_covers_chest = FALSE // for adjusted/rolled-down jumpsuits, FALSE = exposes chest and arms, TRUE = exposes arms only
	var/obj/item/clothing/accessory/attached_accessory
	var/mutable_appearance/accessory_overlay
	var/freshly_laundered = FALSE

/obj/item/clothing/under/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
		if(HAS_BLOOD_DNA(src))
			. += mutable_appearance('icons/effects/blood.dmi', "uniformblood")
		if(accessory_overlay)
			. += accessory_overlay

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if((has_sensor == BROKEN_SENSORS) && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		C.use(1)
		has_sensor = HAS_SENSORS
		update_sensors(NO_SENSORS)
		to_chat(user,"<span class='notice'>You repair the suit sensors on [src] with [C].</span>")
		return 1
	if(!attach_accessory(I, user))
		return ..()

/obj/item/clothing/under/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_w_uniform()
	if(has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
		update_sensors(NO_SENSORS)

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	var/new_sensor_mode = sensor_mode
	sensor_mode = SENSOR_NOT_SET
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		new_sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS, SENSOR_COORDS)
	update_sensors(new_sensor_mode)

/obj/item/clothing/under/Destroy()
	. = ..()
	if(ishuman(loc))
		update_sensors(SENSOR_OFF)

/obj/item/clothing/under/emp_act()
	. = ..()
	if(has_sensor > NO_SENSORS)
		var/new_sensor_mode = pick(SENSOR_OFF, SENSOR_OFF, SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS)
		if(ismob(loc))
			var/mob/M = loc
			to_chat(M,"<span class='warning'>The sensors on the [src] change rapidly!</span>")
		update_sensors(new_sensor_mode)

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if(ishuman(user) || ismonkey(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_w_uniform()
	if(slot == ITEM_SLOT_ICLOTHING)
		update_sensors(sensor_mode, TRUE)

	if(slot == ITEM_SLOT_ICLOTHING && freshly_laundered)
		freshly_laundered = FALSE
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)

	if(attached_accessory && slot != ITEM_SLOT_HANDS && ishuman(user))
		var/mob/living/carbon/human/H = user
		attached_accessory.on_uniform_equip(src, user)
		if(attached_accessory.above_suit)
			H.update_inv_wear_suit()

/obj/item/clothing/under/dropped(mob/user)
	..()
	var/mob/living/carbon/human/H = user
	if(attached_accessory)
		attached_accessory.on_uniform_dropped(src, user)
		if(ishuman(H) && attached_accessory.above_suit)
			H.update_inv_wear_suit()

	if(ishuman(H) || ismonkey(H))
		if(H.w_uniform == src)
			if(!HAS_TRAIT(user, TRAIT_SUIT_SENSORS))
				return
			REMOVE_TRAIT(user, TRAIT_SUIT_SENSORS, TRACKED_SENSORS_TRAIT)
			if(!HAS_TRAIT(user, TRAIT_SUIT_SENSORS) && !HAS_TRAIT(user, TRAIT_NANITE_SENSORS))
				GLOB.suit_sensors_list -= user

/obj/item/clothing/under/proc/attach_accessory(obj/item/I, mob/user, notifyAttach = 1)
	. = FALSE
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(attached_accessory)
			if(user)
				to_chat(user, "<span class='warning'>[src] already has an accessory.</span>")
			return
		else

			if(!A.can_attach_accessory(src, user)) //Make sure the suit has a place to put the accessory.
				return
			if(user && !user.temporarilyRemoveItemFromInventory(I))
				return
			if(!A.attach(src, user))
				return

			if(user && notifyAttach)
				to_chat(user, "<span class='notice'>You attach [I] to [src].</span>")

			var/accessory_color = attached_accessory.icon_state
			accessory_overlay = mutable_appearance('icons/mob/accessories.dmi', "[accessory_color]")
			accessory_overlay.alpha = attached_accessory.alpha
			accessory_overlay.color = attached_accessory.color

			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()
				H.update_inv_wear_suit()
			if(ismonkey(loc))
				var/mob/living/carbon/monkey/H = loc
				H.update_inv_w_uniform()

			return TRUE

/obj/item/clothing/under/proc/remove_accessory(mob/user)
	if(!isliving(user))
		return
	if(!can_use(user))
		return

	if(attached_accessory)
		var/obj/item/clothing/accessory/A = attached_accessory
		attached_accessory.detach(src, user)
		if(user.put_in_hands(A))
			to_chat(user, "<span class='notice'>You detach [A] from [src].</span>")
		else
			to_chat(user, "<span class='notice'>You detach [A] from [src] and it falls on the floor.</span>")

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()
		if(ismonkey(loc))
			var/mob/living/carbon/monkey/H = loc
			H.update_inv_w_uniform()

//Adds or removes mob from suit sensor global list
/obj/item/clothing/under/proc/update_sensors(new_mode, forced = FALSE)
	var/old_mode = sensor_mode
	sensor_mode = new_mode
	if(!forced && (old_mode == new_mode || (old_mode != SENSOR_OFF && new_mode != SENSOR_OFF)))
		return
	if(!ishuman(loc) || istype(loc, /mob/living/carbon/human/dummy))
		return

	if(has_sensor >= HAS_SENSORS && sensor_mode > SENSOR_OFF)
		if(HAS_TRAIT(loc, TRAIT_SUIT_SENSORS))
			return
		ADD_TRAIT(loc, TRAIT_SUIT_SENSORS, TRACKED_SENSORS_TRAIT)
		if(!HAS_TRAIT(loc, TRAIT_NANITE_SENSORS))
			GLOB.suit_sensors_list += loc
	else
		if(!HAS_TRAIT(loc, TRAIT_SUIT_SENSORS))
			return
		REMOVE_TRAIT(loc, TRAIT_SUIT_SENSORS, TRACKED_SENSORS_TRAIT)
		if(!HAS_TRAIT(loc, TRAIT_NANITE_SENSORS))
			GLOB.suit_sensors_list -= loc


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(freshly_laundered)
		. += "It looks fresh and clean."
	if(can_adjust)
		. += "Alt-click on [src] to wear it [adjusted == ALT_STYLE ? "normally" : "casually"]."
	if (has_sensor == BROKEN_SENSORS)
		. += "Its sensors appear to be shorted out."
	else if(has_sensor > NO_SENSORS)
		switch(sensor_mode)
			if(SENSOR_OFF)
				. += "Its sensors appear to be disabled."
			if(SENSOR_LIVING)
				. += "Its binary life sensors appear to be enabled."
			if(SENSOR_VITALS)
				. += "Its vital tracker appears to be enabled."
			if(SENSOR_COORDS)
				. += "Its vital tracker and tracking beacon appear to be enabled."
	if(attached_accessory)
		. += "\A [attached_accessory] is attached to it."

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/compile_monkey_icon()
	var/identity = "[type]_[icon_state]" //Allows using multiple icon states for piece of clothing
	//If the icon, for this type of clothing, is already made by something else, don't make it again
	if(GLOB.monkey_icon_cache[identity])
		monkey_icon = GLOB.monkey_icon_cache[identity]
		return

	//Start with a base and align it with the mask
	var/icon/base = icon('icons/mob/clothing/uniform.dmi', icon_state, SOUTH) //This takes the icon and uses the worn version of the icon
	var/icon/back = icon('icons/mob/clothing/uniform.dmi', icon_state, NORTH) //Awkard but, we have to manually insert the back
	back.Shift(SOUTH, 2) //Allign with masks
	base.Shift(SOUTH, 2)

	//Break the base down into two parts and lay it on-top of the original. This helps with clothing being too small for monkeys
	var/icon/left = new(base)
	var/icon/mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	left.AddAlphaMask(mask)

	var/icon/right = new(base)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_right")
	right.AddAlphaMask(mask)
	right.Shift(EAST, 1)

	var/icon/middle = new(base) //This part is used to correct a line of pixels
	mask = new('icons/mob/monkey.dmi', "monkey_mask_middle")
	middle.AddAlphaMask(mask)
	middle.Shift(EAST, 1)

	left.Blend(right, ICON_OVERLAY)
	left.Blend(middle, ICON_OVERLAY)
	base.Blend(left, ICON_OVERLAY)

	//Again for the back
	left = new(back)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	left.AddAlphaMask(mask)

	right = new(back)
	right.Shift(EAST, 1)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_right")
	right.AddAlphaMask(mask)

	left.Blend(right, ICON_OVERLAY)
	back.Blend(left, ICON_OVERLAY) //blend the outcome into the current to avoid a bald stripe

	//Now modify the left & right facing icons to better emphasize direction / volume
	left = new(base)
	left.Shift(WEST, 3)
	base.Insert(left, dir = WEST)

	right = new(left)
	right.Flip(EAST)
	base.Insert(right, dir = EAST)

	//Apply masking
	mask = new('icons/mob/monkey.dmi', "monkey_mask_cloth")//Roughly monkey shaped clothing
	base.AddAlphaMask(mask)
	back.AddAlphaMask(mask)
	base.Insert(back, dir = NORTH)//Insert faces into the base

	//Mix in GAG color
	if(greyscale_colors)
		base.Blend(greyscale_colors, ICON_MULTIPLY)

	//Finished!
	monkey_icon = base
	GLOB.monkey_icon_cache[identity] = icon(monkey_icon) //Don't create a reference to monkey icon
