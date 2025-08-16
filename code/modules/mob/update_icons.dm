//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

/mob/proc/regenerate_icons()		//TODO: phase this out completely if possible
	return

/mob/proc/update_clothing(slot_flags)
	return

/mob/proc/update_icons()
	return

///Updates item slots obscured by this item (or using an override of flags to check)
/mob/proc/update_obscured_slots(obscured_flags)
	if(obscured_flags & HIDEGLOVES)
		update_inv_gloves(update_obscured = FALSE)
	if(obscured_flags & HIDESUITSTORAGE)
		update_inv_s_store(update_obscured = FALSE)
	if(obscured_flags & HIDEJUMPSUIT)
		update_inv_w_uniform(update_obscured = FALSE)
	if(obscured_flags & HIDESHOES)
		update_inv_shoes(update_obscured = FALSE)
	if(obscured_flags & HIDEMASK)
		update_inv_wear_mask(update_obscured = FALSE)
	if(obscured_flags & HIDEBELT)
		update_inv_belt(update_obscured = FALSE)
	if(obscured_flags & HIDEEARS)
		update_inv_ears(update_obscured = FALSE)
	if(obscured_flags & HIDEEYES)
		update_inv_glasses(update_obscured = FALSE)
	if(obscured_flags & HIDENECK)
		update_inv_neck(update_obscured = FALSE)
	if(obscured_flags & HIDEHEADGEAR)
		update_inv_head(update_obscured = FALSE)

/mob/proc/update_transform()
	return

/mob/proc/update_inv_handcuffed(update_obscured = FALSE)
	return

/mob/proc/update_inv_legcuffed(update_obscured = FALSE)
	return

/mob/proc/update_inv_back(update_obscured = FALSE)
	return

/mob/proc/update_inv_hands()
	return

/mob/proc/update_inv_wear_mask(update_obscured = FALSE)
	return

/mob/proc/update_inv_neck(update_obscured = FALSE)
	return

/mob/proc/update_inv_wear_suit(update_obscured = FALSE)
	return

/mob/proc/update_inv_w_uniform(update_obscured = FALSE)
	return

/mob/proc/update_inv_belt(update_obscured = FALSE)
	return

/mob/proc/update_inv_head(update_obscured = FALSE)
	return

/mob/proc/update_body()
	return

/mob/proc/update_hair()
	return

/mob/proc/update_fire()
	return

/mob/proc/update_inv_glasses(update_obscured = FALSE)
	return

/mob/proc/update_inv_wear_id(update_obscured = FALSE)
	return

/mob/proc/update_inv_shoes(update_obscured = FALSE)
	return

/mob/proc/update_inv_gloves(update_obscured = FALSE)
	return

/mob/proc/update_inv_s_store(update_obscured = FALSE)
	return

/mob/proc/update_inv_pockets()
	return

/mob/proc/update_inv_ears(update_obscured = FALSE)
	return
