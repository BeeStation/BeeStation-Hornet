/**
 * Crime data. Used to store information about crimes.
 */
/datum/crime_record
	/// Name of the crime
	var/name
	/// Details about the crime
	var/details
	/// Player that wrote the crime
	var/author
	/// Time of the crime
	var/time
	/// Whether the crime is active or not
	var/valid = TRUE
	/// Player that marked the crime as invalid
	var/voider
	//Variables for genpop
	var/tooltip
	var/colour
	var/icon
	var/sentence
	var/category
	var/crime_ref

/datum/crime_record/New(name = "Crime", details = "No details provided.", author = "Anonymous")
	src.author = author
	src.details = details
	src.name = name
	src.time = station_time_timestamp()
	src.crime_ref = FAST_REF(src)

/datum/crime_record/citation
	/// Fine for the crime
	var/fine
	/// Amount of money paid for the crime
	var/paid = 0

/datum/crime_record/citation/New(name = "Citation", details = "No details provided.", author = "Anonymous", fine = 0)
	. = ..()
	src.fine = fine

/// Pays off a fine and attempts to fix any weird values.
/datum/crime_record/citation/proc/pay_fine(amount)
	if(amount <= 0)
		return FALSE
	paid += amount
	fine = max(0, fine - amount)

	return TRUE

/// Sends a citation alert message to the target's PDA.
/datum/crime_record/proc/alert_owner(mob/sender, atom/source, target_name, message)
	for(var/obj/item/modular_computer/tablet in GLOB.TabletMessengers)
		if(tablet.saved_identification != target_name)
			continue

		var/datum/signal/subspace/messaging/tablet_msg/signal = new(source, list(
			name = "Security Citation",
			job = "Citation Server",
			message = message,
			targets = list(tablet),
			automated = TRUE
		))
		signal.send_to_receivers()
		sender.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)
		break

	return TRUE

#define PRESET_SHORT 5 MINUTES
#define PRESET_MEDIUM 10 MINUTES
#define PRESET_LONG 15 MINUTES

#define CRIME_MINOR "Minor"
#define CRIME_MISDEMEANOUR "Misdemeanour"
#define CRIME_MAJOR "Major"
#define CRIME_CAPITAL "Capital"

/* This is overwritten by the config (space_law.json as of writting this), this only exists as a backup in case the game fails to load said file.
Do not modify this unless you know what you're doing. */

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
	tooltip = "To use physical force against someone without the apparent intent to kill them."

/datum/crime/minor/pickpocketting
	name = "Pickpocketting"
	icon = "mask"
	tooltip = "To steal items from another's person."

/datum/crime/minor/minor_vandalism
	name = "Minor Vandalism"
	icon = "house-damage"
	tooltip = "To damage, destroy, or permanently deface non-critical furniture, vendors, or personal property."

/datum/crime/minor/vigilantism
	name = "Vigilantism"
	icon = "user-secret"
	tooltip = "To perform the responsibilities and duties of the security department without approval or due cause to act."

/datum/crime/minor/illegal_distribution
	name = "Illegal Distribution"
	icon = "joint"
	tooltip = "The possession of dangerous or illegal drugs/equipment in a quantity greater than that which is reasonable for personal consumption."

/datum/crime/minor/disturbing
	name = "Disturbing the Peace"
	icon = "fist-raised"
	tooltip = "To knowingly organize a movement which disrupts the normal operations of a department."

/datum/crime/minor/negligence
	name = "Negligence"
	icon = "low-vision"
	tooltip = "To be negligent in one's duty to an extent that it may cause harm, illness, or other negative effect, to another."

/datum/crime/minor/trespass
	name = "Trespass"
	icon = "walking"
	tooltip = "To be in an area which a person has either not purposefully been admitted to, does not have access, or has been asked to leave by someone who has access to that area."

/datum/crime/minor/breaking_and_entering
	name = "Breaking and Entering"
	icon = "door-open"
	tooltip = "To trespass into an area using a method of forcible entry."

/datum/crime/minor/discriminatory_language
	name = "Discriminatory Language"
	icon = "comment-slash"
	tooltip = "To use language which demeans, generalizes, or otherwise de-personafies the individual at which it is targeted."

/datum/crime/minor/fine_evasion
	name = "Fine Evasion"
	icon = "dollar-sign"
	tooltip = "To purposefully avoid or refuse to pay a legal fine."

/datum/crime/minor/religious_activity
	name = "Religious Activity outside of the chapel"
	icon = "cross"
	tooltip = "To convert, proselytize, hold rituals or otherwise attempt to act in the name of a religion or deity outside of the chapel."

/datum/crime/misdemeanour
	category = CRIME_MISDEMEANOUR
	sentence = PRESET_MEDIUM
	colour="orange"

/datum/crime/misdemeanour/aggravated_assault
	name = "Aggravated Assault"
	icon = "user-injured"
	tooltip = "To take physical action against a person with intent to grievously harm, but not to kill."

/datum/crime/misdemeanour/theft
	name = "Theft"
	icon = "mask"
	tooltip = "To steal equipment or items from a workplace, or items of extraordinary value from one's person."

/datum/crime/misdemeanour/vandilism
	name = "Major Vandalism"
	icon = "house-damage"
	tooltip = "To destroy or damage non-critical furniture, vendors, or personal property in a manor that can not be repaired."

/datum/crime/misdemeanour/conspiracy
	name = "Conspiracy"
	icon = "user-friends"
	tooltip = "To knowingly work with another person in the interest of committing an illegal action."

/datum/crime/misdemeanour/hostile_agent
	name = "Hostile Agent"
	icon = "user-ninja"
	tooltip = "To knowingly act as a recruiter, representative, messenger, ally, benefactor, or other associate of a hostile organization as defined within Code 405(EOTC)."

/datum/crime/misdemeanour/contraband
	name = "Contraband Equipment Possession"
	icon = "briefcase"
	tooltip = "To possess equipment not approved for use or production aboard Nanotrasen stations. This includes equipment produced by The Syndicate, Wizard Federation, or any other hostile organization as defined within Code 405(EOTC)."

/datum/crime/misdemeanour/rioting
	name = "Rioting"
	icon = "fist-raised"
	tooltip = "To act as a member in a group which collectively commits acts of major vandalism, sabotage, grand sabotage, or other felony crimes."

/datum/crime/misdemeanour/negligence
	name = "High Negligence"
	icon = "blind"
	tooltip = "To be negligent in one's duty to an extent that it may cause harm to multiple individuals, a department, or in a manor which directly leads to a serious injury of another person which requires emergency medical treatment."

/datum/crime/misdemeanour/tresspass
	name = "Trespass, Inherently Dangerous Areas"
	icon = "door-closed"
	tooltip = "Trespassing in an area which may lead to the injury of self, or others."

/datum/crime/misdemeanour/entering
	name = "Breaking and Entering, Inherently Dangerous Areas"
	icon = "door-open"
	tooltip = "To trespass into an area which may lead to the injury of self or others using forcible entry."

/datum/crime/misdemeanour/insubordination
	name = "Insubordination"
	icon = "hand-middle-finger"
	tooltip = "To knowingly disobey a lawful order from a superior."

/datum/crime/misdemeanour/fraud
	name = "Fraud"
	icon = "comment-dollar"
	tooltip = "To misrepresent ones intention in the interest of gaining property or money from another individual."

/datum/crime/misdemeanour/genetic_mutilation
	name = "Genetic Mutilation"
	icon = "dna"
	tooltip = "To purposefully modify an individual's genetic code without consent, or with intent to harm."

/datum/crime/major
	category = CRIME_MAJOR
	sentence = PRESET_LONG
	colour="bad"

/datum/crime/major/murder
	name = "Murder"
	icon = "skull"
	tooltip = "To purposefully kill someone."

/datum/crime/major/larceny
	name = "Larceny"
	icon = "mask"
	tooltip = "To steal rare, expensive (Items of greater than 1000 credit value), or restricted equipment from secure areas or one's person."

/datum/crime/major/sabotage
	name = "Sabotage"
	icon = "bomb"
	tooltip = "To destroy station assets or resources critical to normal or emergency station procedures, or cause sections of the station to become uninhabitable."

/datum/crime/major/conspiracy
	name = "High Conspiracy"
	icon = "users"
	tooltip = "To knowingly work with another person in the interest of committing a major or greater crime."

/datum/crime/major/hostile
	name = "Hostile Activity"
	icon = "thumbs-down"
	tooltip = "To knowingly commit an act which is in direct opposition to the interests of Nanotrasen, Or to directly assist a known enemy of the corporation."

/datum/crime/major/contraband
	name = "Possession, Illegal Inherently Dangerous Equipment"
	icon = "exclamation-triangle"
	tooltip = "To possess restricted or illegal equipment which has a primary purpose of causing harm to others, or large amounts of destruction."

/datum/crime/major/riot
	name = "Inciting a Riot"
	icon = "fist-raised"
	tooltip = "To perform actions in the interest of causing large amounts of unrest up to and including rioting."

/datum/crime/major/manslaughter
	name = "Manslaughter"
	icon = "book-dead"
	tooltip = "To unintentionally kill someone through negligent, but not malicious, actions."

/datum/crime/major/tresspass
	name = "Trespass, High Security Areas"
	icon = "running"
	tooltip = "Trespassing in any of the following without appropriate permission or access: Command areas, Personal offices, Weapons storage, weapon production, explosive storage, explosive production, or other high security areas."

/datum/crime/major/break_enter
	name = "Breaking and Entering, High Security Areas"
	icon = "door-open"
	tooltip = "To commit trespassing into a secure area as defined in Code 309(Trespass, High Security Areas) using forcible entry."

/datum/crime/major/dereliction
	name = "Dereliction"
	icon = "walking"
	tooltip = "To willfully abandon an obligation that is critical to the station's continued operation."

/datum/crime/major/fraud
	name = "Corporate Fraud"
	icon = "hand-holding-usd"
	tooltip = "To misrepresent one's intention in the interest of gaining property or money from Nanotrasen, or to gain or give property or money from Nanotrasen without proper authorization."

/datum/crime/major/impersonation
	name = "Identity Theft"
	icon = "theater-masks"
	tooltip = "To assume the identity of another individual."

/datum/crime/capital
	category = CRIME_CAPITAL
	sentence = SENTENCE_MAX_TIMER
	colour = "grey"

/datum/crime/capital/murder
	name = "Prime Murder"
	icon = "skull-crossbones"
	tooltip = "To commit the act of murder, with clear intent to kill, and clear intent or to have materially take steps to prevent the revival of the victim"

/datum/crime/capital/larcany
	name = "Grand Larceny"
	icon = "mask"
	tooltip = "To steal inherently dangerous items from their storage, one's person, or other such methods acquire through illicit means."

/datum/crime/capital/sabotage
	name = "Grand Sabotage"
	icon = "bomb"
	tooltip = "To destroy or modify station assets or equipment without which the station may collapse or otherwise become uninhabitable."

/datum/crime/capital/espionage
	name = "Espionage"
	icon = "user-secret"
	tooltip = "To knowingly betray critical information to enemies of the station."

/datum/crime/capital/enemy
	name = "Enemy of the Corporation"
	icon = "user-alt-slash"
	tooltip = "To be a member of any of the following organizations: Hostile boarding parties, Wizards, Changeling Hiveminds, cults."

/datum/crime/capital/contraband
	name = "Possession, Corporate Secrets"
	icon = "file-invoice"
	tooltip = "To possess secret documentation or high density tamper-resistant data storage devices (Blackboxes) from any organization without authorization by Nanotrasen."

/datum/crime/capital/subversion
	name = "Subversion of the Chain of Command"
	icon = "link"
	tooltip = "Disrupting the chain of command via either murder of a commanding officer or illegaly declaring oneself to be a commanding officer."

/datum/crime/capital/biological
	name = "Biological Terror"
	icon = "biohazard"
	tooltip = "To knowingly release, cause, or otherwise cause the station to become affected by a disease, plant, or other biological form which may spread uncontained and or cause serious physical harm."

#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG

#undef CRIME_MINOR
#undef CRIME_MISDEMEANOUR
#undef CRIME_MAJOR
#undef CRIME_CAPITAL
