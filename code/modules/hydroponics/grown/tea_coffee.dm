// Tea
/obj/item/food/grown/tea
	seed = /obj/item/plant_seeds/preset/tea
	name = "Tea Aspera tips"
	desc = "These aromatic tips of the tea plant can be dried to make tea."
	icon_state = "tea_aspera_leaves"
	filling_color = COLOR_GREEN
	dry_grind = TRUE
	grind_results = list(/datum/reagent/toxin/teapowder = 0)
	can_distill = FALSE

// Tea Astra
/obj/item/food/grown/tea/astra
	name = "Tea Astra tips"
	desc = "A special blend of tea to sooth the mind."
	icon_state = "tea_astra_leaves"
	bite_consumption_mod = 2
	grind_results = list(/datum/reagent/toxin/teapowder = 0, /datum/reagent/medicine/salglu_solution = 0)
	discovery_points = 300


// Coffee
/obj/item/food/grown/coffee
	seed = /obj/item/plant_seeds/preset/coffee
	name = "coffee arabica beans"
	desc = "Dry them out to make coffee."
	icon_state = "coffee_arabica"
	dry_grind = TRUE
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/kahlua

// Coffee Robusta
/obj/item/food/grown/coffee/robusta
	name = "coffee robusta beans"
	desc = "Increases robustness by 37 percent!"
	icon_state = "coffee_robusta"
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0, /datum/reagent/medicine/morphine = 0)
	discovery_points = 300
