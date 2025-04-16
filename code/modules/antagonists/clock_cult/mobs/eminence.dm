/mob/living/simple_animal/eminence
	name = "the Eminence"
	desc = "A glowing ball of light."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "eminence"
	mob_biotypes = list(MOB_SPIRIT)
	incorporeal_move = INCORPOREAL_MOVE_EMINENCE
	invisibility = INVISIBILITY_SPIRIT
	health = INFINITY
	maxHealth = INFINITY
	plane = GHOST_PLANE
	healable = FALSE
	spacewalk = TRUE
	sight = SEE_SELF
	throwforce = 0

	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	status_flags = 0
	wander = FALSE
	density = FALSE
	is_flying_animal = TRUE
	no_flying_animation = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	unique_name = FALSE
	hud_possible = list(ANTAG_HUD)
	hud_type = /datum/hud/revenant

	var/calculated_cogs = 0
	var/cogs = 0
	var/obj/item/radio/borg/eminence/internal_radio

	var/mob/living/selected_mob = null

	var/datum/action/spell/eminence/reebe/spell_reebe
	var/datum/action/spell/eminence/station/spell_station
	var/datum/action/spell/eminence/servant_warp/spell_servant_warp
	var/datum/action/spell/eminence/mass_recall/mass_recall
	var/datum/action/spell/eminence/linked_abscond/linked_abscond
	var/datum/action/spell/eminence/trigger_event/trigger_event

/mob/living/simple_animal/eminence/ClickOn(atom/A, params)
	. = ..()
	if(!.)
		A.eminence_act(src)

/mob/living/simple_animal/eminence/proc/cog_change()
	//Calculate cogs
	if(calculated_cogs != GLOB.installed_integration_cogs)
		var/difference = GLOB.installed_integration_cogs - calculated_cogs
		calculated_cogs += difference
		cogs += difference
		to_chat(src, span_brass("You have gained [difference] cogs!"))

//Cannot gib the eminence.
/mob/living/simple_animal/eminence/gib()
	return

/mob/living/simple_animal/eminence/UnarmedAttack(atom/A)
	return FALSE

/mob/living/simple_animal/eminence/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return FALSE

/mob/living/simple_animal/eminence/rad_act(amount)
	return

/mob/living/simple_animal/eminence/Initialize(mapload)
	. = ..()
	GLOB.clockcult_eminence = src
	//Add spells

	spell_reebe = new
	spell_reebe.Grant(src)
	spell_station = new
	spell_station.Grant(src)
	spell_servant_warp = new
	spell_servant_warp.Grant(src)
	mass_recall = new
	mass_recall.Grant(src)
	linked_abscond = new
	linked_abscond.Grant(src)
	trigger_event = new
	trigger_event.Grant(src)
	//Wooooo, you are a ghost
	AddComponent(/datum/component/tracking_beacon, "ghost", null, null, TRUE, "#9e4d91", TRUE, TRUE, "#490066")
	internal_radio = new(src)
	cog_change()

/mob/living/simple_animal/eminence/Destroy()
	. = ..()
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(beacon)
		qdel(beacon)

/mob/living/simple_animal/eminence/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(src, silent=TRUE)
	S.prefix = CLOCKCULT_PREFIX_EMINENCE
	to_chat(src, "[span_largebrass("You are the Eminence!")]")
	to_chat(src, span_brass("Click on objects to perform actions, different objects have different actions, try them out!"))
	to_chat(src, span_brass("Many of your spells require a target first. Click on a servant to select them!"))

/mob/living/simple_animal/eminence/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return
	if(message)
		hierophant_message(message, src, span="<span class='large_brass'>", say=FALSE)

/mob/living/simple_animal/eminence/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	return FALSE

/mob/living/simple_animal/eminence/Move(atom/newloc, direct)
	if(istype(get_area(newloc), /area/chapel))
		to_chat(usr, span_warning("You cannot move on to holy grounds!"))
		return
	. = ..()

/mob/living/simple_animal/eminence/bullet_act(obj/projectile/Proj)
	return BULLET_ACT_FORCE_PIERCE

/mob/living/simple_animal/eminence/proc/run_global_event(datum/round_event_control/E)
	E.preRunEvent()
	E.runEvent()
	SSevents.reschedule()

/mob/living/simple_animal/eminence/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Cogs Available"] = GENERATE_STAT_TEXT("[cogs] Cogs")
	return tab_data

/mob/living/simple_animal/eminence/med_hud_set_health()
	return

/mob/living/simple_animal/eminence/med_hud_set_status()
	return

/mob/living/simple_animal/eminence/update_health_hud()
	return

/mob/living/simple_animal/eminence/flash_act(intensity, override_blindness_check, affect_silicon, visual, type)
	return

//Eminence abilities

/datum/action/spell/eminence
	invocation = "none"
	invocation_type = INVOCATION_NONE
	icon_icon = 'icons/hud/actions/actions_clockcult.dmi'
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/cog_cost

/datum/action/spell/eminence/can_cast_spell(feedback = TRUE)
	. = ..()
	var/mob/living/simple_animal/eminence/eminence = owner
	if(!istype(eminence))
		return FALSE
	if(eminence.cogs < cog_cost)
		return FALSE

/datum/action/spell/eminence/proc/consume_cogs(mob/living/simple_animal/eminence/eminence)
	eminence.cogs -= cog_cost

//=====Warp to Reebe=====
/datum/action/spell/eminence/reebe
	name = "Jump to Reebe"
	desc = "Teleport yourself to Reebe."
	button_icon_state = "Abscond"

/datum/action/spell/eminence/reebe/on_cast(mob/living/user, atom/target)
	. = ..()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.celestial_gateway
	if(G)
		user.abstract_move(get_turf(G))
		SEND_SOUND(user, sound('sound/magic/magic_missile.ogg'))
		flash_color(user, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(user, span_warning("There is no Ark!"))

//=====Warp to station=====
/datum/action/spell/eminence/station
	name = "Jump to Station"
	desc = "Teleport yourself to the station."
	button_icon_state = "warp_down"

/datum/action/spell/eminence/station/on_cast(mob/user, atom/target)
	. = ..()
	if(!is_station_level(user.z))
		user.abstract_move(get_turf(pick(GLOB.generic_event_spawns)))
		SEND_SOUND(user, sound('sound/magic/magic_missile.ogg'))
		flash_color(user, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(user, span_warning("You're already on the station!"))

//=====Teleport to servant=====
/datum/action/spell/eminence/servant_warp
	name = "Jump to Servant"
	desc = "Teleport yourself to a specific servant."
	button_icon_state = "Spatial Warp"

/datum/action/spell/eminence/servant_warp/on_cast(mob/user, atom/target)
	. = ..()
	//Get a list of all servants
	var/datum/mind/choice = input(user, "Select servant", "Warp to...", null) in GLOB.all_servants_of_ratvar //List targets spell might have been better, for now this will do
	var/mob/living/M
	if(!choice)
		return
	M = choice.current
	if(!isliving(M))
		to_chat(user, span_warning("You cannot jump to them!"))
		return
	if(!is_servant_of_ratvar(M))
		to_chat(user, span_warning("They are no longer a servant of Rat'var!"))
		return
	var/turf/T = get_turf(M)
	if(SSmapping.level_trait(T.z, ZTRAIT_CENTCOM))
		to_chat(user, span_warning("They are out of your reach!"))
		return
	user.forceMove(get_turf(T))
	SEND_SOUND(user, sound('sound/magic/magic_missile.ogg'))
	flash_color(user, flash_color = "#AF0AAF", flash_time = 25)

//=====Mass Recall=====
/datum/action/spell/eminence/mass_recall
	name = "Initiate Mass Recall"
	desc = "Initiates a mass recall, warping everyone to the Ark. Can only be used 1 time."
	button_icon_state = "Spatial Gateway"

/datum/action/spell/eminence/mass_recall/on_cast(mob/living/user, atom/target)
	. = ..()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/C = GLOB.celestial_gateway
	if(!C)
		return
	C.begin_mass_recall()
	Remove(user)

//=====Linked Abscond=====
/datum/action/spell/eminence/linked_abscond
	name = "Linked Abscond"
	desc = "Warps a target to Reebe if they are still for 7 seconds. Costs 1 cog."
	button_icon_state = "Linked Abscond"
	cooldown_time = 600 SECONDS
	cog_cost = 1

/datum/action/spell/eminence/linked_abscond/can_cast_spell(feedback)
	. = ..()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/eminence/E = owner
	if(!istype(E))
		return FALSE
	if(E.selected_mob && is_servant_of_ratvar(E.selected_mob))
		return TRUE
	return FALSE

/datum/action/spell/eminence/linked_abscond/on_cast(mob/user, atom/target)
	. = ..()
	var/mob/living/simple_animal/eminence/E = user
	if(!istype(E))
		to_chat(E, span_brass("You are not the Eminence! (This is a bug)"))
		reset_spell_cooldown()
		return FALSE
	if(!E.selected_mob || !is_servant_of_ratvar(E.selected_mob))
		E.selected_mob = null
		to_chat(user, span_neovgre("You need to select a valid target by clicking on them."))
		reset_spell_cooldown()
		return FALSE
	var/mob/living/L = E.selected_mob
	if(!istype(L))
		to_chat(E, span_brass("You cannot do that on this mob!"))
		reset_spell_cooldown()
		return FALSE
	to_chat(E, span_brass("You begin recalling [L]..."))
	to_chat(L, span_brass("The Eminence is summoning you..."))
	L.visible_message(span_warning("[L] flares briefly."))
	if(do_after(E, 70, target=L))
		L.visible_message(span_warning("[L] phases out of existence!"))
		var/turf/T = get_turf(pick(GLOB.servant_spawns))
		try_warp_servant(L, T, FALSE)
		consume_cogs(E)
		return TRUE
	else
		to_chat(E, span_brass("You fail to recall [L]."))
		reset_spell_cooldown()
		return FALSE

//Trigger event
/datum/action/spell/eminence/trigger_event
	name = "Manipulate Reality"
	desc = "Manipulate reality causing global events to occur. Costs 5 cogs"
	button_icon_state = "Geis"
	cooldown_time = 600 SECONDS
	cog_cost = 5

/datum/action/spell/eminence/trigger_event/on_cast(mob/user, atom/target)
	. = ..()
	var/picked_event = input(user, "Pick an event to run", "Manipulate Reality", null) in list(
		"Anomaly",
		"Brand Intelligence",
		"Camera Failure",
		"Communications Blackout",
		"Disease Outbreak",
		"Electrical Storm",
		"False Alarm",
		"Grid Check",
		"Mass Hallucination",
		"Processor Overload"
	)
	if(!picked_event)
		reset_spell_cooldown()
		return
	if(picked_event == "Anomaly")
		picked_event = pick("Anomaly: Energetic Flux", "Anomaly: Pyroclastic", "Anomaly: Gravitational", "Anomaly: Bluespace")
	//Reschedule events
	//Get the picked event
	for(var/datum/round_event_control/E in SSevents.control)
		if(E.name == picked_event)
			var/mob/living/simple_animal/eminence/eminence = user
			INVOKE_ASYNC(eminence, TYPE_PROC_REF(/mob/living/simple_animal/eminence, run_global_event), E)
			consume_cogs(user)
			return
	reset_spell_cooldown()

//Internal Radio
/obj/item/radio/borg/eminence
	name = "eminence internal listener"
	desc = "if you can see this, call a coder"
	canhear_range = 0
	radio_silent = TRUE
	prison_radio = TRUE


/obj/item/radio/borg/eminence/Initialize(mapload)
	. = ..()
	set_broadcasting(TRUE)
