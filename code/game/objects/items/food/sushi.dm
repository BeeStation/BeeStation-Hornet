/obj/item/food/seaweed_sheet
	name = "Seaweed Sheet"
	desc = "A dried sheet of seaweed used for making sushi."
	icon = 'icons/obj/food/sushi.dmi'
	icon_state = 'seaweed_sheet'
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("seaweed" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
