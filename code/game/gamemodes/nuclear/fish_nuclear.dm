#define FLUKEOPS_TIME_DELAY 12000 // 20 minutes, how long before the credits stop calling the nukies flukeops

/datum/game_mode/nuclear/fishy
	name = "fishy nuclear emergency"
	config_tag = "fish_nuclear"
	report_type = "fish_nuclear"
	false_report_weight = 10
	required_players = 30 // 30 players - 7 players to be the nuke ops = 23 players remaining
	required_enemies = 8
	recommended_enemies = 5
	antag_flag = ROLE_OPERATIVE //same as normal nuclear ops
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "Syndicate forces are approaching the station in an attempt to destroy it!\n\
	<span class='danger'>Operatives</span>: Secure the nuclear authentication disk and use your nuke to destroy the station.\n\
	<span class='notice'>Crew</span>: Defend the nuclear authentication disk and ensure that it leaves with you on the emergency shuttle."

	title_icon = "nukeops"

	//var/operative_antag_datum_type = /datum/antagonist/nukeop
	//var/leader_antag_datum_type = /datum/antagonist/nukeop/leader

/datum/game_mode/nuclear/fishy/pre_setup()
	var/n_agents = min(round(num_players() / 10), antag_candidates.len, agents_possible)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_nukeops += new_op
			new_op.assigned_role = "A very fishy Nuclear Operative"
			new_op.special_role = "A very fishy Nuclear Operative"
			log_game("[key_name(new_op)] has been selected as a fishy nuclear operative")
		return TRUE
	else
		setup_error = "Not enough fishy candidates"
		return FALSE
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/fishy/post_setup()
	//Assign leader
	var/datum/mind/leader_mind = pre_nukeops[1]
	var/datum/antagonist/nukeop/L = leader_mind.add_antag_datum(leader_antag_datum_type)
	nuke_team = L.nuke_team
	return ..()
	//Assign the remaining operatives
	for(var/i = 2 to pre_nukeops.len)
		var/datum/mind/nuke_mind = pre_nukeops[i]
		nuke_mind.add_antag_datum(operative_antag_datum_type)
	return ..()

/datum/game_mode/nuclear/fishy/OnNukeExplosion(off_station)
	..()
	nukes_left--

/datum/game_mode/nuclear/fishy/check_win()
	if (nukes_left == 0)
		return TRUE
	return ..()

/datum/game_mode/nuclear/fishy/check_finished()
	//Keep the round going if ops are dead but bomb is ticking.
	if(nuke_team.operatives_dead())
		for(var/obj/machinery/nuclearbomb/N in GLOB.nuke_list)
			if(N.proper_bomb && (N.timing || N.exploding))
				return FALSE
	return ..()

/datum/game_mode/nuclear/fishy/set_round_result()
	..()
	var result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/game_mode/nuclear/fishy/generate_report()
	return "One of Central Command's trading routes was recently disrupted by a raid carried out by the Gorlex Marauders. They seemed to only be after one ship - a highly-sensitive \
			transport containing a nuclear fission explosive, although it is useless without the proper code and authorization disk. While the code was likely found in minutes, the only disk that \
			can activate this explosive is on your station. Ensure that it is protected at all times, and remain alert for possible intruders."

/datum/outfit/fishop
	name = "fish operative outfit"

/datum/outfit/fishop/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/mob/living/simple_animal/hostile/carp/cayenne/fishy_operator/fish = new(H.loc)
	H.mind.transfer_to(fish)
	if(H.key)
		fish.key = H.key
	qdel(H)
    //TO DO add radio implant
	//var/obj/item/radio/R = H.ears
	//R.set_frequency(FREQ_SYNDICATE)
	//R.freqlock = TRUE
	//if(command_radio)sawdwad
	//	R.command = TRUE

	var/obj/item/implant/explosive/E = new /obj/item/implant/explosive(fish)
	E.implant(fish)
	var/obj/item/implant/weapons_auth/W = new /obj/item/implant/weapons_auth(fish)
	W.implant(fish)
	fish.faction |= ROLE_SYNDICATE
	fish.update_icons()

/datum/outfit/fishop/leader
	name = "leader fish operative outfit"

/datum/outfit/fishop/leader/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	new /obj/item/nuclear_challenge(H.loc)

/datum/game_mode/nuclear/fishy/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	if((world.time-SSticker.round_start_time) < (FLUKEOPS_TIME_DELAY)) // If the nukies died super early, they're basically a massive disappointment
		title_icon = "flukeops"

	round_credits += "<center><h1>The [syndicate_name()] Operatives:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/operative in nuke_team.members)
		round_credits += "<center><h2>[operative.name] as a nuclear operative</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The operatives blew themselves up!</h2>", "<center><h2>Their remains could not be identified!</h2>")
		round_credits += "<br>"

	round_credits += ..()
	return round_credits
