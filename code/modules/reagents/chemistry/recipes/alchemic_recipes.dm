
/datum/chemical_reaction/berserkium
	name = "Berserkium"
	id = /datum/reagent/magic/berserkium
	results = list(/datum/reagent/magic/berserkium = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/magic = 1)

/datum/chemical_reaction/acceleratium
	name = "acceleratium"
	id = /datum/reagent/magic/acceleratium
	results = list(/datum/reagent/magic/acceleratium = 3)
	required_reagents = list(/datum/reagent/magic = 1, /datum/reagent/toxin = 2)

/datum/chemical_reaction/levitatium
	name = "Levitatium"
	id = /datum/reagent/magic/levitatium
	results = list(/datum/reagent/magic/levitatium = 2)
	required_reagents = list(/datum/reagent/magic/berserkium = 1, /datum/reagent/blood = 1)

/datum/chemical_reaction/invisibilium
	name = "Invisibilium"
	id = /datum/reagent/magic/invisibilium
	results = list(/datum/reagent/magic/invisibilium = 2)
	required_reagents = list(/datum/reagent/magic/acceleratium = 1, /datum/reagent/oil = 1)

/datum/chemical_reaction/hastium
	name = "Hastium"
	id = /datum/reagent/magic/levitatium/hastium
	results = list(/datum/reagent/magic/levitatium/hastium = 2)
	required_reagents = list(/datum/reagent/magic/acceleratium = 1, /datum/reagent/magic/levitatium = 1)



/datum/chemical_reaction/polymorphine
	name = "Polymorphine"
	id = /datum/reagent/magic/polymorphine
	results = list(/datum/reagent/magic/polymorphine = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/blood = 1, /datum/reagent/magic = 1)

/datum/chemical_reaction/polymorphine_u
	name = "Unstable Polymorphine"
	id = /datum/reagent/magic/polymorphine/unstable
	results = list(/datum/reagent/magic/polymorphine/unstable = 2)
	required_reagents = list(/datum/reagent/magic/polymorphine = 1, /datum/reagent/consumable/ethanol/whiskey = 1)

/datum/chemical_reaction/polymorphine_c
	name = "Chaotic Polymorphine"
	id = /datum/reagent/magic/polymorphine/chaotic
	results = list(/datum/reagent/magic/polymorphine/chaotic = 3)
	required_reagents = list(/datum/reagent/magic/polymorphine = 2, /datum/reagent/toxin = 1)

/datum/chemical_reaction/teleportarium
	name = "Teleportarium"
	id = /datum/reagent/magic/teleportarium
	results = list(/datum/reagent/magic/teleportarium = 2)
	required_reagents = list(/datum/reagent/bluespace = 1, /datum/reagent/magic = 1)

/datum/chemical_reaction/teleportarium_u
	name = "Unstable Teleportarium"
	id = /datum/reagent/magic/teleportarium/unstable
	results = list(/datum/reagent/magic/teleportarium/unstable = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/magic/teleportarium = 1)

/datum/chemical_reaction/midas
	name = "Draught of Midas"
	id = /datum/reagent/magic/midas
	results = list(/datum/reagent/magic/midas = 30)
	required_reagents = list(/datum/reagent/liquidgibs = 30, /datum/reagent/gold = 30, /datum/reagent/magic = 30)

/datum/chemical_reaction/midas_replicate
	name = "Draught of Midas"
	id = /datum/reagent/magic/midas
	results = list(/datum/reagent/magic/midas = 2)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/magic/midas = 1)

/datum/chemical_reaction/lc
	name = "Lively Concotion"
	id = /datum/reagent/magic/lc
	results = list(/datum/reagent/magic/lc = 1)
	required_reagents = list(/datum/reagent/magic/lc = 100, /datum/reagent/magic = 100)
	var/initialized = FALSE

/datum/chemical_reaction/lc/proc/generate_random_elements()
	if (initialized)
		return
	initialized = TRUE
	required_reagents = list( /datum/reagent/magic = 1 )
	for(var/i in 1 to 3)
		var/list/picked_reagent = pick( \
			/datum/reagent/water, \
			/datum/reagent/consumable/ice, \
			/datum/reagent/consumable/coffee, \
			/datum/reagent/consumable/cream, \
			/datum/reagent/consumable/tea, \
			/datum/reagent/consumable/icetea, \
			/datum/reagent/consumable/space_cola, \
			/datum/reagent/consumable/spacemountainwind, \
			/datum/reagent/consumable/dr_gibb, \
			/datum/reagent/consumable/space_up, \
			/datum/reagent/consumable/tonic, \
			/datum/reagent/consumable/sodawater, \
			/datum/reagent/consumable/lemon_lime, \
			/datum/reagent/consumable/pwr_game, \
			/datum/reagent/consumable/shamblers, \
			/datum/reagent/consumable/sugar, \
			/datum/reagent/consumable/orangejuice, \
			/datum/reagent/consumable/grenadine, \
			/datum/reagent/consumable/limejuice, \
			/datum/reagent/consumable/tomatojuice, \
			/datum/reagent/consumable/lemonjuice, \
			/datum/reagent/consumable/menthol, \
			/datum/reagent/consumable/ethanol/beer, \
			/datum/reagent/consumable/ethanol/kahlua, \
			/datum/reagent/consumable/ethanol/whiskey, \
			/datum/reagent/consumable/ethanol/wine, \
			/datum/reagent/consumable/ethanol/vodka, \
			/datum/reagent/consumable/ethanol/gin, \
			/datum/reagent/consumable/ethanol/rum, \
			/datum/reagent/consumable/ethanol/tequila, \
			/datum/reagent/consumable/ethanol/vermouth, \
			/datum/reagent/consumable/ethanol/cognac, \
			/datum/reagent/consumable/ethanol/ale, \
			/datum/reagent/consumable/ethanol/absinthe, \
			/datum/reagent/consumable/ethanol/hcider, \
			/datum/reagent/consumable/ethanol/creme_de_menthe, \
			/datum/reagent/consumable/ethanol/creme_de_cacao, \
			/datum/reagent/consumable/ethanol/triple_sec, \
			/datum/reagent/consumable/ethanol/sake, \
			/datum/reagent/consumable/ethanol/applejack, \
			/datum/reagent/aluminium, \
			/datum/reagent/bromine, \
			/datum/reagent/carbon, \
			/datum/reagent/chlorine, \
			/datum/reagent/copper, \
			/datum/reagent/consumable/ethanol, \
			/datum/reagent/fluorine, \
			/datum/reagent/hydrogen, \
			/datum/reagent/iodine, \
			/datum/reagent/iron, \
			/datum/reagent/lithium, \
			/datum/reagent/mercury, \
			/datum/reagent/nitrogen, \
			/datum/reagent/oxygen, \
			/datum/reagent/phosphorus, \
			/datum/reagent/potassium, \
			/datum/reagent/uranium/radium, \
			/datum/reagent/silicon, \
			/datum/reagent/silver, \
			/datum/reagent/sodium, \
			/datum/reagent/stable_plasma, \
			/datum/reagent/consumable/sugar, \
			/datum/reagent/sulfur, \
			/datum/reagent/toxin/acid, \
			/datum/reagent/water, \
			/datum/reagent/fuel, \
			/datum/reagent/acetone, \
			/datum/reagent/ammonia, \
			/datum/reagent/ash, \
			/datum/reagent/diethylamine, \
			/datum/reagent/oil, \
			/datum/reagent/saltpetre \
		)
		required_reagents |= picked_reagent