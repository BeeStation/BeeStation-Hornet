/obj/item/bodypart/chest
	name = BODY_ZONE_CHEST
	desc = "It's impolite to stare at a person's chest."
	icon_state = "default_human_chest"
	max_damage = 100
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	plaintext_zone = "chest"
	is_dimorphic = TRUE
	px_x = 0
	px_y = 0
	organ_slots = list(
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_WINGS,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_STOMACH_AID,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_ZOMBIE,
		ORGAN_SLOT_THRUSTERS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_HEART_AID,
		ORGAN_SLOT_TAIL,
		ORGAN_SLOT_PARASITE_EGG,
		ORGAN_SLOT_PLASMA_VESSEL,
		ORGAN_SLOT_EGGSAC,
		ORGAN_SLOT_NEUROTOXIN_GLAND,
		ORGAN_SLOT_HIVE_NODE,
		ORGAN_SLOT_RESIN_SPINNER,
		ORGAN_SLOT_ACID_GLAND
	)
	pain_multiplier = 0.8
	///The bodytype(s) allowed to attach to this chest.
	var/acceptable_bodytype = BODYTYPE_HUMANOID

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
	..()

/obj/item/bodypart/chest/update_effectiveness()
	var/modifier = effectiveness / 50
	// Ranges from 1 down to 0.5
	modifier = clamp(modifier * 0.5 + 0.5, 0.5, 1)
	owner.blood.multiply_oxygenation_rating(modifier, FROM_CHEST_DAMAGE)
	owner.pain.remove_pain_messages(FROM_CHEST_DAMAGE)
	switch (modifier)
		if (0.6 to 0.9)
			owner.pain.add_pain_message("Your chest hurts.", FROM_CHEST_DAMAGE)
			owner.pain.add_pain_message("You feel a stabbing pain in your chest.", FROM_CHEST_DAMAGE)
			owner.pain.add_pain_message("You find it difficult to breathe.", FROM_CHEST_DAMAGE)
		if (0.3 to 0.6)
			owner.pain.add_pain_message("Your chest is in agony!", FROM_CHEST_DAMAGE)
			owner.pain.add_pain_message("Your breathing is heavy and difficult.", FROM_CHEST_DAMAGE)
			owner.pain.add_pain_message("You struggle to take a deep breath.", FROM_CHEST_DAMAGE)
		if (0 to 0.3)
			owner.pain.add_pain_message("You feel an unbearable pain in your chest.", FROM_CHEST_DAMAGE)
			owner.pain.add_pain_message("You feel a staggering pain as you take a breath.", FROM_CHEST_DAMAGE)
			owner.pain.add_pain_message("You find yourself struggling for breath.", FROM_CHEST_DAMAGE)

/obj/item/bodypart/chest/clear_effectiveness_modifiers()
	owner.blood.multiply_oxygenation_rating(1, FROM_HEAD_DAMAGE)
	owner.pain.remove_pain_messages(FROM_CHEST_DAMAGE)

/obj/item/bodypart/chest/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_static = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_chest"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	is_dimorphic = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_MONKEY
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/chest/monkey/teratoma
	icon_state = "teratoma_chest"
	limb_id = "teratoma"

/obj/item/bodypart/chest/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_chest"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	is_dimorphic = FALSE //All of them are girls
	should_draw_greyscale = FALSE
	dismemberable = 0
	max_damage = 200
	acceptable_bodytype = BODYTYPE_HUMANOID

/obj/item/bodypart/chest/larva
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "larva_chest"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dismemberable = 0
	max_damage = 30
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_LARVA_PLACEHOLDER

/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	attack_verb_continuous = list("slaps", "punches")
	attack_verb_simple = list("slap", "punch")
	max_damage = 40
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	plaintext_zone = "left arm"
	aux_zone = BODY_ZONE_PRECISE_L_HAND
	aux_layer = HANDS_PART_LAYER
	held_index = 1
	px_x = -6
	px_y = 0
	can_be_disabled = TRUE
	organ_slots = list(
		ORGAN_SLOT_LEFT_ARM_AUG
	)

/obj/item/bodypart/l_arm/update_effectiveness()
	// If greater than 50, becomes negative
	// If less than 50, becomes positive
	var/modifier = (50 - effectiveness) / 50
	owner.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/l_arm, TRUE, modifier)

/obj/item/bodypart/l_arm/clear_effectiveness_modifiers()
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/l_arm)

/datum/actionspeed_modifier/l_arm
	variable = TRUE

/obj/item/bodypart/l_arm/set_owner(new_owner)
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
/obj/item/bodypart/l_arm/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_L_ARM trait.
/obj/item/bodypart/l_arm/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_ARM), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/l_arm/set_disabled(new_disabled)
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

/obj/item/bodypart/l_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_arm"
	icon_static = 'icons/mob/animal_parts.dmi'
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	px_x = -5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/l_arm/monkey/teratoma
	icon_state = "teratoma_l_arm"

/obj/item/bodypart/l_arm/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_l_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 80
	should_draw_greyscale = FALSE

/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_arm"
	attack_verb_continuous = list("slaps", "punches")
	attack_verb_simple = list("slap", "punch")
	max_damage = 40
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	plaintext_zone = "right arm"
	aux_zone = BODY_ZONE_PRECISE_R_HAND
	aux_layer = HANDS_PART_LAYER
	held_index = 2
	px_x = 6
	px_y = 0
	can_be_disabled = TRUE
	organ_slots = list(
		ORGAN_SLOT_RIGHT_ARM_AUG
	)

/obj/item/bodypart/r_arm/update_effectiveness()
	// If greater than 50, becomes negative
	// If less than 50, becomes positive
	var/modifier = (50 - effectiveness) / 50
	owner.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/r_arm, TRUE, modifier)

/obj/item/bodypart/r_arm/clear_effectiveness_modifiers()
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/r_arm)

/datum/actionspeed_modifier/r_arm
	variable = TRUE

/obj/item/bodypart/r_arm/set_owner(new_owner)
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
/obj/item/bodypart/r_arm/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_loss))


///Proc to react to the owner losing the TRAIT_PARALYSIS_R_ARM trait.
/obj/item/bodypart/r_arm/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_ARM)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_ARM))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_ARM), PROC_REF(on_owner_paralysis_gain))


/obj/item/bodypart/r_arm/set_disabled(new_disabled)
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

/obj/item/bodypart/r_arm/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_arm"
	icon_static = 'icons/mob/animal_parts.dmi'
	limb_id = SPECIES_MONKEY
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE
	px_x = 5
	px_y = -3
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/r_arm/monkey/teratoma
	icon_state = "teratoma_r_arm"
	limb_id = "teratoma"

/obj/item/bodypart/r_arm/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_r_arm"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 80
	should_draw_greyscale = FALSE

/obj/item/bodypart/l_leg
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
	px_x = -2
	px_y = 12
	can_be_disabled = TRUE

/obj/item/bodypart/l_leg/set_owner(new_owner)
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
/obj/item/bodypart/l_leg/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_loss))

///Proc to react to the owner losing the TRAIT_PARALYSIS_L_LEG trait.
/obj/item/bodypart/l_leg/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_L_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_L_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_L_LEG), PROC_REF(on_owner_paralysis_gain))

/obj/item/bodypart/l_leg/set_disabled(new_disabled)
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

/obj/item/bodypart/l_leg/update_effectiveness()
	// If greater than 50, becomes negative
	// If less than 50, becomes positive
	var/modifier = (50 - effectiveness) / 50
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/l_leg, TRUE, modifier)

/obj/item/bodypart/l_leg/clear_effectiveness_modifiers()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/l_leg)

/datum/movespeed_modifier/l_leg
	variable = TRUE
	movetypes = GROUND
	blacklisted_movetypes = FLOATING|FLYING
	flags = IGNORE_NOSLOW

/obj/item/bodypart/l_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_static = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_l_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/l_leg/monkey/teratoma
	icon_state = "teratoma_l_leg"
	limb_id = "teratoma"

/obj/item/bodypart/l_leg/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_l_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 80
	should_draw_greyscale = FALSE

/obj/item/bodypart/r_leg
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
	px_x = 2
	px_y = 12
	can_be_disabled = TRUE

/obj/item/bodypart/r_leg/set_owner(new_owner)
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
/obj/item/bodypart/r_leg/proc/on_owner_paralysis_gain(mob/living/carbon/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_loss))

///Proc to react to the owner losing the TRAIT_PARALYSIS_R_LEG trait.
/obj/item/bodypart/r_leg/proc/on_owner_paralysis_loss(mob/living/carbon/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, TRAIT_PARALYSIS_R_LEG)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS_R_LEG))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS_R_LEG), PROC_REF(on_owner_paralysis_gain))

/obj/item/bodypart/r_leg/set_disabled(new_disabled)
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

/obj/item/bodypart/r_leg/update_effectiveness()
	// If greater than 50, becomes negative
	// If less than 50, becomes positive
	var/modifier = (50 - effectiveness) / 50
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/r_leg, TRUE, modifier)

/obj/item/bodypart/r_leg/clear_effectiveness_modifiers()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/r_leg)

/datum/movespeed_modifier/r_leg
	variable = TRUE
	movetypes = GROUND
	blacklisted_movetypes = FLOATING|FLYING
	flags = IGNORE_NOSLOW

/obj/item/bodypart/r_leg/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_static = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_r_leg"
	limb_id = SPECIES_MONKEY
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	px_y = 4
	dmg_overlay_type = SPECIES_MONKEY

/obj/item/bodypart/r_leg/monkey/teratoma
	icon_state = "teratoma_r_leg"
	limb_id = "teratoma"

/obj/item/bodypart/r_leg/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_r_leg"
	limb_id = BODYPART_ID_ALIEN
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	can_be_disabled = FALSE
	max_damage = 80
	should_draw_greyscale = FALSE
