
/mob/living/carbon/monkey/regenerate_icons()
	if(!..())
		update_body_parts(TRUE)
		update_hair()
		update_inv_wear_mask()
		update_inv_head()
		update_inv_back()
		update_transform()
		update_inv_w_uniform()

////////


/mob/living/carbon/monkey/update_hair()
	remove_overlay(HAIR_LAYER)

	var/obj/item/bodypart/head/HD = get_bodypart(BODY_ZONE_HEAD)
	if(!HD) //Decapitated
		return

	if(HAS_TRAIT(src, TRAIT_HUSK))
		return

	var/hair_hidden = 0

	if(head)
		var/obj/item/I = head
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = 1
	if(wear_mask)
		var/obj/item/clothing/mask/M = wear_mask
		if(M.flags_inv & HIDEHAIR)
			hair_hidden = 1
	if(!hair_hidden)
		if(!getorgan(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			overlays_standing[HAIR_LAYER] = mutable_appearance('icons/mob/human_face.dmi', "debrained", -HAIR_LAYER)
			apply_overlay(HAIR_LAYER)


/mob/living/carbon/monkey/update_fire()
	..("Monkey_burning")

/mob/living/carbon/monkey/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	if(legcuffed)
		var/mutable_appearance/legcuff_overlay = mutable_appearance('icons/mob/mob.dmi', "legcuff1", -LEGCUFF_LAYER)
		legcuff_overlay.pixel_y = 8
		overlays_standing[LEGCUFF_LAYER] = legcuff_overlay
	apply_overlay(LEGCUFF_LAYER)


//monkey HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/monkey/update_hud_head(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_head
		client.screen += I

//update whether our mask item appears on our hud.
/mob/living/carbon/monkey/update_hud_wear_mask(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_mask
		client.screen += I

//update whether our neck item appears on our hud.
/mob/living/carbon/monkey/update_hud_neck(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_neck
		client.screen += I

//update whether our back item appears on our hud.
/mob/living/carbon/monkey/update_hud_back(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_back
		client.screen += I
		
//Update uniform in compliance with monkey icons
/mob/living/carbon/monkey/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ICLOTHING) + 1]
		inv.update_icon()

	if(istype(w_uniform, /obj/item/clothing/under) && client && hud_used.hud_shown)
		var/obj/item/clothing/under/U = w_uniform
		U.screen_loc = ui_monkey_body
		client.screen += w_uniform

		var/mutable_appearance/uniform_overlay = mutable_appearance(U.monkey_icon, layer = -UNIFORM_LAYER)
		if(OFFSET_UNIFORM in dna.species.offset_features)
			uniform_overlay.pixel_x += dna.species.offset_features[OFFSET_UNIFORM][1]
			uniform_overlay.pixel_y += dna.species.offset_features[OFFSET_UNIFORM][2]
		overlays_standing[UNIFORM_LAYER] = uniform_overlay

	apply_overlay(UNIFORM_LAYER)

/mob/living/carbon/monkey/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_HEAD) + 1]
		inv.update_icon()

	if(istype(head, /obj/item/clothing/head) && client && hud_used.hud_shown)
		var/obj/item/clothing/head/U = head
		U.screen_loc = ui_monkey_head
		client.screen += head

		var/mutable_appearance/head_overlay = mutable_appearance(U.monkey_icon, layer = -HEAD_LAYER)
		if(OFFSET_HEAD in dna.species.offset_features)
			head_overlay.pixel_x += dna.species.offset_features[OFFSET_HEAD][1]
			head_overlay.pixel_y += dna.species.offset_features[OFFSET_HEAD][2]
		overlays_standing[HEAD_LAYER] = head_overlay

	apply_overlay(HEAD_LAYER)

/mob/living/carbon/monkey/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BACK) + 1]
		inv.update_icon()

	if(istype(back, /obj/item/storage) && client && hud_used.hud_shown)
		var/obj/item/storage/U = back
		U.screen_loc = ui_monkey_back
		client.screen += back

		var/mutable_appearance/back_overlay = mutable_appearance(U.monkey_icon, layer = -BACK_LAYER)
		if(OFFSET_BACK in dna.species.offset_features)
			back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK][1]
			back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK][2]
		overlays_standing[BACK_LAYER] = back_overlay

	apply_overlay(BACK_LAYER)

/mob/living/carbon/monkey/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_MASK) + 1]
		inv.update_icon()

	if(istype(wear_mask, /obj/item/clothing/mask) && client && hud_used.hud_shown)
		var/obj/item/clothing/mask/U = wear_mask
		U.screen_loc = ui_monkey_mask
		client.screen += wear_mask

		var/mutable_appearance/mask_overlay = mutable_appearance(U.monkey_icon, layer = -FACEMASK_LAYER)
		if(OFFSET_FACEMASK in dna.species.offset_features)
			mask_overlay.pixel_x += dna.species.offset_features[OFFSET_FACEMASK][1]
			mask_overlay.pixel_y += dna.species.offset_features[OFFSET_FACEMASK][2]
		overlays_standing[FACEMASK_LAYER] = mask_overlay

	apply_overlay(FACEMASK_LAYER)

