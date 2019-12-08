/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	sort_category = "OOC"
	description = "An extra charslot. Pretty self-explanatory."
	cost = 10000

/datum/gear/ooc/char_slot/purchase(var/client/C)
	C?.prefs?.max_save_slots += 1

/datum/gear/ooc/species/fly
	display_name = "Fly Person"
	sort_category = "OOC"
	description = "Select Fly in the Character Creator to play as a fly person!"
	cost = -500

/datum/gear/ooc/species/fly/purchase(var/client/C)
	C?.prefs?.species_owned += "fly"

/datum/gear/ooc/species/plasmaman
	display_name = "Plasma Man"
	sort_category = "OOC"
	description = "Select Plasma Man in the Character Creator to play as a plasma man!"
	cost = -500

/datum/gear/ooc/species/plasmaman/purchase(var/client/C)
	C?.prefs?.species_owned += "plasmaman"
