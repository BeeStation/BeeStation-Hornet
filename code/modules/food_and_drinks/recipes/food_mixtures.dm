
//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/food
	name = "Abstract Food Reaction"
	reaction_tags = REACTION_TAG_FOOD

/datum/chemical_reaction/food/tofu
	name = "Tofu"
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_FOOD

/datum/chemical_reaction/food/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/tofu(location)

/datum/chemical_reaction/food/chocolatepudding
	results = list(/datum/reagent/consumable/chocolatepudding = 20)
	required_reagents = list(/datum/reagent/consumable/cream  = 5, /datum/reagent/consumable/cocoa = 5, /datum/reagent/consumable/eggyolk = 2)

/datum/chemical_reaction/food/vanillapudding
	results = list(/datum/reagent/consumable/vanillapudding = 20)
	required_reagents = list(/datum/reagent/consumable/vanilla = 5, /datum/reagent/consumable/cream = 5, /datum/reagent/consumable/eggyolk = 2)

/datum/chemical_reaction/food/chocolate_bar
	name = "Chocolate Bar"
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/food/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/chocolatebar(location)

/datum/chemical_reaction/food/chocolate_bar2
	name = "Chocolate Bar"
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/sugar = 2)
	mob_react = FALSE

/datum/chemical_reaction/food/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/chocolatebar(location)

/datum/chemical_reaction/food/soysauce
	name = "Soy Sauce"
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/food/corn_syrup
	name = /datum/reagent/consumable/corn_syrup
	results = list(/datum/reagent/consumable/corn_syrup = 5)
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/toxin/acid = 1)
	required_temp = 374

/datum/chemical_reaction/food/caramel
	name = "Caramel"
	results = list(/datum/reagent/consumable/caramel = 1)
	required_reagents = list(/datum/reagent/consumable/sugar = 1)
	required_temp = 413.15
	mob_react = FALSE

/datum/chemical_reaction/food/caramel_burned
	name = "Caramel burned"
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/consumable/caramel = 1)
	required_temp = 483.15
	mob_react = FALSE

/datum/chemical_reaction/food/cheesewheel
	name = "Cheesewheel"
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/cheese/wheel(location)

/datum/chemical_reaction/food/synthmeat
	name = "synthmeat"
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
	mob_react = FALSE

/datum/chemical_reaction/food/synthmeat/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/meat/slab/synthmeat(location)

/datum/chemical_reaction/food/hot_ramen
	name = "Hot Ramen"
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/food/hell_ramen
	name = "Hell Ramen"
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)

/datum/chemical_reaction/food/imitationcarpmeat
	name = "Imitation Carpmeat"
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	required_container = /obj/item/food/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/food/imitationcarpmeat/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/food/fishmeat/carp/imitation(location)
	if(holder?.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/food/dough
	name = "Dough"
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/food/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/dough(location)

/datum/chemical_reaction/food/cakebatter
	name = "Cake Batter"
	required_reagents = list(/datum/reagent/consumable/eggyolk = 6, /datum/reagent/consumable/eggwhite = 12, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
	mix_message = "The ingredients form a cake batter."

/datum/chemical_reaction/food/cakebatter/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/cakebatter(location)

/datum/chemical_reaction/food/cakebatter/vegan
	required_reagents = list(/datum/reagent/consumable/soymilk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)

/datum/chemical_reaction/food/pancakebatter
	results = list(/datum/reagent/consumable/pancakebatter = 15)
	required_reagents = list(/datum/reagent/consumable/eggyolk = 6, /datum/reagent/consumable/eggwhite = 12, /datum/reagent/consumable/milk = 10, /datum/reagent/consumable/flour = 5)

/datum/chemical_reaction/food/uncooked_rice
	name = "Uncooked Rice"
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 10)
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/food/uncooked_rice/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/uncooked_rice(location)

/datum/chemical_reaction/food/bbqsauce
	name = "BBQ Sauce"
	results = list(/datum/reagent/consumable/bbqsauce = 5)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/medicine/salglu_solution = 3, /datum/reagent/consumable/blackpepper = 1)

/datum/chemical_reaction/food/gravy
	results = list(/datum/reagent/consumable/gravy = 3)
	required_reagents = list(/datum/reagent/consumable/milk = 1, /datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/flour = 1)
