// Sidepaths for knowledge between Flesh and Void.

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "Allows you to transmute a glass shard, a bedsheet, and any outer clothing item (such as armor or a suit jacket) \
		to create a Void Cloak. While the hood is down, the cloak functions as a focus, \
		and while the hood is up, the cloak is completely invisible. It also provide decent armor and \
		has pockets which can hold one of your blades, various ritual components (such as organs), and small heretical trinkets."
	gain_text = "The Owl is the keeper of things that are not quite in practice, but in theory are. Many things are."
	next_knowledge = list(
		/datum/heretic_knowledge/limited_amount/flesh_ghoul,
		/datum/heretic_knowledge/cold_snap,
	)
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Allows you to transmute a knife, a shard of glass, and a piece of paper to create a Carving Knife. \
		The Carving Knife allows you to etch difficult to see traps that trigger on heathens who walk overhead. \
		Also makes for a handy throwing weapon."
	gain_text = "Etched, carved... eternal. There is power hidden in everything. I can unveil it! \
		I can carve the monolith to reveal the chains!"
	next_knowledge = list(
		/datum/heretic_knowledge/spell/void_phase,
		/datum/heretic_knowledge/summon/raw_prophet,
	)
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	desc = "Grants you Blood Siphon, a spell that drains a victim of blood and health, transferring it to you."
	gain_text = "\"No matter the man, we bleed all the same.\" That's what the Marshal told me."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/stalker,
		/datum/heretic_knowledge/spell/voidpull,
	)
	spell_to_add = /datum/action/spell/pointed/blood_siphon
	cost = 1
	route = HERETIC_PATH_SIDE
