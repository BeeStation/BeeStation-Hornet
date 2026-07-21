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
	var/unfunny_virus = TRUE
	max_severity = 3 + max(floor((world.time - control.earliest_start)/3000),0) //2 symptoms at 10 minutes, plus 1 per 5 minutes. reaches symptom cap at 30 minutes
	if(!virus_type && prob(0 + (2 * max_severity)))
		dangerous_virus = TRUE // more chance at a dangerous disease the more time passes. at 40 minutes, this event has a 16% chance of a dangerous disease
	if(!virus_type && prob(max_severity)) //allows for a far higher chance at level 0 symptoms
		unfunny_virus = FALSE
	if(!virus_type && prob(min(50, (10 + (5 * max_severity)))))
		advanced_virus = FALSE // more chance at a special disease the more time passes. more common than dangerous diseases. 50% chance of a special disease at 40 minutes

	if(!virus_type && !advanced_virus && dangerous_virus)
		virus_type = pick(/datum/disease/dnaspread, /datum/disease/brainrot, /datum/disease/rhumba_beat, /datum/disease/gastrolosis, /datum/disease/wizarditis)

	if(!virus_type && !advanced_virus)
		virus_type = pick(/datum/disease/fake_gbs, /datum/disease/cold9, /datum/disease/magnitis, /datum/disease/pierrot_throat, /datum/disease/beesease)

	for(var/mob/living/carbon/human/victim in shuffle(GLOB.human_list))
		var/turf/T = get_turf(victim)
		if(!T)
			continue
		if(!is_station_level(T.z))
			continue
		if(!victim.client)
			continue
		if(victim.stat == DEAD)
			continue
		if(!(victim.mob_biotypes & MOB_ORGANIC))
			continue
		if(HAS_TRAIT(victim, TRAIT_VIRUSIMMUNE)) //Don't pick someone who's virus immune, only for it to not do anything.
			continue
		// don't infect someone that already has a disease
		if(length(victim.diseases))
			continue

		var/datum/disease/new_disease
		if(!advanced_virus)
			if(virus_type == /datum/disease/dnaspread)		//Dnaspread needs strain_data set to work.
				new_disease = new virus_type()
				var/datum/disease/dnaspread/DS = new_disease
				DS.strain_data["name"] = victim.real_name
				DS.strain_data["UI"] = victim.dna.unique_identity
				DS.strain_data["SE"] = victim.dna.mutation_index
		else
			var/static/list/spreadsymptoms = list(
				/datum/symptom/sneeze = 20,
				/datum/symptom/cough = 20,
				/datum/symptom/pierrot = 1,
				/datum/symptom/meme = 3,
			)
			var/static/list/majorspreadsymptoms = list(
				/datum/symptom/pustule = 10,
				/datum/symptom/macrophage = 10,
				/datum/symptom/flesh_death = 1,
			)
			var/static/list/effectivesymptoms = list(
				/datum/symptom/heal/surface,
				/datum/symptom/sweat,
				/datum/symptom/parasite,
				/datum/symptom/alcohol,
				/datum/symptom/beesease,
				/datum/symptom/deafness,
				/datum/symptom/fever,
				/datum/symptom/genetic_mutation,
				/datum/symptom/hallucigen,
				/datum/symptom/lubefeet,
				/datum/symptom/shedding,
				/datum/symptom/beard,
				/datum/symptom/visionloss,
				/datum/symptom/voice_change,
				/datum/symptom/cockroach,
			)
			var/static/list/majoreffectivesymptoms = list(
				/datum/symptom/heal/coma,
				/datum/symptom/EMP,
				/datum/symptom/growth,
				/datum/symptom/vampirism,
				/datum/symptom/braindamage,
				/datum/symptom/asphyxiation,
				/datum/symptom/robotic_adaptation,
				/datum/symptom/alkali,
				/datum/symptom/heartattack,
				/datum/symptom/toxoplasmosis,
			)

			var/list/symptoms = list()
			// pick a symptom with a major effect from either the list of spreading symptoms or effective symptoms
			if(dangerous_virus)
				if(prob(50))
					symptoms += pick_weight(majorspreadsymptoms)
					symptoms += pick(effectivesymptoms)
				else
					symptoms += pick_weight(spreadsymptoms)
					symptoms += pick(majoreffectivesymptoms)
			else
				symptoms += pick_weight(spreadsymptoms)
				symptoms += pick(effectivesymptoms)
			new_disease = new /datum/disease/advance/random(max_severity, 8 + dangerous_virus, unfunny_virus, symptoms, mute = FALSE, special = TRUE)

		if(isnull(new_disease))
			continue

		victim.ForceContractDisease(new_disease, FALSE, TRUE)

		if(advanced_virus)
			var/datum/disease/advance/A = new_disease
			var/list/name_symptoms = list() //for feedback
			for(var/datum/symptom/S in A.symptoms)
				name_symptoms += S.name
			message_admins("An event has triggered a random advanced virus outbreak on [ADMIN_LOOKUPFLW(victim)]! It has these symptoms: [english_list(name_symptoms)]")
			log_game("An event has triggered a random advanced virus outbreak on [key_name(victim)]! It has these symptoms: [english_list(name_symptoms)]")
		break
