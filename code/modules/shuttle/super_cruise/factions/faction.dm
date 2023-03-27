/datum/faction
	var/name = "Developers Debug Union"
	var/list/friendly_faction_types = list()
	var/list/hostile_faction_types = list()
	// Instances of hostile factions, for when we attacked someone on our own team and became
	// hostile.
	var/list/hostile_faction_instances = list()
	var/faction_tag = "DEV"
	// ======== LEAD INSTANCE ========
	var/is_lead_instance = FALSE
	// List of missions that this facation is offering
	var/list/available_missions = list()

/datum/faction/New(lead_instance = FALSE)
	. = ..()
	is_lead_instance = lead_instance
	if (is_lead_instance)
		START_PROCESSING(SSorbits, src)

/datum/faction/process(delta_time)
	// Handle mission generation
	if (length(available_missions) < 5 && DT_PROB(5, delta_time))
		// Generate a new mission
		available_missions += new /datum/mission/mining()

/datum/faction/proc/generate_faction_reward(amount)
	return

/datum/faction/proc/on_attacked_by(datum/faction/other)
	hostile_faction_instances += other

// !!! Checks how A should act towards B, rather than what B think of A !!!
/datum/faction/proc/check_faction_alignment(datum/faction/B)
	if ((B in hostile_faction_instances) || (src in B.hostile_faction_instances))
		return FACTION_STATUS_HOSTILE
	//Assume friendliness in faction, unless they are expplicitly hostile
	if(type == B.type)
		if(B.type in hostile_faction_types)
			return FACTION_STATUS_HOSTILE
		else
			return FACTION_STATUS_FRIENDLY
	//If exact type is in any list, use that
	if(B.type in friendly_faction_types)
		return FACTION_STATUS_FRIENDLY
	if(B.type in hostile_faction_types)
		return FACTION_STATUS_HOSTILE
	//Otherwise, try to find parent types in list
	for(var/type in friendly_faction_types)
		if(istype(B, type))
			return FACTION_STATUS_FRIENDLY
	for(var/type in hostile_faction_types)
		if(istype(B, type))
			return FACTION_STATUS_HOSTILE
	return FACTION_STATUS_NEUTRAL

/proc/get_new_faction_from_flag(faction_flag)
	if (faction_flag & FACTION_NANOTRASEN)
		return new /datum/faction/nanotrasen
	if (faction_flag & FACTION_SYNDICATE)
		return new /datum/faction/syndicate
	return new /datum/faction/independant

/datum/faction/independant
	name = "Independant"
	//Faction alignment (Starts only hostile to pirates but can become hostile to the syndicate.)
	hostile_faction_types = list(/datum/faction/pirates)
	faction_tag = "IND"

/datum/faction/pirates
	name = "Pirates"
	hostile_faction_types = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/independant)
	faction_tag = "Unmarked"

/datum/faction/station
	name = "Space Station 13"
	//Faction alignment
	friendly_faction_types = list(/datum/faction/nanotrasen)
	hostile_faction_types = list(/datum/faction/syndicate)
	faction_tag = "NT13"

/datum/faction/nanotrasen
	name = "Nanotrasen"
	//Faction alignment
	friendly_faction_types = list(/datum/faction/station)
	hostile_faction_types = list(/datum/faction/syndicate)
	faction_tag = "NTC"

/datum/faction/syndicate
	name = "The Syndicate"
	//Faction alignment
	hostile_faction_types = list(/datum/faction/nanotrasen, /datum/faction/station)
	faction_tag = "SYD"
