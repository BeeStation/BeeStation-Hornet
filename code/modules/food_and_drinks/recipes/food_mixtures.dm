/datum/crafting_recipe/food
	var/real_parts
	category = CAT_FOOD

/datum/crafting_recipe/food/New()
	real_parts = parts.Copy()
	parts |= reqs

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////
/datum/chemical_reaction/food
	optimal_temp = 400
	temp_exponent_factor = 1
	optimal_ph_min = 2
	optimal_ph_max = 10
	thermic_constant = 0
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/tofu
	name = "Tofu"
	id = "tofu"
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mob_react = FALSE
	reaction_flags = REACTION_INSTANT

/datum/chemical_reaction/food/tofu/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/food/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/food/chocolate_bar/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return


/datum/chemical_reaction/food/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/sugar = 2)
	mob_react = FALSE

/datum/chemical_reaction/food/chocolate_bar2/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/food/hot_cocoa
	name = "Hot Cocoa"
	id = /datum/reagent/consumable/cocoa/hot_cocoa
	results = list(/datum/reagent/consumable/cocoa/hot_cocoa = 5)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/cocoa = 1)

/datum/chemical_reaction/food/coffee
	name = "Coffee"
	id = /datum/reagent/consumable/coffee
	results = list(/datum/reagent/consumable/coffee = 5)
	required_reagents = list(/datum/reagent/toxin/coffeepowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/food/tea
	name = "Tea"
	id = /datum/reagent/consumable/tea
	results = list(/datum/reagent/consumable/tea = 5)
	required_reagents = list(/datum/reagent/toxin/teapowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/food/soysauce
	name = "Soy Sauce"
	id = /datum/reagent/consumable/soysauce
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/food/corn_syrup
	name = /datum/reagent/consumable/corn_syrup
	id = /datum/reagent/consumable/corn_syrup
	results = list(/datum/reagent/consumable/corn_syrup = 5)
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/toxin/acid = 1)
	required_temp = 374

/datum/chemical_reaction/food/caramel
	name = "Caramel"
	id = /datum/reagent/consumable/caramel
	results = list(/datum/reagent/consumable/caramel = 1)
	required_reagents = list(/datum/reagent/consumable/sugar = 1)
	required_temp = 413.15
	mob_react = FALSE

/datum/chemical_reaction/food/caramel_burned
	name = "Caramel burned"
	id = "caramel_burned"
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/consumable/caramel = 1)
	required_temp = 483.15
	mob_react = FALSE

/datum/chemical_reaction/food/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/cheesewheel/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/store/cheesewheel(location)

/datum/chemical_reaction/food/synthmeat
	name = "synthmeat"
	id = "synthmeat"
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
	mob_react = FALSE

/datum/chemical_reaction/food/synthmeat/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat(location)

/datum/chemical_reaction/food/hot_ramen
	name = "Hot Ramen"
	id = /datum/reagent/consumable/hot_ramen
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/food/hell_ramen
	name = "Hell Ramen"
	id = /datum/reagent/consumable/hell_ramen
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)

/datum/chemical_reaction/food/imitationcarpmeat
	name = "Imitation Carpmeat"
	id = "imitationcarpmeat"
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	required_container = /obj/item/reagent_containers/food/snacks/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/food/imitationcarpmeat/on_reaction(datum/equilibrium/reaction, datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/carpmeat/imitation(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/food/dough
	name = "Dough"
	id = "dough"
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/food/dough/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/dough(location)

/datum/chemical_reaction/food/cakebatter
	name = "Cake Batter"
	id = "cakebatter"
	required_reagents = list(/datum/reagent/consumable/eggyolk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
	mix_message = "The ingredients form a cake batter."

/datum/chemical_reaction/food/cakebatter/on_reaction(datum/reagents/holder, datum/equilibrium/reaction, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cakebatter(location)

/datum/chemical_reaction/food/cakebatter/vegan
	id = "vegancakebatter"
	required_reagents = list(/datum/reagent/consumable/soymilk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)

/datum/chemical_reaction/food/ricebowl
	name = "Rice Bowl"
	id = "ricebowl"
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 10)
	required_container = /obj/item/reagent_containers/glass/bowl
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/food/ricebowl/on_reaction(datum/equilibrium/reaction, datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/salad/ricebowl(location)
	if(holder?.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/food/bbqsauce
	name = "BBQ Sauce"
	id = /datum/reagent/consumable/bbqsauce
	results = list(/datum/reagent/consumable/bbqsauce = 5)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/medicine/salglu_solution = 3, /datum/reagent/consumable/blackpepper = 1)
