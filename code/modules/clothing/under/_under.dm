/obj/item/clothing/under
	name = "under"
	icon = 'icons/obj/clothing/under/default.dmi'
	worn_icon = 'icons/mob/clothing/under/default.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	slot_flags = ITEM_SLOT_ICLOTHING
	armor_type = /datum/armor/clothing_under
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	/// The variable containing the flags for how the woman uniform cropping is supposed to interact with the sprite.
	var/female_sprite_flags = FEMALE_UNIFORM_FULL
	var/has_sensor = HAS_SENSORS // For the crew computer
	var/random_sensor = TRUE
	var/sensor_mode = NO_SENSORS
	var/can_adjust = TRUE
	var/adjusted = NORMAL_STYLE
	var/alt_covers_chest = FALSE // for adjusted/rolled-down jumpsuits, FALSE = exposes chest and arms, TRUE = exposes arms only
	/// Assoc list [key: slot]: /obj/item/clothing/accessory
	var/list/attached_accessories = list()
	var/mutable_appearance/accessory_overlay_under
	var/mutable_appearance/accessory_overlay_over
	var/freshly_laundered = FALSE
	dying_key = DYE_REGISTRY_UNDER

/datum/armor/clothing_under
	bio = 10
	bleed = 10

/obj/item/clothing/under/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform", item_layer +  0.0002)
		if(GET_ATOM_BLOOD_DNA_LENGTH(src))
			var/mutable_appearance/bloody_uniform = mutable_appearance('icons/effects/blood.dmi', "uniformblood", item_layer + 0.0002)
			bloody_uniform.color = get_blood_dna_color(GET_ATOM_BLOOD_DNA(src))
			. += bloody_uniform
		if(accessory_overlay_under)
			accessory_overlay_under.layer = item_layer +  0.0001
			. += accessory_overlay_under

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if((has_sensor == BROKEN_SENSORS) && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		C.use(1)
		has_sensor = HAS_SENSORS
		update_sensors(NO_SENSORS)
		to_chat(user, span_notice("You repair the suit sensors on [src] with [C]."))
		return 1
	if(!attach_accessory(I, user))
		return ..()

/obj/item/clothing/under/attack_hand_secondary(mob/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	toggle()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/under/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_undersuit()
	if(damaged_state == CLOTHING_SHREDDED && has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
	else if(damaged_state == CLOTHING_PRISTINE && has_sensor == BROKEN_SENSORS)
		has_sensor = HAS_SENSORS
	update_sensors(NO_SENSORS)

/obj/item/clothing/under/add_context_self(datum/screentip_context/context, mob/user)
	if(isnull(context.held_item) && has_sensor == HAS_SENSORS)
		context.add_right_click_action("Toggle suit sensors")

	if(istype(context.held_item, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/accessory = context.held_item
		if(accessory.can_attach_accessory(src, user, TRUE))
			context.add_left_click_action("Attach accessory")

	if(has_sensor == BROKEN_SENSORS)
		context.add_left_click_item_action("Repair suit sensors", /obj/item/stack/cable_coil)

	if(length(attached_accessories))
		context.add_alt_click_item_action("Remove accessory", null)
	else if(can_adjust)
		context.add_alt_click_action(adjusted == ALT_STYLE ? "Wear normally" : "Wear casually")

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
			to_chat(M,span_warning("The sensors on the [src] change rapidly!"))
		update_sensors(new_sensor_mode)

/obj/item/clothing/under/visual_equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE
		female_sprite_flags = initial(female_sprite_flags)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if(ishuman(user) || ismonkey(user))
		var/mob/living/carbon/human/H = user
		H.update_worn_undersuit()
	if(slot == ITEM_SLOT_ICLOTHING)
		update_sensors(sensor_mode, TRUE)

	if(length(attached_accessories) && slot != ITEM_SLOT_HANDS && ishuman(user))
		var/mob/living/carbon/human/H = user
		// Check for oversuit update
		for (var/acc_slot in attached_accessories)
			var/obj/item/clothing/accessory/accessory = attached_accessories[acc_slot]
			if (accessory.above_suit)
				H.update_worn_oversuit()
				break

/obj/item/clothing/under/update_overlays()
	. = ..()
	var/list/accessories = list()
	for (var/accessory_slot in attached_accessories)
		var/obj/item/clothing/accessory/accessory = attached_accessories[accessory_slot]
		BINARY_INSERT(accessory, accessories, /obj/item/clothing/accessory, accessory, accessory_layer, COMPARE_KEY)
	var/current_pixel_y = 0
	for (var/obj/item/clothing/accessory/accessory in accessories)
		if (!accessory.icon_state)
			continue
		// Copy the appearance
		var/mutable_appearance/accessory_appearance = mutable_appearance()
		accessory_appearance.appearance = accessory.appearance
		if (accessory.minimize_when_attached)
			accessory_appearance.transform *= 0.5
			accessory_appearance.pixel_x += 8
			accessory_appearance.pixel_y -= 8 - 8 * current_pixel_y
			current_pixel_y ++
		. += accessory_appearance

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_ICLOTHING && freshly_laundered)
		freshly_laundered = FALSE
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)
	// If we have an accessory, trigger equipepd behaviour
	if (slot & slot_flags)
		for (var/acc_slot in attached_accessories)
			var/obj/item/clothing/accessory/accessory = attached_accessories[acc_slot]
			accessory.on_uniform_equip(src, user)

/obj/item/clothing/under/dropped(mob/user)
	..()
	var/mob/living/carbon/human/H = user
	var/needs_visual_update = FALSE
	for (var/acc_slot in attached_accessories)
		var/obj/item/clothing/accessory/accessory = attached_accessories[acc_slot]
		accessory.on_uniform_dropped(src, user)
		if (accessory.above_suit)
			needs_visual_update = TRUE
	if(ishuman(H) && needs_visual_update)
		H.update_worn_oversuit()

	if(ishuman(H) || ismonkey(H))
		if(H.w_uniform == src)
			if(!HAS_TRAIT(user, TRAIT_SUIT_SENSORS))
				return
			REMOVE_TRAIT(user, TRAIT_SUIT_SENSORS, TRAIT_TRACKED_SENSORS)
			if(!HAS_TRAIT(user, TRAIT_SUIT_SENSORS) && !HAS_TRAIT(user, TRAIT_NANITE_SENSORS))
				GLOB.suit_sensors_list -= user

/obj/item/clothing/under/proc/attach_accessory(obj/item/I, mob/user, notifyAttach = 1)
	. = FALSE
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/attached_accessory = I
		if(!attached_accessory.can_attach_accessory(src, user, FALSE)) //Make sure the suit has a place to put the accessory.
			return
		if(user && !user.temporarilyRemoveItemFromInventory(I))
			return
		if(!attached_accessory.attach(src, user))
			return

		if(user && notifyAttach)
			to_chat(user, span_notice("You attach [I] to [src]."))

		update_accessory_overlays()

		return TRUE

/obj/item/clothing/under/proc/update_accessory_overlays()
	if (accessory_overlay_over)
		accessory_overlay_over.overlays.Cut()
	if (accessory_overlay_under)
		accessory_overlay_under.overlays.Cut()
	// Populate overlays
	for (var/accessory_slot in attached_accessories)
		var/obj/item/clothing/accessory/accessory = attached_accessories[accessory_slot]
		var/accessory_icon = accessory.icon_state
		if (!accessory_icon)
			continue
		var/mutable_appearance/accessory_overlay = mutable_appearance('icons/mob/accessories.dmi', "[accessory_icon]")
		accessory_overlay.alpha = accessory.alpha
		accessory_overlay.color = accessory.color
		accessory_overlay.layer = FLOAT_PLANE + accessory.accessory_layer
		if (accessory.above_suit)
			if (!accessory_overlay_over)
				accessory_overlay_over = mutable_appearance()
				accessory_overlay_over.appearance_flags |= RESET_COLOR
			accessory_overlay_over.overlays += accessory_overlay
		else
			if (!accessory_overlay_under)
				accessory_overlay_under = mutable_appearance()
				accessory_overlay_under.appearance_flags |= RESET_COLOR
			accessory_overlay_under.overlays += accessory_overlay
	if (accessory_overlay_over && !length(accessory_overlay_over.overlays))
		accessory_overlay_over = null
	if (accessory_overlay_under && !length(accessory_overlay_under.overlays))
		accessory_overlay_under = null
	// Update if necessary
	if (ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_worn_undersuit()
		H.update_worn_oversuit()
	if(ismonkey(loc))
		var/mob/living/carbon/human/species/monkey/H = loc
		H.update_worn_undersuit()

/obj/item/clothing/under/proc/remove_accessory(mob/user)
	if(!isliving(user))
		return
	if(!can_use(user))
		return

	var/obj/item/clothing/accessory/attached_accessory = attached_accessories[attached_accessories[1]]

	if (length(attached_accessories) > 1)
		var/list/options = list()
		for (var/accessory_slot in attached_accessories)
			var/obj/item/clothing/accessory/accessory = attached_accessories[accessory_slot]
			options[accessory.name] = accessory
		var/result = tgui_input_list(user, "Which accessory would you like to remove?", "Remove Accessory", options)
		if (!result)
			return
		if(!isliving(user))
			return
		if(!can_use(user))
			return
		attached_accessory = options[result]
	if (!attached_accessory)
		return

	attached_accessory.detach(src, user)
	if(user.put_in_hands(attached_accessory))
		to_chat(user, span_notice("You detach [attached_accessory] from [src]."))
	else
		to_chat(user, span_notice("You detach [attached_accessory] from [src] and it falls on the floor."))

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
		ADD_TRAIT(loc, TRAIT_SUIT_SENSORS, TRAIT_TRACKED_SENSORS)
		if(!HAS_TRAIT(loc, TRAIT_NANITE_SENSORS))
			GLOB.suit_sensors_list += loc
	else
		if(!HAS_TRAIT(loc, TRAIT_SUIT_SENSORS))
			return
		REMOVE_TRAIT(loc, TRAIT_SUIT_SENSORS, TRAIT_TRACKED_SENSORS)
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
	var/mob/living/carbon/human/wearer = istype(loc, /mob/living/carbon/human) ? loc : null
	for (var/accessory_slot in attached_accessories)
		var/obj/item/clothing/accessory/accessory = attached_accessories[accessory_slot]
		// Hidden accessories do not show, unless the examiner is the person wearing it
		if (wearer != user && accessory.hidden)
			continue
		// Accessories that are below a suit hiding them do not show
		if (wearer != user && !accessory.above_suit && wearer && wearer.wear_suit && (wearer.wear_suit.body_parts_covered & accessory.attachment_slot))
			continue
		. += "It has \A [accessory] is attached to it's [LOWER_TEXT(accessory_slot)]."

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/attack_hand(mob/user, list/modifiers)
	for (var/accessory_slot in attached_accessories)
		var/obj/item/clothing/accessory/attached_accessory = attached_accessories[accessory_slot]
		if(attached_accessory && ispath(attached_accessory.atom_storage) && loc == user)
			attached_accessory.attack_hand(user)
			return
	..()

/obj/item/clothing/under/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	if(length(attached_accessories))
		remove_accessory(user)
	else
		rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		to_chat(usr, span_warning("You cannot wear this suit any differently!"))
		return
	if(toggle_jumpsuit_adjust())
		to_chat(usr, span_notice("You adjust the suit to wear it more casually."))
	else
		to_chat(usr, span_notice("You adjust the suit back to normal."))
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_worn_undersuit()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	if(adjusted == DIGITIGRADE_STYLE)
		return
	adjusted = !adjusted
	if(adjusted)
		envirosealed = FALSE
		if(female_sprite_flags != FEMALE_UNIFORM_TOP_ONLY)
			female_sprite_flags = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted
			body_parts_covered &= ~CHEST
			body_parts_covered &= ~ARMS
	else
		female_sprite_flags = initial(female_sprite_flags)
		envirosealed = initial(envirosealed)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
			body_parts_covered |= ARMS
			if(!LAZYLEN(damage_by_parts))
				return adjusted
			for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) // ugly check to make sure we don't reenable protection on a disabled part
				if(damage_by_parts[zone] > limb_integrity)
					body_parts_covered &= body_zone2cover_flags(zone)
	return adjusted

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/compile_monkey_icon()
	var/identity = "[type]_[icon_state]" //Allows using multiple icon states for piece of clothing
	//If the icon, for this type of clothing, is already made by something else, don't make it again
	if(GLOB.monkey_icon_cache[identity])
		monkey_icon = GLOB.monkey_icon_cache[identity]
		return

	//Start with a base and align it with the mask
	var/icon/base = icon('icons/mob/clothing/under/default.dmi', icon_state, SOUTH) //This takes the icon and uses the worn version of the icon
	var/icon/back = icon('icons/mob/clothing/under/default.dmi', icon_state, NORTH) //Awkard but, we have to manually insert the back
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

/obj/item/clothing/under/on_start_stripping(mob/source, mob/user, item_slot)
	if(!iscarbon(user))
		return FALSE

	var/mob/living/carbon/source_pocket = source
	var/obj/item/pocket_item = source_pocket.get_item_by_slot(ITEM_SLOT_LPOCKET)

	if(pocket_item && pocket_item.on_start_stripping(source, user, ITEM_SLOT_ICLOTHING))
		return TRUE

	pocket_item = source_pocket.get_item_by_slot(ITEM_SLOT_RPOCKET)
	if(pocket_item && pocket_item.on_start_stripping(source, user, ITEM_SLOT_ICLOTHING))
		return TRUE

	return FALSE

/obj/item/clothing/under/examine_worn_title(mob/living/wearer, mob/user, skip_examine_link = FALSE)
	var/mob/living/carbon/human/human_wearer = istype(wearer, /mob/living/carbon/human) ? wearer : null
	//accessory
	var/accessory_message = ""
	var/list/accessories = list()
	for (var/accessory_slot in attached_accessories)
		var/obj/item/clothing/accessory/accessory = attached_accessories[accessory_slot]
		// Hidden accessories do not show, unless the examiner is the person wearing it
		if (accessory.hidden && wearer != user)
			continue
		// Accessories that are below a suit hiding them do not show
		if (wearer != user && !accessory.above_suit && human_wearer && human_wearer.wear_suit && (human_wearer.wear_suit.body_parts_covered & accessory.attachment_slot))
			continue
		accessories += accessory.examine_worn_title(wearer, user)
	if (length(accessories))
		accessory_message += " with [english_list(accessories)]"
	return "[..()][accessory_message]"
