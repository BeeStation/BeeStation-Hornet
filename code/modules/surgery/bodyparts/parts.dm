/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 200
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	plaintext_zone = "chest"
	is_dimorphic = TRUE
	px_x = 0
	px_y = 0
	stam_damage_coeff = 1
	max_stamina_damage = 120
	grind_results = null
	bodypart_trait_source = CHEST_TRAIT
	///The bodyshape(s) allowed to attach to this chest.
	var/acceptable_bodyshape = BODYSHAPE_HUMANOID
	///The bodytype(s) allowed to attach to this chest.
	var/acceptable_bodytype = ALL

	var/obj/item/cavity_item

	/// Offset to apply to equipment worn as a uniform
	var/datum/worn_feature_offset/worn_uniform_offset
	/// Offset to apply to equipment worn on the id slot
	var/datum/worn_feature_offset/worn_id_offset
	/// Offset to apply to equipment worn in the suit slot
	var/datum/worn_feature_offset/worn_suit_storage_offset
	/// Offset to apply to equipment worn on the hips
	var/datum/worn_feature_offset/worn_belt_offset
	/// Offset to apply to overlays placed on the back
	var/datum/worn_feature_offset/worn_back_offset
	/// Offset to apply to equipment worn as a suit
	var/datum/worn_feature_offset/worn_suit_offset
	/// Offset to apply to equipment worn on the neck
	var/datum/worn_feature_offset/worn_neck_offset
	/// Which functional (i.e. flightpotion) wing types (if any) does this bodypart support? If count is >1 a radial menu is used to choose between all icons in list
	var/list/wing_types = list(/obj/item/organ/wings/angel)

/obj/item/bodypart/chest/forced_removal(dismembered, special, move_to_floor)
	var/mob/living/carbon/old_owner = owner
	..(special = TRUE) //special because we're self destructing

	//If someones chest is teleported away, they die pretty hard
	if(!old_owner)
		return
	message_admins("[ADMIN_LOOKUPFLW(old_owner)] was gibbed after their chest teleport to [ADMIN_VERBOSEJMP(loc)].")
	old_owner.gib()

/obj/item/bodypart/chest/can_dismember(obj/item/I)
	if(owner.stat < HARD_CRIT || !contents.len)
		return FALSE
	return ..()

/obj/item/bodypart/chest/Destroy()
	QDEL_NULL(cavity_item)
	QDEL_NULL(worn_uniform_offset)
	QDEL_NULL(worn_id_offset)
	QDEL_NULL(worn_suit_storage_offset)
	QDEL_NULL(worn_belt_offset)
	QDEL_NULL(worn_back_offset)
	QDEL_NULL(worn_suit_offset)
	QDEL_NULL(worn_neck_offset)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user, violent_removal)
	if(cavity_item)
		cavity_item.forceMove(drop_location())
		cavity_item = null
	..()

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_static = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodyshape = BODYSHAPE_MONKEY
	acceptable_bodyshape = BODYSHAPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/chest/monkey/teratoma
	icon_state = "teratoma_chest"
	limb_id = "teratoma"

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_chest"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	is_dimorphic = FALSE //All of them are girls
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 500
	acceptable_bodyshape = BODYSHAPE_HUMANOID
	wing_types = NONE

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "larva_chest"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 50
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_LARVA_PLACEHOLDER
	wing_types = NONE

/// Parent Type for arms, should not appear in game.
/obj/item/bodypart/arm
	name = "arm"
	desc = "Hey buddy give me a HAND and report this to the github because you shouldn't be seeing this."
	attack_verb_continuous = list("slaps", "punches")
	attack_verb_simple = list("slap", "punch")
	max_damage = 50
	max_stamina_damage = 50
	aux_layer = BODYPARTS_HIGH_LAYER
	body_damage_coeff = 0.75
	can_be_disabled = TRUE
	unarmed_attack_verb = "punch" /// The classic punch, wonderfully classic and completely random
	unarmed_damage = 7
	body_zone = BODY_ZONE_L_ARM
	/// Datum describing how to offset things worn on the hands of this arm, note that an x offset won't do anything here
	var/datum/worn_feature_offset/worn_glove_offset
	/// Datum describing how to offset things held in the hands of this arm, the x offset IS functional here
	var/datum/worn_feature_offset/held_hand_offset

/obj/item/bodypart/arm/Destroy()
	QDEL_NULL(worn_glove_offset)
	QDEL_NULL(held_hand_offset)
	return ..()

/// We need to clear out hand hud items and appearance, so do that here
/obj/item/bodypart/arm/clear_ownership(mob/living/carbon/old_owner)
	..()

	old_owner.update_worn_gloves()

	if(!held_index)
		return

	old_owner.on_lost_hand(src)

	if(!old_owner.hud_used)
		return

	var/atom/movable/screen/inventory/hand/hand = old_owner.hud_used.hand_slots["[held_index]"]
	hand?.update_appearance()

/// We need to add hand hud items and appearance, so do that here
/obj/item/bodypart/arm/apply_ownership(mob/living/carbon/new_owner)
	..()

	new_owner.update_worn_gloves()

	if(!held_index)
		return

	new_owner.on_added_hand(src, held_index)

	if(!new_owner.hud_used)
		return

	var/atom/movable/screen/inventory/hand/hand = new_owner.hud_used.hand_slots["[held_index]"]
	hand.update_appearance()

/obj/item/bodypart/arm/left
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	plaintext_zone = "left arm"
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	held_index = 1
	px_x = -6
	px_y = 0

/obj/item/bodypart/arm/left/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_L_ARM))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/arm/left/clear_ownership(mob/living/carbon/old_owner)
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_ARM))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))
	..()

///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/arm/left/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/arm/left/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/arm/left/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_hands(owner.usable_hands - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("Your lose control of your [name]!"))
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(!bodypart_disabled)
		owner.set_usable_hands(owner.usable_hands + 1)

	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/hand_screen_object = owner.hud_used.hand_slots["[held_index]"]
		hand_screen_object?.update_icon()

/obj/item/bodypart/arm/left/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_arm"
	icon_static = 'icons/mob/animal_parts.dmi'
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage = 3

/obj/item/bodypart/arm/left/monkey/teratoma
	icon_state = "teratoma_l_arm"

/obj/item/bodypart/arm/left/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_l_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	plaintext_zone = "right arm"
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = BODYPARTS_HIGH_LAYER
	held_index = 2
	px_x = 6
	px_y = 0

/obj/item/bodypart/arm/right/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_R_ARM))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/arm/right/clear_ownership(mob/living/carbon/old_owner)
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_ARM))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))
	..()

///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/arm/right/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/arm/right/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/arm/right/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_hands(owner.usable_hands - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("Your lose control of your [name]!"))
			if(held_index)
				owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	else if(!bodypart_disabled)
		owner.set_usable_hands(owner.usable_hands + 1)

	if(owner.hud_used)
		var/atom/movable/screen/inventory/hand/hand_screen_object = owner.hud_used.hand_slots["[held_index]"]
		hand_screen_object?.update_icon()

/obj/item/bodypart/arm/right/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_arm"
	icon_static = 'icons/mob/animal_parts.dmi'
	limb_id = SPECIES_MONKEY
	bodyshape = BODYSHAPE_MONKEY
	should_draw_greyscale = FALSE
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage = 3

/obj/item/bodypart/arm/right/monkey/teratoma
	icon_state = "teratoma_r_arm"
	limb_id = "teratoma"

/obj/item/bodypart/arm/right/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_r_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE

/// Parent Type for arms, should not appear in game.
/obj/item/bodypart/leg
	name = "leg"
	desc = "This item shouldn't exist. Talk about breaking a leg. Badum-Tss!"
	attack_verb_continuous = list("kicks", "stomps")
	attack_verb_simple = list("kick", "stomp")
	max_damage = 50
	body_damage_coeff = 0.75
	max_stamina_damage = 50
	can_be_disabled = TRUE
	unarmed_attack_effect = ATTACK_EFFECT_KICK
	body_zone = BODY_ZONE_L_LEG
	unarmed_attack_verb = "kick" // The lovely kick, typically only accessable by attacking a grouded foe. 1.5 times better than the punch.
	unarmed_damage = 7

	/// Datum describing how to offset things worn on the foot of this leg, note that an x offset won't do anything here
	var/datum/worn_feature_offset/worn_foot_offset

/obj/item/bodypart/leg/left
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT
	plaintext_zone = "left leg"
	px_x = -2
	px_y = 12
	can_be_disabled = TRUE
	bodypart_trait_source = LEFT_LEG_TRAIT

/obj/item/bodypart/leg/left/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_L_LEG))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/leg/left/clear_ownership(mob/living/carbon/old_owner)
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_LEG))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))
	..()

///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/leg/left/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_L_LEG trait.
/obj/item/bodypart/leg/left/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/leg/left/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("Your lose control of your [name]!"))
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)


/obj/item/bodypart/leg/left/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_static = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage = 3

/obj/item/bodypart/leg/left/monkey/teratoma
	icon_state = "teratoma_l_leg"
	limb_id = "teratoma"

/obj/item/bodypart/leg/left/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_l_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	// alternative spellings of 'pokey' are available
	icon_state = "default_human_r_leg"
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	plaintext_zone = "right leg"
	px_x = 2
	px_y = 12
	bodypart_trait_source = RIGHT_LEG_TRAIT

/obj/item/bodypart/leg/right/apply_ownership(mob/living/carbon/new_owner)
	if(HAS_TRAIT(new_owner, TRAIT_PARALYSIS_R_LEG))
		ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
		RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))
	else
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
		RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))
	..()

/obj/item/bodypart/leg/right/clear_ownership(mob/living/carbon/old_owner)
	if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_LEG))
		UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
		REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	else
		UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))
	..()

///Proc to react to the owner gaining the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/leg/right/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/leg/right/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/leg/right/set_disabled(new_disabled)
	. = ..()
	if(isnull(.) || !owner)
		return

	if(!.)
		if(bodypart_disabled)
			owner.set_usable_legs(owner.usable_legs - 1)
			if(owner.stat < UNCONSCIOUS)
				to_chat(owner, span_userdanger("Your lose control of your [name]!"))
	else if(!bodypart_disabled)
		owner.set_usable_legs(owner.usable_legs + 1)


/obj/item/bodypart/leg/right/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_static = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_MONKEY
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY
	unarmed_damage = 3

/obj/item/bodypart/leg/right/monkey/teratoma
	icon_state = "teratoma_r_leg"
	limb_id = "teratoma"

/obj/item/bodypart/leg/right/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_r_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	can_be_disabled = FALSE
	max_damage = 100
	should_draw_greyscale = FALSE
