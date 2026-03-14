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
	///The bodyshape(s) allowed to attach to this chest.
	var/acceptable_bodyshape = BODYSHAPE_HUMANOID
	///The bodytype(s) allowed to attach to this chest.
	var/acceptable_bodytype = ALL

	var/obj/item/cavity_item

/obj/item/bodypart/chest/can_dismember(obj/item/I)
	if(owner.stat < HARD_CRIT || !get_organs())
		return FALSE
	return ..()

/obj/item/bodypart/chest/Destroy()
	QDEL_NULL(cavity_item)
	return ..()

/obj/item/bodypart/chest/drop_organs(mob/user, violent_removal)
	if(cavity_item)
		cavity_item.forceMove(drop_location())
		cavity_item = null
	return ..()

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
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "alien_chest"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	bodyshape = BODYSHAPE_HUMANOID
	is_dimorphic = FALSE //All of them are girls
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 500
	acceptable_bodyshape = BODYSHAPE_HUMANOID

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "larva_chest"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 50
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_LARVA_PLACEHOLDER

/// Parent Type for arms, should not appear in game.
/obj/item/bodypart/arm
	/// The noun to use when referring to this arm's appendage, e.g. "hand" or "paw"
	var/appendage_noun = "hand"

/obj/item/bodypart/arm/left
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	attack_verb_continuous = list("slaps", "punches")
	attack_verb_simple = list("slap", "punch")
	max_damage = 40
	max_stamina_damage = 50
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	plaintext_zone = "left arm"
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 1
	px_x = -6
	px_y = 0
	can_be_disabled = TRUE


/obj/item/bodypart/arm/left/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_ARM))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))


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
	appendage_noun = "paw"

/obj/item/bodypart/arm/left/monkey/teratoma
	icon_state = "teratoma_l_arm"

/obj/item/bodypart/arm/left/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
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
	appendage_noun = "scythe-like hand"

/obj/item/bodypart/arm/right
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	attack_verb_continuous = list("slaps", "punches")
	attack_verb_simple = list("slap", "punch")
	max_damage = 40
	max_stamina_damage = 50
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	plaintext_zone = "right arm"
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = HANDS_PART_LAYER
	body_damage_coeff = 0.75
	held_index = 2
	px_x = 6
	px_y = 0
	can_be_disabled = TRUE


/obj/item/bodypart/arm/right/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_ARM))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_R_ARM))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))


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
	appendage_noun = "paw"

/obj/item/bodypart/arm/right/monkey/teratoma
	icon_state = "teratoma_r_arm"
	limb_id = "teratoma"

/obj/item/bodypart/arm/right/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
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
	appendage_noun = "scythe-like hand"

/obj/item/bodypart/leg/left
	name = "left leg"
	desc = "Some athletes prefer to tie their left shoelaces first for good \
		luck. In this instance, it probably would not have helped."
	icon_state = "default_human_l_leg"
	attack_verb_continuous = list("kicks", "stomps")
	attack_verb_simple = list("kick", "stomp")
	max_damage = 40
	body_zone = BODY_ZONE_L_LEG
	body_part = LEG_LEFT
	plaintext_zone = "left leg"
	body_damage_coeff = 0.75
	px_x = -2
	px_y = 12
	max_stamina_damage = 50
	can_be_disabled = TRUE


/obj/item/bodypart/leg/left/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_L_LEG))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_L_LEG))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))


///Proc to react to the owner gaining the TRAIT_PARALYSIS_L_LEG trait.
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

/obj/item/bodypart/leg/left/monkey/teratoma
	icon_state = "teratoma_l_leg"
	limb_id = "teratoma"

/obj/item/bodypart/leg/left/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
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
	attack_verb_continuous = list("kicks", "stomps")
	attack_verb_simple = list("kick", "stomp")
	max_damage = 40
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	plaintext_zone = "right leg"
	body_damage_coeff = 0.75
	px_x = 2
	px_y = 12
	max_stamina_damage = 50
	can_be_disabled = TRUE


/obj/item/bodypart/leg/right/set_owner(new_owner)
	. = ..()
	if(. == FALSE)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
			ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))
		else
			REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))
	if(.)
		var/mob/living/carbon/old_owner = .
		if(HAS_TRAIT(old_owner, TRAIT_PARALYSIS_R_LEG))
			UnregisterSignal(old_owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
			if(!owner || !HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
				REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
		else
			UnregisterSignal(old_owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))


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

/obj/item/bodypart/leg/right/monkey/teratoma
	icon_state = "teratoma_r_leg"
	limb_id = "teratoma"

/obj/item/bodypart/leg/right/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
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
