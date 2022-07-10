/datum/faction/syndicate
	name = "The Syndicate"
	//Faction alignment
	friendly_factions = list(/datum/faction/syndicate)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/nanotrasen/central_command, /datum/faction/station)
	faction_tag = "SYD"

/datum/faction/syndicate/cybersun
	name = "Cybersun Industries"
	friendly_factions = list(/datum/faction/syndicate/mi_thirteen)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/nanotrasen/central_command, /datum/faction/station, /datum/faction/felinids)
	faction_tag = "CBS"

/datum/faction/syndicate/mi_thirteen
	name = "MI13"
	friendly_factions = list(/datum/faction/syndicate/cybersun)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/nanotrasen/central_command, /datum/faction/station, /datum/faction/felinids)
	faction_tag = "MI13"

/datum/faction/syndicate/tiger_corp
	name = "Tiger Cooperative"
	friendly_factions = list(/datum/faction/syndicate/gorlex)
	hostile_factions = list(/datum/faction/nanotrasen, /datum/faction/nanotrasen/central_command, /datum/faction/station, /datum/faction/felinids)
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
