GLOBAL_VAR(medibot_unique_id_gen)
//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY

#define MEDBOT_PANIC_NONE	0
#define MEDBOT_PANIC_LOW	15
#define MEDBOT_PANIC_MED	35
#define MEDBOT_PANIC_HIGH	55
#define MEDBOT_PANIC_AAAA	70
#define MEDBOT_PANIC_ENDING	90
#define MEDBOT_PANIC_END	100
#define MEDBOT_TREAT_INJECT "inject"
#define MEDBOT_TREAT_SUCK "suck"
#define MEDBOT_TREAT_BANDAGE "bandage"


/mob/living/simple_animal/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "medibot0"
	density = FALSE
	anchored = FALSE
	health = 20
	maxHealth = 20
	pass_flags = PASSMOB

	status_flags = (CANPUSH | CANSTUN)

	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

	bot_type = MED_BOT
	model = "Medibot"
	bot_core_type = /obj/machinery/bot_core/medbot
	window_id = "automed"
	window_name = "Automatic Medical Unit v1.1"
	data_hud_type = DATA_HUD_MEDICAL_ADVANCED
	path_image_color = "#DDDDFF"
	var/obj/item/reagent_containers/reagent_glass = null //Can be set to draw from this for reagents.
	var/healthanalyzer = /obj/item/healthanalyzer
	var/firstaid = /obj/item/storage/firstaid
	var/skin = null //based off medkit_X skins in aibots.dmi for your selection; X goes here IE medskin_tox means skin var should be "tox"
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 95 //Start healing when they have this much damage
	var/efficiency = 1.1 //how much of the internal beaker gets used
	var/declare_crit = 1 //If active, the bot will transmit a critical patient alert to MedHUD users.
	var/stationary_mode = 0 //If enabled, the Medibot will not move automatically.
	//Are we tipped over? Used to stop the mode from being conflicted.
	var/tipped = FALSE
	///How panicked we are about being tipped over (why would you do this?)
	var/tipped_status = MEDBOT_PANIC_NONE
	///The name we got when we were tipped
	var/tipper_name
	///Cooldown to track last time we were tipped/righted and said a voice line, to avoid spam
	COOLDOWN_DECLARE(last_tipping_action_voice)
	var/shut_up = 0 //self explanatory :)
	var/datum/techweb/linked_techweb
	var/medibot_counter = 0 //we use this to stop multibotting
	var/synth_epi = TRUE
	COOLDOWN_DECLARE(synth_cooldown) //prevents spam of "I need a refill!"
	COOLDOWN_DECLARE(declare_cooldown) //Prevents spam of critical patient alerts.

/mob/living/simple_animal/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = MEDBOT_SKIN_BEZERK
	faction = list(FACTION_CREATURE, FACTION_NEUTRAL)

/mob/living/simple_animal/bot/medbot/derelict
	name = "\improper Old Medibot"
	desc = "Looks like it hasn't been modified since the late 2080s."
	skin = MEDBOT_SKIN_BEZERK
	heal_threshold = 0
	declare_crit = 0

/mob/living/simple_animal/bot/medbot/nukie
	name = "\improper Oppenheimer"
	desc = "A medibot stolen from a Nanotrasen station and upgraded by the Syndicate."
	skin = MEDBOT_SKIN_BEZERK
	health = 40
	maxHealth = 40
	radio_key = /obj/item/encryptionkey/syndicate
	radio_channel = RADIO_CHANNEL_SYNDICATE
	heal_threshold = 30
	reagent_glass = new /obj/item/reagent_containers/cup/beaker/large/nanites
	faction = list(FACTION_SYNDICATE, FACTION_NEUTRAL, FACTION_SILICON)

/mob/living/simple_animal/bot/medbot/filled
	skin = MEDBOT_SKIN_ADVANCED
	heal_threshold = 30
	declare_crit = TRUE
	reagent_glass = new /obj/item/reagent_containers/chem_bag/triamed

/mob/living/simple_animal/bot/medbot/update_icon()
	cut_overlays()
	if(skin)
		add_overlay("medskin_[skin]")
	if(!on)
		icon_state = "medibot0"
		return
	if(HAS_TRAIT(src, TRAIT_INCAPACITATED))
		icon_state = "medibota"
		return
	if(mode == BOT_HEALING)
		icon_state = "medibots[stationary_mode]"
		return
	else if(mode== BOT_EMPTY) //Bot has grey light if empty
		icon_state = "medibot_empty"
	else if(stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "medibot2"
	else
		icon_state = "medibot1"

/mob/living/simple_animal/bot/medbot/proc/rename_bot()
	var/t = sanitize_name(stripped_input(usr, "Enter new robot name", name, name,MAX_NAME_LEN))
	if(!t)
		return
	if(!in_range(src, usr) && loc != usr)
		return
	name = t

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/bot/medbot)

/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()

	if(!isnull(new_skin))
		skin = new_skin
	update_appearance()

	var/datum/job/J = SSjob.GetJob(JOB_NAME_MEDICALDOCTOR)
	access_card.access = J.get_access()
	prev_access = access_card.access.Copy()
	linked_techweb = SSresearch.science_tech

	if(mapload)
		reagent_glass = new /obj/item/reagent_containers/chem_bag/epi
	if(!GLOB.medibot_unique_id_gen)
		GLOB.medibot_unique_id_gen = 0
	medibot_counter = GLOB.medibot_unique_id_gen
	GLOB.medibot_unique_id_gen++

	AddComponent(/datum/component/tippable, \
		tip_time = 3 SECONDS, \
		untip_time = 3 SECONDS, \
		self_right_time = 3.5 MINUTES, \
		pre_tipped_callback = CALLBACK(src, PROC_REF(pre_tip_over)), \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_tip_over)), \
		post_untipped_callback = CALLBACK(src, PROC_REF(after_righted)))

/mob/living/simple_animal/bot/medbot/bot_reset()
	..()
	set_patient(null)
	oldpatient = null
	oldloc = null
	last_found = world.time
	COOLDOWN_RESET(src, declare_cooldown)
	update_icon()

/mob/living/simple_animal/bot/medbot/proc/soft_reset() //Allows the medibot to still actively perform its medical duties without being completely halted as a hard reset does.
	path = list()
	set_patient(null)
	oldpatient = null
	mode = BOT_IDLE
	last_found = world.time
	update_icon()

/mob/living/simple_animal/bot/medbot/set_custom_texts()

	text_hack = "You corrupt [name]'s reagent processor circuits."
	text_dehack = "You reset [name]'s reagent processor circuits."
	text_dehack_fail = "[name] seems damaged and does not respond to reprogramming!"

/mob/living/simple_animal/bot/medbot/attack_paw(mob/user)
	return attack_hand(user)

/mob/living/simple_animal/bot/medbot/ui_data(mob/user)
	var/list/data = ..()
	if(!locked || issilicon(user) || IsAdminGhost(user))
		data["custom_controls"]["container"] = list(
			"reagent_glass" = reagent_glass,
			"total_volume" = reagent_glass?.reagents.total_volume,
			"maximum_volume" = reagent_glass?.reagents.maximum_volume
		)
		data["custom_controls"]["heal_threshold"] = heal_threshold
		data["custom_controls"]["injection_amount"] = injection_amount
		data["custom_controls"]["speaker"] = !shut_up
		data["custom_controls"]["crit_alerts"] = declare_crit
		data["custom_controls"]["stationary_mode"] = stationary_mode
		data["custom_controls"]["synth_epi"] = synth_epi
		data["custom_controls"]["sync_tech"] = efficiency
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/medbot/ui_act(action, params)
	if(..())
		return TRUE
	switch(action)
		if("eject")
			if (!isnull(reagent_glass))
				reagent_glass.forceMove(drop_location())
				reagent_glass = null
				update_icon()
		if("heal_threshold")
			var/adjust_num = round(text2num(params["threshold"]))
			heal_threshold = adjust_num
			if(heal_threshold < 5)
				heal_threshold = 5
			if(heal_threshold > 120)
				heal_threshold = 120
		if("injection_amount")
			var/adjust_num = round(text2num(params["inject"]))
			injection_amount = adjust_num
			if(injection_amount < 5)
				injection_amount = 5
			if(injection_amount > 30)
				injection_amount = 30
		if("speaker")
			shut_up = !shut_up
		if("crit_alerts")
			declare_crit = !declare_crit
		if("stationary_mode")
			stationary_mode = !stationary_mode
			path = list()
		if("synth_epi")
			synth_epi = !synth_epi
		if("sync_tech")
			var/old_eff = efficiency
			var/tech_boosters
			for(var/i in linked_techweb.researched_designs)
				var/datum/design/surgery/healing/D = SSresearch.techweb_design_by_id(i)
				if(!istype(D))
					continue
				tech_boosters++
			if(tech_boosters)
				efficiency = 1+(0.075*tech_boosters) //increase efficiency by 7.5% for every surgery researched
				if(old_eff < efficiency)
					speak("Surgical research data found! Efficiency increased by [round(efficiency/old_eff*100)]%!")
					window_name = "Automatic Medical Unit v[efficiency]"

/mob/living/simple_animal/bot/medbot/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/reagent_containers))
		. = 1 //no afterattack
		if(locked)
			to_chat(user, span_warning("You cannot insert a beaker because the panel is locked!"))
			return
		if(!isnull(reagent_glass))
			to_chat(user, span_warning("There is already a beaker loaded!"))
			return
		if(!user.transferItemToLoc(W, src))
			return

		reagent_glass = W
		mode = BOT_IDLE
		to_chat(user, span_notice("You insert [W]."))
		var/reagentlist = pretty_string_from_reagent_list(reagent_glass.reagents.reagent_list)
		log_combat(user, src, "inserted a [W] with [reagentlist]" )
		add_fingerprint(user)
		update_icon()

	if(istype(W, /obj/item/pen)&&!locked)
		rename_bot()
		return
	if(istype(W,/obj/item/toy/crayon/spraycan))
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		reskin(user)

	else
		var/current_health = health
		..()
		if(health < current_health) //if medbot took some damage
			step_to(src, (get_step_away(src,user)))

/mob/living/simple_animal/bot/medbot/proc/reskin(mob/M)
	var/skinlist = list(
		MEDBOT_SKIN_DEFAULT = image(icon = 'icons/mob/aibots.dmi', icon_state = "firstaid_arm"),
		MEDBOT_SKIN_BRUTE= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_brute"),
		MEDBOT_SKIN_BURN= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_burn"),
		MEDBOT_SKIN_TOXIN= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_tox"),
		MEDBOT_SKIN_OXY= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_oxy"),
		MEDBOT_SKIN_SURGERY= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_surgery"),
		MEDBOT_SKIN_ADVANCED= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_advanced"),
		MEDBOT_SKIN_RADIATION= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_rad")
	)
	if(emagged)
		skinlist +=list(MEDBOT_SKIN_SYNDI= image(icon = 'icons/mob/aibots.dmi', icon_state = "kit_skin_syndi"),
			MEDBOT_SKIN_BEZERK= image(icon = 'icons/mob/aibots.dmi', icon_state = "medskin_bezerk")
			)
	var/choice = show_radial_menu(M, src, skinlist, radius = 42, require_near = TRUE)
	if(choice && !M.incapacitated() && in_range(M,src))
		skin = choice
		update_icon()

/mob/living/simple_animal/bot/medbot/on_emag(atom/target, mob/user)
	..()
	if(emagged == 2)
		declare_crit = 0
		if(user)
			to_chat(user, span_notice("You short out [src]'s reagent synthesis circuits."))
		audible_message(span_danger("[src] buzzes oddly!"))
		flick("medibot_spark", src)
		playsound(src, "sparks", 75, TRUE)
		if(user)
			oldpatient = user

/mob/living/simple_animal/bot/medbot/process_scan(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return

	if((H == oldpatient) && (world.time < last_found + 200))
		return

	if(assess_patient(H))
		last_found = world.time
		if((last_newpatient_speak + 300) < world.time) //Don't spam these messages!
			var/list/messagevoice = list("Hey, [H.name]! Hold on, I'm coming." = 'sound/voice/medbot/coming.ogg',"Wait [H.name]! I want to help!" = 'sound/voice/medbot/help.ogg',"[H.name], you appear to be injured!" = 'sound/voice/medbot/injured.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(src, messagevoice[message], 50, 0)
			last_newpatient_speak = world.time
		return H
	else
		return

/*
 * Proc used in a callback for before this medibot is tipped by the tippable component.
 *
 * user - the mob who is tipping us over
 */
/mob/living/simple_animal/bot/medbot/proc/pre_tip_over(mob/user)
	if(!COOLDOWN_FINISHED(src, last_tipping_action_voice))
		return

	COOLDOWN_START(src, last_tipping_action_voice, 15 SECONDS) // message for tipping happens when we start interacting, message for righting comes after finishing
	var/static/list/messagevoice = list(
		"Hey, wait..." = 'sound/voice/medbot/hey_wait.ogg',
		"Please don't..." = 'sound/voice/medbot/please_dont.ogg',
		"I trusted you..." = 'sound/voice/medbot/i_trusted_you.ogg',
		"Nooo..." = 'sound/voice/medbot/nooo.ogg',
		"Oh fuck-" = 'sound/voice/medbot/oh_fuck.ogg',
		)
	var/message = pick(messagevoice)
	speak(message)
	playsound(src, messagevoice[message], 70, FALSE)

/*
 * Proc used in a callback for after this medibot is tipped by the tippable component.
 *
 * user - the mob who tipped us over
 */
/mob/living/simple_animal/bot/medbot/proc/after_tip_over(mob/user)
	tipped = TRUE
	tipper_name = user.name
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)

/*
 * Proc used in a callback for after this medibot is righted, either by themselves or by a mob, by the tippable component.
 *
 * user - the mob who righted us. Can be null.
 */
/mob/living/simple_animal/bot/medbot/proc/after_righted(mob/user)
	var/list/messagevoice
	if(user)
		if(user.name == tipper_name)
			messagevoice = list("I forgive you." = 'sound/voice/medbot/forgive.ogg')
		else
			messagevoice = list("Thank you!" = 'sound/voice/medbot/thank_you.ogg', "You are a good person." = 'sound/voice/medbot/youre_good.ogg')
	else
		messagevoice = list("Fuck you." = 'sound/voice/medbot/fuck_you.ogg', "Your behavior has been reported, have a nice day." = 'sound/voice/medbot/reported.ogg')

	tipper_name = null
	if(COOLDOWN_FINISHED(src, last_tipping_action_voice))
		COOLDOWN_START(src, last_tipping_action_voice, 15 SECONDS)
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	tipped_status = MEDBOT_PANIC_NONE
	tipped = FALSE

/// if someone tipped us over, check whether we should ask for help or just right ourselves eventually
/mob/living/simple_animal/bot/medbot/proc/handle_panic()
	tipped_status++
	var/list/messagevoice

	switch(tipped_status)
		if(MEDBOT_PANIC_LOW)
			messagevoice = list("I require assistance." = 'sound/voice/medbot/i_require_asst.ogg')
		if(MEDBOT_PANIC_MED)
			messagevoice = list("Please put me back." = 'sound/voice/medbot/please_put_me_back.ogg')
		if(MEDBOT_PANIC_HIGH)
			messagevoice = list("Please, I am scared!" = 'sound/voice/medbot/please_im_scared.ogg')
		if(MEDBOT_PANIC_AAAA)
			messagevoice = list("I DON'T LIKE THIS, I NEED HELP!" = 'sound/voice/medbot/dont_like.ogg', "THIS HURTS, MY PAIN IS REAL!" = 'sound/voice/medbot/pain_is_real.ogg')
		if(MEDBOT_PANIC_ENDING)
			messagevoice = list("Is this the end?" = 'sound/voice/medbot/is_this_the_end.ogg', "Nooo!" = 'sound/voice/medbot/nooo.ogg')
		if(MEDBOT_PANIC_END)
			speak("PSYCH ALERT: Crewmember [tipper_name] recorded displaying antisocial tendencies by torturing bots in [get_area(src)]. Please schedule psych evaluation.", radio_channel)

	if(prob(tipped_status))
		do_jitter_animation(tipped_status * 0.1)

	if(messagevoice)
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	else if(prob(tipped_status * 0.2))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 30, extrarange=-2)

/mob/living/simple_animal/bot/medbot/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += span_notice("Use a spraycan to change its colour, or a pen to change its name if unlocked.")
	if(tipped_status == MEDBOT_PANIC_NONE)
		return

	switch(tipped_status)
		if(MEDBOT_PANIC_NONE to MEDBOT_PANIC_LOW)
			. += "It appears to be tipped over, and is quietly waiting for someone to set it right."
		if(MEDBOT_PANIC_LOW to MEDBOT_PANIC_MED)
			. += "It is tipped over and requesting help."
		if(MEDBOT_PANIC_MED to MEDBOT_PANIC_HIGH)
			. += "They are tipped over and appear visibly distressed." // now we humanize the medbot as a they, not an it
		if(MEDBOT_PANIC_HIGH to MEDBOT_PANIC_AAAA)
			. += span_warning("They are tipped over and visibly panicking!")
		if(MEDBOT_PANIC_AAAA to INFINITY)
			. += span_warning("<b>They are freaking out from being tipped over!</b>")


/mob/living/simple_animal/bot/medbot/handle_automated_action()
	if(!..())
		return

	if(!reagent_glass?.reagents.total_volume)
		mode = BOT_EMPTY
		update_icon()
		if(COOLDOWN_FINISHED(src, synth_cooldown) && synth_epi && reagent_glass)
			reagent_glass.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
			playsound(src, "sound/effects/bubbles.ogg", 40)
			COOLDOWN_START(src, synth_cooldown, 5 MINUTES)
		return
	if(tipped)
		handle_panic()
		return

	if(mode == BOT_HEALING)
		return

	if(IsStun() || IsParalyzed())
		set_patient(null)
		mode = BOT_IDLE
		return

	if(frustration > 8)
		soft_reset()

	if(QDELETED(patient))
		if(!shut_up && prob(1))
			if(emagged && prob(30))
				var/list/i_need_scissors = list('sound/voice/medbot/fuck_you.ogg', 'sound/voice/medbot/im_different.ogg', 'sound/voice/medbot/shindemashou.ogg') //some lines removed because they are very LRP/meta, doesn't fit with bee
				playsound(src, pick(i_need_scissors), 70)
			else
				var/list/messagevoice = list("Radar, put a mask on!" = 'sound/voice/medbot/radar.ogg',"There's always a catch, and I'm the best there is." = 'sound/voice/medbot/catch.ogg',"I knew it, I should've been a plastic surgeon." = 'sound/voice/medbot/surgeon.ogg',"What kind of medbay is this? Everyone's dropping like flies." = 'sound/voice/medbot/flies.ogg',"Delicious!" = 'sound/voice/medbot/delicious.ogg', "Why are we still here? Just to suffer?" = 'sound/voice/medbot/why.ogg')
				var/message = pick(messagevoice)
				speak(message)
				playsound(src, messagevoice[message], 50)
		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE) //If in stationary mode, scan range is limited to adjacent patients.
		set_patient(scan(/mob/living/carbon/human, oldpatient, scan_range))

	if(patient && (get_dist(src,patient) <= 1)) //Patient is next to us, begin treatment!
		if(mode != BOT_HEALING)
			mode = BOT_HEALING
			update_icon()
			frustration = 0
			medicate_patient(patient)
		return

	//Patient has moved away from us!
	else if(patient && path.len && (get_dist(patient,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	else if(stationary_mode && patient) //Since we cannot move in this mode, ignore the patient and wait for another.
		soft_reset()
		return

	if(patient && path.len == 0 && (get_dist(src,patient) > 1))
		path = get_path_to(src, patient, 30,id=access_card)
		mode = BOT_MOVING
		if(!path.len) //try to get closer if you can't reach the patient directly
			path = get_path_to(src, patient, 30,1,id=access_card)
			if(!path.len) //Do not chase a patient we cannot reach.
				soft_reset()

	if(path.len > 0 && patient)
		if(!bot_move(path[path.len]))
			soft_reset()
		return

	if(path.len > 8 && patient)
		frustration++

	if(auto_patrol && !stationary_mode && !patient)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	return

/mob/living/simple_animal/bot/medbot/proc/assess_patient(mob/living/carbon/C)
	//Time to see if they need medical help!
	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		return FALSE	//welp too late for them!

	var/can_inject = FALSE
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/part = X
		if(IS_ORGANIC_LIMB(part))
			can_inject = TRUE
	if(!can_inject)
		return 0

	if(!(loc == C.loc) && !(isturf(C.loc) && isturf(loc)))
		return FALSE

	if(C.suiciding)
		return FALSE //Kevorkian school of robotic medical assistants.

	if(C.dna.species.reagent_tag==PROCESS_SYNTHETIC) //robots don't need our medicine
		return FALSE

	if(emagged == 2) //Everyone needs our medicine. (Our medicine is bloodloss)
		return TRUE

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if (H.wear_suit && H.head && isclothing(H.wear_suit) && isclothing(H.head))
			var/obj/item/clothing/CS = H.wear_suit
			var/obj/item/clothing/CH = H.head
			if (CS.clothing_flags & CH.clothing_flags & THICKMATERIAL)
				return FALSE // Skip over them if they have no exposed flesh.
		if(H.is_bleeding())
			return TRUE

	if(declare_crit && C.health <= 0) //Critical condition! Call for help!
		declare(C)


	if(!reagent_glass?.reagents.total_volume) // no beaker, we can't do that
		return FALSE

	for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
		if(C.reagents.has_reagent(R.type))
			return FALSE

	if(C.maxHealth - C.health >= heal_threshold) // a true patient
		return TRUE

	return FALSE // we shouldn't get random TRUE cases

/mob/living/simple_animal/bot/medbot/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		set_patient(C)
		mode = BOT_HEALING
		update_icon()
		medicate_patient(C)
		update_icon()
	else
		..()

/mob/living/simple_animal/bot/medbot/examinate(atom/A as mob|obj|turf in view())
	..()
	if(!is_blind(src))
		chemscan(src, A)

/mob/living/simple_animal/bot/medbot/proc/medicate_patient(mob/living/carbon/C)
	if(!on)
		return

	if(!istype(C))
		soft_reset()
		return

	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		var/list/messagevoice = list("No! Stay with me!" = 'sound/voice/medbot/no.ogg',"Live, damnit! LIVE!" = 'sound/voice/medbot/live.ogg',"I...I've never lost a patient before. Not today, I mean." = 'sound/voice/medbot/lost.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 50)
		soft_reset()
		return

	var/tending = TRUE
	while(tending)
		if(tipped)
			soft_reset()
			break


		var/treat_behaviour // what this medibot will do?

		if(emagged)
			treat_behaviour = MEDBOT_TREAT_SUCK // Emagged! Time to drain everybody.

		if(!treat_behaviour && ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.is_bleeding())
				treat_behaviour = MEDBOT_TREAT_BANDAGE

		if(!treat_behaviour && reagent_glass?.reagents.total_volume) //have a beaker with something?
			treat_behaviour = MEDBOT_TREAT_INJECT

			for(var/datum/reagent/each_beaker_reagent in reagent_glass.reagents.reagent_list)
				if(C.reagents.has_reagent(each_beaker_reagent.type)) // they have the chems inside them already
					treat_behaviour = null
					break

		if(!treat_behaviour) //If they don't need any of that they're probably cured!
			if(C.maxHealth - C.health < heal_threshold)
				to_chat(src, span_notice("[C] is healthy! Your programming prevents you from injecting anyone without at least [heal_threshold] damage of any one type ([heal_threshold + 15] for oxygen damage.)"))
			var/list/messagevoice = list("All patched up!" = 'sound/voice/medbot/patchedup.ogg',"An apple a day keeps me away." = 'sound/voice/medbot/apple.ogg',"Feel better soon!" = 'sound/voice/medbot/feelbetter.ogg')
			var/message = pick(messagevoice)
			speak(message, radio_channel)
			playsound(src, messagevoice[message], 50)
			bot_reset()
			return

		var/tool_action = "inject"
		if(treat_behaviour == MEDBOT_TREAT_BANDAGE)
			tool_action = "bandage"
		C.visible_message(span_danger("[src] is trying to [tool_action] [patient]!"), span_userdanger("[src] is trying to [tool_action] you!"))
		if(get_dist(src, patient) > 1 || \
				!do_after(src, 2 SECONDS, patient) ||\
				!assess_patient(patient) || \
				!on) //are they near us? did they move away? are they still hurt? are we stil on?
			visible_message("[src] retracts its tools.")
			update_icon()
			soft_reset()
			return

		switch(treat_behaviour)
			if(MEDBOT_TREAT_INJECT)
				if(reagent_glass?.reagents.total_volume)
					var/fraction = min(injection_amount/reagent_glass.reagents.total_volume, 1)
					var/reagentlist = pretty_string_from_reagent_list(reagent_glass.reagents.reagent_list)
					log_combat(src, patient, "injected", "beaker source", "[reagentlist]:[injection_amount]")
					reagent_glass.reagents.expose(patient, INJECT, fraction)
					reagent_glass.reagents.trans_to(patient,injection_amount/efficiency, efficiency) //Inject from beaker.
					if(!reagent_glass.reagents.total_volume && !synth_epi) //when empty, alert medbay unless we're on synth mode
						var/list/messagevoice = list("Can someone fill me back up?" = 'sound/voice/medbot/fillmebackup.ogg',"I need new medicine." = 'sound/voice/medbot/needmedicine.ogg',"I need to restock." = 'sound/voice/medbot/needtorestock.ogg')
						var/message = pick(messagevoice)
						speak(message,radio_channel)
						playsound(src, messagevoice[message], 50)
						COOLDOWN_START(src, declare_cooldown, 10 SECONDS)
					C.visible_message(span_danger("[src] injects [patient] with its syringe!"), \
					span_userdanger("[src] injects you with its syringe!"))
			if(MEDBOT_TREAT_BANDAGE)
				var/mob/living/carbon/human/H = C
				if(!H.is_bleeding())
					to_chat(src, span_warning("[H] isn't bleeding!"))
					update_icon()
					soft_reset()
					return
				H.suppress_bloodloss(BLEED_SURFACE) // as good as a improvized medical gauze
				C.visible_message(span_danger("[src] bandages [patient] with its gauze!"), \
				span_userdanger("[src] bandages you with its gauze!"))
			if(MEDBOT_TREAT_SUCK)
				if(patient.transfer_blood_to(reagent_glass, injection_amount))
					patient.visible_message(span_danger("[src] is trying to inject [patient]!"), \
						span_userdanger("[src] is trying to inject you!"))
					log_combat(src, patient, "drained of blood")
				else
					to_chat(src, span_warning("You are unable to draw any blood from [patient]!"))
				C.visible_message(span_danger("[src] injects [patient] with its syringe!"), \
				span_userdanger("[src] injects you with its syringe!"))
		update_icon()
		soft_reset()
		return


/mob/living/simple_animal/bot/medbot/explode()
	on = FALSE
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	drop_part(firstaid, Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	drop_part(healthanalyzer, Tsec)

	if(reagent_glass)
		drop_part(reagent_glass, Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)

	if(emagged && prob(25))
		playsound(src, 'sound/voice/medbot/insult.ogg', 50)

	do_sparks(3, TRUE, src)
	..()

/mob/living/simple_animal/bot/medbot/proc/set_patient(new_patient)
	if(patient)
		REMOVE_TRAIT(patient,TRAIT_MEDIBOTCOMINGTHROUGH,medibot_counter)
		oldpatient = patient
	patient = new_patient
	if(patient)
		ADD_TRAIT(patient,TRAIT_MEDIBOTCOMINGTHROUGH,medibot_counter)

/mob/living/simple_animal/bot/medbot/proc/declare(crit_patient)
	if(!COOLDOWN_FINISHED(src, declare_cooldown))
		return
	var/area/location = get_area(src)
	speak("Medical emergency! [crit_patient || "A patient"] is in critical condition at [location]!",radio_channel)
	COOLDOWN_START(src, declare_cooldown, 20 SECONDS)

/obj/machinery/bot_core/medbot
	req_one_access = list(ACCESS_MEDICAL, ACCESS_ROBOTICS)
#undef MEDBOT_PANIC_NONE
#undef MEDBOT_PANIC_LOW
#undef MEDBOT_PANIC_MED
#undef MEDBOT_PANIC_HIGH
#undef MEDBOT_PANIC_AAAA
#undef MEDBOT_PANIC_ENDING
#undef MEDBOT_PANIC_END

#undef MEDBOT_TREAT_INJECT
#undef MEDBOT_TREAT_SUCK
#undef MEDBOT_TREAT_BANDAGE
