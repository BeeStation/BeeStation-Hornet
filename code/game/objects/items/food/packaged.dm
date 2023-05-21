// Pre-packaged meals, canned, wrapped, and vended

// Cans
/obj/item/food/canned
	name = "Canned Air"
	desc = "If you ever wondered where air came from..."
	food_reagents = list(
		/datum/reagent/oxygen = 6,
		/datum/reagent/nitrogen = 24,
	)
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "peachcan"
	food_flags = FOOD_IN_CONTAINER
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 30

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
		to_chat(user, "<span class='warning'>[src]'s lid hasn't been opened!</span>")
		return 0
	return ..()

/obj/item/food/canned/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	trash_type = /obj/item/trash/can/food/beans
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/ketchup = 4
	)
	tastes = list("beans" = 1)
	foodtypes = VEGETABLES

/obj/item/food/canned/peaches
	name = "canned peaches"
	desc = "Just a nice can of ripe peaches swimming in their own juices."
	icon_state = "peachcan"
	trash_type = /obj/item/trash/can/food/peaches
	food_reagents = list(
		/datum/reagent/consumable/peachjuice = 20,
		/datum/reagent/consumable/sugar = 8,
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("peaches" = 7, "tin" = 1)
	foodtypes = FRUIT | SUGAR

/obj/item/food/canned/peaches/maint
	name = "Maintenance Peaches"
	desc = "I have a mouth and I must eat."
	icon_state = "peachcanmaint"
	trash_type = /obj/item/trash/can/food/peaches/maint
	tastes = list("peaches" = 1, "tin" = 7)

/obj/item/food/canned/beefbroth
	name = "canned beef broth"
	desc = "Why does this exist?"
	icon_state = "beefcan"
	trash_type = /obj/item/trash/can/food/beefbroth
	food_reagents = list(/datum/reagent/consumable/beefbroth = 50)
	tastes = list("disgust" = 7, "tin" = 1)
	foodtypes = MEAT | GROSS | JUNKFOOD
