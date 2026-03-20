/datum/antagonist/space_dragon
	name = "Space Dragon"
	roundend_category = "space dragons"
	antagpanel_category = "Space Dragon"
	banning_key = ROLE_SPACE_DRAGON
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	required_living_playtime = 0
	// TODO: ui_name = "AntagInfoDragon"
	var/list/datum/mind/carp = list()
	/// The innate ability to summon rifts
	var/datum/action/innate/summon_rift/rift_ability
	/// A list of all of the rifts created by Space Dragon.  Used for setting them all to infinite carp spawn when Space Dragon wins, and removing them when Space Dragon dies.
	var/list/obj/structure/carp_rift/rift_list = list()
	/// How many rifts have been successfully charged
	var/rifts_charged = 0
	/// Whether or not Space Dragon has completed their objective, and thus triggered the ending sequence.
	var/objective_complete = FALSE
	/// What mob to spawn from ghosts using this dragon's rifts
	var/minion_to_spawn = /mob/living/simple_animal/hostile/carp/advanced
	/// What AI mobs to spawn from this dragon's rifts
	var/ai_to_spawn = /mob/living/simple_animal/hostile/carp
	/// Wavespeak mind linker, to allow telepathy between dragon and carps
	var/datum/component/mind_linker/wavespeak
	/// What areas are we allowed to place rifts in?
	var/list/chosen_rift_areas = list()

/datum/antagonist/space_dragon/greet()
	to_chat(owner, "<b>Endless time and space we have moved through. We do not remember from where we came, we do not know where we will go. All space belongs to us.\n\
					Space is an empty void, of which our kind is the apex predator, and there was little to rival our claim to this title.\n\
					But now, we find intruders spread out amongst our claim, willing to fight our teeth with magics unimaginable, their dens like lights flicking in the depths of space.\n\
					Today, we will snuff out one of those lights.</b>")
	to_chat(owner, span_boldwarning("You have five minutes to find a safe location to place down the first rift. If you take longer than five minutes to place a rift, you will enter a depression and become slow and vulnerable."))
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/demon_attack1.ogg'))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Space Dragon",
		"You've existed for so long, you have forgotten your purpose. The sight of an intruder in your endless claim of the void of space re-kindles the magic within you. Place rifts and summon an army to snuff out another light intruding in your domain.")

/datum/antagonist/space_dragon/proc/forge_objectives()
	var/static/list/area/allowed_areas
	if(!allowed_areas)
		// Areas that will prove challenging for the dragon and provocative to the crew.
		var/list/area/allowed_areas = typecacheof(list(
			/area/crew_quarters/heads/captain,
			/area/crew_quarters/heads/hop,
			/area/bridge,
			/area/engine,
			/area/security,
			/area/science,
		))
	// Things included above that we do NOT want
	var/list/area/blocked_areas = typecacheof(list(
		/area/bridge/showroom,
		/area/science/test_area,
		/area/science/misc_lab,
		/area/science/research/abandoned,
		/area/science/shuttledock,
		/area/engine/gravity_generator, // dragon already has a huge incentive to go here, let's not give them more reasons
		/area/engine/transit_tube,
		/area/engine/engine_room/external,
		/area/security/prison/asteroid,
		/area/security/checkpoint,
		/area/security/courtroom,
	))

	var/list/possible_areas = GLOB.areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(!is_type_in_typecache(possible_area, allowed_areas) || is_type_in_typecache(possible_area, blocked_areas) || initial(possible_area.outdoors))
			possible_areas -= possible_area

	var/list/area_names = list()
	for(var/i in 1 to 7)
		var/area/chosen_rift_area = pick_n_take(possible_areas)
		if(!istype(chosen_rift_area))
			continue
		chosen_rift_areas += chosen_rift_area
		area_names += initial(chosen_rift_area.name)

	var/datum/objective/summon_carp/summon = new
	objectives += summon
	summon.owner = owner
	summon.update_explanation_text()

/datum/antagonist/space_dragon/on_gain()
	forge_objectives()
	rift_ability = new
	owner.special_role = ROLE_SPACE_DRAGON
	if(istype(owner.current, /mob/living/simple_animal/hostile/space_dragon))
		var/mob/living/simple_animal/hostile/space_dragon/S = owner.current
		S.can_summon_rifts = TRUE
	return ..()

/datum/antagonist/space_dragon/apply_innate_effects(mob/living/mob_override)
	var/mob/living/antag = mob_override || owner.current
	RegisterSignal(antag, COMSIG_LIVING_LIFE, PROC_REF(rift_checks))
	RegisterSignal(antag, COMSIG_LIVING_DEATH, PROC_REF(destroy_rifts))
	antag.faction |= FACTION_CARP
	// Give the ability over if we have one
	rift_ability?.Grant(antag)
	wavespeak = antag.AddComponent( \
		/datum/component/mind_linker, \
		network_name = "Wavespeak", \
		chat_color = "#635BAF", \
		signals_which_destroy_us = list(COMSIG_LIVING_DEATH), \
		speech_action_icon = 'icons/hud/actions/actions_space_dragon.dmi', \
		speech_action_icon_state = "wavespeak", \
	)
	RegisterSignal(wavespeak, COMSIG_QDELETING, PROC_REF(clear_wavespeak))

/datum/antagonist/space_dragon/on_removal()
	owner.special_role = null
	return ..()

/datum/antagonist/space_dragon/remove_innate_effects(mob/living/mob_override)
	var/mob/living/antag = mob_override || owner.current
	UnregisterSignal(antag, COMSIG_LIVING_LIFE)
	UnregisterSignal(antag, COMSIG_LIVING_DEATH)
	antag.faction -= FACTION_CARP
	rift_ability?.Remove(antag)
	QDEL_NULL(wavespeak)

/datum/antagonist/space_dragon/Destroy()
	rift_list = null
	carp = null
	QDEL_NULL(rift_ability)
	QDEL_NULL(wavespeak)
	chosen_rift_areas.Cut()
	return ..()

/datum/antagonist/space_dragon/proc/clear_wavespeak()
	SIGNAL_HANDLER
	wavespeak = null

/**
  * Sets up Space Dragon's victory for completing the objectives.
  *
  * Triggers when Space Dragon completes his objective.
  * Calls the shuttle with a coefficient of 3, making it impossible to recall.
  * Sets all of his rifts to allow for infinite sentient carp spawns
  * Also plays appropiate sounds and CENTCOM messages.
  */
/datum/antagonist/space_dragon/proc/victory()
	objective_complete = TRUE
	permanent_empower()
	var/datum/objective/summon_carp/main_objective = locate() in objectives
	main_objective?.completed = TRUE
	priority_announce("A large amount of lifeforms have been detected approaching [station_name()] at extreme speeds. \
		Remaining crew are advised to evacuate as soon as possible.", "Central Command Wildlife Observations", has_important_message = TRUE)
	sound_to_playing_players('sound/creatures/space_dragon_roar.ogg', volume = 75)
	for(var/obj/structure/carp_rift/rift in rift_list)
		rift.carp_stored = 999999
		rift.time_charged = rift.max_charge

/datum/antagonist/space_dragon/proc/rift_checks()
	SIGNAL_HANDLER
	if((rifts_charged == 3 || (SSshuttle.emergency.mode == SHUTTLE_DOCKED && rifts_charged > 0)) && !objective_complete)
		victory()

/**
 * Handles Space Dragon's temporary empowerment after boosting a rift.
 *
 * Empowers and depowers Space Dragon after a successful rift charge.
 * Empowered, Space Dragon regains all his health and becomes temporarily faster for 30 seconds, along with being tinted red.
 */
/datum/antagonist/space_dragon/proc/rift_empower(is_permanent)
	owner.current.fully_heal()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/rift_empowerment)
	addtimer(CALLBACK(src, PROC_REF(rift_depower)), 30 SECONDS)

/**
 * Gives Space Dragon their the rift speed buff permanently.
 *
 * Gives Space Dragon the enraged speed buff from charging rifts permanently.
 * Only happens in circumstances where Space Dragon completes their objective.
 */
/datum/antagonist/space_dragon/proc/permanent_empower()
	owner.current.fully_heal()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/rift_empowerment)

/**
 * Removes Space Dragon's rift speed buff.
 *
 * Removes Space Dragon's speed buff from charging a rift.  This is only called
 * in rift_empower, which uses a timer to call this after 30 seconds.  Also
 * removes the red glow from Space Dragon which is synonymous with the speed buff.
 */
/datum/antagonist/space_dragon/proc/rift_depower()
	owner.current.remove_filter("anger_glow")
	owner.current.remove_movespeed_modifier(/datum/movespeed_modifier/rift_empowerment)

/**
 * Destroys all of Space Dragon's current rifts.
 *
 * QDeletes all the current rifts after removing their references to other objects.
 * Currently, the only reference they have is to the Dragon which created them, so we clear that before deleting them.
 * Currently used when Space Dragon dies.
 */
/datum/antagonist/space_dragon/proc/destroy_rifts()
	SIGNAL_HANDLER
	if(objective_complete) // this will always trigger on death, be sure that we didn't succeed already
		return
	for(var/mob/S in GLOB.player_list)
		if(!S.stat && ("carp" in S.faction))
			to_chat(S, span_bigbold("<font color=\"#44aaff\">The Space Dragon has died! All is lost, and the rifts have closed...</font>"))
	rifts_charged = 0
	playsound(owner.current, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	for(var/obj/structure/carp_rift/rift in rift_list)
		if(!QDELETED(rift))
			qdel(rift)
	rift_list.Cut()

/datum/objective/summon_carp
	explanation_text = "Summon 3 rifts in order to flood the station with carp. Your possible rift locations are: (ERROR)."

/datum/objective/summon_carp/update_explanation_text()
	var/datum/antagonist/space_dragon/dragon_owner = owner.has_antag_datum(/datum/antagonist/space_dragon)
	if(isnull(dragon_owner))
		return

	var/list/converted_names = list()
	for(var/area/possible_area as anything in dragon_owner.chosen_rift_areas)
		converted_names += possible_area.get_original_area_name()

	explanation_text = initial(explanation_text)
	explanation_text += " Your possible rift locations are: [english_list(converted_names)]"

/datum/antagonist/space_dragon/roundend_report()
	var/list/parts = list()
	var/datum/objective/summon_carp/S = locate() in objectives
	if(S.check_completion())
		parts += span_redtextbig("The [name] has succeeded! Station space has been reclaimed by the space carp!")
	parts += printplayer(owner)
	var/objectives_complete = TRUE
	if(length(objectives))
		parts += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(objectives_complete)
		parts += span_greentextbig("The [name] was successful!")
	else
		parts += span_redtextbig("The [name] has failed!")
	if(length(carp))
		parts += "<br><span class='header'>The [name] was assisted by:</span>"
		parts += "<ul class='playerlist'>"
		var/list/players_to_carp_taken = list()
		for(var/datum/mind/carpy as anything in carp)
			players_to_carp_taken[carpy.key] += 1
		var/list = ""
		for(var/carp_user in players_to_carp_taken)
			list += "<li><b>[carp_user]<b>, who played <b>[players_to_carp_taken[carp_user]]</b> space carps.</li>"
		parts += list
		parts += "</ul>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
