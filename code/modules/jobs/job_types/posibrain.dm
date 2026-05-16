GLOBAL_LIST_EMPTY(on_station_posis)

/datum/job/posibrain
	title = JOB_NAME_POSIBRAIN
	description = "Follow your AI's interpretation of your laws above all else, or your own interpretation if not connected to an AI. Choose one of many modules with different tools, ask robotics for maintenance and upgrades."
	department_for_prefs = DEPARTMENT_NAME_SILICON
	department_head_for_prefs = JOB_NAME_AI
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = FACTION_STATION
	total_positions = 0
	supervisors = "your laws" //No AI yet as you are just a cube
	selection_color = "#ddffdd"
	minimal_player_age = 21
	exp_requirements = 120
	exp_required_type = EXP_TYPE_CREW
	random_spawns_possible = FALSE

	job_flags = JOB_CANNOT_OPEN_SLOTS

	display_order = JOB_DISPLAY_ORDER_CYBORG
	departments_list = list(
		/datum/department_group/silicon,
		)

	show_in_prefs = FALSE //No reason to show in preferences

/// Posibrain spawns at a random available on-station posi item, not at a map landmark.
/datum/job/posibrain/get_latejoin_spawn_point()
	return pick(GLOB.on_station_posis)

/// Returns the existing brainmob from the selected posibrain item rather than creating a new human.
/datum/job/posibrain/get_spawn_mob(client/player_client, atom/spawn_point)
	var/obj/item/mmi/posibrain/posi = spawn_point
	if(!istype(posi) || QDELETED(posi) || QDELETED(posi.brainmob) || posi.is_occupied())
		return null
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(player_client, span_warning("Central Command has temporarily outlawed posibrain sentience in this sector..."))
		return null
	var/mob/living/brain/brainmob = posi.brainmob
	var/character_name
	if(player_client.prefs.read_character_preference(/datum/preference/choiced/random_name) == RANDOM_ENABLED \
	|| CONFIG_GET(flag/force_random_names) \
	|| is_banned_from(player_client.ckey, "Appearance"))
		character_name = generate_random_name_species_based(
			player_client.prefs.read_character_preference(/datum/preference/choiced/gender),
			TRUE,
			player_client.prefs.read_character_preference(/datum/preference/choiced/species),
		)
	else
		character_name = player_client.prefs.read_character_preference(/datum/preference/name/real_name)
	if(character_name)
		brainmob.real_name = character_name
		brainmob.name = character_name
	return brainmob

/datum/job/posibrain/after_latejoin_spawn(mob/living/spawning)
	. = ..()
	var/obj/item/mmi/posibrain/posi = spawning
	if(!istype(posi))
		return
	remove_posi_slot(posi)
	posi.name = "[initial(posi.name)] ([spawning.name])"
	to_chat(spawning, posi.welcome_message)
	spawning.set_stat(CONSCIOUS)
	spawning.remove_from_dead_mob_list()
	spawning.add_to_alive_mob_list()
	posi.visible_message(posi.success_message)
	playsound(posi, 'sound/machines/ping.ogg', 15, TRUE)
	posi.update_icon()
	posi.investigate_flags = ADMIN_INVESTIGATE_TARGET

/datum/job/posibrain/get_radio_information()
	return "<b>Prefix your message with :b to speak with other cyborgs and AI.</b>"

/datum/job/posibrain/proc/check_add_posi_slot(obj/item/mmi/posibrain/pb)
	var/turf/currentturf = get_turf(pb)
	if( is_station_level(currentturf.z) )
		GLOB.on_station_posis |= pb

	//Update Job Quantities
	//We should never show a posibrain as a filled job, so just make number of current positions zero
	current_positions = 0
	total_positions = length(GLOB.on_station_posis)

/datum/job/posibrain/proc/remove_posi_slot(obj/item/mmi/posibrain/pb)
	GLOB.on_station_posis -= pb

	//Update Job Quantities
	//We should never show a posibrain as a filled job, so just make number of current positions zero
	current_positions = 0
	total_positions = length(GLOB.on_station_posis)
