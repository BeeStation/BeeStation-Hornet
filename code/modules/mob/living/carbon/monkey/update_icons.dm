
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
		if(!get_organ_by_type(/obj/item/organ/brain)) //Applies the debrained overlay if there is no brain
			overlays_standing[HAIR_LAYER] = mutable_appearance('icons/mob/human_face.dmi', "debrained", CALCULATE_MOB_OVERLAY_LAYER(HAIR_LAYER))
			apply_overlay(HAIR_LAYER)


/mob/living/carbon/monkey/update_fire()
	..("Monkey_burning")

/mob/living/carbon/monkey/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	if(legcuffed)
		var/mutable_appearance/legcuff_overlay = mutable_appearance('icons/mob/mob.dmi', "legcuff1", CALCULATE_MOB_OVERLAY_LAYER(LEGCUFF_LAYER))
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
	update_clothing_icons(UNIFORM_LAYER)

/mob/living/carbon/monkey/update_inv_head()
	update_clothing_icons(HEAD_LAYER)

/mob/living/carbon/monkey/update_inv_back()
	update_clothing_icons(BACK_LAYER)

/mob/living/carbon/monkey/update_inv_wear_mask()
	update_clothing_icons(FACEMASK_LAYER)

//used to handle monkey clothing
/mob/living/carbon/monkey/proc/update_clothing_icons(c_layer)
	///Item slot
	var/slot
	///Species offset feature
	var/offset
	///Actual item being worn
	var/obj/item/U
	//UI location
	var/ui
	switch(c_layer)
		if(FACEMASK_LAYER)
			slot = ITEM_SLOT_MASK
			offset = OFFSET_FACEMASK
			U = wear_mask
			ui = ui_monkey_mask
		if(BACK_LAYER)
			slot = ITEM_SLOT_BACK
			offset = OFFSET_BACK
			U = back
			ui = ui_monkey_back
		if(HEAD_LAYER)
			slot = ITEM_SLOT_HEAD
			offset = OFFSET_HEAD
			U = head
			ui = ui_monkey_head
		if(UNIFORM_LAYER)
			slot = ITEM_SLOT_ICLOTHING
			offset = OFFSET_UNIFORM
			U = w_uniform
			ui = ui_monkey_body

	remove_overlay(c_layer)

	if(client && hud_used.hud_shown)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(slot) + 1]
		inv.update_icon()
		client.screen += U

	if(U)
		U.screen_loc = ui
		var/mutable_appearance/cloth_overlay = mutable_appearance(U.monkey_icon, layer = -c_layer)
		if(offset in dna.species.offset_features)
			cloth_overlay.pixel_x += dna.species.offset_features[offset][1]
			cloth_overlay.pixel_y += dna.species.offset_features[offset][2]
		overlays_standing[c_layer] = cloth_overlay

	apply_overlay(c_layer)
