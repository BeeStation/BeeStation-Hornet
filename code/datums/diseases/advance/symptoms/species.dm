/datum/symptom/undead_adaptation
	name = "Necrotic Metabolism"
	desc = "The virus is able to thrive and act even within dead hosts."
	stealth = 2
	resistance = 2
	stage_speed = 2
	transmission = 0
	level = 4
	severity = 0
	prefixes = list("Zombie ")

/datum/symptom/undead_adaptation/OnAdd(datum/disease/advance/A)
	if(CONFIG_GET(flag/process_dead_allowed))
		A.process_dead = TRUE
	A.infectable_biotypes |= MOB_UNDEAD
	A.spread_dead = TRUE

/datum/symptom/undead_adaptation/OnRemove(datum/disease/advance/A)
	if(CONFIG_GET(flag/process_dead_allowed))
		A.process_dead = FALSE
	A.infectable_biotypes &= ~MOB_UNDEAD
	A.spread_dead = TRUE

/datum/symptom/inorganic_adaptation
	name = "Inorganic Biology"
	desc = "The virus can survive and replicate even in an inorganic environment, increasing its resistance and infection rate."
	stealth = -1
	resistance = 4
	stage_speed = -2
	transmission = 3
	level = 4
	severity = 0
	prefixes = list("Crystalline ")


/datum/symptom/inorganic_adaptation/OnAdd(datum/disease/advance/A)
	A.infectable_biotypes |= MOB_MINERAL //Mineral covers plasmamen and golems.

/datum/symptom/inorganic_adaptation/OnRemove(datum/disease/advance/A)
	A.infectable_biotypes &= ~MOB_MINERAL
