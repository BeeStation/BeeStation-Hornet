// Pre-packaged meals, canned, wrapped, and vended

// Cans
/obj/item/food/canned
	name = "canned Air"
	desc = "If you ever wondered where air came from..."
	food_reagents = list(
		/datum/reagent/oxygen = 6,
		/datum/reagent/nitrogen = 24,
	)
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "air"
	trash_type = /obj/item/trash/canned
	food_flags = FOOD_IN_CONTAINER
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 30
	preserved_food = TRUE
	var/maint = FALSE
	var/maint_overlay = ""
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/canned/Initialize(mapload)
	. = ..()
	if(maint)
		maint_overlay = "can_maint"
		add_overlay(maint_overlay)
		name = "maintenance [name]"

/obj/item/food/canned/proc/open_can(mob/user)
	to_chat(user, "You pull back the tab of \the [src].")
	playsound(user.loc, 'sound/items/foodcanopen.ogg', 50)
	ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)

/obj/item/food/canned/attack_self(mob/user)
	if(!is_drainable())
		open_can(user)
		icon_state = "[icon_state]_open"
	return ..()

/obj/item/food/canned/attack(mob/living/M, mob/user, def_zone)
	if (!is_drainable())
		to_chat(user, span_warning("[src]'s lid hasn't been opened!"))
		return 0
	return ..()

///can types

/obj/item/food/canned/beans
	name = "can of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	trash_type = /obj/item/trash/canned/beans
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/ketchup = 4
	)
	tastes = list("beans" = 3 , "tomato sauce" = 1, "tin" = 1)
	foodtypes = VEGETABLES

/obj/item/food/canned/peaches
	name = "can of peaches"
	desc = "Just a nice can of ripe peaches swimming in their own juices."
	icon_state = "peaches"
	trash_type = /obj/item/trash/canned/peaches
	food_reagents = list(
		/datum/reagent/consumable/peachjuice = 20,
		/datum/reagent/consumable/sugar = 8,
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("peaches" = 7, "tin" = 1)
	foodtypes = FRUIT | SUGAR

/obj/item/food/canned/beefbroth
	name = "can of beef stew"
	desc = "Beef on a pinch, an aquired taste really."
	icon_state = "beef"
	trash_type = /obj/item/trash/canned/beefbroth
	food_reagents = list(/datum/reagent/consumable/beefbroth = 50)
	tastes = list("meat" = 7, "beef gelatin" = 1, "tin" = 1)
	foodtypes = MEAT | GROSS | JUNKFOOD

///maintenance variants

/obj/item/food/canned/maint

	maint = TRUE
	desc = "This is just a memory of canned beans..."
	food_reagents = list(
		/datum/reagent/oxygen = 6,
		/datum/reagent/nitrogen = 22,
		/datum/reagent/sulfur = 2,
	)
	trash_type = /obj/item/trash/canned/maint

/obj/item/food/canned/beans/maint
	maint = TRUE
	desc = "At this point, it's music will outlive the station."
	trash_type = /obj/item/trash/canned/beans/maint
	tastes = list("beans" = 1 , "tomato sauce" = 1, "tin" = 7)

/obj/item/food/canned/peaches/maint
	maint = TRUE
	desc = "I have a mouth and I must eat."
	trash_type = /obj/item/trash/canned/peaches/maint
	tastes = list("peaches" = 1, "tin" = 7)

/obj/item/food/canned/beefbroth/maint
	desc = "Really old beef on a pinch, a gamble really."
	icon_state = "beef"
	trash_type = /obj/item/trash/canned/beefbroth/maint
	tastes = list("disgust" = 3, "beef gelatin" = 1, "tin" = 4)

