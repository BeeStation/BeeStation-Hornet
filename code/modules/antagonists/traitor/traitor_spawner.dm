/*
 * Traitors have been refactored into minor antagonists so they can
 * be used alongside other compatible gamemodes with ease.
 * This code is what creates them.
 */

/datum/special_role/traitor
	attached_antag_datum = /datum/antagonist/traitor
	spawn_mode = SPAWNTYPE_ROUNDSTART
	probability = 15	//15% chance to be plopped ontop
	proportion = 0.07	//Quite a low amount since we are going alongside other gamemodes.
	max_amount = 5
	allowAntagTargets = TRUE
	latejoin_allowed = TRUE
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")

	special_role_flag = ROLE_TRAITOR
	role_name = ROLE_TRAITOR

/datum/special_role/traitor/higher_chance
	probability = 60

/datum/special_role/traitor/add_antag_status_to(datum/mind/M)
	addtimer(CALLBACK(src, .proc/reveal_antag_status, M), rand(10,100))

/datum/special_role/traitor/proc/reveal_antag_status(datum/mind/M)
	M.special_role = role_name
	var/datum/antagonist/special/A = M.add_antag_datum(new attached_antag_datum())
	A.forge_objectives(M)
	A.equip()
	return A

/datum/special_role/traitor/infiltrator
	attached_antag_datum = /datum/antagonist/traitor/infiltrator
	probability = 5			//5% chance for this to occur. Kind of rare, but something that HOS's and wardens need to consider.
	min_players = 20		//Give us 20 players minimum.
	proportion = 1			//This is limited by max amount anyway.
	max_amount = 1			//Only 1, we don't want insane chaos
	telecrystals = 16		//You are in security and have gear. You get slightly less to work with.

/datum/special_role/traitor/infiltrator/New()
	. = ..()
	//Make sure HOS or warden exists
	var/allowed = FALSE
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.mind?.assigned_role in list("Head of Security", "Warden"))
			allowed = TRUE
			break
	if(!allowed)
		probability = 0
	protected_jobs = get_all_jobs()
	protected_jobs -= list("Detective", "Security Officer")

/datum/antagonist/traitor/infiltrator
	name = "Infiltrator"
	telecrystals = 16

/datum/antagonist/traitor/infiltrator/on_gain()
	. = ..()
	to_chat(owner.current, "<span class='syndradio italics'>It's taken a lot of work from a lot of people to get you in this possition. Don't mess this up, we are counting on you.</span>")
	to_chat(owner.current, "<span class='warning'>You have been inserted into the security detail of [station_name()]. You have a strong resiliance against the effects of the mindshield and have been cleared past Nanotrasen's background checks. You have a reduced supply of telecrystals, but have a lot to work with in terms of your environment. Good luck.</span>")
