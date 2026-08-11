/datum/action/spell/eminence
	invocation = "none"
	invocation_type = INVOCATION_NONE
	button_icon = 'icons/hud/actions/actions_clockcult.dmi'
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	/// The amount of cogs this costs
	var/cog_cost

/datum/action/spell/eminence/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

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
	if(!IS_SERVANT_OF_RATVAR(M))
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
	desc = "Initiates a mass recall, warping everyone to the Ark. Can only be used once."
	button_icon_state = "Spatial Gateway"

/datum/action/spell/eminence/mass_recall/on_cast(mob/living/user, atom/target)
	. = ..()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		return

	gateway.begin_mass_recall()
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
	if(E.selected_mob && IS_SERVANT_OF_RATVAR(E.selected_mob))
		return TRUE
	return FALSE

/datum/action/spell/eminence/linked_abscond/on_cast(mob/user, atom/target)
	. = ..()
	var/mob/living/simple_animal/eminence/E = user
	if(!istype(E))
		to_chat(E, span_brass("You are not the Eminence! (This is a bug)"))
		reset_spell_cooldown()
		return FALSE
	if(!E.selected_mob || !IS_SERVANT_OF_RATVAR(E.selected_mob))
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
