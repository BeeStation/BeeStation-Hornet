//IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/changed = 0
	if(lying != lying_prev && rotate_on_lying)
		changed++
		ntransform.TurnTo(lying_prev , lying)
		if(!lying) //Lying to standing
			final_pixel_y = get_standard_pixel_y_offset()
		else //if(lying != 0)
			if(lying_prev == 0) //Standing to lying
				pixel_y = get_standard_pixel_y_offset()
				final_pixel_y = get_standard_pixel_y_offset(lying)
				if(dir & (EAST|WEST)) //Facing east or west
					final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = (lying_prev == 0 || !lying) ? 2 : 0, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))
		setMovetype(movement_type & ~FLOATING)  // If we were without gravity, the bouncing animation got stopped, so we make sure we restart it in next life().

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

		hands += I.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)

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

	var/mutable_appearance/damage_overlay = mutable_appearance('icons/mob/dam_mob.dmi', "blank", -DAMAGE_LAYER)
	overlays_standing[DAMAGE_LAYER] = damage_overlay

	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.dmg_overlay_type)
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
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/mask.dmi')
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_inv_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_icon()

	if(wear_neck)
		if(!(check_obscured_slots() & ITEM_SLOT_NECK))
			overlays_standing[NECK_LAYER] = wear_neck.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = 'icons/mob/neck.dmi')
		update_hud_neck(wear_neck)

	apply_overlay(NECK_LAYER)

/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_icon()

	if(back)
		overlays_standing[BACK_LAYER] = back.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = 'icons/mob/back.dmi')
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
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/head.dmi')
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[HANDCUFF_LAYER] = mutable_appearance('icons/mob/mob.dmi', "handcuff1", -HANDCUFF_LAYER)
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
/obj/item/proc/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = list()


/mob/living/carbon/update_body()
	update_body_parts()

/mob/living/carbon/proc/update_body_parts(var/update_limb_data)
	//Check the cache to see if it needs a new sprite
	update_damage_overlays()
	var/list/needs_update = list()
	var/limb_count_update = FALSE
	for(var/obj/item/bodypart/BP as() in bodyparts)
		BP.update_limb(is_creating = update_limb_data) //Update limb actually doesn't do much, get_limb_icon is the cpu eater.
		var/old_key = icon_render_keys?[BP.body_zone]
		icon_render_keys[BP.body_zone] = (BP.is_husked) ? generate_husk_key(BP) : generate_icon_key(BP)
		if(!(icon_render_keys[BP.body_zone] == old_key))
			needs_update += BP


	var/list/missing_bodyparts = get_missing_limbs()
	if(((dna ? dna.species.max_bodypart_count : 6) - icon_render_keys.len) != missing_bodyparts.len)
		limb_count_update = TRUE
		for(var/X in missing_bodyparts)
			icon_render_keys -= X

	if(!needs_update.len && !limb_count_update)
		return

	remove_overlay(BODYPARTS_LAYER)


	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP in needs_update)
			var/bp_icon = BP.get_limb_icon()
			new_limbs += bp_icon
			limb_icon_cache[icon_render_keys[BP.body_zone]] = bp_icon
		else
			new_limbs += limb_icon_cache[icon_render_keys[BP.body_zone]]

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
/mob/living/carbon/proc/generate_icon_key(obj/item/bodypart/BP)
	if(BP.is_dimorphic)
		. += "[BP.limb_gender]-"
	. += "[BP.limb_id]"
	. += "-[BP.body_zone]"
	if(BP.should_draw_greyscale && BP.draw_color)
		. += "-[BP.draw_color]"

/mob/living/carbon/proc/generate_husk_key(obj/item/bodypart/BP)
	. += "[BP.husk_type]"
	. += "-husk"
	. += "-[BP.body_zone]"
