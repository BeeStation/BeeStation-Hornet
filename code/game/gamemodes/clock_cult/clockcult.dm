//==========================
//===Clock cult Gamemode ===
//==========================

GLOBAL_LIST_EMPTY(servants_of_ratvar)
GLOBAL_VAR_INIT(gateway_opening, FALSE)

/datum/game_mode/clockcult
	name = "clockcult"
	config_tag = "clockcult"
	report_type = "clockcult"
	false_report_weight = 5
	required_players = 24
	required_enemies = 4
	recommended_enemies = 4
	antag_flag = ROLE_SERVANT_OF_RATVAR
	enemy_minimum_age = 14

	title_icon = "clockcult"

	var/datum/team/clockcult/clockcult_team
	var/clock_cultists = CLOCKCULT_MIN_SERVANTS
	var/list/selected_servants = list()

/datum/game_mode/clockcult/pre_setup()
	//Load Reebe
	var/list/errorList = list()
	var/list/reebe = SSmapping.LoadGroup(errorList, "Reebe", "map_files/generic", "CityOfCogs.dmm", default_traits=ZTRAITS_REEBE, silent=TRUE)
	if(errorList.len)
		message_admins("Reebe failed to load")
		log_game("Reebe failed to load")
		return FALSE
	for(var/datum/parsed_map/map in reebe)
		map.initTemplateBounds()
	//How many cultists?
	var/players = get_active_player_count()
	players = round(players / CLOCKCULT_CREW_PER_CULT)
	players = clamp(players, CLOCKCULT_MIN_SERVANTS, CLOCKCULT_MAX_SERVANTS)
	//Generate cultists
	for(var/i in 1 to players)
		if(!antag_candidates.len)
			message_admins("Not enough servants, only [i-1] managed to spawn.")
			break	//Oof, debug mode huh?
		var/datum/mind/clockie = antag_pick(antag_candidates, ROLE_SERVANT_OF_RATVAR)
		message_admins("[clockie.current.ckey] is now a clock cultists!")
		antag_candidates -= clockie
		selected_servants += clockie
		clockie.assigned_role = ROLE_SERVANT_OF_RATVAR
		clockie.special_role = ROLE_SERVANT_OF_RATVAR
	//Generate clock classes
	for(var/class in typesof(/datum/clockcult/servant_class))
		GLOB.servant_classes |= class
	return TRUE

/datum/game_mode/clockcult/post_setup(report)
	var/list/spawns = GLOB.servant_spawns.Copy()
	for(var/datum/mind/servant_mind in selected_servants)
		servant_mind.current.forceMove(pick_n_take(spawns))
		var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(servant_mind.current)
		S.equip_servant_basic(TRUE)
	return ..()

/datum/game_mode/clockcult/check_finished(force_ending)
	return FALSE

//==========================
//==== Clock cult procs ====
//==========================

/proc/add_servant_of_ratvar(mob/M)
	if(!istype(M))
		return
	var/antagdatum = /datum/antagonist/servant_of_ratvar
	. = M.mind.add_antag_datum(antagdatum)

/proc/is_servant_of_ratvar(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/servant_of_ratvar)

//Similar to cultist one, except silicons are allowed
/proc/is_convertable_to_clockcult(mob/living/M)
	if(!istype(M))
		return FALSE
	if(!M.mind)
		return FALSE
	if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
		return FALSE
	if(M.mind.enslaved_to && !is_servant_of_ratvar(M.mind.enslaved_to))
		return FALSE
	if(M.mind.unconvertable)
		return FALSE
	if(iscultist(M) || isconstruct(M) || ispAI(M))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return FALSE
	if(ishuman(M) || isbrain(M) || isguardian(M) || issilicon(M))
		return TRUE
	return FALSE

/proc/flee_reebe(allow_servant_exit = FALSE)
	for(var/mob/living/M in GLOB.mob_list)
		if(!is_reebe(get_area(M).z))
			continue
		var/safe_place = find_safe_turf()
		if(is_servant_of_ratvar(M))
			if(!allow_servant_exit)
				continue
		else
			M.SetSleeping(50)
		M.forceMove(safe_place)

//Transmits a message to everyone in the cult
//Doesn't work if the cultists contain holy water, or are not on the station or Reebe
/proc/hierophant_message(msg, mob/living/sender, span = "<span class='brass'>")
	var/hierophant_message = "[span]"
	if(!msg)
		if(sender)
			to_chat(sender, "<span class='brass'>You cannot transmit nothing!</span>")
		return FALSE
	if(sender)
		hierophant_message += "<b>[sender.name]</b> transmits, \"[msg]\""
	else
		hierophant_message += msg
	if(span)
		hierophant_message += "</span>"
	for(var/mob/M in GLOB.player_list)
		if(isliving(M) && !is_servant_of_ratvar(M))
			continue
		to_chat(M, hierophant_message)
		SEND_SOUND(M, 'sound/magic/clockwork/fellowship_armory.ogg')
