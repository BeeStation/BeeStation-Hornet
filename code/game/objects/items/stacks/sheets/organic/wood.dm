/**********************
Woods Sheets
	Contains:
		- Wood
		- Bamboo
		- Paper frames
**********************/


/* Wood */

/obj/item/stack/sheet/wood
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	inhand_icon_state = "sheet-wood"
	icon = 'icons/obj/stacks/organic.dmi'
	mats_per_unit = list(/datum/material/wood=MINERAL_MATERIAL_AMOUNT)
	sheettype = "wood"
	armor_type = /datum/armor/sheet_wood
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/wood
	material_type = /datum/material/wood
	grind_results = list(/datum/reagent/carbon = 20)
	walltype = /turf/closed/wall/mineral/wood


/datum/armor/sheet_wood
	fire = 50

/obj/item/stack/sheet/wood/get_recipes()
	return GLOB.wood_recipes

/obj/item/stack/sheet/wood/attackby(obj/item/item, mob/user, params)
	if(!item.is_sharp())
		return ..()
	user.visible_message(
		span_notice("[user] begins whittling [src] into a pointy object."),
		span_notice("You begin whittling [src] into a sharp point at one end."),
		span_hear("You hear wood carving."),
	)
	// 5 Second Timer
	if(!do_after(user, 5 SECONDS, src, NONE, TRUE))
		return
	// Make Stake
	var/obj/item/stake/new_item = new(user.loc)
	user.visible_message(
		span_notice("[user] finishes carving a stake out of [src]."),
		span_notice("You finish carving a stake out of [src]."),
	)
	// Prepare to Put in Hands (if holding wood)
	var/obj/item/stack/sheet/wood/wood_stack = src
	var/replace = (user.get_inactive_held_item() == wood_stack)
	// Use Wood
	wood_stack.use(1)
	// If stack depleted, put item in that hand (if it had one)
	if(!wood_stack && replace)
		user.put_in_hands(new_item)

/* Bamboo */

/obj/item/stack/sheet/bamboo
	name = "bamboo cuttings"
	desc = "Finely cut bamboo sticks."
	singular_name = "cut bamboo"
	icon_state = "sheet-bamboo"
	inhand_icon_state = "sheet-bamboo"
	icon = 'icons/obj/stacks/organic.dmi'
	force = 10
	throwforce = 10
	armor_type = /datum/armor/sheet_bamboo
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/bamboo
	grind_results = list("carbon" = 5)


/datum/armor/sheet_bamboo
	fire = 50

/obj/item/stack/sheet/bamboo/get_recipes()
	return GLOB.bamboo_recipes

/obj/item/stack/sheet/bamboo/Topic(href, href_list)
	. = ..()
	if(href_list["make"])
		var/list/recipes_list = get_recipes()
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		if(R.result_type == /obj/structure/punji_sticks)
			var/turf/T = get_turf(src)
			usr.investigate_log("has placed punji sticks trap at [AREACOORD(T)].", INVESTIGATE_BOTANY)

/* Paper frames */

/obj/item/stack/sheet/paperframes
	name = "paper frames"
	desc = "A thin wooden frame with paper attached."
	singular_name = "paper frame"
	icon_state = "sheet-paper"
	inhand_icon_state = "sheet-paper"
	icon = 'icons/obj/stacks/organic.dmi'
	merge_type = /obj/item/stack/sheet/paperframes
	resistance_flags = FLAMMABLE

/obj/item/stack/sheet/paperframes/get_recipes()
	return GLOB.paperframe_recipes
