//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying_angle != lying_prev && rotate_on_lying)
		changed++
		ntransform.TurnTo(lying_prev , lying_angle)
		if(!lying_angle) //Lying to standing
			final_pixel_y = base_pixel_y
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = base_pixel_y
				final_pixel_y = base_pixel_y + PIXEL_Y_OFFSET_LYING
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		SEND_SIGNAL(src, COMSIG_PAUSE_FLOATING_ANIM, 0.3 SECONDS)
		animate(src, transform = ntransform, time = (lying_prev == 0 || lying_angle == 0) ? 2 : 0, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))
	UPDATE_OO_IF_PRESENT

/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)

/mob/living/carbon/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null
		return TRUE
	return FALSE

/mob/living/carbon/regenerate_icons()
	if(notransform)
		return 1
	update_inv_hands()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_fire()


/mob/living/carbon/update_inv_hands()
	remove_overlay(HANDS_LAYER)
	if (handcuffed)
		drop_all_held_items()
		return

	var/list/hands = list()
	for(var/obj/item/I in held_items)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			if(observers?.len)
				for(var/M in observers)
					var/mob/dead/observe = M
					if(observe.client && observe.client.eye == src)
						observe.client.screen += I
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/icon_file = I.lefthand_file
		if(get_held_index_of_item(I) % 2 == 0)
			icon_file = I.righthand_file

		hands += I.build_worn_icon(src, default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)


/mob/living/carbon/update_fire(var/fire_icon = "Generic_mob_burning")
	remove_overlay(FIRE_LAYER)
	if(on_fire || islava(loc))
		var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', fire_icon, -FIRE_LAYER)
		new_fire_overlay.appearance_flags = RESET_COLOR
		overlays_standing[FIRE_LAYER] = new_fire_overlay

	apply_overlay(FIRE_LAYER)

/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/mutable_appearance/damage_overlay = mutable_appearance('icons/mob/dam_mob.dmi', "blank", CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER))
	overlays_standing[DAMAGE_LAYER] = damage_overlay

	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.dmg_overlay_type && !BP.is_husked)
			if(BP.brutestate)
				damage_overlay.add_overlay("[BP.dmg_overlay_type]_[BP.body_zone]_[BP.brutestate]0")	//we're adding icon_states of the base image as overlays
			if(BP.burnstate)
				damage_overlay.add_overlay("[BP.dmg_overlay_type]_[BP.body_zone]_0[BP.burnstate]")

	apply_overlay(DAMAGE_LAYER)


/mob/living/carbon/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_icon()

	if(wear_mask)
		if(!(check_obscured_slots() & ITEM_SLOT_MASK))
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(src, default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/clothing/mask.dmi')
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_inv_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_icon()

	if(wear_neck)
		if(!(check_obscured_slots() & ITEM_SLOT_NECK))
			overlays_standing[NECK_LAYER] = wear_neck.build_worn_icon(src, default_layer = NECK_LAYER, default_icon_file = 'icons/mob/clothing/neck.dmi')
		update_hud_neck(wear_neck)

	apply_overlay(NECK_LAYER)

/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_icon()

	if(back)
		overlays_standing[BACK_LAYER] = back.build_worn_icon(src, default_layer = BACK_LAYER, default_icon_file = 'icons/mob/clothing/back.dmi')
		update_hud_back(back)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_icon()

	if(head)
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)

/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[HANDCUFF_LAYER] = mutable_appearance('icons/mob/mob.dmi', "handcuff1", CALCULATE_MOB_OVERLAY_LAYER(HANDCUFF_LAYER))
		apply_overlay(HANDCUFF_LAYER)


//mob HUD updates for items in our inventory

//update whether handcuffs appears on our hud.
/mob/living/carbon/proc/update_hud_handcuffed()
	if(hud_used)
		for(var/hand in hud_used.hand_slots)
			var/atom/movable/screen/inventory/hand/H = hud_used.hand_slots[hand]
			if(H)
				H.update_icon()

//update whether our head item appears on our hud.
/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

//update whether our mask item appears on our hud.
/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

//update whether our neck item appears on our hud.
/mob/living/carbon/proc/update_hud_neck(obj/item/I)
	return

//update whether our back item appears on our hud.
/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return



//Overlays for the worn overlay so you can overlay while you overlay
//eg: ammo counters, primed grenade flashing, etc.
//"icon_file" is used automatically for inhands etc. to make sure it gets the right inhand file
//Clothing layer is the layer that clothing would usually appear on
/obj/item/proc/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = list()


/mob/living/carbon/update_body()
	update_body_parts()

/mob/living/carbon/proc/update_body_parts(var/update_limb_data)
	//Check the cache to see if it needs a new sprite
	update_damage_overlays()
	var/list/needs_update = list()
	var/limb_count_update = FALSE
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		BP.update_limb(is_creating = update_limb_data) //Update limb actually doesn't do much, get_limb_icon is the cpu eater.
		var/old_key = icon_render_keys?[BP.body_zone]
		icon_render_keys[BP.body_zone] = (BP.is_husked) ? BP.generate_husk_key().Join() : BP.generate_icon_key().Join()
		if(!(icon_render_keys[BP.body_zone] == old_key))
			needs_update += BP


	var/list/missing_bodyparts = get_missing_limbs()
	if(((dna ? dna.species.max_bodypart_count : 6) - icon_render_keys.len) != missing_bodyparts.len)
		limb_count_update = TRUE
		for(var/X in missing_bodyparts)
			icon_render_keys -= X

	if(!needs_update.len && !limb_count_update)
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		if(BP in needs_update)
			var/bp_icon = BP.get_limb_icon()
			new_limbs += bp_icon
			limb_icon_cache[icon_render_keys[BP.body_zone]] = bp_icon
		else
			new_limbs += limb_icon_cache[icon_render_keys[BP.body_zone]]

	remove_overlay(BODYPARTS_LAYER)

	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs

	apply_overlay(BODYPARTS_LAYER)


/////////////////////////
// Limb Icon Cache 2.0 //
/////////////////////////
//Updated by Kapu#1178
/*
	Called from update_body_parts() these procs handle the limb icon cache.
	the limb icon cache adds an icon_render_key to a human mob, it represents:
	- Gender, if applicable
	- The ID of the limb
	- Draw color, if applicable
	These procs only store limbs as to increase the number of matching icon_render_keys
	This cache exists because drawing 6/7 icons for humans constantly is quite a waste
	See RemieRichards on irc.rizon.net #coderbus (RIP remie :sob:)
*/
/obj/item/bodypart/proc/generate_icon_key()
	RETURN_TYPE(/list)
	. = list()
	if(is_dimorphic)
		. += "[limb_gender]-"
	. += "[limb_id]"
	. += "-[body_zone]"
	if(should_draw_greyscale && draw_color)
		. += "-[draw_color]"

	return .

/obj/item/bodypart/proc/generate_husk_key()
	RETURN_TYPE(/list)
	. = list()
	. += "[husk_type]"
	. += "-husk"
	. += "-[body_zone]"
	return .

GLOBAL_LIST_EMPTY(masked_leg_icons_cache)

/obj/item/bodypart/leg/proc/generate_masked_leg(mutable_appearance/limb_overlay, image_dir = NONE)
	RETURN_TYPE(/list)
	if(!limb_overlay)
		return
	. = list()

	var/icon_cache_key = "[limb_overlay.icon]-[limb_overlay.icon_state]-[body_zone]"
	var/icon/new_leg_icon
	var/icon/new_leg_icon_lower

	//in case we do not have a cached version of the two cropped icons for this key, we have to create it
	if(!GLOB.masked_leg_icons_cache[icon_cache_key])
		var/icon/leg_crop_mask = (body_zone == BODY_ZONE_R_LEG ? icon('icons/mob/leg_masks.dmi', "right_leg") : icon('icons/mob/leg_masks.dmi', "left_leg"))
		var/icon/leg_crop_mask_lower = (body_zone == BODY_ZONE_R_LEG ? icon('icons/mob/leg_masks.dmi', "right_leg_lower") : icon('icons/mob/leg_masks.dmi', "left_leg_lower"))

		new_leg_icon = icon(limb_overlay.icon, limb_overlay.icon_state)
		new_leg_icon.Blend(leg_crop_mask, ICON_MULTIPLY)

		new_leg_icon_lower = icon(limb_overlay.icon, limb_overlay.icon_state)
		new_leg_icon_lower.Blend(leg_crop_mask_lower, ICON_MULTIPLY)

		GLOB.masked_leg_icons_cache[icon_cache_key] = list(new_leg_icon, new_leg_icon_lower)
	new_leg_icon = GLOB.masked_leg_icons_cache[icon_cache_key][1]
	new_leg_icon_lower = GLOB.masked_leg_icons_cache[icon_cache_key][2]

	//this could break layering in oddjob cases, but i'm sure it will work fine most of the time... right?
	var/mutable_appearance/new_leg_appearance = new(limb_overlay)
	new_leg_appearance.icon = new_leg_icon
	new_leg_appearance.layer = -BODYPARTS_LAYER
	new_leg_appearance.dir = image_dir //for some reason, things do not work properly otherwise
	. += new_leg_appearance
	var/mutable_appearance/new_leg_appearance_lower = new(limb_overlay)
	new_leg_appearance_lower.icon = new_leg_icon_lower
	new_leg_appearance_lower.layer = -BODYPARTS_LOW_LAYER
	new_leg_appearance_lower.dir = image_dir
	. += new_leg_appearance_lower
	return .
