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
#define MEDIBOT_TREAT_INJECT "inject"
#define MEDIBOT_TREAT_SUCK "suck"


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
	///The last time we were tipped/righted and said a voice line, to avoid spam
	var/last_tipping_action_voice = 0
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

/mob/living/simple_animal/bot/medbot/derelict
	name = "\improper Old Medibot"
	desc = "Looks like it hasn't been modified since the late 2080s."
	skin = MEDBOT_SKIN_BEZERK
	heal_threshold = 0
	declare_crit = 0

/mob/living/simple_animal/bot/medbot/filled
	skin = MEDBOT_SKIN_ADVANCED
	heal_threshold = 30
	declare_crit = TRUE
	reagent_glass = new /obj/item/reagent_containers/glass/beaker/large/kelobic

/mob/living/simple_animal/bot/medbot/update_icon()
	cut_overlays()
	if(skin)
		add_overlay("medskin_[skin]")
	if(!on)
		icon_state = "medibot0"
		return
	if(IsStun() || IsParalyzed())
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

/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	skin = new_skin
	update_icon()

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

/mob/living/simple_animal/bot/medbot/update_mobility()
	. = ..()
	update_icon()

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

/mob/living/simple_animal/bot/medbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Medical Unit Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "<br>Behaviour controls are [locked ? "locked" : "unlocked"]<hr>"
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "Beaker: "
		if(reagent_glass)
			dat += "<A href='?src=[REF(src)];eject=1'>Loaded \[[reagent_glass.name]: [reagent_glass.reagents.total_volume]/[reagent_glass.reagents.maximum_volume]\]</a><br>"
		else
			dat += "None Loaded<br>"
		dat += "<TT>Healing Threshold: "
		dat += "<a href='?src=[REF(src)];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=[REF(src)];adj_threshold=-5'>-</a> "
		dat += "[heal_threshold] "
		dat += "<a href='?src=[REF(src)];adj_threshold=5'>+</a> "
		dat += "<a href='?src=[REF(src)];adj_threshold=10'>++</a>"
		dat += "</TT><br>"
		dat += "<TT>Injection Level: "
		dat += "<a href='?src=[REF(src)];adj_inject=-5'>-</a> "
		dat += "[injection_amount] "
		dat += "<a href='?src=[REF(src)];adj_inject=5'>+</a> "
		dat += "</TT><br>"
		dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=[REF(src)];togglevoice=[1]'>Toggle</a><br>"
		dat += "Critical Patient Alerts: <a href='?src=[REF(src)];critalerts=1'>[declare_crit ? "Yes" : "No"]</a><br>"
		dat += "Patrol Station: <a href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</a><br>"
		dat += "Stationary Mode: <a href='?src=[REF(src)];stationary=1'>[stationary_mode ? "Yes" : "No"]</a><br>"
		dat += "Synthesise Epinephrine: <a href='?src=[REF(src)];synth_epi=1'>[synth_epi ? "Yes" : "No"]</a><br>"
		dat += "<a href='?src=[REF(src)];hptech=1'>Search for Technological Advancements</a><br>"

	return dat

/mob/living/simple_animal/bot/medbot/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["adj_threshold"])
		var/adjust_num = text2num(href_list["adj_threshold"])
		heal_threshold += adjust_num
		if(heal_threshold < 5)
			heal_threshold = 5
		if(heal_threshold > 120)
			heal_threshold = 120

	else if(href_list["adj_inject"])
		var/adjust_num = text2num(href_list["adj_inject"])
		injection_amount += adjust_num
		if(injection_amount < 5)
			injection_amount = 5
		if(injection_amount > 30)
			injection_amount = 30


	else if(href_list["eject"] && (!isnull(reagent_glass)))
		reagent_glass.forceMove(drop_location())
		reagent_glass = null
		update_icon()

	else if(href_list["togglevoice"])
		shut_up = !shut_up

	else if(href_list["critalerts"])
		declare_crit = !declare_crit

	else if(href_list["stationary"])
		stationary_mode = !stationary_mode
		path = list()
		update_icon()

	else if(href_list["synth_epi"])
		synth_epi = !synth_epi

	else if(href_list["hptech"])
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
	update_controls()
	return


/mob/living/simple_animal/bot/medbot/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/reagent_containers))
		. = 1 //no afterattack
		if(locked)
			to_chat(user, "<span class='warning'>You cannot insert a beaker because the panel is locked!</span>")
			return
		if(!isnull(reagent_glass))
			to_chat(user, "<span class='warning'>There is already a beaker loaded!</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return

		reagent_glass = W
		mode = BOT_IDLE
		to_chat(user, "<span class='notice'>You insert [W].</span>")
		var/reagentlist = pretty_string_from_reagent_list(reagent_glass.reagents.reagent_list)
		log_combat(user, src, "inserted a [W] with [reagentlist]" )
		add_fingerprint(user)
		show_controls(user)
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
			to_chat(user, "<span class='notice'>You short out [src]'s reagent synthesis circuits.</span>")
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
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

/mob/living/simple_animal/bot/medbot/proc/tip_over(mob/user)
	mobility_flags &= ~MOBILITY_MOVE
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
	user.visible_message("<span class='danger'>[user] tips over [src]!</span>", "<span class='danger'>You tip [src] over!</span>")
	tipped = TRUE
	var/matrix/mat = transform
	transform = mat.Turn(180)
	tipper_name = user.name

/mob/living/simple_animal/bot/medbot/proc/set_right(mob/user)
	mobility_flags &= MOBILITY_MOVE
	var/list/messagevoice

	if(user)
		user.visible_message("<span class='notice'>[user] sets [src] right-side up!</span>", "<span class='green'>You set [src] right-side up!</span>")
		if(user.name == tipper_name)
			messagevoice = list("I forgive you." = 'sound/voice/medbot/forgive.ogg')
		else
			messagevoice = list("Thank you!" = 'sound/voice/medbot/thank_you.ogg', "You are a good person." = 'sound/voice/medbot/youre_good.ogg')
	else
		visible_message("<span class='notice'>[src] manages to writhe wiggle enough to right itself.</span>")
		messagevoice = list("Fuck you." = 'sound/voice/medbot/fuck_you.ogg', "Your behavior has been reported, have a nice day." = 'sound/voice/medbot/reported.ogg')

	tipper_name = null
	if(world.time > last_tipping_action_voice + 15 SECONDS)
		last_tipping_action_voice = world.time
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	tipped_status = MEDBOT_PANIC_NONE
	tipped = FALSE
	transform = matrix()

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
			set_right() // strong independent medbot

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
		. += "<span class='notice'>Use a spraycan to change its colour, or a pen to change its name if unlocked.</span>"
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
			. += "<span class='warning'>They are tipped over and visibly panicking!</span>"
		if(MEDBOT_PANIC_AAAA to INFINITY)
			. += "<span class='warning'><b>They are freaking out from being tipped over!</b></span>"


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

/mob/living/simple_animal/bot/medbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_DISARM && !tipped)
		H.visible_message("<span class='danger'>[H] begins tipping over [src].</span>", "<span class='warning'>You begin tipping over [src]...</span>")

		if(world.time > last_tipping_action_voice + 15 SECONDS)
			last_tipping_action_voice = world.time // message for tipping happens when we start interacting, message for righting comes after finishing
			var/list/messagevoice = list("Hey, wait..." = 'sound/voice/medbot/hey_wait.ogg',"Please don't..." = 'sound/voice/medbot/please_dont.ogg',"I trusted you..." = 'sound/voice/medbot/i_trusted_you.ogg', "Nooo..." = 'sound/voice/medbot/nooo.ogg', "Oh fuck-" = 'sound/voice/medbot/oh_fuck.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(src, messagevoice[message], 70, FALSE)

		if(do_after(H, 3 SECONDS, target=src))
			tip_over(H)

	else if(H.a_intent == INTENT_HELP && tipped)
		H.visible_message("<span class='notice'>[H] begins righting [src].</span>", "<span class='notice'>You begin righting [src]...</span>")
		if(do_after(H, 3 SECONDS, target=src))
			set_right(H)
	else
		..()

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
			treat_behaviour = MEDIBOT_TREAT_SUCK // Emagged! Time to drain everybody.

		if(!treat_behaviour && reagent_glass?.reagents.total_volume) //have a beaker with something?
			treat_behaviour = MEDIBOT_TREAT_INJECT

			for(var/datum/reagent/each_beaker_reagent in reagent_glass.reagents.reagent_list)
				if(C.reagents.has_reagent(each_beaker_reagent.type)) // they have the chems inside them already
					treat_behaviour = null
					break

		if(!treat_behaviour) //If they don't need any of that they're probably cured!
			if(C.maxHealth - C.health < heal_threshold)
				to_chat(src, "<span class='notice'>[C] is healthy! Your programming prevents you from injecting anyone without at least [heal_threshold] damage of any one type ([heal_threshold + 15] for oxygen damage.)</span>")
			var/list/messagevoice = list("All patched up!" = 'sound/voice/medbot/patchedup.ogg',"An apple a day keeps me away." = 'sound/voice/medbot/apple.ogg',"Feel better soon!" = 'sound/voice/medbot/feelbetter.ogg')
			var/message = pick(messagevoice)
			speak(message, radio_channel)
			playsound(src, messagevoice[message], 50)
			bot_reset()
			return


		C.visible_message("<span class='danger'>[src] is trying to inject [patient]!</span>", "<span class='userdanger'>[src] is trying to inject you!</span>")
		if( get_dist(src, patient) > 1 || \
				!do_after(src, 2 SECONDS, patient) ||\
				!assess_patient(patient) || \
				!on) //are they near us? did they move away? are they still hurt? are we stil on?
			visible_message("[src] retracts its syringe.")
			update_icon()
			soft_reset()
			return

		switch(treat_behaviour)
			if(MEDIBOT_TREAT_INJECT)
				if(reagent_glass?.reagents.total_volume)
					var/fraction = min(injection_amount/reagent_glass.reagents.total_volume, 1)
					var/reagentlist = pretty_string_from_reagent_list(reagent_glass.reagents.reagent_list)
					log_combat(src, patient, "injected", "beaker source", "[reagentlist]:[injection_amount]")
					reagent_glass.reagents.reaction(patient, INJECT, fraction)
					reagent_glass.reagents.trans_to(patient,injection_amount/efficiency, efficiency) //Inject from beaker.
					if(!reagent_glass.reagents.total_volume && !synth_epi) //when empty, alert medbay unless we're on synth mode
						var/list/messagevoice = list("Can someone fill me back up?" = 'sound/voice/medbot/fillmebackup.ogg',"I need new medicine." = 'sound/voice/medbot/needmedicine.ogg',"I need to restock." = 'sound/voice/medbot/needtorestock.ogg')
						var/message = pick(messagevoice)
						speak(message,radio_channel)
						playsound(src, messagevoice[message], 50)
						COOLDOWN_START(src, declare_cooldown, 10 SECONDS)
			if(MEDIBOT_TREAT_SUCK)
				if(patient.transfer_blood_to(reagent_glass, injection_amount))
					patient.visible_message("<span class='danger'>[src] is trying to inject [patient]!</span>", \
						"<span class='userdanger'>[src] is trying to inject you!</span>")
					log_combat(src, patient, "drained of blood")
				else
					to_chat(src, "<span class='warning'>You are unable to draw any blood from [patient]!</span>")
		C.visible_message("<span class='danger'>[src] injects [patient] with its syringe!</span>", \
			"<span class='userdanger'>[src] injects you with its syringe!</span>")
		update_icon()
		soft_reset()
		return


/mob/living/simple_animal/bot/medbot/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
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
