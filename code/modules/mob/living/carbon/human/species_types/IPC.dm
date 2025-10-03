/datum/species/ipc
	name = "\improper Integrated Positronic Chassis"
	plural_form = "IPCs"
	id = SPECIES_IPC
	bodyflag = FLAG_IPC
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
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_EASYDISMEMBER,
		TRAIT_POWERHUNGRY,
		TRAIT_XENO_IMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
	)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	mutantbrain = /obj/item/organ/brain/positron
	mutanteyes = /obj/item/organ/eyes/robotic
	mutanttongue = /obj/item/organ/tongue/robot
	mutantliver = /obj/item/organ/liver/cybernetic/upgraded/ipc
	mutantstomach = /obj/item/organ/stomach/battery/ipc
	mutantears = /obj/item/organ/ears/robot
	mutantheart = /obj/item/organ/heart/cybernetic/ipc
	mutantlungs = null
	mutantappendix = null
	mutant_organs = list(/obj/item/organ/cyberimp/arm/power_cord)
	mutant_bodyparts = list("mcolor" = "#7D7D7D", "ipc_screen" = "Static", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics (Custom)")
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/iron{amount = 10}

	burnmod = 2
	heatmod = 1.5
	brutemod = 1
	clonemod = 0
	staminamod = 0.8
	siemens_coeff = 1.5
	reagent_tag = PROCESS_SYNTHETIC
	species_gibs = GIB_TYPE_ROBOTIC
	attack_sound = 'sound/items/trayhit1.ogg'
	allow_numbers_in_name = TRUE
	deathsound = "sound/voice/borg_deathsound.ogg"
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	species_language_holder = /datum/language_holder/synthetic
	special_step_sounds = list('sound/effects/servostep.ogg')
	species_bitflags = NOT_TRANSMORPHIC

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

/datum/species/ipc/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.posibrain_names)]-[rand(100, 999)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

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
	icon_icon = 'icons/hud/actions/actions_silicon.dmi'
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
	H.eye_color = sanitize_hexcolor(color_choice)
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
	var/obj/item/organ/stomach/battery/battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!battery)
		to_chat(H, span_warning("You try to siphon energy from \the [target], but your power cell is gone!"))
		return

	if(istype(H) && H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
		to_chat(user, span_warning("You are already fully charged!"))
		return

	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.cell && A.cell.charge > A.cell.maxcharge/4)
			powerdraw_loop(A, H, TRUE)
			return
		else
			to_chat(user, span_warning("There is not enough charge to draw from that APC."))
			return

	if(isethereal(target))
		var/mob/living/carbon/human/target_ethereal = target
		var/obj/item/organ/stomach/battery/target_battery = target_ethereal.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(target_ethereal.nutrition > 0 && target_battery)
			powerdraw_loop(target_battery, H, FALSE)
			return
		else
			to_chat(user, span_warning("There is not enough charge to draw from that being!"))
			return
/obj/item/apc_powercord/proc/powerdraw_loop(atom/target, mob/living/carbon/human/H, apc_target)
	H.visible_message(span_notice("[H] inserts a power connector into [target]."), span_notice("You begin to draw power from the [target]."))
	var/obj/item/organ/stomach/battery/battery = H.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(apc_target)
		var/obj/machinery/power/apc/A = target
		if(!istype(A))
			return
		while(do_after(H, 10, target = A))
			if(!battery)
				to_chat(H, span_warning("You need a battery to recharge!"))
				break
			if(loc != H)
				to_chat(H, span_warning("You must keep your connector out while charging!"))
				break
			if(A.cell.charge <= A.cell.maxcharge/4)
				to_chat(H, span_warning("The [A] doesn't have enough charge to spare."))
				break
			A.charging = 1
			if(A.cell.charge > A.cell.maxcharge/4 + 250)
				battery.adjust_charge(250)
				A.cell.charge -= 250
				to_chat(H, span_notice("You siphon off some of the stored charge for your own use."))
			else
				battery.adjust_charge(A.cell.charge - A.cell.maxcharge/4)
				A.cell.charge = A.cell.maxcharge/4
				to_chat(H, span_notice("You siphon off as much as the [A] can spare."))
				break
			if(battery.charge >= battery.max_charge)
				to_chat(H, span_notice("You are now fully charged."))
				break
	else
		var/obj/item/organ/stomach/battery/A = target
		if(!istype(A))
			return
		var/charge_amt
		while(do_after(H, 10, target = A.owner))
			if(!battery)
				to_chat(H, span_warning("You need a battery to recharge!"))
				break
			if(loc != H)
				to_chat(H, span_warning("You must keep your connector out while charging!"))
				break
			if(A.charge == 0)
				to_chat(H, span_warning("[A] is completely drained!"))
				break
			charge_amt = A.charge <= 50 ? A.charge : 50
			A.adjust_charge(-1 * charge_amt)
			battery.adjust_charge(charge_amt)
			if(battery.charge >= battery.max_charge)
				to_chat(H, span_notice("You are now fully charged."))
				break

	H.visible_message(span_notice("[H] unplugs from the [target]."), span_notice("You unplug from the [target]."))
	return

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
	return list("bleed" = "leaking", "brute" = "denting", "burn" = "burns")

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

/datum/status_effect/bleeding/robotic/update_icon()
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
