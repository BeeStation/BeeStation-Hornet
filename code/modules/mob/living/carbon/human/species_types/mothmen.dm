#define COCOON_WEAVE_DELAY 5 SECONDS //how long it takes you to create the cocoon
#define COCOON_EMERGE_DELAY 60 SECONDS //how long you remain inside of it
#define COCOON_HARM_AMOUNT 35 //how much damage gets dealt to you if the cocoon gets broken prematurely
#define COCOON_HEAL_AMOUNT 30 //how much damage gets restored while you're cocooned
#define COCOON_NUTRITION_AMOUNT 200 //how much hunger gets drained in total
	//these are here to make adjusting the balance easier

/datum/species/moth
	name = "\improper Mothman"
	id = SPECIES_MOTH
	bodyflag = FLAG_MOTH
	default_color = "00FF00"
	species_traits = list(LIPS, NOEYESPRITES, HAS_MARKINGS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutant_bodyparts = list("moth_wings", "moth_antennae", "moth_markings")
	default_features = list("moth_wings" = "Plain", "moth_antennae" = "Plain", "moth_markings" = "None", "body_size" = "Normal")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	var/datum/action/innate/cocoon/cocoon_action
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	mutanteyes = /obj/item/organ/eyes/moth
	mutantwings = /obj/item/organ/wings/moth
	mutanttongue = /obj/item/organ/tongue/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	inert_mutation = STRONGWINGS
	deathsound = 'sound/voice/moth/moth_deathgasp.ogg'

	species_chest = /obj/item/bodypart/chest/moth
	species_head = /obj/item/bodypart/head/moth
	species_l_arm = /obj/item/bodypart/l_arm/moth
	species_r_arm = /obj/item/bodypart/r_arm/moth
	species_l_leg = /obj/item/bodypart/l_leg/moth
	species_r_leg = /obj/item/bodypart/r_leg/moth

/datum/species/moth/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.moth_first)]"

	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.moth_last)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return FALSE
	return ..()
/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 9 //flyswatters deal 10x damage to moths
	return 0

/datum/species/moth/get_laugh_sound(mob/living/carbon/user)
	return 'sound/emotes/mothlaugh.ogg'

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
		cocoon_action.UpdateButtonIcon()

/datum/action/innate/cocoon
	name = "Cocoon"
	desc = "Restore your wings and antennae, and heal some damage. If your cocoon is broken externally you will take heavy damage!"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	button_icon_state = "wrap_0"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'

/datum/action/innate/cocoon/Activate()
	var/mob/living/carbon/H = owner
	var/obj/item/organ/wingcheck = H.getorgan(/obj/item/organ/wings/moth)
	if(!wingcheck) //This is to stop easy organ farms
		to_chat(H, "<span class='warning'>You don't have any wings to regenerate!</span>")
		return
	if(!HAS_TRAIT(H, TRAIT_MOTH_BURNT))
		to_chat(H, "<span class='warning'>Your wings are fine as they are!</span>")
		return
	if(H.nutrition < COCOON_NUTRITION_AMOUNT)
		to_chat(H, "<span class='warning'>You are too hungry to weave a cocoon!</span>")
		return
	H.visible_message("<span class='notice'>[H] begins to hold still and concentrate on weaving a cocoon...</span>", \
	"<span class='notice'>You begin to focus on weaving a cocoon... (This will take [DisplayTimeText(COCOON_WEAVE_DELAY)] and you must hold still.)</span>")
	H.adjustStaminaLoss(20, FALSE) //this is here to deter people from spamming it if they get interrupted
	if(do_after(H, COCOON_WEAVE_DELAY, H, timed_action_flags = IGNORE_HELD_ITEM))
		if(!ismoth(H))
			to_chat(H, "<span class='warning'>You have lost your mandibles and cannot weave anymore!.</span>")
			return
		if(H.incapacitated())
			to_chat(H, "<span class='warning'>You cannot weave a cocoon in your current state.</span>")
			return
		if(!HAS_TRAIT(H, TRAIT_MOTH_BURNT))
			to_chat(H, "<span class='warning'>Your wings are fine as they are!</span>")
			return
		H.visible_message("<span class='notice'>[H] finishes weaving a cocoon!</span>", "<span class='notice'>You finish weaving your cocoon.</span>")
		var/obj/structure/moth_cocoon/C = new(get_turf(H))
		H.forceMove(C)
		H.Sleeping(20, FALSE)
		C.done_regenerating = FALSE
		H.apply_status_effect(STATUS_EFFECT_COCOONED)
		H.log_message("has finished weaving a cocoon.", LOG_GAME)
		addtimer(CALLBACK(src, PROC_REF(emerge), C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)
	else
		to_chat(H, "<span class='warning'>You need to hold still in order to weave a cocoon!</span>")

/datum/action/innate/cocoon/IsAvailable()
	if(..())
		var/mob/living/carbon/human/H = owner
		if(HAS_TRAIT(H, TRAIT_MOTH_BURNT))
			return TRUE
		return FALSE

//Removes moth from cocoon, restores burnt wings
/datum/action/innate/cocoon/proc/emerge(obj/structure/moth_cocoon/C)
	for(var/mob/living/carbon/human/H in C.contents)
		if(!H.has_status_effect(STATUS_EFFECT_COCOONED))
			return
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "burnt_wings")
		if(ismoth(H) && HAS_TRAIT(H, TRAIT_MOTH_BURNT))
			REMOVE_TRAIT(H, TRAIT_MOTH_BURNT, "fire")
			var/obj/item/organ/wings/moth/W = H.getorgan(/obj/item/organ/wings/moth)
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
		visible_message("<span class='danger'>[src] splits open from within!</span>")
	else
		visible_message("<span class='danger'>[src] is torn open, harming the Mothperson within!</span>")
	for(var/mob/living/carbon/human/H in contents)
		if(H.has_status_effect(STATUS_EFFECT_COCOONED) && !done_regenerating)
			H.adjustBruteLoss(COCOON_HARM_AMOUNT, FALSE)
			H.SetSleeping(0, FALSE)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		H.dna.species.handle_mutant_bodyparts(H)
		H.dna.species.handle_body(H)
		H.forceMove(loc)
		H.log_message("[key_name(H)] [done_regenerating ? "has emerged" : "was forcefully ejected"] from their cocoon with a nutrition level of [H.nutrition][H.nutrition <= NUTRITION_LEVEL_STARVING ? ", now starving" : ""], (NEWHP: [H.health])", LOG_GAME)
		if(done_regenerating)
			visible_message("<span class='notice'>[H]'s wings unfold, looking good as new!</span>")
			to_chat(H, "<span class='notice'>Your wings unfold with new vigor!</span>")
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
