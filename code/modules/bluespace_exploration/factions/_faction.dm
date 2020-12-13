/datum/faction
	var/name = "unnammed"
	var/list/friendly_factions = list()
	var/list/hostile_factions = list()
	var/faction_tag = "DEV"

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

/datum/faction/station
	name = "Space Station 13"
	//Faction alignment
	friendly_factions = list(/datum/faction/nanotrasen)
	hostile_factions = list(/datum/faction/syndicate, /datum/faction/spider_clan)
	faction_tag = "NT13"

/datum/faction/nanotrasen
	name = "Nanotrasen"
	//Faction alignment
	friendly_factions = list(/datum/faction/station)
	hostile_factions = list(/datum/faction/syndicate, /datum/faction/spider_clan)
	faction_tag = "NTC"

/datum/faction/syndicate
	name = "The Syndicate"
	//Faction alignment
	friendly_factions = list(/datum/faction/syndicate)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station)
	faction_tag = "SYD"

/datum/faction/spider_clan
	name = "Spider Clan"
	//No straight hostiles until acted aganist
	faction_tag = "SPD"

/datum/faction/pirates
	name = "Pirates"
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/independant)
	faction_tag = "Unmarked"

/datum/faction/golems
	name = "Free Golems"
	friendly_factions = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/felinids)
	hostile_factions = list(/datum/faction/spider_clan, /datum/faction/syndicate)
	faction_tag = "GLM"

/datum/faction/felinids
	name = "United Felinid Alliance"
	friendly_factions = list(/datum/faction/syndicate/arc, /datum/faction/golems)
	hostile_factions = list(/datum/faction/spider_clan)
	faction_tag = "CAT"

/datum/faction/syndicate/cybersun
	name = "Cybersun Industries"
	friendly_factions = list(/datum/faction/syndicate/mi_thirteen)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/felinids)
	faction_tag = "CBS"

/datum/faction/syndicate/mi_thirteen
	name = "MI13"
	friendly_factions = list(/datum/faction/syndicate/cybersun)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/felinids)
	faction_tag = "MI13"

/datum/faction/syndicate/tiger_corp
	name = "Tiger Cooperative"
	friendly_factions = list(/datum/faction/syndicate/gorlex)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/station, /datum/faction/felinids)
	faction_tag = "TGR"

/datum/faction/syndicate/self
	name = "S.E.L.F"
	faction_tag = "SELF"

/datum/faction/syndicate/arc
	name = "Animal Rights Consortium"
	faction_tag = "ARC"

/datum/faction/syndicate/gorlex
	friendly_factions = list(/datum/faction/syndicate/tiger_corp, /datum/faction/felinids)
	name = "Gorlex Marauders"
	faction_tag = "GOR"

/datum/faction/syndicate/donk
	name = "Donk Corporation"
	faction_tag = "DNK"

/datum/faction/syndicate/waffle
	name = "Waffle Corporation"
	faction_tag = "WFL"

// Oh god oh fuck
/datum/faction/syndicate/elite
	name = "Syndicate High Command"
	faction_tag = "SHC"

/datum/faction/independant
	name = "Independant"
	//Faction alignment (Starts only hostile to pirates but can become hostile to the syndicate.)
	hostile_factions = list(/datum/faction/pirates)
	faction_tag = "IND"
