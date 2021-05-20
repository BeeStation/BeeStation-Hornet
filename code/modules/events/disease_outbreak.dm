/datum/round_event_control/disease_outbreak
	name = "Disease Outbreak"
	typepath = /datum/round_event/disease_outbreak
	max_occurrences = 1
	min_players = 10
	weight = 5
	earliest_start = 10 MINUTES

/datum/round_event/disease_outbreak
	announceWhen	= 15

	var/virus_type

	var/max_severity = 2


/datum/round_event/disease_outbreak/announce(fake)
	priority_announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK7)

/datum/round_event/disease_outbreak/setup()
	announceWhen = rand(15, 30)


/datum/round_event/disease_outbreak/start()
	var/advanced_virus = TRUE //default virus is a random advanced disease
	var/dangerous_virus = FALSE
	max_severity = 3 + max(FLOOR((world.time - control.earliest_start)/3000, 1),0) //2 symptoms at 10 minutes, plus 1 per 5 minutes. reaches symptom cap at 30 minutes
	if(prob(0 + (2 * max_severity)))
		dangerous_virus = TRUE // more chance at a dangerous disease the more time passes. at 40 minutes, this event has a 16% chance of a dangerous disease
	if(prob(10 + (5 * max_severity)))
		advanced_virus = FALSE // more chance at a special disease the more time passes. more common than dangerous diseases. 50% chance of a special disease at 40 minutes

	if(!virus_type && !advanced_virus && dangerous_virus)
		virus_type = pick(/datum/disease/dnaspread, /datum/disease/brainrot, /datum/disease/rhumba_beat, /datum/disease/gastrolosis, /datum/disease/wizarditis)

	if(!virus_type && !advanced_virus)
		virus_type = pick(/datum/disease/fake_gbs, /datum/disease/cold9, /datum/disease/magnitis, /datum/disease/pierrot_throat, /datum/disease/beesease)

	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(!is_station_level(T.z))
			continue
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(HAS_TRAIT(H, TRAIT_VIRUSIMMUNE)) //Don't pick someone who's virus immune, only for it to not do anything.
			continue
		var/foundAlready = FALSE	// don't infect someone that already has a disease
		for(var/thing in H.diseases)
			foundAlready = TRUE
			break
		if(foundAlready)
			continue

		var/datum/disease/D
		if(!advanced_virus)
			if(virus_type == /datum/disease/dnaspread)		//Dnaspread needs strain_data set to work.
				D = new virus_type()
				var/datum/disease/dnaspread/DS = D
				DS.strain_data["name"] = H.real_name
				DS.strain_data["UI"] = H.dna.uni_identity
				DS.strain_data["SE"] = H.dna.mutation_index
		else
			D = new /datum/disease/advance/random(max_severity, max_severity)
		D.carrier = TRUE
		H.ForceContractDisease(D, FALSE, TRUE)

		if(advanced_virus)
			var/datum/disease/advance/A = D
			var/list/name_symptoms = list() //for feedback
			for(var/datum/symptom/S in A.symptoms)
				name_symptoms += S.name
			message_admins("An event has triggered a random advanced virus outbreak on [ADMIN_LOOKUPFLW(H)]! It has these symptoms: [english_list(name_symptoms)]")
			log_game("An event has triggered a random advanced virus outbreak on [key_name(H)]! It has these symptoms: [english_list(name_symptoms)]")
		break
