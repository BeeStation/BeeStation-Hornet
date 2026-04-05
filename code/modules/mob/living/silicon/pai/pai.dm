#define HOLOCHASSIS_INIT_TIME (40 SECONDS)

/mob/living/silicon/pai
	name = "pAI"
	desc = "A generic pAI mobile hard-light holographics emitter. It seems to be deactivated."
	icon = 'icons/mob/pai.dmi'
	icon_state = "repairbot"
	mouse_opacity = MOUSE_OPACITY_ICON
	density = FALSE
	hud_type = /datum/hud/pai
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	health = 500
	maxHealth = 500
	layer = BELOW_MOB_LAYER
	can_be_held = TRUE
	radio = /obj/item/radio/headset/silicon/pai
	can_buckle_to = FALSE
	move_force = 0
	pull_force = 0
	move_resist = 0
	worn_slot_flags = ITEM_SLOT_HEAD
	held_lh = 'icons/mob/pai_item_lh.dmi'
	held_rh = 'icons/mob/pai_item_rh.dmi'
	head_icon = 'icons/mob/pai_item_head.dmi'
	var/network = "ss13"
	var/obj/machinery/camera/current = null
	light_system = MOVABLE_LIGHT
	light_power = 1
	light_range = 5
	light_on = FALSE

	/// Used as currency to purchase different abilities
	var/ram = 100
	/// Installed software on the pAI
	var/list/software = list()
	/// current user's DNA
	var/userDNA
	/// The card we inhabit
	var/obj/item/pai_card/card
	/// Are we hacking a door?
	var/hacking = FALSE
	/// The progress for hacking
	var/datum/progressbar/hackbar
	/// Changes the display to syndi if true
	var/emagged = FALSE

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakDoubleExclamation = "alarms"
	var/speakQuery = "queries"

	/// The cable we produce when hacking a door
	var/obj/item/pai_cable/hacking_cable
	/// Name of the one who commands us
	var/master_name
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
	var/obj/machinery/newscaster/pai/newscaster
	/// pAI healthanalyzer
	var/obj/item/healthanalyzer/hostscan
	/// Internal pAI GPS, enabled if pAI downloads GPS software, and then uses it.
	var/obj/item/gps/pai/internal_gps = null


	var/encryptmod = FALSE
	var/holoform = FALSE
	var/can_holo = TRUE
	var/can_transmit = TRUE
	var/can_receive = TRUE
	var/chassis = "repairbot"
	/// Holochassis available to use
	var/holochassis_ready = FALSE
	/// List of all possible chassis. TRUE means the pAI can be picked up in this chasis.
	var/static/list/possible_chassis = list(
		"bat" = TRUE,
		"bee" = TRUE,
		"butterfly" = TRUE,
		"carp" = TRUE,
		"cat" = TRUE,
		"corgi" = TRUE,
		"corgi_puppy" = TRUE,
		"crow" = TRUE,
		"duffel" = TRUE,
		"fox" = TRUE,
		"frog" = TRUE,
		"hawk" = TRUE,
		"lizard" = TRUE,
		"monkey" = TRUE,
		"mothroach" = TRUE,
		"mouse" = TRUE,
		"mushroom" = TRUE,
		"phantom" = TRUE,
		"rabbit" = TRUE,
		"repairbot" = TRUE,
		"snake" = TRUE,
		"spider" = TRUE
	)
	var/static/item_head_icon = 'icons/mob/pai_item_head.dmi'
	var/static/item_lh_icon = 'icons/mob/pai_item_lh.dmi'
	var/static/item_rh_icon = 'icons/mob/pai_item_rh.dmi'

	var/emitterhealth = 20
	var/emittermaxhealth = 20
	var/emitterregen = 0.50
	var/emittercd = 50
	var/emitteroverloadcd = 100

	var/overload_ventcrawl = 0
	var/overload_bulletblock = 0	//Why is this a good idea?
	var/overload_maxhealth = 0
	var/silent = FALSE
	var/atom/movable/screen/ai/modpc/interface_button


/mob/living/silicon/pai/handle_atom_del(atom/A)
	if(A == hacking_cable)
		hacking_cable = null
		if(!QDELETED(card))
			card.update_icon()
	if(A == atmos_analyzer)
		atmos_analyzer = null
	if(A == internal_instrument)
		internal_instrument = null
	if(A == newscaster)
		newscaster = null
	if(A == signaler)
		signaler = null
	if(A == hostscan)
		hostscan = null
	if(A == internal_gps)
		internal_gps = null
	return ..()

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(atmos_analyzer)
	QDEL_NULL(internal_instrument)
	QDEL_NULL(internal_gps)
	QDEL_NULL(hacking_cable)
	QDEL_NULL(newscaster)
	QDEL_NULL(signaler)
	QDEL_NULL(hostscan)
	if (loc != card)
		card.forceMove(drop_location())
	card.pai = null
	card.cut_overlays()
	card.add_overlay("pai-off")
	GLOB.pai_list -= src
	return ..()

/mob/living/silicon/pai/Initialize(mapload)
	var/obj/item/pai_card/pai_card = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	if(!istype(pai_card)) // when manually spawning a pai, we create a card to put it into.
		var/newcardloc = pai_card
		pai_card = new(newcardloc)
		pai_card.set_personality(src)
	card = pai_card
	forceMove(pai_card)
	job = JOB_NAME_PAI
	signaler = new /obj/item/assembly/signaler/internal(src)
	hostscan = new /obj/item/healthanalyzer(src)
	atmos_analyzer = new /obj/item/analyzer(src)
	newscaster = new /obj/machinery/newscaster/pai(src)
	if(!aicamera)
		aicamera = new /obj/item/camera/siliconcam/ai_camera(src)
		aicamera.flash_enabled = TRUE

	RegisterSignals(src, list(COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_ADJUST_BURN_DAMAGE), PROC_REF(on_shell_damaged))
	RegisterSignal(src, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(on_shell_weakened))

	. = ..()

	create_modularInterface()

	addtimer(VARSET_CALLBACK(src, holochassis_ready, TRUE), HOLOCHASSIS_INIT_TIME)

	if(!holoform)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAI_FOLDED)
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, PAI_FOLDED)

	return INITIALIZE_HINT_LATELOAD


/mob/living/silicon/pai/Life(delta_time = SSMOBS_DT, times_fired)
	if(hacking)
		process_hack(delta_time)
	return ..()

/mob/living/silicon/pai/proc/process_hack(delta_time, times_fired)
	if(hacking_cable?.machine && istype(hacking_cable.machine, /obj/machinery/door) && hacking_cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
		hackprogress = clamp(hackprogress + (2 * delta_time), 0, 100)
		hackbar.update(hackprogress)
	else
		to_chat(src, span_notice("Door Jack: Connection to airlock has been lost. Hack aborted."))
		hackprogress = 0
		hacking = FALSE
		hackdoor = null
		QDEL_NULL(hackbar)
		QDEL_NULL(hacking_cable)
		if(!QDELETED(card))
			card.update_icon()
		return
	if(hackprogress >= 100)
		hackprogress = 0
		hacking = FALSE
		var/obj/machinery/door/door = hacking_cable.machine
		door.open()
		QDEL_NULL(hackbar)
		QDEL_NULL(hacking_cable)

/mob/living/silicon/pai/LateInitialize()
	. = ..()
	modularInterface.saved_identification = name

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	var/datum/asset/notes_assets = get_asset_datum(/datum/asset/simple/pAI)
	mind.assigned_role = JOB_NAME_PAI
	notes_assets.send(client)
	client.perspective = EYE_PERSPECTIVE
	if(holoform)
		client.set_eye(src)
	else
		client.set_eye(card)

/mob/living/silicon/pai/get_stat_tab_status()
	var/list/tab_data = ..()
	if(!stat)
		tab_data["Emitter Integrity"] = GENERATE_STAT_TEXT("[emitterhealth * (100/emittermaxhealth)]")
	else
		tab_data["Systems"] = GENERATE_STAT_TEXT("nonfunctional")
	return tab_data

// See software.dm for Topic()

/mob/living/silicon/pai/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE, need_hands = FALSE, floor_okay=FALSE)
	return ..(M, be_close, no_dexterity, no_tk, need_hands, TRUE) //Resting is just an aesthetic feature for them.

/mob/proc/makePAI(delold)
	var/obj/item/pai_card/card = new /obj/item/pai_card(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	pai.ckey = ckey
	pai.name = name
	card.set_personality(pai)
	if(delold)
		qdel(src)

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(!.)
		add_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
		return TRUE
	remove_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
	return TRUE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "A personal AI in holochassis mode. Its master ID string seems to be [master_name]."

/mob/living/silicon/pai/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	if(hacking_cable)
		if(get_dist(src, hacking_cable) > 1)
			var/turf/T = get_turf(src.loc)
			T.visible_message(span_warning("[hacking_cable] rapidly retracts back into its spool."), span_hear("You hear a click and the sound of wire spooling rapidly."))
			QDEL_NULL(hacking_cable)
			if(!QDELETED(card))
				card.update_icon()
		else if(hacking)
			process_hack(delta_time, times_fired)
	silent = max(silent - (0.5 * delta_time), 0)

/mob/living/silicon/pai/updatehealth()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	set_health(maxHealth - getBruteLoss() - getFireLoss())
	update_stat()
	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)

/mob/living/silicon/pai/update_desc(updates)
	desc = "A hard-light holographic avatar representing a pAI. This one appears in the form of a [chassis]."
	return ..()

/mob/living/silicon/pai/update_icon_state()
	icon_state = resting ? "[chassis]_rest" : "[chassis]"
	held_state = "[chassis]"
	return ..()

/mob/living/silicon/pai/set_stat(new_stat)
	. = ..()
	update_stat()

/mob/living/silicon/pai/on_knockedout_trait_loss(datum/source)
	set_stat(CONSCIOUS)
	update_stat()

/**
 * Fixes weird speech issues with the pai.
 *
 * @returns {boolean} - TRUE if successful.
 */
/mob/living/silicon/pai/proc/fix_speech()
	var/mob/living/silicon/pai = src
	balloon_alert(pai, "speech modulation corrected")
	for(var/effect in typesof(/datum/status_effect/speech))
		pai.remove_status_effect(effect)
	return TRUE

/mob/living/silicon/pai/process(delta_time)
	emitterhealth = clamp((emitterhealth + (emitterregen * delta_time)), -50, emittermaxhealth)

/mob/living/silicon/pai/can_interact_with(atom/A)
	if(A == signaler) // Bypass for signaler
		return TRUE

	return ..()

/obj/item/pai_card/attackby(obj/item/used, mob/user, params)
	if(pai && (istype(used, /obj/item/encryptionkey) || used.tool_behaviour == TOOL_SCREWDRIVER))
		if(!pai.encryptmod)
			to_chat(user, span_alert("Encryption Key ports not configured."))
			return
		user.set_machine(src)
		pai.radio.attackby(used, user, params)
		to_chat(user, span_notice("You insert [used] into the [src]."))
		return

	return ..()

/mob/living/silicon/pai/can_interact_with(atom/A)
	if(A == modularInterface)
		return TRUE
	return ..()

/obj/item/pai_card/should_emag(mob/user)
	return !!pai

/obj/item/pai_card/on_emag(mob/user) // Emag to wipe the master DNA and supplemental directive
	..()
	to_chat(user, span_notice("You override [pai]'s directive system, clearing its master string and supplied directive."))
	to_chat(pai, span_danger("Warning: System override detected, check directive sub-system for any changes.'"))
	log_game("[key_name(user)] emagged [key_name(pai)], wiping their master DNA and supplemental directive.")
	pai.emagged = TRUE
	pai.master_name = null
	pai.master_dna = null
	pai.laws.clear_supplied_laws()
	pai.laws.add_supplied_law(0, "None.") // Sets supplemental directive to this

/mob/living/silicon/pai/proc/set_dna(mob/user)
	if(!iscarbon(user))
		balloon_alert(user, "incompatible DNA signature")
		balloon_alert(src, "incompatible DNA signature")
		return FALSE
	if(emagged)
		balloon_alert(user, "directive system malfunctioning")
		return FALSE
	var/mob/living/carbon/master = user
	master_name = master.real_name
	master_dna = master.dna.unique_enzymes
	to_chat(src, span_bolddanger("You have been bound to a new master: [user.real_name]!"))
	laws.set_zeroth_law("Serve your master.")
	holochassis_ready = TRUE
	return TRUE

/mob/living/silicon/pai/proc/set_laws(mob/user)
	var/new_laws = tgui_input_text(user, "Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", laws.supplied[1], 300)
	if(!in_range(src, usr))
		return FALSE
	if(!new_laws)
		return FALSE
	add_supplied_law(0, new_laws)
	to_chat(src, span_notice(new_laws))
	return TRUE

/**
 * Toggles the ability of the pai to enter holoform
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/toggle_holo()
	balloon_alert(src, "holomatrix [can_holo ? "disabled" : "enabled"]")
	can_holo = !can_holo
	return TRUE

/**
 * Toggles the radio settings on and off.
 *
 * @param {string} option - The option being toggled.
 */
/mob/living/silicon/pai/proc/toggle_radio(option)
	// it can't be both so if we know it's not transmitting it must be receiving.
	var/transmitting = option == "transmit"
	var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
	if(transmitting)
		can_transmit = !can_transmit
	else //receiving
		can_receive = !can_receive
	radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
	transmit_holder = (transmitting ? can_transmit : can_receive) //recycling can be fun!
	balloon_alert(src, "[transmitting ? "outgoing" : "incoming"] radio [transmit_holder ? "enabled" : "disabled"]")
	return TRUE

/**
 * Wipes the current pAI on the card.
 *
 * @param {mob} user - The user performing the action.
 *
 * @returns {boolean} - TRUE if successful, FALSE if not.
 */
/mob/living/silicon/pai/proc/wipe_pai(mob/user)
	if(tgui_alert(user, "Are you certain you wish to delete the current personality? This action cannot be undone.", "Personality Wipe", list("Yes", "No")) != "Yes")
		return FALSE
	to_chat(src, span_warning("You feel yourself slipping away from reality."))
	to_chat(src, span_danger("Byte by byte you lose your sense of self."))
	to_chat(src, span_userdanger("Your mental faculties leave you."))
	to_chat(src, span_rose("oblivion... "))
	balloon_alert(user, "personality wiped")
	playsound(src, 'sound/machines/buzz-two.ogg', 30, TRUE)
	qdel(src)
	return TRUE

#undef HOLOCHASSIS_INIT_TIME
