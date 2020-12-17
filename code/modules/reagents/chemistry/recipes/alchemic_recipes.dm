
/datum/chemical_reaction/levitatium
	name = "Levitatium"
	id = /datum/reagent/magic/levitatium
	results = list(/datum/reagent/magic/levitatium = 2)
	required_reagents = list(/datum/reagent/magic/berserkium = 1, /datum/reagent/oil = 1)

/datum/chemical_reaction/berserkium
	name = "Berserkium"
	id = /datum/reagent/magic/berserkium
	results = list(/datum/reagent/magic/berserkium = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/magic = 1)

/datum/chemical_reaction/invisibilium
	name = "Invisibilium"
	id = /datum/reagent/magic/invisibilium
	results = list(/datum/reagent/magic/invisibilium = 2)
	required_reagents = list(/datum/reagent/magic/berserkium = 1, /datum/reagent/blood = 1)

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
	results = list(/datum/reagent/magic/teleportarium = 3)
	required_reagents = list(/datum/reagent/bluespace = 1, /datum/reagent/magic = 1)

/datum/chemical_reaction/teleportarium_u
	name = "Unstable Teleportarium"
	id = /datum/reagent/magic/teleportarium/unstable
	results = list(/datum/reagent/magic/teleportarium/unstable = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/magic/teleportarium = 1)

