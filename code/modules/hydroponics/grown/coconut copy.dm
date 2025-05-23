// https://www.youtube.com/watch?v=WIcK_QqD_v8
/obj/item/seeds/tetopear
	name = "pack of tetopear seeds"
	desc = "These seeds grow into a tetopear tree."
	icon_state = "seed-tetopear"
	species = "tetopear"
	plantname = "Tetopear Tree"
	product = /obj/item/grown/tetopear
	lifespan = 55
	endurance = 35
	production = 7
	yield = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
	icon_harvest = "tetopear-harvest"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/grown/tetopear
	seed = /obj/item/seeds/tetopear
	name = "tetopear"
	desc = "A tetopear. It stares at you."
	icon_state = "tetopear"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 4
