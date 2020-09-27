/datum/faction
	var/name = "unnammed"
	var/list/friendly_factions = list()
	var/list/neutral_factions = list()
	var/list/hostile_factions = list()

// !!! Checks how A should act towards B, rather than what B think of A !!!
/proc/check_faction_alignment(datum/faction/A, datum/faction/B)
	//Assume friendliness in faction
	if(A.type == B.type)
		return FACTION_STATUS_FRIENDLY
	//If exact type is in any list, use that
	if(B.type in A.friendly_factions)
		return FACTION_STATUS_FRIENDLY
	if(B.type in A.neutral_factions)
		return FACTION_STATUS_NEUTRAL
	if(B.type in A.hostile_factions)
		return FACTION_STATUS_HOSTILE
	//Otherwise, try to find parent types in list
	for(var/type in A.friendly_factions)
		if(istype(B, type))
			return FACTION_STATUS_FRIENDLY
	for(var/type in A.neutral_factions)
		if(istype(B, type))
			return FACTION_STATUS_NEUTRAL
	for(var/type in A.hostile_factions)
		if(istype(B, type))
			return FACTION_STATUS_HOSTILE
	return FACTION_STATUS_NEUTRAL

/datum/faction/station
	name = "Space Station 13"
	//Faction alignment
	friendly_factions = list(/datum/faction/nanotrasen)
	neutral_factions = list(/datum/faction/spider_clan)
	hostile_factions = list(/datum/faction/syndicate)

/datum/faction/nanotrasen
	name = "Nanotrasen"
	//Faction alignment
	friendly_factions = list(/datum/faction/station)
	neutral_factions = list(/datum/faction/spider_clan)
	hostile_factions = list(/datum/faction/syndicate)

/datum/faction/syndicate
	name = "The Syndicate"
	//Faction alignment
	neutral_factions = list(/datum/faction/spider_clan, /datum/faction/syndicate)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station)

/datum/faction/spider_clan
	name = "Spider Clan"
	//Faction alignment
	neutral_factions = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/syndicate)

/datum/faction/pirates
	name = "Pirates"
	friendly_factions = list()
	neutral_factions = list(/datum/faction/spider_clan, /datum/faction/syndicate)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/independant)

/datum/faction/golems
	name = "Free Golems"
	friendly_factions = list(/datum/faction/nanotrasen, /datum/faction/station)
	neutral_factions = list(/datum/faction/independant)
	hostile_factions = list(/datum/faction/spider_clan, /datum/faction/syndicate)

/datum/faction/syndicate/cybersun
	name = "Cybersun Industries"
	friendly_factions = list(/datum/faction/syndicate/mi_thirteen)
	neutral_factions = list(/datum/faction/spider_clan, /datum/faction/syndicate)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station)

/datum/faction/syndicate/mi_thirteen
	name = "MI13"
	friendly_factions = list(/datum/faction/syndicate/cybersun)
	neutral_factions = list(/datum/faction/spider_clan, /datum/faction/syndicate)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station)

/datum/faction/syndicate/tiger_corp
	name = "Tiger Cooperative"
	friendly_factions = list(/datum/faction/syndicate/gorlex)
	neutral_factions = list(/datum/faction/spider_clan, /datum/faction/syndicate)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station)

/datum/faction/syndicate/self
	name = "S.E.L.F"

/datum/faction/syndicate/arc
	name = "Animal Rights Consortium"

/datum/faction/syndicate/gorlex
	friendly_factions = list(/datum/faction/syndicate/tiger_corp)
	name = "Gorlex Marauders"

/datum/faction/syndicate/donk
	name = "Donk Corporation"

/datum/faction/syndicate/waffle
	name = "Waffle Corporation"

// Oh god oh fuck
/datum/faction/syndicate/elite
	name = "Syndicate High Command"

/datum/faction/independant
	name = "Independant"
	//Faction alignment
	friendly_factions = list(/datum/faction/nanotrasen, /datum/faction/station)
	hostile_factions = list(/datum/faction/syndicate)
