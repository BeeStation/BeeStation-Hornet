//==================================//
// !      Tinkerer's Cache     ! //
//==================================//
/datum/clockcult/scripture/create_structure/tinkerers_cache
	name = "Tinkerer's Cache"
	desc = "Creates a tinkerer's cache, a powerful forge capable of crafting elite equiptment."
	tip = "Use the cache to create more powerful equiptment with a cooldown."
	button_icon_state = "Tinkerer's Cache"
	power_cost = 700
	invokation_time = 50
	invokation_text = list("Guide my hand and we shall create greatness.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	cogs_required = 4
	category = SPELLTYPE_MANUFACTORING
