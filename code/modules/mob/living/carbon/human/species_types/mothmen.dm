#define COCOON_WEAVE_DELAY 5 SECONDS //how long it takes you to create the cocoon
#define COCOON_EMERGE_DELAY 60 SECONDS //how long you remain inside of it
#define COCOON_HARM_AMOUNT 35 //how much damage gets dealt to you if the cocoon gets broken prematurely
#define COCOON_HEAL_AMOUNT 30 //how much damage gets restored while you're cocooned
#define COCOON_NUTRITION_AMOUNT 200 //how much hunger gets drained in total
	//these are here to make adjusting the balance easier

/datum/species/moth
	name = "\improper Mothman"
	plural_form = "Mothmen"
	id = SPECIES_MOTH
	species_traits = list(
		LIPS,
		HAS_MARKINGS
	)
	inherent_traits = list(
		TRAIT_TACKLING_WINGED_ATTACKER
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID |  MOB_BUG
	mutant_bodyparts = list(
		"moth_wings" = "Plain",
		"moth_antennae" = "Plain",
		"moth_markings" = "None",
		"body_size" = "Normal"
	)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	var/datum/action/innate/cocoon/cocoon_action
	meat = /obj/item/food/meat/slab/human/mutant/moth
	mutanteyes = /obj/item/organ/eyes/moth
	mutantwings = /obj/item/organ/wings/moth
	mutanttongue = /obj/item/organ/tongue/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	inert_mutation = /datum/mutation/strongwings
	deathsound = 'sound/voice/moth/moth_deathgasp.ogg'

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/moth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/moth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/moth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/moth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/moth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/moth,
	)

	species_height = SPECIES_HEIGHTS(2, 1, 0)

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return FALSE
	return ..()
/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 9 //flyswatters deal 10x damage to moths
	return 0

/datum/species/moth/get_laugh_sound(mob/living/carbon/user)
	return 'sound/emotes/moth/mothlaugh.ogg'

/datum/species/moth/get_scream_sound(mob/living/carbon/user)
	return 'sound/voice/moth/scream_moth.ogg'

/datum/species/moth/on_species_gain(mob/living/carbon/human/H)
	..()
	cocoon_action = new()
	cocoon_action.Grant(H)

/datum/species/moth/on_species_loss(mob/living/carbon/human/H)
	..()
	cocoon_action.Remove(H)
	QDEL_NULL(cocoon_action)

/datum/species/moth/spec_life(mob/living/carbon/human/H)
	if(cocoon_action)
		cocoon_action.update_buttons()

/datum/action/innate/cocoon
	name = "Cocoon"
	desc = "Restore your wings and antennae, and heal some damage. If your cocoon is broken externally you will take heavy damage!"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS
	button_icon_state = "wrap_0"
	button_icon = 'icons/hud/actions/actions_animal.dmi'

/datum/action/innate/cocoon/on_activate()
	var/mob/living/carbon/H = owner
	var/obj/item/organ/wingcheck = H.get_organ_by_type(/obj/item/organ/wings/moth)
	if(!wingcheck) //This is to stop easy organ farms
		to_chat(H, span_warning("You don't have any wings to regenerate!"))
		return
	if(!HAS_TRAIT(H, TRAIT_MOTH_BURNT))
		to_chat(H, span_warning("Your wings are fine as they are!"))
		return
	if(H.nutrition < COCOON_NUTRITION_AMOUNT)
		to_chat(H, span_warning("You are too hungry to weave a cocoon!"))
		return
	H.visible_message(span_notice("[H] begins to hold still and concentrate on weaving a cocoon..."), \
	span_notice("You begin to focus on weaving a cocoon... (This will take [DisplayTimeText(COCOON_WEAVE_DELAY)] and you must hold still.)"))
	H.adjustStaminaLoss(20, FALSE) //this is here to deter people from spamming it if they get interrupted
	if(do_after(H, COCOON_WEAVE_DELAY, H, timed_action_flags = IGNORE_HELD_ITEM))
		if(!ismoth(H))
			to_chat(H, span_warning("You have lost your mandibles and cannot weave anymore!."))
			return
		if(H.incapacitated())
			to_chat(H, span_warning("You cannot weave a cocoon in your current state."))
			return
		if(!HAS_TRAIT(H, TRAIT_MOTH_BURNT))
			to_chat(H, span_warning("Your wings are fine as they are!"))
			return
		H.visible_message(span_notice("[H] finishes weaving a cocoon!"), span_notice("You finish weaving your cocoon."))
		var/obj/structure/moth_cocoon/C = new(get_turf(H))
		H.forceMove(C)
		H.Sleeping(20, FALSE)
		C.done_regenerating = FALSE
		H.apply_status_effect(/datum/status_effect/cocooned)
		H.log_message("has finished weaving a cocoon.", LOG_GAME)
		addtimer(CALLBACK(src, PROC_REF(emerge), C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)
	else
		to_chat(H, span_warning("You need to hold still in order to weave a cocoon!"))

/datum/action/innate/cocoon/is_available()
	if(..())
		var/mob/living/carbon/human/H = owner
		if(HAS_TRAIT(H, TRAIT_MOTH_BURNT))
			return TRUE
		return FALSE

//Removes moth from cocoon, restores burnt wings
/datum/action/innate/cocoon/proc/emerge(obj/structure/moth_cocoon/C)
	for(var/mob/living/carbon/human/H in C.contents)
		if(!H.has_status_effect(/datum/status_effect/cocooned))
			return
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "burnt_wings")
		if(ismoth(H) && HAS_TRAIT(H, TRAIT_MOTH_BURNT))
			REMOVE_TRAIT(H, TRAIT_MOTH_BURNT, "fire")
			var/obj/item/organ/wings/moth/W = H.get_organ_by_type(/obj/item/organ/wings/moth)
			if(W)
				W.flight_level = WINGS_FLIGHTLESS//The check for wings getting burned makes them cosmetic, so this allows the burned off effect to be applied again
				if(locate(/datum/mutation/strongwings) in H.dna.mutations)
					W.flight_level = WINGS_FLYING
		H.dna.species.handle_mutant_bodyparts(H)
		H.dna.species.handle_body(H)
	C.done_regenerating = TRUE
	qdel(C)

/obj/structure/moth_cocoon
	name = "\improper Mothperson cocoon"
	desc = "Someone wrapped in a Mothperson cocoon. It's best to let them rest."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon_moth"
	anchored = TRUE
	max_integrity = 10
	///Determines whether or not the mothperson is still regenerating their wings
	var/done_regenerating = FALSE

/obj/structure/moth_cocoon/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/slash.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/moth_cocoon/Destroy()
	if(done_regenerating)
		visible_message(span_danger("[src] splits open from within!"))
	else
		visible_message(span_danger("[src] is torn open, harming the Mothperson within!"))
	for(var/mob/living/carbon/human/H in contents)
		if(H.has_status_effect(/datum/status_effect/cocooned) && !done_regenerating)
			H.adjustBruteLoss(COCOON_HARM_AMOUNT, FALSE)
			H.SetSleeping(0, FALSE)
		H.remove_status_effect(/datum/status_effect/cocooned)
		H.dna.species.handle_mutant_bodyparts(H)
		H.dna.species.handle_body(H)
		H.forceMove(loc)
		H.log_message("[key_name(H)] [done_regenerating ? "has emerged" : "was forcefully ejected"] from their cocoon with a nutrition level of [H.nutrition][H.nutrition <= NUTRITION_LEVEL_STARVING ? ", now starving" : ""], (NEWHP: [H.health])", LOG_GAME)
		if(done_regenerating)
			visible_message(span_notice("[H]'s wings unfold, looking good as new!"))
			to_chat(H, span_notice("Your wings unfold with new vigor!"))
	return ..()

/datum/status_effect/cocooned
	id = "cocooned"
	alert_type = null

/datum/status_effect/cocooned/tick()
	owner.SetSleeping(10, TRUE)
	owner.adjustBruteLoss(-(COCOON_HEAL_AMOUNT / (COCOON_EMERGE_DELAY)), FALSE)
	owner.adjustFireLoss(-(COCOON_HEAL_AMOUNT / (COCOON_EMERGE_DELAY)), FALSE)
	owner.adjust_nutrition(-((COCOON_NUTRITION_AMOUNT * 10 ) / (COCOON_EMERGE_DELAY)))

#undef COCOON_WEAVE_DELAY
#undef COCOON_EMERGE_DELAY
#undef COCOON_HARM_AMOUNT
#undef COCOON_HEAL_AMOUNT
#undef COCOON_NUTRITION_AMOUNT

/datum/species/moth/get_species_description()
	return "Mothpeople are an intelligent species, known for their affinity to all things moth - lights, cloth, wings, and friendship."

/datum/species/moth/get_species_lore()
	return null

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Precious Wings",
			SPECIES_PERK_DESC = "Moths can fly in pressurized, zero-g environments and safely land short falls using their wings.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Meal Plan",
			SPECIES_PERK_DESC = "Moths can eat clothes for nourishment.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Ablazed Wings",
			SPECIES_PERK_DESC = "Moth wings are fragile, and can be easily burnt off. However, moths can spin a cooccon to restore their wings if necessary.",
		),
	)

	return to_add
