//Contains all of the magician book entries.

/// format :p

// name = "name that appears in the tgui"
// desc = "text that appears next to the name in the tgui"
// item_path = /obj/item/___/spell_type = /datum/action/spell/___
// category = "the tab that this item appears in"
// cost = how much magic knowledge it costs to buy this spell/item
// limit = how many times this spell can be bought from a book
// times = how many times this spell has been bought from a book
// cooldown = how long it takes to use this spell/item again
// requires_magician_focus = THIS IS DONE AUTOMATICALLY!!
// no_coexistance_typecache = list of spell types that cannot be bought together with this spell/item
// locked = whether the spell/item is locked and cannot be bought
// magician_level = the level of magician required to buy this spell/item


/datum/magician_entry/item/wand
	name = "Wand of Something"
	desc = "The key to your success, allows you to learn through natural magic. Don't lose it!"
	item_path = /obj/item/magician/wand
	category = "Core"
	cost = 5
	limit = 1

/datum/magician_entry/spell/shapeshift
	name = "Magician's Shapechange"
	desc = "Transform into a different creature, gaining its abilities and appearance. \
		Once you have made your choice, it cannot be changed."
	spell_type = /datum/action/spell/shapeshift/magician
	category = "Transformation"
	cost = 10
	limit = 5
	cooldown = 60 SECONDS
	no_coexistance_typecache = list(/datum/action/spell/shapeshift/wizard)
