#define COCOON_WEAVE_DELAY 5 SECONDS //how long it takes you to create the cocoon
#define COCOON_EMERGE_DELAY 15 SECONDS //how long you remain inside of it
#define COCOON_HARM_AMOUNT 50 //how much damage gets dealt to you if the cocoon gets broken prematurely
#define COCOON_HEAL_AMOUNT 35 //how much damage gets restored while you're cocooned
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
/*
/datum/species/moth/spec_WakeUp(mob/living/carbon/human/H)
	if(H.has_status_effect(STATUS_EFFECT_COCOONED))
		return TRUE //Cocooned mobs dont get to wake up
*/
/datum/action/innate/cocoon
	name = "Cocoon"
	desc = "Restore your wings and antennae, and heal some damage. If your cocoon is broken externally you will take heavy damage!"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	button_icon_state = "wrap_0"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'

//
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
	"<span class='notice'>You begin to focus on weaving a cocoon... (This will take [COCOON_WEAVE_DELAY / 10] seconds and you must hold still.)</span>")
	H.adjustStaminaLoss(20, 0) //this is here to deter people from spamming it if they get interrupted
	if(do_after(H, COCOON_WEAVE_DELAY, FALSE, H))
		if(!ismoth(H))
			to_chat(H, "<span class='warning'>You have lost your mandibles and cannot weave anymore!.</span>")
			return
		if(H.incapacitated())
			to_chat(H, "<span class='warning'>You cannot weave a cocoon in your current state.</span>")
			return
		H.visible_message("<span class='notice'>[H] finishes weaving a cocoon!</span>", "<span class='notice'>You finish weaving your cocoon.</span>")
		var/obj/structure/moth/cocoon/C = new(get_turf(H))
		H.forceMove(C)
		H.Sleeping(20, 0)
		C.preparing_to_emerge = TRUE
		H.apply_status_effect(STATUS_EFFECT_COCOONED)
		//owner.log_message("[key_name(owner)] has finished weaving a cocoon at [AREACOORD(owner)]")
		addtimer(CALLBACK(src, .proc/emerge, C), COCOON_EMERGE_DELAY, TIMER_UNIQUE)
	else
		to_chat(H, "<span class='warning'>You need to hold still in order to weave a cocoon!</span>")

//Removes moth from cocoon, restores burnt wings
/datum/action/innate/cocoon/proc/emerge(obj/structure/moth/cocoon/C)
	for(var/mob/living/carbon/human/H in C.contents)
		if(!H.has_status_effect(STATUS_EFFECT_COCOONED))
			return
		//if(H.dna.features["moth_wings"] == "Burnt Off") //this check seems redundant as burned wings are a roundstart option and sending a signal to clear a non-existing mood event doesn't cause any issues
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "burnt_wings")
		//if(!ismoth(H))//mutation toxin is a thing, so this is here to prevent accidentally creating a mishmash of moth and whatever else
			//return Note - this makes the transformed user NEVER wake up
		if(ismoth(H))
			REMOVE_TRAIT(H, TRAIT_MOTH_BURNT, "fire")
		H.dna.species.handle_mutant_bodyparts(H)
		H.dna.species.handle_body(H)
	C.preparing_to_emerge = FALSE
	qdel(C)

/datum/status_effect/cocooned/tick()
	owner.SetSleeping(20, TRUE)
	owner.adjustBruteLoss(-(COCOON_HEAL_AMOUNT / (COCOON_EMERGE_DELAY)), 0)
	owner.adjustFireLoss(-(COCOON_HEAL_AMOUNT / (COCOON_EMERGE_DELAY)), 0)
	owner.adjust_nutrition(-(COCOON_NUTRITION_AMOUNT / (COCOON_EMERGE_DELAY)), 0)


/obj/structure/moth/cocoon
	name = "\improper Mothperson cocoon"
	desc = "Someone wrapped in a Mothperson cocoon. It's best to let them rest."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon_large1"
	anchored = TRUE
	max_integrity = 10
	var/preparing_to_emerge

/obj/structure/moth/cocoon/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/slash.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/moth/cocoon/Destroy()
	if(!preparing_to_emerge)
		visible_message("<span class='danger'>[src] splits open from within!</span>")
		for(var/mob/living/carbon/human/H in contents)
			log_game("[key_name(H)] has emerged from their cocoon with the nutrition level of [H.nutrition][H.nutrition <= NUTRITION_LEVEL_STARVING ? ", now starving" : ""]")
	else
		visible_message("<span class='danger'>[src] is torn open, harming the Mothperson within!</span>")
		for(var/mob/living/carbon/human/H in contents)
			H.drowsyness += COCOON_HARM_AMOUNT / 2
			H.adjustBruteLoss(COCOON_HARM_AMOUNT, 0)
			H.adjustStaminaLoss(COCOON_HARM_AMOUNT * 2, 0)
			//log_game("[key_name(H)] has emerged from their cocoon with the nutrition level of [H.nutrition][H.nutrition <= NUTRITION_LEVEL_STARVING ? ", now starving" : ""]")

	for(var/mob/living/carbon/human/H in contents)
		H.remove_status_effect(STATUS_EFFECT_COCOONED)
		//H.AdjustSleeping(0, 0)
		//H.adjust_nutrition(-COCOON_NUTRITION_AMOUNT)
		H.forceMove(loc)
		H.visible_message("<span class='notice'>[H]'s wings unfold, looking good as new!</span>", "<span class='notice'>Your wings unfold with new vigor!.</span>")
		log_game("[key_name(H)] has emerged from their cocoon with the nutrition level of [H.nutrition][H.nutrition <= NUTRITION_LEVEL_STARVING ? ", now starving" : ""]")
		//H.create_log(MISC_LOG, "has emerged from their cocoon with the nutrition level of [H.nutrition][H.nutrition <= NUTRITION_LEVEL_STARVING ? ", now starving" : ""]")
	return ..()

/datum/status_effect/cocooned
	id = "cocooned"
	alert_type = null
