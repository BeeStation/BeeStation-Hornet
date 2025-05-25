/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	report_type = "vampire"
	role_preference = /datum/role_preference/antagonist/vampire
	antag_datum = /datum/antagonist/vampire
	false_report_weight = 20 //Reports of vampires are pretty common.
	restricted_jobs = list(JOB_NAME_CYBORG)//They are part of the AI if he is vampire so are they, they use to get double chances
	protected_jobs = list(JOB_NAME_CAPTAIN, JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN, JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_CURATOR)
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1

	announce_span = "danger"
	announce_text = "Undead vampires have infested the station!\n \
	" + span_danger("Vampires") + ": Accomplish your objectives and vassalize the crew.\n \
	" + span_notice("Crew") + ": Do not let the vampires succeed!"

	title_icon = "vampire"

	var/const/vampire_amount = 4 //hard limit on vampires if scaling is turned off
	var/list/vampires = list()

/datum/game_mode/vampire/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)

	var/num_vampires = 1

	var/vsc = CONFIG_GET(number/vampire_scaling_coeff)
	if(vsc)
		num_vampires = max(1, min(round(num_players() / (vsc * 2)) + 2, round(num_players() / vsc)))
	else
		num_vampires = max(1, min(num_players(), vampire_amount))

	if(antag_candidates.len>0)
		for(var/i = 0, i < num_vampires, i++)
			if(!antag_candidates.len)
				break
			var/datum/mind/vampire = antag_pick(antag_candidates, /datum/role_preference/antagonist/vampire)
			antag_candidates -= vampire
			vampires += vampire
			vampire.special_role = ROLE_VAMPIRE
			vampire.restricted_roles = restricted_jobs
			GLOB.pre_setup_antags += vampire
		return TRUE
	else
		setup_error = "Not enough vampire candidates"
		return FALSE

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in vampires)
		log_game("[key_name(vampire)] has been selected as a vampire")
		var/datum/antagonist/vampire/new_antag = new()
		vampire.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= vampire
	..()

/datum/game_mode/vampire/make_antag_chance(mob/living/carbon/human/character) //Assigns vampire to latejoiners
	var/vsc = CONFIG_GET(number/vampire_scaling_coeff)
	var/vampirecap = min(round(GLOB.joined_player_list.len / (vsc * 2)) + 2, round(GLOB.joined_player_list.len / vsc))
	if(vampires.len >= vampirecap) //Caps number of latejoin antagonists
		return
	if(vampires.len <= (vampirecap - 2) || prob(100 - (vsc * 2)))
		if(!QDELETED(character) && character.client?.should_include_for_role(
			banning_key = initial(antag_datum.banning_key),
			role_preference_key = role_preference,
			req_hours = initial(antag_datum.required_living_playtime)
		))
			if(!(character.job in restricted_jobs))
				character.mind.make_vampire()
				vampires += character.mind

/datum/game_mode/vampire/generate_report()
	return "Although more specific threats are commonplace, you should always remain vigilant for Syndicate agents aboard your station. Syndicate communications have implied that many \
		Nanotrasen employees are Syndicate agents with hidden memories that may be activated at a moment's notice, so it's possible that these agents might not even know their positions."

/datum/game_mode/vampire/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The vampires:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/vampire in vampires)
		round_credits += "<center><h2>[vampire.name] as a vampire</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The vampires have concealed their treachery!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
