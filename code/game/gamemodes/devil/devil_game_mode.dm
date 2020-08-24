/datum/game_mode/devil
	name = "devil"
	config_tag = "devil"
	report_type = "devil"
	antag_flag = ROLE_DEVIL
	false_report_weight = 1
	protected_jobs = list("Lawyer", "Curator", "Chaplain", "Head of Security", "Captain", "AI", "Cyborg", "Security Officer", "Warden", "Detective", "Brig Physician")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 0
	title_icon = "devil"

	var/traitors_possible = 4 //hard limit on devils if scaling is turned off
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.
	var/objective_count = 2
	var/minimum_devils = 1

	announce_text = "There are devils onboard the station!\n\
		+	<span class='danger'>Devils</span>: Purchase souls and tempt the crew to sin!\n\
		+	<span class='notice'>Crew</span>: Resist the lure of sin and remain pure!"

/datum/game_mode/devil/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += GLOB.command_positions

	var/num_devils = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_devils = max(minimum_devils, min( round(num_players() / (tsc * 3))+ 2 + num_modifier, round(num_players() / (tsc * 1.5)) + num_modifier))
	else
		num_devils = max(minimum_devils, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_devils, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/devil = antag_pick(antag_candidates, ROLE_DEVIL)
		devils += devil
		devil.special_role = traitor_name
		devil.restricted_roles = restricted_jobs

		log_game("[key_name(devil)] has been selected as a [traitor_name]")
		antag_candidates.Remove(devil)

	if(devils.len < required_enemies)
		setup_error = "Not enough devil candidates"
		return 0
	return 1


/datum/game_mode/devil/post_setup()
	for(var/datum/mind/devil in devils)
		post_setup_finalize(devil)
	..()
	return 1

/datum/game_mode/devil/generate_report()
	return "Infernal creatures have been seen nearby offering great boons in exchange for souls.  This is considered theft against Nanotrasen, as all employment contracts contain a lien on the \
			employee's soul.  If anyone sells their soul in error, contact an attorney to overrule the sale.  Be warned that if the devil purchases enough souls, a gateway to hell may open."

/datum/game_mode/devil/proc/post_setup_finalize(datum/mind/devil)
	add_devil(devil.current, ascendable = TRUE) //Devil gamemode devils are ascendable.
	add_devil_objectives(devil,2)

/proc/is_devil(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/devil)

/proc/add_devil(mob/living/L, ascendable = FALSE)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/devil/devil_datum = L.mind.add_antag_datum(/datum/antagonist/devil)
	devil_datum.ascendable = ascendable
	return devil_datum

/proc/remove_devil(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/devil_datum = L.mind.has_antag_datum(/datum/antagonist/devil)
	devil_datum.on_removal()
	return TRUE

/datum/game_mode/devil/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Tempting Devils:</h1>"
	len_before_addition = round_credits.len
	var/datum/antagonist/devil/devil_info
	for(var/datum/mind/devil in devils)
		devil_info = devil.has_antag_datum(/datum/antagonist/devil)
		if(devil_info) // This should never fail, but better to be sure
			round_credits += "<center><h2>[devil_info.truename] in the form of [devil.name]</h2>"
			devil_info = null
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The devils were all utterly destroyed!</h2>", "<center><h2>The love of Space Jesus shines through!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
