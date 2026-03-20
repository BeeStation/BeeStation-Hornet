/// Some defines for items the daemon forge can create.
#define NARSIE_ARMOR "Shielded Robe"
#define FLAGELLANT_ARMOR "Flagellant's Robe"
#define MIRROR_SHIELD "Mirror Shield"
#define CURSED_BLADE "Cursed Ritual Blade"

// Cult forge. Gives out combat weapons.
/obj/structure/destructible/cult/item_dispenser/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar'Sie."
	cult_examine_tip = "Can be used to create shielded robes, flagellant's robes, and mirror shields."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = span_warning("The forge breaks apart into shards with a howling scream!")
	mansus_conversion_path = /obj/structure/destructible/eldritch_crucible
	custom_materials = list(/datum/material/runedmetal = 300)

/obj/structure/destructible/cult/item_dispenser/forge/setup_options()
	var/static/list/forge_items = list(
		NARSIE_ARMOR = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/clothing/suits/armor.dmi', icon_state = "cult_armor"),
			OUTPUT_ITEMS = list(/obj/item/clothing/suit/hooded/cultrobes/cult_shield),
			RADIAL_DESC = "Smiths a set of [/obj/item/clothing/suit/hooded/cultrobes/cult_shield::name], a robust suit of armor that shields its wearer.",
			),
		MIRROR_SHIELD = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/shields.dmi', icon_state = "mirror_shield"),
			OUTPUT_ITEMS = list(/obj/item/shield/mirror),
			RADIAL_DESC = "Smiths \a [/obj/item/shield/mirror::name], a powerful shield that can reflect energy attacks.",
			),
	)

	var/extra_item = extra_options()

	options = forge_items
	if(!isnull(extra_item))
		options += extra_item


/obj/structure/destructible/cult/item_dispenser/forge/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cultitalic("You work [src] as dark knowledge guides your hands, creating [spawned_item]!"))

/obj/structure/destructible/cult/item_dispenser/forge/engine
	name = "magma engine"
	desc = "An arcane engine used for powering a shuttle."
	debris = list()

#undef NARSIE_ARMOR
#undef FLAGELLANT_ARMOR
#undef MIRROR_SHIELD
#undef CURSED_BLADE
