/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	results = list(/datum/reagent/space_cleaner/sterilizine = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/charcoal = 1, /datum/reagent/chlorine = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/cooking_oil
	name = "Cooking Oil"
	results = list(/datum/reagent/consumable/nutriment/fat/oil = 4)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/oil = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/carbon = 1)
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_OTHER

/datum/chemical_reaction/lube
	name = "Space Lube"
	results = list(/datum/reagent/lube = 4)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/spraytan
	name = "Spray Tan"
	results = list(/datum/reagent/spraytan = 2)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 1, /datum/reagent/oil = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/spraytan2
	name = "Spray Tan"
	results = list(/datum/reagent/spraytan = 2)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 1, /datum/reagent/consumable/nutriment/fat/oil = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	results = list(/datum/reagent/impedrezene = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_DAMAGING | REACTION_TAG_ORGAN

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	results = list(/datum/reagent/cryptobiolin = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	results = list(/datum/reagent/glycerol = 1)
	required_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = 3, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	results = list(/datum/reagent/consumable/sodiumchloride = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/sodium = 1, /datum/reagent/chlorine = 1)
	reaction_tags = REACTION_TAG_FOOD

/datum/chemical_reaction/synthetic_blood
	name = "Synthesized Coolant Blood"
	results = list(/datum/reagent/blood/coolant = 2)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/iron = 1, /datum/reagent/cryostylane = 1)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_HEALING

/datum/chemical_reaction/plasmasolidification
	name = "Solid Plasma"
	required_reagents = list(/datum/reagent/iron = 5, /datum/reagent/consumable/frostoil = 5, /datum/reagent/toxin/plasma = 20)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/plasmasolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/plasma(location)

/datum/chemical_reaction/goldsolidification
	name = "Solid Gold"
	required_reagents = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/gold = 20, /datum/reagent/iron = 1)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/goldsolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/gold(location)

/datum/chemical_reaction/adamantinesolidification
	name = "Adamantine Sheet"
	required_reagents = list(/datum/reagent/gold = 5, /datum/reagent/consumable/frostoil = 5, /datum/reagent/liquidadamantine = 10)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/adamantinesolidification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/mineral/adamantine(location)

/datum/chemical_reaction/capsaicincondensation
	name = "Capsaicincondensation"
	results = list(/datum/reagent/consumable/condensedcapsaicin = 5)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/ethanol = 5)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/soapification
	name = "Soapification"
	required_reagents = list(/datum/reagent/liquidgibs = 10, /datum/reagent/lye  = 10) // requires two scooped gib tiles
	required_temp = 374
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/soap/homemade(location)

/datum/chemical_reaction/candlefication
	name = "Candlefication"
	required_reagents = list(/datum/reagent/liquidgibs = 5, /datum/reagent/oxygen  = 5) //
	required_temp = 374
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	name = "Meatification"
	required_reagents = list(/datum/reagent/liquidgibs = 10, /datum/reagent/consumable/nutriment = 10)
	mob_react = FALSE
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/meat/slab/meatproduct(location)
	return

/datum/chemical_reaction/carbondioxide
	name = "Direct Carbon Oxidation"
	results = list(/datum/reagent/carbondioxide = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 2)
	required_temp = 777 // pure carbon isn't especially reactive.
	reaction_tags = REACTION_TAG_CHEMICAL

/datum/chemical_reaction/nitrous_oxide
	name = "Nitrous Oxide"
	results = list(/datum/reagent/nitrous_oxide = 5)
	required_reagents = list(/datum/reagent/ammonia = 2, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 2)
	required_temp = 525
	reaction_tags = REACTION_TAG_CHEMICAL

//Technically a mutation toxin
/datum/chemical_reaction/mulligan
	name = "Mulligan"
	results = list(/datum/reagent/mulligan = 1)
	required_reagents = list(/datum/reagent/mutationtoxin/jelly = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_OTHER


//prevents the disease from spreading via symptoms
/datum/chemical_reaction/falter_virus
	name = "Falter Virus"
	required_reagents = list(/datum/reagent/medicine/spaceacillin = 1)
	required_catalysts = list(/datum/reagent/blood = 1)

/datum/chemical_reaction/falter_virus/check_other()
	if(CONFIG_GET(flag/neuter_allowed))
		return TRUE
	return FALSE

/datum/chemical_reaction/falter_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/disease/advance/target = find_virus(holder)
	if(target)
		target.faltered = TRUE
		target.spread_flags = DISEASE_SPREAD_FALTERED
		target.spread_text = "Intentional Injection"
		target.logchanges(holder, "FALTER")

/datum/chemical_reaction/proc/find_virus(datum/reagents/holder)
	var/datum/reagent/blood/blood = locate(/datum/reagent/blood) in holder.reagent_list
	if(!length(blood?.data))
		return
	for(var/datum/disease/advance/virus in blood.data["viruses"])
		if(!virus.mutable)
			continue
		return virus

////////////////////////////////// foam and foam precursor ///////////////////////////////////////////////////


/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	results = list(/datum/reagent/fluorosurfactant = 5)
	required_reagents = list(/datum/reagent/fluorine = 2, /datum/reagent/carbon = 2, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/foam
	name = "Foam"
	required_reagents = list(/datum/reagent/fluorosurfactant = 1, /datum/reagent/water = 1)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/foam/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates an expanding bubble of foam",
		REACTION_HINT_RADIUS_TABLE = list(
			round(sqrt(10), 1),
			round(sqrt(50), 1),
			round(sqrt(100), 1),
			round(sqrt(200), 1),
			round(sqrt(500), 1),
		)
	)

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M as() in viewers(5, location))
		to_chat(M, span_danger("The solution spews out foam!"))
	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume*2, location, holder)
	s.start()
	holder.clear_reagents()
	return


/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	required_reagents = list(/datum/reagent/aluminium = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/metalfoam/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates an expanding bubble of hardening foam",
		REACTION_HINT_RADIUS_TABLE = list(
			round(sqrt(10*2.5), 1),
			round(sqrt(50*2.5), 1),
			round(sqrt(100*2.5), 1),
			round(sqrt(200*2.5), 1),
			round(sqrt(500*2.5), 1),
		)
	)

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/mob/M as() in viewers(5, location))
		to_chat(M, span_danger("The solution spews out a metallic foam!"))

	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume*5, location, holder, 1)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/smart_foam
	name = "Smart Metal Foam"
	required_reagents = list(/datum/reagent/aluminium = 3, /datum/reagent/smart_foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = TRUE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/smart_foam/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates an expanding bubble of hardening smart-foam",
		REACTION_HINT_RADIUS_TABLE = list(
			round(sqrt(10*2.5), 1),
			round(sqrt(50*2.5), 1),
			round(sqrt(100*2.5), 1),
			round(sqrt(200*2.5), 1),
			round(sqrt(500*2.5), 1),
		)
	)

/datum/chemical_reaction/smart_foam/on_reaction(datum/reagents/holder, created_volume)
	var/turf/location = get_turf(holder.my_atom)
	location.visible_message(span_danger("The solution spews out metallic foam!"))
	var/datum/effect_system/foam_spread/metal/smart/s = new()
	s.set_up(created_volume * 5, location, holder, TRUE)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	required_reagents = list(/datum/reagent/iron = 3, /datum/reagent/foaming_agent = 1, /datum/reagent/toxin/acid/fluacid = 1)
	mob_react = FALSE
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/ironfoam/New()
	. = ..()
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates an expanding bubble of iron foam",
		REACTION_HINT_RADIUS_TABLE = list(
			round(sqrt(10*2.5), 1),
			round(sqrt(50*2.5), 1),
			round(sqrt(100*2.5), 1),
			round(sqrt(200*2.5), 1),
			round(sqrt(500*2.5), 1),
		)
	)

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/mob/M as() in viewers(5, location))
		to_chat(M, span_danger("The solution spews out a metallic foam!"))
	var/datum/effect_system/foam_spread/metal/s = new()
	s.set_up(created_volume*5, location, holder, 2)
	s.start()
	holder.clear_reagents()

/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	results = list(/datum/reagent/foaming_agent = 1)
	required_reagents = list(/datum/reagent/lithium = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_EXPLOSIVE

/datum/chemical_reaction/smart_foaming_agent
	name = "Smart foaming Agent"
	results = list(/datum/reagent/smart_foaming_agent = 3)
	required_reagents = list(/datum/reagent/foaming_agent = 3, /datum/reagent/acetone = 1, /datum/reagent/iron = 1)
	mix_message = "The solution mixes into a frothy metal foam and conforms to the walls of its container."
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_EXPLOSIVE


/////////////////////////////// Cleaning and hydroponics /////////////////////////////////////////////////

/datum/chemical_reaction/ammonia
	name = "Ammonia"
	results = list(/datum/reagent/ammonia = 3)
	required_reagents = list(/datum/reagent/hydrogen = 3, /datum/reagent/nitrogen = 1)
	reaction_tags = REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	results = list(/datum/reagent/diethylamine = 2)
	required_reagents = list (/datum/reagent/ammonia = 1, /datum/reagent/consumable/ethanol = 1)
	reaction_tags = REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	results = list(/datum/reagent/space_cleaner = 2)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/water = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	results = list(/datum/reagent/toxin/plantbgone = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/water = 4)
	reaction_tags = REACTION_TAG_PLANT

/datum/chemical_reaction/weedkiller
	name = "Weed Killer"
	results = list(/datum/reagent/toxin/plantbgone/weedkiller = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/ammonia = 4)
	reaction_tags = REACTION_TAG_PLANT

/datum/chemical_reaction/pestkiller
	name = "Pest Killer"
	results = list(/datum/reagent/toxin/pestkiller = 5)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/consumable/ethanol = 4)
	reaction_tags = REACTION_TAG_PLANT

/datum/chemical_reaction/drying_agent
	name = "Drying agent"
	results = list(/datum/reagent/drying_agent = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/sodium = 1)
	reaction_tags = REACTION_TAG_OTHER

//////////////////////////////////// Other goon stuff ///////////////////////////////////////////

/datum/chemical_reaction/acetone
	name = /datum/reagent/acetone
	results = list(/datum/reagent/acetone = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/fuel = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_CHEMICAL

/datum/chemical_reaction/carpet
	name = /datum/reagent/carpet
	results = list(/datum/reagent/carpet = 10)
	required_reagents = list(/datum/reagent/drug/space_drugs = 1, /datum/reagent/blood = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/carpet/black
	name = /datum/reagent/carpet/black
	results = list(/datum/reagent/carpet/black = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/oil = 0.1)

/datum/chemical_reaction/carpet/blue
	name = /datum/reagent/carpet/blue
	results = list(/datum/reagent/carpet/blue = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/cryostylane = 0.1)

/datum/chemical_reaction/carpet/cyan
	name = /datum/reagent/carpet/cyan
	results = list(/datum/reagent/carpet/cyan = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/toxin/cyanide = 0.1)
	//cyan = cyanide get it huehueuhuehuehheuhe

/datum/chemical_reaction/carpet/green
	name = /datum/reagent/carpet/green
	results = list(/datum/reagent/carpet/green = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/ethanol/beer/green = 0.1)
	//make green beer by grinding up green crayons and mixing with beer

/datum/chemical_reaction/carpet/orange
	name = /datum/reagent/carpet/orange
	results = list(/datum/reagent/carpet/orange = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/consumable/orangejuice = 0.1)

/datum/chemical_reaction/carpet/purple
	name = /datum/reagent/carpet/purple
	results = list(/datum/reagent/carpet/purple = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/medicine/regen_jelly = 0.1)
	//slimes only party

/datum/chemical_reaction/carpet/red
	name = /datum/reagent/carpet/red
	results = list(/datum/reagent/carpet/red = 2)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/liquidgibs = 0.1)

/datum/chemical_reaction/carpet/royalblack
	name = /datum/reagent/carpet/royal/black
	results = list(/datum/reagent/carpet/royal/black = 2)
	required_reagents = list(/datum/reagent/carpet/black = 1, /datum/reagent/royal_bee_jelly = 0.1)

/datum/chemical_reaction/carpet/royalblue
	name = /datum/reagent/carpet/royal/blue
	results = list(/datum/reagent/carpet/royal/blue = 2)
	required_reagents = list(/datum/reagent/carpet/blue = 1, /datum/reagent/royal_bee_jelly = 0.1)

/datum/chemical_reaction/oil
	name = "Oil"
	results = list(/datum/reagent/oil = 3)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_CHEMICAL

/datum/chemical_reaction/phenol
	name = /datum/reagent/phenol
	results = list(/datum/reagent/phenol = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/chlorine = 1, /datum/reagent/oil = 1)
	reaction_tags = REACTION_TAG_CHEMICAL

/datum/chemical_reaction/ash
	name = "Ash"
	results = list(/datum/reagent/ash = 1)
	required_reagents = list(/datum/reagent/oil = 1)
	required_temp = 480
	reaction_tags = REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/datum/chemical_reaction/colorful_reagent
	name = /datum/reagent/colorful_reagent
	results = list(/datum/reagent/colorful_reagent = 5)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/drug/space_drugs = 1, /datum/reagent/medicine/cryoxadone = 1, /datum/reagent/consumable/triple_citrus = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/hair_dye
	name = /datum/reagent/hair_dye
	results = list(/datum/reagent/hair_dye = 5)
	required_reagents = list(/datum/reagent/colorful_reagent = 1, /datum/reagent/drug/space_drugs = 1, /datum/reagent/uranium/radium = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/life
	name = "Life"
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/blood = 1)
	required_temp = 374
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Produces hostile lifeforms",
	)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/life/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (hostile)") //defaults to HOSTILE_SPAWN

/datum/chemical_reaction/life_friendly
	name = "Life (Friendly)"
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/consumable/sugar = 1)
	required_temp = 374
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Produces friendly lifeforms",
	)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/life_friendly/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Life (friendly)", FRIENDLY_SPAWN)

/datum/chemical_reaction/corgium
	name = "corgium"
	required_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/colorful_reagent = 1, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/blood = 1)
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Produces a corgi",
	)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, created_volume)
	if(isliving(holder.my_atom) && !iscorgi(holder.my_atom))
		var/mob/living/L = holder
		L.reagents.add_reagent(/datum/reagent/corgium, created_volume)
	else
		var/location = get_turf(holder.my_atom)
		for(var/i in rand(1, created_volume) to created_volume) // More lulz.
			new /mob/living/basic/pet/dog/corgi(location)
	..()

/datum/chemical_reaction/barbers_aid
	name = /datum/reagent/barbers_aid
	results = list(/datum/reagent/barbers_aid = 5)
	required_reagents = list(/datum/reagent/carpet = 1, /datum/reagent/uranium/radium = 1, /datum/reagent/drug/space_drugs = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/concentrated_barbers_aid
	name = /datum/reagent/concentrated_barbers_aid
	results = list(/datum/reagent/concentrated_barbers_aid = 2)
	required_reagents = list(/datum/reagent/barbers_aid = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/barbers_afro_mania
	name = /datum/reagent/barbers_afro_mania
	results = list(/datum/reagent/barbers_afro_mania = 2)
	required_reagents = list(/datum/reagent/concentrated_barbers_aid = 1, /datum/reagent/colorful_reagent = 1)

/datum/chemical_reaction/barbers_shaving_aid
	name = /datum/reagent/barbers_shaving_aid
	results = list(/datum/reagent/barbers_shaving_aid = 2)
	required_reagents = list(/datum/reagent/concentrated_barbers_aid = 1, /datum/reagent/napalm = 1)

/datum/chemical_reaction/saltpetre
	name = /datum/reagent/saltpetre
	results = list(/datum/reagent/saltpetre = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 3)
	reaction_tags = REACTION_TAG_PLANT

/datum/chemical_reaction/lye
	name = /datum/reagent/lye
	results = list(/datum/reagent/lye = 3)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_CHEMICAL

/datum/chemical_reaction/lye2
	name = /datum/reagent/lye
	results = list(/datum/reagent/lye = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/water = 1, /datum/reagent/carbon = 1)
	reaction_tags = REACTION_TAG_CHEMICAL

/datum/chemical_reaction/royal_bee_jelly
	name = "royal bee jelly"
	results = list(/datum/reagent/royal_bee_jelly = 5)
	required_reagents = list(/datum/reagent/toxin/mutagen = 10, /datum/reagent/consumable/honey = 40)
	reaction_tags = REACTION_TAG_PLANT

/datum/chemical_reaction/laughter
	name = /datum/reagent/consumable/laughter
	results = list(/datum/reagent/consumable/laughter = 10) // Fuck it. I'm not touching this one.
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/banana = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/plastic_polymers
	name = "plastic polymers"
	required_reagents = list(/datum/reagent/oil = 5, /datum/reagent/toxin/acid = 2, /datum/reagent/ash = 3)
	required_temp = 374 //lazily consistent with soap & other crafted objects generically created with heat.
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER

/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/stack/sheet/plastic(location)

/datum/chemical_reaction/glitter
	name = "light pink glitter"
	results = list(/datum/reagent/glitter = 10)
	required_reagents = list(/datum/reagent/oil = 5, /datum/reagent/toxin/acid = 2, /datum/reagent/ash = 3, /datum/reagent/aluminium = 2)
	required_temp = 340 //arbitrarily lower than plastic to prevent conflict

/datum/chemical_reaction/glitter/pink
	name = "pink glitter"
	results = list(/datum/reagent/glitter/pink = 5)
	required_reagents = list(/datum/reagent/glitter = 5, /datum/reagent/stable_plasma = 1)

/datum/chemical_reaction/glitter/white
	name = "white glitter"
	results = list(/datum/reagent/glitter/white = 5)
	required_reagents = list(/datum/reagent/glitter = 5, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/glitter/blue
	name = "blue glitter"
	results = list(/datum/reagent/glitter/blue = 5)
	required_reagents = list(/datum/reagent/glitter = 5, /datum/reagent/nitrogen = 1)

/datum/chemical_reaction/pax
	name = /datum/reagent/pax
	results = list(/datum/reagent/pax = 3)
	required_reagents  = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/medicine/synaptizine = 1, /datum/reagent/water = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_OTHER


//////////////////EXPANDED MUTATION TOXINS/////////////////////

/datum/chemical_reaction/mutationtoxin
	name = "Generic Mutation Toxin Recipe"
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/mutationtoxin/stable
	name = /datum/reagent/mutationtoxin
	results = list(/datum/reagent/mutationtoxin = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/blood = 10)

/datum/chemical_reaction/mutationtoxin/lizard
	name = /datum/reagent/mutationtoxin/lizard
	results = list(/datum/reagent/mutationtoxin/lizard = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/liquidgibs = 10)

/datum/chemical_reaction/mutationtoxin/felinid
	name = /datum/reagent/mutationtoxin/felinid
	results = list(/datum/reagent/mutationtoxin/felinid = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/toxin/fentanyl = 10, /datum/reagent/impedrezene = 10)

/datum/chemical_reaction/mutationtoxin/fly
	name = /datum/reagent/mutationtoxin/fly
	results = list(/datum/reagent/mutationtoxin/fly = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/toxin/mutagen = 10)

/datum/chemical_reaction/mutationtoxin/moth
	name = /datum/reagent/mutationtoxin/moth
	results = list(/datum/reagent/mutationtoxin/moth = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/toxin/lipolicide = 10) //I know it's the opposite of what moths like, but I am out of ideas for this.

/datum/chemical_reaction/mutationtoxin/apid
	name = /datum/reagent/mutationtoxin/apid
	results = list(/datum/reagent/mutationtoxin/apid = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/consumable/honey = 20) // beeeeeeeeeeeeeeeeeeeeees

/datum/chemical_reaction/mutationtoxin/golem
	name = /datum/reagent/mutationtoxin/golem
	results = list(/datum/reagent/mutationtoxin/golem = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/liquidadamantine = 20)

/datum/chemical_reaction/mutationtoxin/abductor
	name = /datum/reagent/mutationtoxin/abductor
	results = list(/datum/reagent/mutationtoxin/abductor = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/medicine/morphine = 10, /datum/reagent/toxin/mutetoxin = 10)

/datum/chemical_reaction/mutationtoxin/ethereal
	name = /datum/reagent/mutationtoxin/ethereal
	results = list(/datum/reagent/mutationtoxin/ethereal = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/consumable/liquidelectricity = 20)

/datum/chemical_reaction/mutationtoxin/oozeling
	name = /datum/reagent/mutationtoxin/oozeling
	results = list(/datum/reagent/mutationtoxin/oozeling = 5)
	required_reagents  = list(/datum/reagent/mutationtoxin/unstable = 5, /datum/reagent/medicine/calomel = 10, /datum/reagent/toxin/bad_food = 30, /datum/reagent/stable_plasma = 5)

//////////////Mutation toxins made out of advanced toxin/////////////

/datum/chemical_reaction/mutationtoxin/ipc
	name = /datum/reagent/mutationtoxin/ipc
	id = /datum/reagent/mutationtoxin/ipc
	results = list(/datum/reagent/mutationtoxin/ipc = 5)
	required_reagents  = list(/datum/reagent/aslimetoxin = 5, /datum/reagent/teslium = 20)

/datum/chemical_reaction/mutationtoxin/skeleton
	name = /datum/reagent/mutationtoxin/skeleton
	results = list(/datum/reagent/mutationtoxin/skeleton = 5)
	required_reagents  = list(/datum/reagent/aslimetoxin = 5, /datum/reagent/consumable/milk = 30, /datum/reagent/toxin/acid/fluacid = 30) //Because acid melts flesh off.

///datum/chemical_reaction/mutationtoxin/zombie //No zombies until holopara issue is fixed.
//	name = /datum/reagent/mutationtoxin/zombie
//	id = /datum/reagent/mutationtoxin/zombie
//	results = list(/datum/reagent/mutationtoxin/zombie = 1)
//	required_reagents  = list(/datum/reagent/aslimetoxin = 1, /datum/reagent/toxin = 1, /datum/reagent/toxin/bad_food = 1) //Because rotting

/datum/chemical_reaction/mutationtoxin/goofzombie //go on. try it with holopara
	name = /datum/reagent/mutationtoxin/goofzombie
	results = list(/datum/reagent/mutationtoxin/goofzombie = 5)
	required_reagents  = list(/datum/reagent/aslimetoxin = 5, /datum/reagent/drug/krokodil = 10, /datum/reagent/toxin/bad_food = 10) //Because rotting

/datum/chemical_reaction/mutationtoxin/ash
	name = /datum/reagent/mutationtoxin/ash
	results = list(/datum/reagent/mutationtoxin/ash = 5)
	required_reagents  = list(/datum/reagent/aslimetoxin = 5, /datum/reagent/mutationtoxin/lizard = 1, /datum/reagent/ash = 10, /datum/reagent/consumable/entpoly = 5)

/datum/chemical_reaction/mutationtoxin/shadow
	name = /datum/reagent/mutationtoxin/shadow
	results = list(/datum/reagent/mutationtoxin/shadow = 5)
	required_reagents  = list(/datum/reagent/aslimetoxin = 5, /datum/reagent/liquid_dark_matter = 30, /datum/reagent/water/holywater = 10) //You need a tiny bit of thinking how to mix it

/datum/chemical_reaction/mutationtoxin/plasma
	name = /datum/reagent/mutationtoxin/plasma
	results = list(/datum/reagent/mutationtoxin/plasma = 5)
	required_reagents  = list(/datum/reagent/aslimetoxin = 5, /datum/reagent/toxin/plasma = 60, /datum/reagent/uranium = 20)

/datum/chemical_reaction/mutationtoxin/psyphoza
	name = /datum/reagent/mutationtoxin/psyphoza
	results = list(/datum/reagent/mutationtoxin/psyphoza = 5)
	required_reagents  = list(/datum/reagent/aslimetoxin = 5, /datum/reagent/toxin/amatoxin = 5)

/datum/chemical_reaction/ants // Breeding ants together, high sugar cost makes this take a while to farm.
	name = "Breed Ants"
	results = list(/datum/reagent/ants = 3)
	required_reagents = list(/datum/reagent/ants = 2, /datum/reagent/consumable/sugar = 8)

/datum/chemical_reaction/ant_slurry // We're basically glueing ants together with synthflesh & maint sludge to make a bigger ant.
	name = "Any Slurry"
	required_reagents = list(/datum/reagent/ants = 50, /datum/reagent/medicine/synthflesh = 20, /datum/reagent/ammonia = 5)
	required_temp = 480
	//reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_OTHER
	hints = list(
		REACTION_HINT_EXPLOSION_OTHER = "Creates a giant ant"
	)

/datum/chemical_reaction/ant_slurry/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in rand(1, created_volume) to created_volume)
		new /mob/living/simple_animal/hostile/ant(location)
	..()
