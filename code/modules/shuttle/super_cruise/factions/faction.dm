/datum/faction
	var/name = "Developers Debug Union"
	var/list/friendly_factions = list()
	var/list/hostile_factions = list()
	var/faction_tag = "DEV"
	var/datum/faction/parent_faction

/datum/faction/New()
	. = ..()
	//Set the parent faction type (If we are a shuttle, this is our representing faction)
	parent_faction = SSorbits.get_faction(type)

// !!! Checks how A should act towards B, rather than what B think of A !!!
/proc/check_faction_alignment(datum/faction/A, datum/faction/B)
	//Assume friendliness in faction
	if(A.type == B.type)
		return FACTION_STATUS_FRIENDLY
	//If exact type is in any list, use that
	if(B.type in A.friendly_factions)
		return FACTION_STATUS_FRIENDLY
	if(B.type in A.hostile_factions)
		return FACTION_STATUS_HOSTILE
	//Otherwise, try to find parent types in list
	for(var/type in A.friendly_factions)
		if(istype(B, type))
			return FACTION_STATUS_FRIENDLY
	for(var/type in A.hostile_factions)
		if(istype(B, type))
			return FACTION_STATUS_HOSTILE
	return FACTION_STATUS_NEUTRAL
