/datum/species/ipc // im fucking lazy mk2 and cant get sprites to normally work
	name = "IPC" //inherited from the real species, for health scanners and things
	id = "ipc"
	say_mod = "beeps" //inherited from a user's real species
	sexes = 0
	species_traits = list(NOTRANSSTING,NOREAGENTS,NOEYESPRITES,NO_DNA_COPY,NOBLOOD,TRAIT_EASYDISMEMBER,NOFLASH) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_VIRUSIMMUNE,TRAIT_NOHUNGER,TRAIT_NOBREATH,TRAIT_RADIMMUNE,TRAIT_LIMBATTACHMENT)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	mutant_brain = /obj/item/organ/brain/positron
	meat = null
	exotic_blood = "oil"
	damage_overlay_type = "synth"
	limbs_id = "synth"
	mutant_bodyparts = list("ipc_screen", "ipc_antenna")
	default_features = list("ipc_screen" = "BSOD", "ipc_antenna" = "None")
	speedmod = -0.12
	burnmod = 1.75
	heatmod = 1.6
	brutemod = 1.2
	toxmod = 0
	clonemod = 0
	staminamod = 0.8
	siemens_coeff = 1
	var/list/initial_species_traits //for getting these values back for assume_disguise()
	var/list/initial_inherent_traits
	changesource_flags = MIRROR_BADMIN | WABBAJACK


	var/datum/action/innate/monitor_change/screen

/datum/species/ipc/spec_emp_act(mob/living/carbon/human/H, severity)
	. = ..()
	switch(severity)
		if(1)
			to_chat(H, "<span class='warning'>$!^%$* Processor Not Responding $!^%$*")
			H.Stun(160)
			H.adjustBruteLoss(50)
		if(2)
			to_chat(H, "<span class='warning'>BZZ!£$!ZZ$RT. E$%MP De$£%ec$£d")
			H.Stun(60)
			H.adjustBruteLoss(35)

/datum/species/ipc/check_roundstart_eligible()
	return TRUE

/datum/species/ipc/military/check_roundstart_eligible()
	return FALSE //yes

/datum/species/ipc/spec_attacked_by(obj/item/I, mob/user, obj/item/bodypart/affecting, intent, mob/living/H)
    if(I.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
        if (!I.tool_start_check(user, amount=0))
            return
        else
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
        if(do_after(user, 30, target = H))
            var/obj/item/stack/cable_coil/C = I
            C.use(1)
            if(H == user)
                H.adjustFireLoss(-2)
                H.adjustToxLoss(-2)
                H.adjustBrainLoss(-5)
                H.adjustCloneLoss(-50) //HOW THE FUCK DO YOU EVEN GET THIS
            else
                H.adjustFireLoss(-10)
                H.adjustToxLoss(-10)
                H.adjustBrainLoss(-10)
                H.adjustCloneLoss(-50) //HOW THE FUCK DO YOU EVEN GET THIS
            H.updatehealth()
            H.visible_message("<span class='notice'>[user] has [H == user ? "poorly " : ""]fixed some of the burnt cables on \the [affecting.name].</span>")
        return
    else if(istype(I, /obj/item/borg/upgrade/restart))
        if(H.health < 0)
            to_chat(user, "<span class='warning'>You have to repair the IPC before using this module!</span>")
            return FALSE
        if(H.mind)
            H.mind.grab_ghost()
        H.revive()
        to_chat(user, "<span class='notice'>You reset the IPC's internal circuitry - reviving them!</span>")
        return
    else
        return ..()

/datum/species/ipc/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_ipc_name()

	var/randname = ipc_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/ipc/military
	name = "Military IPC"
	id = "military_synth"
	armor = 25
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14 //about 50% chance to stun
	
/datum/species/ipc/on_species_gain(mob/living/carbon/human/C)
	var/obj/item/organ/appendix/appendix = C.getorganslot(ORGAN_SLOT_APPENDIX) // Easiest way to remove it.
	appendix?.Remove(C)
	if(isIPC(C) && !screen)
		screen = new
		screen.Grant(C)
	..()

/datum/species/ipc/on_species_loss(mob/living/carbon/human/C)
	if(screen)
		screen.Remove(C)
	..()

/datum/species/ipc/get_spans()
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
