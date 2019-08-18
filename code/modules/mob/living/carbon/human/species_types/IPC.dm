/datum/species/IPC // im fucking lazy mk2 and cant get sprites to normally work
	name = "IPC" //inherited from the real species, for health scanners and things
	id = "ipc"
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
	default_features = list("ipc_screen" = "BSOD", "ipc_antenna" = "None")
	burnmod = 1.75
	heatmod = 1.6
	brutemod = 1.2
	var/list/initial_species_traits //for getting these values back for assume_disguise()
	var/list/initial_inherent_traits
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	var/datum/action/innate/monitor_change/screen
	var/obj/item/mmi/mmi = null

/datum/species/IPC/spec_emp_act(mob/living/carbon/human/H, severity)
	. = ..()
	switch(severity)
		if(1)
			H.Stun(160)
			H.adjustBruteLoss(50)
		if(2)
			H.Stun(60)
			H.adjustBruteLoss(35)

/datum/species/IPC/check_roundstart_eligible()
	return TRUE

/datum/species/IPC/military/check_roundstart_eligible()
	return FALSE //yes

/datum/species/IPC/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
    if(I.tool_behaviour == TOOL_WELDER && intent != INTENT_HARM)
        if (!I.tool_start_check(user, amount=0))
            return
        else
            to_chat(user, "<span class='notice'>You start fixing [H == user ? "your" : "\the"] [affecting.name]...</span>")
            if(I.use_tool(src, user, 0, volume=40))
                if(H == user)
                    H.adjustBruteLoss(-3)
                else
                    H.adjustBruteLoss(-10)
                H.updatehealth()
                H.add_fingerprint(user)
                H.visible_message("<span class='notice'>[user] has [H == user ? "poorly " : ""]fixed some of the dents on \the [affecting.name].</span>")
        return
    else if(istype(I, /obj/item/stack/cable_coil))
        to_chat(user, "<span class='notice'>You start fixing [H == user ? "your" : "\the"] [affecting.name]...</span>")
        if(do_after(user, 30, target = H))
            var/obj/item/stack/cable_coil/C = I
            C.use(1)
            if(H == user)
                H.adjustFireLoss(-2)
                H.adjustToxLoss(-2)
            else
                H.adjustFireLoss(-10)
                H.adjustToxLoss(-10)
            H.updatehealth()
            H.visible_message("<span class='notice'>[user] has [H == user ? "poorly " : ""]fixed some of the burnt cables on \the [affecting.name].</span>")
        return
    else
        return ..()

/datum/species/IPC/military
	name = "Military IPC"
	id = "military_synth"
	armor = 25
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14 //about 50% chance to stun

/datum/species/IPC/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/medicine/synthflesh)
		chem.reaction_mob(H, TOUCH, 2 ,0) //heal a little
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return 1
	else
		return ..()

/datum/species/IPC/on_species_gain(mob/living/carbon/human/C)
	if(isIPC(C) && !screen)
		screen = new
		screen.Grant(C)
	..()

/datum/species/IPC/on_species_loss(mob/living/carbon/human/C)
	if(screen)
		screen.Remove(C)
	..()

/datum/species/IPC/get_spans()
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
