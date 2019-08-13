//mistake time
/datum/game_mode

/datum/game_mode/nations
	name = "Nations"
	config_tag = "nations"
	report_type = "nations"
	required_players = 0
	required_enemies = 0
	recommended_enemies = 0
	reroll_friendly = 0
	enemy_minimum_age = 0
	false_report_weight = 1
	var/list/living_crew = list()
	var/list/nations = list()

/datum/antagonist/nations
	name = "NATION"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nationengi
	var/hud_type = "nation"

/datum/game_mode/nations/pre_setup()
	for(var/datum/mind/H)
		living_crew += H
		nations += H
	return TRUE

		//sci
/datum/game_mode/nations/post_setup()
	for(var/datum/mind/M in living_crew)
		log_game("Nations Is starting to exist")
		for(var/mob/living/carbon/human/H)
			switch(H.job)
				if("Atmospheric Technician","Station Engineer","Chief Engineer")
					M.add_antag_datum(/datum/antagonist/engitopia)
					log_game("Nations Is possibly attempting to work")
				if("Research Director","Scientist","Roboticist")
					M.add_antag_datum(/datum/antagonist/sciencetopia)
					log_game("Nations Is possibly attempting to work")
				if("Bartender","Botanist","Cook","Janitor","Curator","Lawyer","Chaplain","Clown","Mime","Assistant","Head of Personnel")
					M.add_antag_datum(/datum/antagonist/servicetopia)
					log_game("Nations Is possibly attempting to work")
				if("Quartermaster","Cargo Technician","Shaft Miner")
					M.add_antag_datum(/datum/antagonist/cargonia)
					log_game("Nations Is possibly attempting to work")
				if("Quartermaster","Cargo Technician","Shaft Miner")
					M.add_antag_datum(/datum/antagonist/securitystan)
					log_game("Nations Is possibly attempting to work")
				if(	"Chief Medical Officer","Medical Doctor","Geneticist","Virologist","Chemist")
					M.add_antag_datum(/datum/antagonist/medistannis)
					log_game("Nations Is possibly attempting to work")
	return TRUE


/datum/game_mode/nations/make_antag_chance(mob/living/carbon/human/character)
	switch(character.job)
		if("Atmospheric Technician","Station Engineer","Chief Engineer")
			character.mind.add_antag_datum(/datum/antagonist/engitopia)
			log_game("Nations Is possibly attempting to work")
		if("Research Director","Scientist","Roboticist")
			character.mind.add_antag_datum(/datum/antagonist/sciencetopia)
			log_game("Nations Is possibly attempting to work")
		if("Bartender","Botanist","Cook","Janitor","Curator","Lawyer","Chaplain","Clown","Mime","Assistant","Head of Personnel")
			character.mind.add_antag_datum(/datum/antagonist/servicetopia)
			log_game("Nations Is possibly attempting to work")
		if("Quartermaster","Cargo Technician","Shaft Miner")
			character.mind.add_antag_datum(/datum/antagonist/cargonia)
			log_game("Nations Is possibly attempting to work")
		if("Quartermaster","Cargo Technician","Shaft Miner")
			character.mind.add_antag_datum(/datum/antagonist/securitystan)
			log_game("Nations Is possibly attempting to work")
		if(	"Chief Medical Officer","Medical Doctor","Geneticist","Virologist","Chemist")
			character.mind.add_antag_datum(/datum/antagonist/medistannis)
			log_game("Nations Is possibly attempting to work")