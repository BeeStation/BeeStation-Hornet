GLOBAL_LIST_EMPTY(ipc_screens_list)
GLOBAL_LIST_EMPTY(ipc_antennas_list)
#define isipcperson(A) (is_species(A, /datum/species/synth))

/datum/species/synth // im fucking lazy mk2 and cant get sprites to normally work
	name = "IPC" //inherited from the real species, for health scanners and things
	id = "synth"
	say_mod = "beep boops" //inherited from a user's real species
	sexes = 0
	species_traits = list(NOTRANSSTING,NOBLOOD,TRAIT_EASYDISMEMBER,NOFLASH) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_VIRUSIMMUNE,TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER,TRAIT_NOBREATH,TRAIT_RADIMMUNE,TRAIT_LIMBATTACHMENT)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	meat = null
	exotic_blood = "oil"
	damage_overlay_type = "synth"
	limbs_id = "synth"
	mutant_bodyparts = list("ipc_screen", "ipc_antenna")
	default_features = list("ipc_screen" = "Blank", "ipc_antenna" = "None")
	burnmod = 1.75
	heatmod = 1.6
	brutemod = 1.2
	var/list/initial_species_traits //for getting these values back for assume_disguise()
	var/list/initial_inherent_traits
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	var/datum/action/innate/monitor_change/screen

/datum/species/synth/spec_emp_act(mob/living/carbon/human/H, severity)
	. = ..()
	switch(severity)
		if(1)
			H.Stun(160)
			H.adjustBruteLoss(50)
		if(2)
			H.Stun(60)
			H.adjustBruteLoss(35)

/datum/species/synth/check_roundstart_eligible()
	return TRUE

/datum/species/synth/military/check_roundstart_eligible()
	return FALSE

/datum/species/synth/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	if(I.tool_behaviour == TOOL_WELDER && intent != INTENT_HARM)
		if (!I.tool_start_check(user, amount=0))
			return
		if(H == user)
			to_chat(user, "<span class='notice'>You start fixing yourself...</span>")
			if(I.use_tool(src, user, 0, volume=40))
				H.adjustBruteLoss(-3)
				H.updatehealth()
				H.add_fingerprint(user)
				H.visible_message("<span class='notice'>[user] has poorly fixed some of the dents on the [src.name].</span>")
				return

		H.adjustBruteLoss(-10)
		H.updatehealth()
		H.add_fingerprint(user)
		H.visible_message("<span class='notice'>[user] has fixed some of the dents on the [src.name].</span>")
	else if(istype(I, /obj/item/stack/cable_coil))
		if(H == user)
			to_chat(user, "<span class='notice'>You start fixing yourself...</span>")
			if(H == user)
				H.adjustFireLoss(-2)
				H.adjustToxLoss(-2)
				H.updatehealth()
				H.visible_message("<span class='notice'>[user] has poorly fixed some of the burnt cables on the [src.name].</span>")
				return

		H.adjustFireLoss(-10)
		H.adjustToxLoss(-10)
		H.updatehealth()
		H.visible_message("<span class='notice'>[user] has fixed some of the burnt cables on the [src.name].</span>")
	else
		return ..()

/datum/species/synth/military
	name = "Military IPC"
	id = "military_synth"
	armor = 25
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14 //about 50% chance to stun

/datum/species/synth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/medicine/synthflesh)
		chem.reaction_mob(H, TOUCH, 2 ,0) //heal a little
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return 1
	else
		return ..()

/datum/species/synth/on_species_gain(mob/living/carbon/human/C)
	if(isipcperson(C) && !screen)
		screen = new
		screen.Grant(C)
	..()

/datum/species/synth/on_species_loss(mob/living/carbon/human/C)
	if(screen)
		screen.Remove(C)
	..()

/datum/species/synth/get_spans()
	return SPAN_ROBOT

/datum/action/innate/monitor_change
	name = "Screen Change"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/monitor_change/Activate()
	var/mob/living/carbon/human/H = owner
	var/new_ipc_screen = input(usr, "Choose your character's screen:", "Monitor Display") as null|anything in GLOB.ipc_screens_list
	if(!new_ipc_screen)
		return
	H.dna.features["ipc_screen"] = new_ipc_screen
	H.update_body()
