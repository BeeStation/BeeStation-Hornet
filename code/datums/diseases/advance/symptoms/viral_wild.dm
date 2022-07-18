#define MAXIMUM_STAT 18

// ignore this
/datum/symptom/wild
	name = "Wild virus"
	desc = "A wild symptom that only exists in the incredible and great mother nature. This is not extractable, moddable, or usable by any means, as it only exists and lives in a nature and wild virus. The power of the wild symptom is synergised with other symptoms and it goes very wild."
	level = 12 // it would make people awkward
	prefixes = list("Wild ")
	naturally_occuring = FALSE

// the real ones
// high resistance
/datum/symptom/wild/wildresistance
	name = "Viral Wild-Resistance Adaption"
	stealth = -2
	resistance = 7
	stage_speed = 2
	transmission = -1

// high stage speed
/datum/symptom/wild/wildspeed
	name = "Viral Wild-Speed Adaption"
	stealth = 0
	resistance = 2
	stage_speed = 10
	transmission = -1

// High stealth
/datum/symptom/wild/wildstealth
	name = "Viral Wild-Stealth Adaption"
	stealth = 7
	resistance = 2
	stage_speed = 2
	transmission = -7

// High tranmission, minus stealth
/datum/symptom/wild/wildtransmission
	name = "Viral Wild-Transmission Adaption"
	stealth = -20
	resistance = 3
	stage_speed = 3
	transmission = 10

// when it failed to get any good stat from random code
/datum/symptom/wild/wildbrutality
	name = "Viral Wild-Brutality Adaption"
	stealth = -20
	resistance = 15
	stage_speed = 15
	transmission = 15 // this is not transmitible. no worries.

/datum/symptom/wild/wildbrutality/OnAdd(datum/disease/advance/A)
	A.faltered = TRUE

// --unused ideas--
// need more 2/3 cures
// patient zero
// species only virus

#undef MAXIMUM_STAT
