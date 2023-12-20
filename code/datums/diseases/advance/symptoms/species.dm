/datum/symptom/undead_adaptation
	name = "Necrotic Metabolism"
	desc = "The virus is able to maintain its core functionality after the host has died, allowing specific symptoms to continue functioning."
	symptom_flags = SYMPTOM_DEAD_TICK_ALWAYS
	stealth = 2
	resistance = 2
	stage_speed = 2
	transmission = 0
	level = 4
	severity = 0
	prefixes = list("Zombie ")
	threshold_desc = "<b>Transmission 7:</b> The virus is capable of continuing to spread after the host has died."
	var/spread = FALSE

/datum/symptom/undead_adaptation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 7)
		spread = TRUE

/datum/symptom/undead_adaptation/OnAdd(datum/disease/advance/A)
	A.infectable_biotypes |= MOB_UNDEAD
	if(spread)
		A.spread_dead = TRUE

/datum/symptom/undead_adaptation/OnRemove(datum/disease/advance/A)
	A.infectable_biotypes -= MOB_UNDEAD
	A.spread_dead = FALSE

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
	A.infectable_biotypes |= MOB_INORGANIC

/datum/symptom/inorganic_adaptation/OnRemove(datum/disease/advance/A)
	A.infectable_biotypes -= MOB_INORGANIC
