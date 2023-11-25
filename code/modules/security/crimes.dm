#define MAX_TIMER 10 HOURS //Permabrig.
#define PRESET_SHORT 5 MINUTES
#define PRESET_MEDIUM 10 MINUTES
#define PRESET_LONG 15 MINUTES

#define CRIME_MINOR "Minor"
#define CRIME_MISDEMEANOUR "Misdemeanour"
#define CRIME_MAJOR "Major"
#define CRIME_CAPITAL "Capital"

/datum/crime
	var/name
	var/tooltip
	var/colour
	var/icon
	var/sentence
	var/category

/datum/crime/minor
	category = CRIME_MINOR
	sentence = PRESET_SHORT
	colour="yellow"

/datum/crime/minor/assault
	name = "Assault"
	icon = "hand-rock"

/datum/crime/minor/pickpocketting
	name = "Pickpocketting"
	icon = "mask"

/datum/crime/minor/minor_vandalism
	name = "Minor Vandalism"
	icon = "house-damage"

/datum/crime/minor/vigilantism
	name = "Vigilantism"
	icon = "user-secret"

/datum/crime/minor/illegal_distribution
	name = "Illegal Distribution"
	icon = "joint"

/datum/crime/minor/negligence
	name = "Negligence"
	icon = "low-vision"

/datum/crime/minor/trespass
	name = "Trespass"
	icon = "walking"

/datum/crime/minor/breaking_and_entering
	name = "Breaking and Entering"
	icon = "door-open"

/datum/crime/minor/discriminatory_language
	name = "Discriminatory Language"
	icon = "comment-slash"

/datum/crime/minor/fine_evasion
	name = "Fine Evasion"
	icon = "dollar-sign"

/datum/crime/minor/religious_activity
	name = "Religious Activity outside of the chapel"
	icon = "cross"

/datum/crime/misdemeanour
	category = CRIME_MISDEMEANOUR
	sentence = PRESET_MEDIUM
	colour="orange"

/datum/crime/misdemeanour/aggravated_assault
	name = "Aggravated Assault"
	icon = "user-injured"

/datum/crime/misdemeanour/theft
	name = "Theft"
	icon = "mask"

/datum/crime/misdemeanour/vandilism
	name = "Major Vandalism"
	icon = "house-damage"

/datum/crime/misdemeanour/conspiracy
	name = "Conspiracy"
	icon = "user-friends"

/datum/crime/misdemeanour/hostile_agent
	name = "Hostile Agent"
	icon = "user-ninja"

/datum/crime/misdemeanour/contraband
	name = "Contraband Equipment Possession"
	icon = "briefcase"

/datum/crime/misdemeanour/rioting
	name = "Rioting"
	icon = "fist-raised"

/datum/crime/misdemeanour/negligence
	name = "High Negligence"
	icon = "blind"

/datum/crime/misdemeanour/tresspass
	name = "Trespass, Inherently Dangerous Areas"
	icon = "door-closed"

/datum/crime/misdemeanour/entering
	name = "Breaking and Entering, Inherently Dangerous Areas"
	icon = "door-open"

/datum/crime/misdemeanour/insubordination
	name = "Insubordination"
	icon = "hand-middle-finger"

/datum/crime/misdemeanour/fraud
	name = "Fraud"
	icon = "comment-dollar"

/datum/crime/misdemeanour/genetic_mutilation
	name = "Genetic Mutilation"
	icon = "dna"

/datum/crime/major
	category = CRIME_MAJOR
	sentence = PRESET_LONG
	colour="bad"

/datum/crime/major/murder
	name = "Murder"
	icon = "skull"

/datum/crime/major/larceny
	name = "Larceny"
	icon = "mask"

/datum/crime/major/sabotage
	name = "Sabotage"
	icon = "bomb"

/datum/crime/major/conspiracy
	name = "High Conspiracy"
	icon = "users"

/datum/crime/major/hostile
	name = "Hostile Activity"
	icon = "thumbs-down"

/datum/crime/major/contraband
	name = "Possession, Illegal Inherently Dangerous Equipment"
	icon = "exclamation-triangle"

/datum/crime/major/riot
	name = "Inciting a Riot"
	icon = "fist-raised"

/datum/crime/major/manslaughter
	name = "Manslaughter"
	icon = "book-dead"

/datum/crime/major/tresspass
	name = "Trespass, High Security Areas"
	icon = "running"

/datum/crime/major/break_enter
	name = "Breaking and Entering, High Security Areas"
	icon = "door-open"

/datum/crime/major/dereliction
	name = "Dereliction"
	icon = "walking"

/datum/crime/major/fraud
	name = "Corporate Fraud"
	icon = "hand-holding-usd"

/datum/crime/major/impersonation
	name = "Identity Theft"
	icon = "theater-masks"

/datum/crime/capital
	category = CRIME_CAPITAL
	sentence = MAX_TIMER
	colour = "grey"

/datum/crime/capital/murder
	name = "Prime Murder"
	icon = "skull-crossbones"

/datum/crime/capital/larcany
	name = "Grand Larceny"
	icon = "mask"

/datum/crime/capital/sabotage
	name = "Grand Sabotage"
	icon = "bomb"

/datum/crime/capital/espionage
	name = "Espionage"
	icon = "user-secret"

/datum/crime/capital/enemy
	name = "Enemy of the Corporation"
	icon = "user-alt-slash"

/datum/crime/capital/contraband
	name = "Possession, Corporate Secrets"
	icon = "file-invoice"

/datum/crime/capital/subversion
	name = "Subversion of the Chain of Command"
	icon = "link"

/datum/crime/capital/biological
	name = "Biological Terror"
	icon = "biohazard"

#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG
