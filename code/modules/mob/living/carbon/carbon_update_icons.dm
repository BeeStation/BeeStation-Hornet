
/mob/living/carbon/update_obscured_slots(obscured_flags)
	..()
	if(obscured_flags & (HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT|HIDEMUTWINGS))
		update_body()

/// Updates features and clothing attached to a specific limb with limb-specific offsets
/mob/living/carbon/proc/update_features(feature_key)
	switch(feature_key)
		if(OFFSET_UNIFORM)
			update_worn_undersuit()
		if(OFFSET_ID)
			update_worn_id()
		if(OFFSET_GLOVES)
			update_worn_gloves()
		if(OFFSET_GLASSES)
			update_worn_glasses()
		if(OFFSET_EARS)
			update_worn_ears()
		if(OFFSET_SHOES)
			update_worn_shoes()
		if(OFFSET_S_STORE)
			update_suit_storage()
		if(OFFSET_FACEMASK)
			update_worn_mask()
		if(OFFSET_HEAD)
			update_worn_head()
		if(OFFSET_FACE)
			dna?.species?.handle_body(src) // updates eye icon
			update_worn_mask()
		if(OFFSET_BELT)
			update_worn_belt()
		if(OFFSET_BACK)
			update_worn_back()
		if(OFFSET_SUIT)
			update_worn_oversuit()
		if(OFFSET_NECK)
			update_worn_neck()
		if(OFFSET_HELD)
			update_held_items()

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

/mob/living/carbon/var/list/overlays_standing[TOTAL_LAYERS]

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

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts()
	dna?.species.handle_mutant_bodyparts(src)
	update_body_parts()

/mob/living/carbon/update_body(is_creating = FALSE)
	dna?.species.handle_body(src) //This calls `handle_mutant_bodyparts` which calls `update_mutant_bodyparts()`. Don't double call!
	update_body_parts(is_creating)
	dna?.update_body_size()

/mob/living/carbon/regenerate_icons()
	if(notransform)
		return 1
	icon_render_keys = list() //Clear this bad larry out
	update_held_items()
	update_worn_handcuffs()
	update_worn_legcuffs()
	update_body()
	update_appearance(UPDATE_OVERLAYS)

/mob/living/carbon/update_held_items()
	remove_overlay(HANDS_LAYER)
	if (handcuffed)
		drop_all_held_items()
		return

	var/list/hands = list()
	for(var/obj/item/I in held_items)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			if(length(observers))
				for(var/mob/dead/observe as anything in observers)
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

/mob/living/carbon/get_fire_overlay(stacks, on_fire)
	var/fire_icon = "human_[stacks > MOB_BIG_FIRE_STACK_THRESHOLD ? "big_fire" : "small_fire"]"

	if(!GLOB.fire_appearances[fire_icon])
		GLOB.fire_appearances[fire_icon] = mutable_appearance(
			'icons/mob/effects/onfire.dmi',
			fire_icon,
			-HIGHEST_LAYER,
			appearance_flags = RESET_COLOR | KEEP_APART,
		)

	return GLOB.fire_appearances[fire_icon]

/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)

	var/mutable_appearance/damage_overlay
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		if(!iter_part.dmg_overlay_type)
			continue
		if(isnull(damage_overlay) && (iter_part.brutestate || iter_part.burnstate))
			damage_overlay = mutable_appearance('icons/mob/dam_mob.dmi', "blank", layer = CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER))
			damage_overlay.color = iter_part.damage_overlay_color
		if(iter_part.brutestate)
			var/image/brute_overlay = image('icons/mob/dam_mob.dmi', "[iter_part.dmg_overlay_type]_[iter_part.body_zone]_[iter_part.brutestate]0")
			if(iter_part.use_damage_color && !HAS_TRAIT(src, TRAIT_NOBLOOD))
				//Set damage_color to species blood color
				iter_part.damage_color = src.dna.blood_type.blood_color
				brute_overlay.color = iter_part.damage_color
			damage_overlay.add_overlay(brute_overlay)
		if(iter_part.burnstate)
			damage_overlay.add_overlay("[iter_part.dmg_overlay_type]_[iter_part.body_zone]_0[iter_part.burnstate]")

	if(isnull(damage_overlay))
		return

	overlays_standing[DAMAGE_LAYER] = damage_overlay
	apply_overlay(DAMAGE_LAYER)


/mob/living/carbon/update_worn_mask(update_obscured = TRUE)
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_icon()

	if(wear_mask)
		if(update_obscured)
			update_obscured_slots(wear_mask.flags_inv)
		if(!(check_obscured_slots() & ITEM_SLOT_MASK))
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(src, default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/clothing/mask.dmi')
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_worn_neck(update_obscured = TRUE)
	remove_overlay(NECK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_NECK) + 1]
		inv.update_icon()

	if(wear_neck)
		if(update_obscured)
			update_obscured_slots(wear_neck.flags_inv)
		if(!(check_obscured_slots() & ITEM_SLOT_NECK))
			overlays_standing[NECK_LAYER] = wear_neck.build_worn_icon(src, default_layer = NECK_LAYER, default_icon_file = 'icons/mob/clothing/neck.dmi')
		update_hud_neck(wear_neck)

	apply_overlay(NECK_LAYER)

/mob/living/carbon/update_worn_back(update_obscured = TRUE)
	remove_overlay(BACK_LAYER)

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_icon()

	if(back)
		if(update_obscured)
			update_obscured_slots(back.flags_inv)
		overlays_standing[BACK_LAYER] = back.build_worn_icon(src, default_layer = BACK_LAYER, default_icon_file = 'icons/mob/clothing/back.dmi')
		update_hud_back(back)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/update_worn_head(update_obscured = TRUE)
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used && hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_icon()

	if(head)
		if(update_obscured)
			update_obscured_slots(head.flags_inv)
		if(!(check_obscured_slots() & ITEM_SLOT_HEAD))
			overlays_standing[HEAD_LAYER] = head.build_worn_icon(src, default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_worn_handcuffs(update_obscured = TRUE)
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		if(update_obscured)
			update_obscured_slots(handcuffed.flags_inv)
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
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()
	if(blocks_emissive)
		. += emissive_blocker(standing.icon, standing.icon_state, alpha = standing.alpha)
	SEND_SIGNAL(src, COMSIG_ITEM_GET_WORN_OVERLAYS, ., standing, isinhands, icon_file)

///Checks to see if any bodyparts need to be redrawn, then does so. update_limb_data = TRUE redraws the limbs to conform to the owner.
///Returns an integer representing the number of limbs that were updated.
/mob/living/carbon/proc/update_body_parts(update_limb_data)
	//Check the cache to see if it needs a new sprite
	update_damage_overlays()
	//update_wound_overlays()
	var/list/needs_update = list()
	var/limb_count_update = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		limb.update_limb(is_creating = update_limb_data) //Update limb actually doesn't do much, get_limb_icon is the cpu eater.

		var/old_key = icon_render_keys?[limb.body_zone] //Checks the mob's icon render key list for the bodypart
		icon_render_keys[limb.body_zone] = (limb.is_husked) ? limb.generate_husk_key().Join() : limb.generate_icon_key().Join() //Generates a key for the current bodypart

		if(icon_render_keys[limb.body_zone] != old_key) //If the keys match, that means the limb doesn't need to be redrawn
			needs_update += limb

	limb_count_update += length(needs_update)
	var/list/missing_bodyparts = get_missing_limbs()
	if(((dna ? dna.species.max_bodypart_count : BODYPARTS_DEFAULT_MAXIMUM) - icon_render_keys.len) != missing_bodyparts.len) //Checks to see if the target gained or lost any limbs.
		limb_count_update += 1
		for(var/missing_limb in missing_bodyparts)
			icon_render_keys -= missing_limb //Removes dismembered limbs from the key list

	. = limb_count_update
	if(!.)
		return

	//GENERATE NEW LIMBS
	var/list/new_limbs = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(limb in needs_update) //Checks to see if the limb needs to be redrawn
			var/bodypart_icon = limb.get_limb_icon()
			new_limbs += bodypart_icon
			limb_icon_cache[icon_render_keys[limb.body_zone]] = bodypart_icon //Caches the icon with the bodypart key, as it is new
		else
			new_limbs += limb_icon_cache[icon_render_keys[limb.body_zone]] //Pulls existing sprites from the cache

	remove_overlay(BODYPARTS_LAYER)

	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs

	apply_overlay(BODYPARTS_LAYER)

/////////////////////////
// Limb Icon Cache 2.0 //
/////////////////////////
/**
 * Called from update_body_parts() these procs handle the limb icon cache.
 * the limb icon cache adds an icon_render_key to a human mob, it represents:
 * - Gender, if applicable
 * - The ID of the limb
 * - Draw color, if applicable
 * These procs only store limbs as to increase the number of matching icon_render_keys
 * This cache exists because drawing 6/7 icons for humans constantly is quite a waste
 * See RemieRichards on irc.rizon.net #coderbus (RIP remie :sob:)
**/
/obj/item/bodypart/proc/generate_icon_key()
	RETURN_TYPE(/list)
	. = list()
	if(is_dimorphic)
		. += "[limb_gender]-"
	. += "[limb_id]"
	. += "-[body_zone]"
	if(should_draw_greyscale && draw_color)
		. += "-[draw_color]"
	for(var/datum/bodypart_overlay/overlay as anything in bodypart_overlays)
		if(!overlay.can_draw_on_bodypart(src, owner))
			continue
		. += "-[jointext(overlay.generate_icon_cache(), "-")]"

	return .

///Generates a cache key specifically for husks
/obj/item/bodypart/proc/generate_husk_key()
	RETURN_TYPE(/list)
	. = list()
	. += "[limb_id]-"
	. += "[husk_type]"
	. += "-husk"
	. += "-[body_zone]"
	return .

/obj/item/bodypart/head/generate_icon_key()
	. = ..()
	if(lip_style)
		. += "-[lip_style]"
		. += "-[lip_color]"

	if(facial_hair_hidden)
		. += "-FACIAL_HAIR_HIDDEN"
	else
		. += "-[facial_hairstyle]"
		. += "-[override_hair_color || fixed_hair_color || facial_hair_color]"
		. += "-[facial_hair_alpha]"
		if(gradient_styles?[GRADIENT_FACIAL_HAIR_KEY])
			. += "-[gradient_styles[GRADIENT_FACIAL_HAIR_KEY]]"
			. += "-[gradient_colors[GRADIENT_FACIAL_HAIR_KEY]]"

	if(show_eyeless)
		. += "-SHOW_EYELESS"
	if(show_debrained)
		. += "-SHOW_DEBRAINED"
		return .

	if(hair_hidden)
		. += "-HAIR_HIDDEN"
	else
		. += "-[hairstyle]"
		. += "-[override_hair_color || fixed_hair_color || hair_color]"
		. += "-[hair_alpha]"
		if(gradient_styles?[GRADIENT_HAIR_KEY])
			. += "-[gradient_styles[GRADIENT_HAIR_KEY]]"
			. += "-[gradient_colors[GRADIENT_HAIR_KEY]]"

	return .

GLOBAL_LIST_EMPTY(masked_leg_icons_cache)

/**
 * This proc serves as a way to ensure that legs layer properly on a mob.
 * To do this, two separate images are created - A low layer one, and a normal layer one.
 * Each of the image will appropriately crop out dirs that are not used on that given layer.
 *
 * Arguments:
 * * limb_overlay - The limb image being masked, not necessarily the original limb image as it could be an overlay on top of it
 * * image_dir - Direction of the masked images.
 *
 * Returns the list of masked images, or `null` if the limb_overlay didn't exist
 */
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
	new_leg_appearance.layer = CALCULATE_MOB_OVERLAY_LAYER(BODYPARTS_LAYER)
	new_leg_appearance.dir = image_dir //for some reason, things do not work properly otherwise
	. += new_leg_appearance
	var/mutable_appearance/new_leg_appearance_lower = new(limb_overlay)
	new_leg_appearance_lower.icon = new_leg_icon_lower
	new_leg_appearance_lower.layer = CALCULATE_MOB_OVERLAY_LAYER(BODYPARTS_LOW_LAYER)
	new_leg_appearance_lower.dir = image_dir
	. += new_leg_appearance_lower
	return .
