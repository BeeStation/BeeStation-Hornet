// Carrot
/obj/item/seeds/carrot
	name = "pack of carrot seeds"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	species = "carrot"
	plantname = "Carrots"
	product = /obj/item/reagent_containers/food/snacks/grown/carrot
	maturation = 10
	production = 1
	yield = 5
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 12),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8),
		/datum/reagent/medicine/oculine = list(5, 25))
	mutatelist = list(/obj/item/seeds/carrot/parsnip)

/obj/item/reagent_containers/food/snacks/grown/carrot
	seed = /obj/item/seeds/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	filling_color = "#FFA500"
	bitesize_mod = 2
	foodtype = VEGETABLES
	juice_results = list(/datum/reagent/consumable/carrotjuice = 0)
	wine_power = 30

/obj/item/reagent_containers/food/snacks/grown/carrot/attackby(obj/item/I, mob/user, params)
	if(I.is_sharp())
		to_chat(user, "<span class='notice'>You sharpen the carrot into a shiv with [I].</span>")
		var/obj/item/kitchen/knife/carrotshiv/Shiv = new /obj/item/kitchen/knife/carrotshiv
		remove_item_from_storage(user)
		qdel(src)
		user.put_in_hands(Shiv)
	else
		return ..()

// Parsnip
/obj/item/seeds/carrot/parsnip
	name = "pack of parsnip seeds"
	desc = "These seeds grow into parsnips."
	icon_state = "seed-parsnip"
	species = "parsnip"
	plantname = "Parsnip"
	product = /obj/item/reagent_containers/food/snacks/grown/parsnip
	icon_dead = "carrot-dead"
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(5, 15),
		/datum/reagent/consumable/nutriment/vitamin = list(5, 10))
	mutatelist = list(/obj/item/seeds/carrot)


/obj/item/reagent_containers/food/snacks/grown/parsnip
	seed = /obj/item/seeds/carrot/parsnip
	name = "parsnip"
	desc = "Closely related to carrots."
	icon_state = "parsnip"
	bitesize_mod = 2
	foodtype = VEGETABLES
	juice_results = list(/datum/reagent/consumable/parsnipjuice = 0)
	wine_power = 35
	discovery_points = 300


// White-Beet
/obj/item/seeds/whitebeet
	name = "pack of white-beet seeds"
	desc = "These seeds grow into sugary beet producing plants."
	icon_state = "seed-whitebeet"
	species = "whitebeet"
	plantname = "White-Beet Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/whitebeet
	lifespan = 60
	endurance = 50
	yield = 6
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(5, 15),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8),
		/datum/reagent/consumable/sugar = list(15, 25))
	mutatelist = list(/obj/item/seeds/redbeet)

/obj/item/reagent_containers/food/snacks/grown/whitebeet
	seed = /obj/item/seeds/whitebeet
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	bitesize_mod = 2
	foodtype = VEGETABLES
	wine_power = 40

// Red Beet
/obj/item/seeds/redbeet
	name = "pack of redbeet seeds"
	desc = "These seeds grow into red beet producing plants."
	icon_state = "seed-redbeet"
	species = "redbeet"
	plantname = "Red-Beet Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/redbeet
	lifespan = 60
	endurance = 50
	yield = 6
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	genes = list(/datum/plant_gene/trait/maxchem)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(5, 12),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8),
		/datum/reagent/consumable/sugar = list(0, 25))
	mutatelist = list(/obj/item/seeds/whitebeet)

/obj/item/reagent_containers/food/snacks/grown/redbeet
	seed = /obj/item/seeds/redbeet
	name = "red beet"
	desc = "You can't beat red beet."
	icon_state = "redbeet"
	bitesize_mod = 2
	foodtype = VEGETABLES
	wine_power = 60
	discovery_points = 300
