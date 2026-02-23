/obj/item/seeds/flower/rainbow_bunch
	name = "pack of rainbow bunch seeds"
	desc = "A pack of seeds that'll grow into a beautiful bush of various colored flowers."
	icon_state = "seed-rainbowbunch"
	species = "rainbowbunch"
	plantname = "Rainbow Bunch"
	icon_harvest = "rainbowbunch-harvest"
	product = /obj/item/food/grown/flower/rainbow
	lifespan = 100
	endurance = 10
	maturation = 6
	production = 3
	yield = 5
	potency = 20
	growthstages = 4
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/flower/rainbow
	seed = /obj/item/seeds/flower/rainbow_bunch
	name = "rainbow flower"
	desc = "A beautiful flower capable of being used for most dyeing processes."
	icon_state = "rainbow_flower"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 2
	throw_range = 3
	bite_consumption_mod = 0
	foodtypes = null
	attack_verb_continuous = list("pompfs")
	attack_verb_simple = list("pompf")

/obj/item/food/grown/flower/rainbow/Initialize(mapload)
	. = ..()
	var/flower_color = rand(1,8)
	switch(flower_color)
		if(1)
			color = "#DA0000"
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/red, 3)
			dye_color = DYE_RED
			desc += " This one is in a fiery red color."
		if(2)
			color = "#FF9300"
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/orange, 3)
			dye_color = DYE_ORANGE
			desc += " This one is in a citrus orange color."
		if(3)
			color = "#FFF200"
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/yellow, 3)
			dye_color = DYE_YELLOW
			desc += " This one is in a bright yellow color."
		if(4)
			color = "#A8E61D"
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/green, 3)
			dye_color = DYE_GREEN
			desc += " This one is in a grassy green color."
		if(5)
			color = "#00B7EF"
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/blue, 3)
			dye_color = DYE_BLUE
			desc += " This one is in a soothing blue color."
		if(6)
			color = "#DA00FF"
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/purple, 3)
			dye_color = DYE_PURPLE
			desc += " This one is in a vibrant purple color."
		if(7)
			color = "#1C1C1C"
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/black, 3)
			dye_color = DYE_BLACK
			desc += " This one is in a midnight black color."
		if(8)
			color = COLOR_WHITE
			reagents.add_reagent(/datum/reagent/colorful_reagent/powder/white, 3)
			dye_color = DYE_WHITE
			desc += " This one is in a pure white color."
