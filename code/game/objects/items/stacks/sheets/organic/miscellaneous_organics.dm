//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	novariants = TRUE

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

/* Sinew */

/obj/item/stack/sheet/sinew
	name = "watcher sinew"
	icon = 'icons/obj/stacks/organic.dmi'
	desc = "Long stringy filaments which presumably came from a watcher's wings."
	singular_name = "watcher sinew"
	icon_state = "sinew"
	novariants = TRUE


GLOBAL_LIST_INIT(sinew_recipes, list ( \
	new/datum/stack_recipe("sinew restraints", /obj/item/restraints/handcuffs/cable/sinew, 1), \
))

/obj/item/stack/sheet/sinew/get_recipes()
	return GLOB.sinew_recipes

