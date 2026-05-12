/datum/species/ipc
	name = "\improper Integrated Positronic Chassis"
	plural_form = "IPCs"
	id = SPECIES_IPC
	sexes = FALSE
	species_traits = list(
		NOEYESPRITES,
		NOZOMBIE,
		MUTCOLORS,
		REVIVESBYHEALING,
		NOHUSK,
		NOMOUTH,
		MUTCOLORS
	)
	inherent_traits = list(
		TRAIT_BLOOD_COOLANT,
		TRAIT_RESISTCOLD,
		TRAIT_LOWPRESSURELEAKING,
		TRAIT_NOBREATH,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_EASYDISMEMBER,
		TRAIT_EASYLIMBDISABLE,
		TRAIT_XENO_IMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOSOFTCRIT,
		TRAIT_NO_DNA_COPY,
		TRAIT_NOT_TRANSMORPHIC,
	)
	inherent_biotypes = MOB_ROBOTIC | MOB_HUMANOID
	mutantbrain = /obj/item/organ/brain/positron
	mutanteyes = /obj/item/organ/eyes/robotic
	mutanttongue = /obj/item/organ/tongue/robot
	mutantliver = /obj/item/organ/liver/cybernetic/tier2/ipc
	mutantstomach = /obj/item/organ/stomach/electrical/ipc
	mutantears = /obj/item/organ/ears/robot
	mutantheart = /obj/item/organ/heart/cybernetic/ipc
	mutantlungs = null
	mutantappendix = null
	mutant_organs = list(/obj/item/organ/cyberimp/arm/power_cord)
	mutant_bodyparts = list("mcolor" = "#7D7D7D", "ipc_screen" = "Static", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics (Custom)")
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/iron{amount = 10}

	//IPCs are extremely fragile, but do not go into softcrit and can be repaired with relative ease
	clonemod = 0
	siemens_coeff = 1.5
	reagent_tag = PROCESS_SYNTHETIC
	species_gibs = GIB_TYPE_ROBOTIC
	attack_sound = 'sound/items/trayhit1.ogg'
	allow_numbers_in_name = TRUE
	deathsound = "sound/voice/borg_deathsound.ogg"
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	species_language_holder = /datum/language_holder/synthetic
	special_step_sounds = list('sound/effects/servostep.ogg')

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ipc,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ipc,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ipc,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ipc,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ipc,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ipc
	)

	exotic_bloodtype = "Coolant"
	bleed_effect = /datum/status_effect/bleeding/robotic

	var/saved_screen //for saving the screen when they die
	var/datum/action/innate/change_screen/change_screen

	speak_no_tongue = FALSE  // who stole my soundblaster?! (-candy/etherware)

/datum/species/ipc/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C) && !change_screen)
		change_screen = new
		change_screen.Grant(C)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.physiology.bleed_mod *= 0.1
	RegisterSignal(C, COMSIG_LIVING_REVIVE, PROC_REF(mechanical_revival))

/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(change_screen)
		change_screen.Remove(C)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.physiology.bleed_mod *= 10
	UnregisterSignal(C, COMSIG_LIVING_REVIVE)

/datum/species/ipc/handle_radiation(mob/living/carbon/human/source, intensity, delta_time)
	if(intensity > RAD_MOB_KNOCKDOWN && DT_PROB(RAD_MOB_KNOCKDOWN_PROB, delta_time))
		if(!source.IsParalyzed())
			source.emote("collapse")
		source.Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(source, span_danger("You feel weak."))

/datum/species/ipc/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT //beep

/datum/species/ipc/spec_death(gibbed, mob/living/carbon/C)
	saved_screen = C.dna.features["ipc_screen"]
	C.dna.features["ipc_screen"] = "BSOD"
	C.update_body()
	addtimer(CALLBACK(src, PROC_REF(post_death), C), 5 SECONDS)

/datum/species/ipc/proc/post_death(mob/living/carbon/C)
	if(C.stat < DEAD)
		return
	C.dna.features["ipc_screen"] = null //Turns off screen on death
	C.update_body()

/datum/action/innate/change_screen
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/change_screen/on_activate()
	var/screen_choice = tgui_input_list(usr, "Which screen do you want to use?", "Screen Change", GLOB.ipc_screens_list)
	var/color_choice = tgui_color_picker(usr, "Which color do you want your screen to be?", "Color Change")
	if(!screen_choice)
		return
	if(!color_choice)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.dna.features["ipc_screen"] = screen_choice
	H.eye_color_left = sanitize_hexcolor(color_choice)
	H.update_body()

/obj/item/apc_powercord
	name = "power cord"
	desc = "An internal power cord hooked up to a battery. Useful if you run on electricity. Not so much otherwise."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if((!istype(target, /obj/machinery/power/apc) && !isethereal(target)) || !ishuman(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/stomach/electrical/battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!battery)
		balloon_alert(H, "power cell is gone!")
		return
	if(battery.drain_time > world.time)
		return

	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(isnull(A.cell))
			balloon_alert(H, "no cell in apc!")
			return
		A.charge_stomach_from_apc(H, battery)
		return

	if(isethereal(target))
		var/mob/living/carbon/human/target_ethereal = target
		var/obj/item/organ/stomach/electrical/target_battery = target_ethereal.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(!target_battery || target_battery.cell.charge <= 0)
			balloon_alert(H, "not enough charge!")
			return
		draw_from_stomach(H, target_battery)

/obj/item/apc_powercord/afterattack_secondary(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/power/apc) || !ishuman(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/stomach/electrical/battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!battery)
		balloon_alert(H, "power cell is gone!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(battery.drain_time > world.time)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/machinery/power/apc/A = target
	if(isnull(A.cell))
		balloon_alert(H, "no cell in apc!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	A.discharge_stomach_to_apc(H, battery, ETHEREAL_CHARGE_NORMAL)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/apc_powercord/proc/draw_from_stomach(mob/living/carbon/human/H, obj/item/organ/stomach/electrical/target_battery)
	var/obj/item/organ/stomach/electrical/our_battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	var/mob/living/carbon/human/target_ethereal = target_battery.owner
	H.visible_message(span_notice("[H] inserts a power connector into [target_ethereal]."), span_notice("You begin to draw power from [target_ethereal]."))
	our_battery.drain_time = world.time + ELECTRICAL_APC_DRAIN_TIME
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), H, "draining power..."), ELECTRICAL_APC_ALERT_DELAY)
	while(do_after(H, ELECTRICAL_APC_DRAIN_TIME, target = target_ethereal))
		our_battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(!our_battery)
			balloon_alert(H, "power cell is gone!")
			break
		if(loc != H)
			balloon_alert(H, "connector dropped!")
			break
		if(isnull(target_battery) || target_battery != target_ethereal.get_organ_slot(ORGAN_SLOT_STOMACH))
			balloon_alert(H, "target lost!")
			break
		if(target_battery.cell.charge <= 0)
			balloon_alert(H, "target depleted!")
			break
		if(our_battery.cell.used_charge() <= 0)
			balloon_alert(H, "charge is full!")
			break
		var/potential_charge = min(target_battery.cell.charge, our_battery.cell.used_charge())
		var/to_drain = min(ELECTRICAL_APC_POWER_GAIN, potential_charge)
		var/energy_drained = target_battery.adjust_charge(-to_drain)
		our_battery.adjust_charge(-energy_drained)
	H.visible_message(span_notice("[H] disconnects from [target_ethereal]."), span_notice("You disconnect from [target_ethereal]."))

/datum/species/ipc/proc/mechanical_revival(mob/living/carbon/human/H)

	H.notify_ghost_cloning("You have been repaired!")
	H.grab_ghost()
	H.dna.features["ipc_screen"] = "BSOD"
	INVOKE_ASYNC(src, PROC_REF(declare_revival), H)
	H.update_body()

/datum/species/ipc/proc/declare_revival(mob/living/carbon/human/H)
	H.say("Reactivating [pick("core systems", "central subroutines", "key functions")]...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	playsound(H, 'sound/voice/dialup.ogg', 25)
	H.say("Reinitializing [pick("personality matrix", "behavior logic", "morality subsystems")]...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Finalizing setup...")
	sleep(3 SECONDS)
	if(H.stat == DEAD)
		return
	H.say("Unit [H.real_name] is fully functional. Have a nice day.")
	H.dna.features["ipc_screen"] = saved_screen

/datum/species/ipc/get_harm_descriptors()
	return list(
		BLEED = "leaking",
		BRUTE = "denting",
		BURN = "burns"
	)

/datum/species/ipc/replace_body(mob/living/carbon/C, datum/species/new_species)
	..()

	var/datum/sprite_accessory/ipc_chassis/chassis_of_choice = GLOB.ipc_chassis_list[C.dna.features["ipc_chassis"]]

	for(var/obj/item/bodypart/BP as() in C.bodyparts) //Override bodypart data as necessary
		BP.uses_mutcolor = chassis_of_choice.color_src ? TRUE : FALSE
		if(BP.uses_mutcolor)
			BP.should_draw_greyscale = TRUE
			BP.species_color = C.dna?.features["mcolor"]

		BP.limb_id = chassis_of_choice.limbs_id
		BP.name = "\improper[chassis_of_choice.name] [parse_zone(BP.body_zone)]"
		BP.update_limb()

/datum/species/ipc/get_species_description()
	return "The newest in artificial life, IPCs are entirely robotic, synthetic life, made of motors, circuits, and wires \
	- based on newly developed Postronic brain technology."

/datum/species/ipc/get_species_lore()
	return null

/datum/species/ipc/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "IPCs can feed on electricity from APCs and powercells to restore their charge; and do not otherwise need to eat.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "robot",
			SPECIES_PERK_NAME = "Robotic",
			SPECIES_PERK_DESC = "IPCs have an entirely robotic body, meaning medical care is typically done through Robotics or Engineering. \
			Whether this is helpful or not is heavily dependent on your coworkers. It does, however, mean you are usually able to perform self-repairs easily.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "magnet",
			SPECIES_PERK_NAME = "EMP Vulnerable",
			SPECIES_PERK_DESC = "IPC organs are cybernetic, and thus susceptible to electromagnetic interference. Getting hit by an EMP may stop your heart.",
		),
	)

	return to_add

/datum/status_effect/bleeding/robotic
	alert_type = /atom/movable/screen/alert/status_effect/bleeding/robotic
	bleed_heal_multiplier = 0

/datum/status_effect/bleeding/robotic/tick()
	// Since we don't have flesh, we will instantly repair any sealed wounds
	bandaged_bleeding = 0
	..()

/datum/status_effect/bleeding/robotic/update_shown_duration()
	// The actual rate of bleeding, can be reduced by holding wounds
	// Calculate the message to show to the user
	if (HAS_TRAIT(owner, TRAIT_BLEED_HELD))
		linked_alert.name = "Leaking (Held)"
		if (bleed_rate > BLEED_RATE_MINOR)
			linked_alert.desc = "Critical leaks have been detected in your system and require welding. Leak rate slowed by applied pressure."
		else
			linked_alert.desc = "Minor leaks have been detected in your system and require welding. Leak rate slowed by applied pressure."
	else
		if (bleed_rate < BLEED_RATE_MINOR)
			linked_alert.name = "Leaking (Light)"
			linked_alert.desc = "Minor leaks have been detected in your system and require welding."
		else
			linked_alert.name = "Leaking (Heavy)"
			linked_alert.desc = "Critical leaks have been detected in your system and require welding."
	linked_alert.icon_state = "bleed_robo"

	linked_alert.maptext = MAPTEXT(owner.get_bleed_rate_string())

/atom/movable/screen/alert/status_effect/bleeding/robotic
	name = "Leaking"
	desc = "You are leaking, weld the leaks back together or you will die."
	icon_state = "bleed_robo"
