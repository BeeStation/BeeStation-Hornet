GLOBAL_LIST_EMPTY(servants_of_ratvar)	//List of minds in the cult
GLOBAL_LIST_EMPTY(all_servants_of_ratvar)	//List of minds in the cult
GLOBAL_LIST_EMPTY(human_servants_of_ratvar)	//Humans in the cult
GLOBAL_LIST_EMPTY(cyborg_servants_of_ratvar)

GLOBAL_VAR(ratvar_arrival_tick)	//The world.time that Ratvar will arrive if the gateway is not disrupted

GLOBAL_VAR_INIT(installed_integration_cogs, 0)

GLOBAL_VAR(celestial_gateway)	//The celestial gateway
GLOBAL_VAR_INIT(ratvar_risen, FALSE)	//Has ratvar risen?
GLOBAL_VAR_INIT(gateway_opening, FALSE)	//Is the gateway currently active?

GLOBAL_VAR_INIT(clockcult_power, 2500)
GLOBAL_VAR_INIT(clockcult_vitality, 200)

GLOBAL_VAR(clockcult_eminence)

//==========================
//===Clock cult Gamemode ===
//==========================

/datum/game_mode/clockcult
	name = "clockcult"
	config_tag = "clockcult"
	report_type = "clockcult"
	false_report_weight = 5
	required_players = 24
	required_enemies = 4
	recommended_enemies = 4
	role_preference = /datum/role_preference/antagonist/clock_cultist
	antag_datum = /datum/antagonist/servant_of_ratvar

	title_icon = "clockcult"
	announce_span = "danger"
	announce_text = "A powerful group of fanatics is trying to summon their deity!\n \
	" + span_danger("Servants") + ": Convert more servants and defend the Ark of the Clockwork Justicar!\n \
	" + span_notice("Crew") + ": Prepare yourselfs and destroy the Ark of the Clockwork Justicar."

	var/clock_cultists = CLOCKCULT_SERVANTS
	var/list/selected_servants = list()

	var/datum/team/clock_cult/main_cult

/datum/game_mode/clockcult/setup_maps()
	//Since we are loading in pre_setup, disable map loading.
	SSticker.gamemode_hotswap_disabled = TRUE
	LoadReebe()
	return TRUE

/datum/game_mode/clockcult/pre_setup()
	//Generate cultists
	for(var/i in 1 to clock_cultists)
		if(!antag_candidates.len)
			break
		var/datum/mind/clockie = antag_pick(antag_candidates, /datum/role_preference/antagonist/clock_cultist)
		//In case antag_pick breaks
		if(!clockie)
			continue
		antag_candidates -= clockie
		selected_servants += clockie
		clockie.assigned_role = ROLE_SERVANT_OF_RATVAR
		clockie.special_role = ROLE_SERVANT_OF_RATVAR
		GLOB.pre_setup_antags += clockie
	generate_clockcult_scriptures()
	return TRUE

/datum/game_mode/clockcult/post_setup(report)
	var/list/spawns = GLOB.servant_spawns.Copy()
	main_cult = new
	main_cult.setup_objectives()
	//Create team
	for(var/datum/mind/servant_mind in selected_servants)
		//Somehow the mind has no mob, ignore them so it doesn't break everything
		if(!(servant_mind?.current))
			continue
		//Somehow all spawns where used, reuse old spawns
		if(!length(spawns))
			spawns = GLOB.servant_spawns.Copy()
		servant_mind.current.forceMove(pick_n_take(spawns))
		servant_mind.current.set_species(/datum/species/human)
		var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(servant_mind.current, team=main_cult)
		S.equip_carbon(servant_mind.current)
		S.equip_servant()
		S.prefix = CLOCKCULT_PREFIX_MASTER
		GLOB.pre_setup_antags -= S
	//Setup the conversion limits for auto opening the ark
	calculate_clockcult_values()
	return ..()

/datum/game_mode/clockcult/generate_report()
	return "Central Command's higher dimensional affairs division has been recently investigating a huge, anomalous energy spike \
	emanating from a neutron star close to your sector. It is currently theorised that an ancient group of fanatics praising an \
	eldritch deity made from brass and other outdated materials are abusing the energy of the dying star to breach dimensional \
	boundaries. The bluespace veil is faltering at your current location, making it a prime target for dangerous individuals to \
	abuse dimensional interdiction. Any evidence of tampering with bluespace fields should be reported to your local chaplain and \
	Central Command if a connection is still available at the time of discovery."

/datum/game_mode/clockcult/set_round_result()
	..()
	if(check_cult_victory())
		SSticker.mode_result = "win - clockcult win"
		SSticker.news_report = CLOCK_SUMMON
	else if(LAZYLEN(GLOB.cyborg_servants_of_ratvar))
		SSticker.mode_result = "loss - staff destroyed the ark"
		SSticker.news_report = CLOCK_SILICONS
	else
		SSticker.mode_result = "loss - staff destroyed the ark"
		SSticker.news_report = CLOCK_PROSELYTIZATION

/datum/game_mode/clockcult/check_finished(force_ending)
	return force_ending

/datum/game_mode/clockcult/proc/check_cult_victory()
	return GLOB.ratvar_risen

/datum/game_mode/clockcult/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	if(GLOB.ratvar_risen)
		round_credits += "<center><h1>Ratvar has been released from his prison!</h1>"
	else
		round_credits += "<center><h1>The clock cultists failed to summon Ratvar, he will remain trapped forever to rust!</h1>"
	round_credits += "<center><h1>The Servants of Ratvar:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/operative in GLOB.servants_of_ratvar)
		round_credits += "<center><h2>[operative.name] as a servant of Ratvar!</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The servants were annihilated!</h2>", "<center><h2>Their remains could not be identified!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits

/datum/game_mode/proc/update_clockcult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "clockwork")

/datum/game_mode/proc/update_clockcult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)

//==========================
//==== Clock cult procs ====
//==========================

//Similar to cultist one, except silicons are allowed
/proc/is_convertable_to_clockcult(mob/living/M)
	if(!istype(M))
		return FALSE
	if(!M.mind)
		return FALSE
	if(ishuman(M) && (M.mind.assigned_role in list(JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN)))
		return FALSE
	if(istype(M.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
		return FALSE
	if(IS_SERVANT_OF_RATVAR(M))
		return FALSE
	if(M.mind.enslaved_to && !M.mind.enslaved_to.has_antag_datum(/datum/antagonist/servant_of_ratvar))
		return FALSE
	if(M.mind.unconvertable)
		return FALSE
	if(IS_CULTIST(M) || isconstruct(M) || ispAI(M))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return FALSE
	return TRUE
