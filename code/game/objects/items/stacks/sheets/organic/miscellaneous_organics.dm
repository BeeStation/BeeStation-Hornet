//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/xenochitin

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"

/* Bones */

/obj/item/stack/sheet/bone
	name = "bones"
	icon_state = "bone"
	item_state = "sheet-bone"
	icon = 'icons/obj/stacks/organic.dmi'
	singular_name = "bone"
	desc = "Someone's been drinking their milk."
	force = 7
	throwforce = 5
	max_amount = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	grind_results = list(/datum/reagent/carbon = 10)
	merge_type = /obj/item/stack/sheet/bone

/obj/item/stack/sheet/bone/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()

	// As bone and sinew have just a little too many recipes for this, we'll just split them up.
	// Sinew slapcrafting will mostly-sinew recipes, and bones will have mostly-bones recipes.
	var/static/list/slapcraft_recipe_list = list(\
		/datum/crafting_recipe/bonedagger, /datum/crafting_recipe/bonespear, /datum/crafting_recipe/boneaxe,\
		/datum/crafting_recipe/bonearmor, /datum/crafting_recipe/skullhelm, /datum/crafting_recipe/bracers
		)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/* Sinew */

/obj/item/stack/sheet/sinew
	name = "watcher sinew"
	icon = 'icons/obj/stacks/organic.dmi'
	desc = "Long stringy filaments which presumably came from a watcher's wings."
	singular_name = "watcher sinew"
	icon_state = "sinew"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/sinew

/obj/item/stack/sheet/sinew/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()

	// As bone and sinew have just a little too many recipes for this, we'll just split them up.
	// Sinew slapcrafting will mostly-sinew recipes, and bones will have mostly-bones recipes.
	var/static/list/slapcraft_recipe_list = list(\
		/datum/crafting_recipe/goliathcloak, /datum/crafting_recipe/drakecloak,\
		)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

GLOBAL_LIST_INIT(sinew_recipes, list ( \
	new/datum/stack_recipe("sinew restraints", /obj/item/restraints/handcuffs/cable/sinew, 1, crafting_flags = NONE, category = CAT_EQUIPMENT), \
))

/obj/item/stack/sheet/sinew/get_recipes()
	return GLOB.sinew_recipes

