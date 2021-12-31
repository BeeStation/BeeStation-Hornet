/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'
	icon_state = "repairbot"
	mouse_opacity = MOUSE_OPACITY_ICON
	density = FALSE
	hud_type = /datum/hud/pai
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	desc = "A generic pAI mobile hard-light holographics emitter. It seems to be deactivated."
	weather_immunities = list("ash")
	health = 500
	maxHealth = 500
	layer = BELOW_MOB_LAYER
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_lh = 'icons/mob/pai_item_lh.dmi'
	held_rh = 'icons/mob/pai_item_rh.dmi'
	head_icon = 'icons/mob/pai_item_head.dmi'
	var/network = "ss13"
	var/obj/machinery/camera/current = null

	/// Used as currency to purchase different abilities
	var/ram = 100
	/// Installed software on the pAI
	var/list/software = list()
	/// current user's DNA
	var/userDNA
	/// The card we inhabit
	var/obj/item/paicard/card
	/// Are we hacking a door?
	var/hacking = FALSE
	/// Changes the display to syndi if true
	var/emagged = FALSE

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakDoubleExclamation = "alarms"
	var/speakQuery = "queries"

	/// The cable we produce when hacking a door
	var/obj/item/pai_cable/hacking_cable
	/// Name of the one who commands us
	var/master
	/// DNA string for owner verification
	var/master_dna

// Various software-specific vars

	/// Toggles whether the Security HUD is active or not
	var/secHUD = FALSE
	/// Toggles whether the Medical  HUD is active or not
	var/medHUD = FALSE
	/// Toggles whether universal translator has been activated. Cannot be reversed
	var/languages_granted = FALSE
	/// The airlock being hacked
	var/obj/machinery/door/hackdoor
	/// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check
	var/hackprogress = 0

	// Software
	/// Atmospheric analyzer
	var/obj/item/analyzer/atmos_analyzer
	/// AI's signaler
	var/obj/item/assembly/signaler/internal/signaler
	/// Synthesizer
	var/obj/item/instrument/piano_synth/internal_instrument
	/// pAI Newscaster
	var/obj/machinery/newscaster
	/// pAI healthanalyzer
	var/obj/item/healthanalyzer/hostscan

	var/encryptmod = FALSE
	var/holoform = FALSE
	var/canholo = TRUE
	var/can_transmit = TRUE
	var/can_receive = TRUE
	var/obj/item/card/id/access_card = null
	var/chassis = "repairbot"
	var/list/possible_chassis = list("bat" = TRUE, "bee" = TRUE, "butterfly" = TRUE, "carp" = TRUE, "cat" = TRUE, "corgi" = TRUE, "corgi_puppy" = TRUE, "crow" = TRUE, "duffel" = TRUE, "fox" = TRUE, "frog" = TRUE, "hawk" = TRUE, "lizard" = TRUE, "monkey" = TRUE, "mouse" = TRUE, "mushroom" = TRUE, "phantom" = TRUE, "rabbit" = TRUE, "repairbot" = TRUE, "snake" = TRUE, "spider" = TRUE)		//assoc value is whether it can be picked up.
	var/static/item_head_icon = 'icons/mob/pai_item_head.dmi'
	var/static/item_lh_icon = 'icons/mob/pai_item_lh.dmi'
	var/static/item_rh_icon = 'icons/mob/pai_item_rh.dmi'

	var/emitterhealth = 20
	var/emittermaxhealth = 20
	var/emitterregen = 0.50
	var/emittercd = 50
	var/emitteroverloadcd = 100
	var/emittersemicd = FALSE

	var/overload_ventcrawl = 0
	var/overload_bulletblock = 0	//Why is this a good idea?
	var/overload_maxhealth = 0
	var/silent = FALSE
	var/brightness_power = 5

/mob/living/silicon/pai/can_unbuckle()
	return FALSE

/mob/living/silicon/pai/can_buckle()
	return FALSE

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(internal_instrument)
	QDEL_NULL(atmos_analyzer)
	QDEL_NULL(hacking_cable)
	if (loc != card)
		card.forceMove(drop_location())
	card.pai = null
	card.cut_overlays()
	card.add_overlay("pai-off")
	GLOB.pai_list -= src
	return ..()

/mob/living/silicon/pai/Initialize()
	var/obj/item/paicard/P = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	if(!istype(P)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = P
		P = new /obj/item/paicard(newcardloc)
		P.setPersonality(src)
	forceMove(P)
	card = P
	job = "Personal AI"
	signaler = new(src)
	hostscan = new /obj/item/healthanalyzer(src)
	if(!radio)
		radio = new /obj/item/radio/headset/silicon/pai(src)
	newscaster = new /obj/machinery/newscaster(src)
	atmos_analyzer = new /obj/item/analyzer(src)
	if(!aicamera)
		aicamera = new /obj/item/camera/siliconcam/ai_camera(src)
		aicamera.flash_enabled = TRUE

	//PDA
	aiPDA = new/obj/item/pda/ai(src)
	aiPDA.owner = real_name
	aiPDA.ownjob = "pAI Messenger"
	aiPDA.name = real_name + " (" + aiPDA.ownjob + ")"

	. = ..()

	emittersemicd = TRUE
	addtimer(CALLBACK(src, .proc/emittercool), 600)

/mob/living/silicon/pai/Life()
	if(hacking)
		process_hack()
	return ..()

/mob/living/silicon/pai/proc/process_hack()

	if(cable && cable.machine && istype(cable.machine, /obj/machinery/door) && cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
		hackprogress = CLAMP(hackprogress + 4, 0, 100)
	else
		to_chat(src, "<span class='notice'>Door Jack: Connection to airlock has been lost. Hack aborted.</span>")
		hackprogress = 0
		hacking = FALSE
		hackdoor = null
		return
	if(hackprogress >= 100)
		hackprogress = 0
		var/obj/machinery/door/D = cable.machine
		D.open()
		hacking = FALSE
		QDEL_NULL(hacking_cable)

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/Login()
	..()
	var/datum/asset/notes_assets = get_asset_datum(/datum/asset/simple/pAI)
	mind.assigned_role = "Personal AI"
	notes_assets.send(client)
	client.perspective = EYE_PERSPECTIVE
	if(holoform)
		client.eye = src
	else
		client.eye = card

/mob/living/silicon/pai/get_stat_tab_status()
	var/list/tab_data = ..()
	if(!stat)
		tab_data["Emitter Integrity"] = GENERATE_STAT_TEXT("[emitterhealth * (100/emittermaxhealth)]")
	else
		tab_data["Systems"] = GENERATE_STAT_TEXT("nonfunctional")
	return tab_data

/mob/living/silicon/pai/restrained(ignore_grab)
	. = FALSE

// See software.dm for Topic()

/mob/living/silicon/pai/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/proc/makePAI(delold)
	var/obj/item/paicard/card = new /obj/item/paicard(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	pai.key = key
	pai.name = name
	card.setPersonality(pai)
	if(delold)
		qdel(src)

/datum/action/innate/pai
	name = "PAI Action"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	var/mob/living/silicon/pai/P

/datum/action/innate/pai/Trigger()
	if(!ispAI(owner))
		return 0
	P = owner

/datum/action/innate/pai/software
	name = "Software Interface"
	button_icon_state = "pai"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/software/Trigger()
	..()
	P.ui_act()

/datum/action/innate/pai/shell
	name = "Toggle Holoform"
	button_icon_state = "pai_holoform"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/shell/Trigger()
	..()
	if(P.holoform)
		P.fold_in(0)
	else
		P.fold_out()

/datum/action/innate/pai/chassis
	name = "Holochassis Appearance Composite"
	button_icon_state = "pai_chassis"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/chassis/Trigger()
	..()
	P.choose_chassis()

/datum/action/innate/pai/rest
	name = "Rest"
	button_icon_state = "pai_rest"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/rest/Trigger()
	..()
	P.lay_down()

/datum/action/innate/pai/light
	name = "Toggle Integrated Lights"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "emp"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/light/Trigger()
	..()
	P.toggle_integrated_light()

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(!.)
		add_movespeed_modifier(MOVESPEED_ID_PAI_SPACEWALK_SPEEDMOD, TRUE, 100, multiplicative_slowdown = 2)
		return TRUE
	remove_movespeed_modifier(MOVESPEED_ID_PAI_SPACEWALK_SPEEDMOD, TRUE)
	return TRUE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "A personal AI in holochassis mode. Its master ID string seems to be [master]."

/mob/living/silicon/pai/Life()
	if(stat == DEAD)
		return
	if(cable)
		if(get_dist(src, cable) > 1)
			var/turf/T = get_turf(src.loc)
			T.visible_message("<span class='warning'>[src.cable] rapidly retracts back into its spool.</span>", "<span class='italics'>You hear a click and the sound of wire spooling rapidly.</span>")
			qdel(src.cable)
			cable = null
	silent = max(silent - 1, 0)
	. = ..()

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getBruteLoss() - getFireLoss()
	update_stat()

/mob/living/silicon/pai/process(delta_time)
	emitterhealth = CLAMP((emitterhealth + (emitterregen * delta_time)), -50, emittermaxhealth)

/obj/item/paicard/attackby(obj/item/W, mob/user, params)
	..()
	user.set_machine(src)
	if(pai?.encryptmod == TRUE)
		if(W.tool_behaviour == TOOL_SCREWDRIVER)
			pai.radio.attackby(W, user, params)
		else if(istype(W, /obj/item/encryptionkey))
			pai.radio.attackby(W, user, params)
	else
		to_chat(user, "Encryption Key ports not configured.")

/obj/item/paicard/emag_act(mob/user) // Emag to wipe the master DNA and supplemental directive
	if(!pai)
		return
	to_chat(user, "<span class='notice'>You override [pai]'s directive system, clearing its master string and supplied directive.</span>")
	to_chat(pai, "<span class='danger'>Warning: System override detected, check directive sub-system for any changes.'</span>")
	log_game("[key_name(user)] emagged [key_name(pai)], wiping their master DNA and supplemental directive.")
	pai.master = null
	pai.master_dna = null
	pai.emagged = TRUE
	pai.laws.supplied[1] = "None." // Sets supplemental directive to this
