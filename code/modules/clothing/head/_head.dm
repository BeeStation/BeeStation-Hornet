/obj/item/clothing/head
	name = BODY_ZONE_HEAD
	icon = 'icons/obj/clothing/head/default.dmi'
	worn_icon = 'icons/mob/clothing/head/default.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	///Is the person wearing this trackable by the AI?
	var/blockTracking = FALSE

///Special throw_impact for hats to frisbee hats at people to place them on their heads/attempt to de-hat them.
/obj/item/clothing/head/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	///if the thrown object is caught
	if(..())
		return
	///if the thrown object's target zone isn't the head
	if(!thrownthing || thrownthing.target_zone != BODY_ZONE_HEAD)
		return
	///ignore any hats with special effects that prevent removal ie tinfoil hats
	if(clothing_flags & EFFECT_HAT)
		return
	///if the hat happens to be capable of holding contents and has something in it. mostly to prevent super cheesy stuff like stuffing a mini-bomb in a hat and throwing it
	if(length(contents))
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/H = hit_atom
		if(isclothing(H.head))
			var/obj/item/clothing/WH = H.head
			///check if the item has NODROP
			if(HAS_TRAIT(WH, TRAIT_NODROP))
				H.visible_message(span_warning("[src] bounces off [H]'s [WH.name]!"), span_warning("[src] bounces off your [WH.name], falling to the floor."))
				return
			///check if the item is an actual clothing head item, since some non-clothing items can be worn
			if(istype(WH, /obj/item/clothing/head))
				var/obj/item/clothing/head/WHH = WH
				///SNUG_FIT hats are immune to being knocked off
				if(WHH.clothing_flags & SNUG_FIT)
					H.visible_message(span_warning("[src] bounces off [H]'s [WHH.name]!"), span_warning("[src] bounces off your [WHH.name], falling to the floor."))
					return
			///if the hat manages to knock something off
			if(H.dropItemToGround(WH))
				H.visible_message(span_warning("[src] knocks [WH] off [H]'s head!"), span_warning("[WH] is suddenly knocked off your head by [src]!"))
		if(H.equip_to_slot_if_possible(src, ITEM_SLOT_HEAD, 0, 1, 1))
			H.visible_message(span_notice("[src] lands neatly on [H]'s head!"), span_notice("[src] lands perfectly onto your head!"))
		return
	if(iscyborg(hit_atom))
		var/mob/living/silicon/robot/R = hit_atom
		///hats in the borg's blacklist bounce off
		if(is_type_in_typecache(src, R.blacklisted_hats))
			R.visible_message(span_warning("[src] bounces off [R]!"), span_warning("[src] bounces off you, falling to the floor."))
			return
		else
			R.visible_message(span_notice("[src] lands neatly on top of [R]"), span_notice("[src] lands perfectly on top of you."))
			R.place_on_head(src) //hats aren't designed to snugly fit borg heads or w/e so they'll always manage to knock eachother off

/obj/item/clothing/head/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedhelmet", item_layer)
		if(GET_ATOM_BLOOD_DNA_LENGTH(src))
			var/mutable_appearance/bloody_helmet = mutable_appearance('icons/effects/blood.dmi', "helmetblood", item_layer)
			bloody_helmet.color = get_blood_dna_color(GET_ATOM_BLOOD_DNA(src))
			. += bloody_helmet

/obj/item/clothing/head/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_head()

/obj/item/clothing/head/compile_monkey_icon()
	var/identity = "[type]_[icon_state]" //Allows using multiple icon states for piece of clothing
	//If the icon, for this type of item, is already made by something else, don't make it again
	if(GLOB.monkey_icon_cache[identity])
		monkey_icon = GLOB.monkey_icon_cache[identity]
		return

	//Start with two sides for the front
	var/icon/main = icon('icons/mob/clothing/head/default.dmi', icon_state) //This takes the icon and uses the worn version of the icon
	var/icon/sub = icon('icons/mob/clothing/head/default.dmi', icon_state)

	//merge the sub side with the main, after masking off the middle pixel line
	var/icon/mask = new('icons/mob/monkey.dmi', "monkey_mask_right") //masking
	main.AddAlphaMask(mask)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	sub.AddAlphaMask(mask)
	sub.Shift(EAST, 1)
	main.Blend(sub, ICON_OVERLAY)

	//handle side icons
	sub = icon('icons/mob/clothing/head/default.dmi', icon_state, dir = EAST)
	main.Insert(sub, dir = EAST)
	sub.Flip(WEST)
	main.Insert(sub, dir = WEST)

	//Mix in GAG color
	if(greyscale_colors)
		main.Blend(greyscale_colors, ICON_MULTIPLY)

	//Finished
	monkey_icon = main
	GLOB.monkey_icon_cache[identity] = icon(monkey_icon)
