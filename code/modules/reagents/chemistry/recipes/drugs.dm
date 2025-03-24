/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	results = list(/datum/reagent/drug/space_drugs = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1)
	reaction_tags = REACTION_TAG_DRUG

/datum/chemical_reaction/crank
	name = "Crank"
	results = list(/datum/reagent/drug/crank = 5)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/ammonia = 1, /datum/reagent/lithium = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/fuel = 1)
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	required_temp = 390
	reaction_tags = REACTION_TAG_DRUG

/datum/chemical_reaction/krokodil
	name = "Krokodil"
	results = list(/datum/reagent/drug/krokodil = 6)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/medicine/morphine = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/potassium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/fuel = 1)
	mix_message = "The mixture dries into a pale blue powder."
	required_temp = 380
	reaction_tags = REACTION_TAG_DRUG

/datum/chemical_reaction/methamphetamine
	name = /datum/reagent/drug/methamphetamine
	results = list(/datum/reagent/drug/methamphetamine = 4)
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/iodine = 1, /datum/reagent/phosphorus = 1, /datum/reagent/hydrogen = 1)
	required_temp = 374
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_DRUG | REACTION_TAG_ORGAN

/datum/chemical_reaction/bath_salts
	name = /datum/reagent/drug/bath_salts
	results = list(/datum/reagent/drug/bath_salts = 7)
	required_reagents = list(/datum/reagent/toxin/bad_food = 1, /datum/reagent/saltpetre = 1, /datum/reagent/consumable/nutriment = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/consumable/enzyme = 1, /datum/reagent/consumable/tea = 1, /datum/reagent/mercury = 1)
	required_temp = 374
	reaction_tags = REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/aranesp
	name = /datum/reagent/drug/aranesp
	results = list(/datum/reagent/drug/aranesp = 3)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 1, /datum/reagent/medicine/atropine = 1, /datum/reagent/medicine/morphine = 1)
	reaction_tags = REACTION_TAG_DRUG | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_DAMAGING

/datum/chemical_reaction/happiness
	name = "Happiness"
	results = list(/datum/reagent/drug/happiness = 4)
	required_reagents = list(/datum/reagent/nitrous_oxide = 2, /datum/reagent/medicine/epinephrine = 1, /datum/reagent/consumable/ethanol = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_DRUG | REACTION_TAG_ORGAN | REACTION_TAG_DAMAGING

/datum/chemical_reaction/ketamine
	name = "Ketamine"
	results = list(/datum/reagent/drug/ketamine = 3)
	required_reagents = list(/datum/reagent/medicine/morphine = 3, /datum/reagent/toxin/chloralhydrate = 3, /datum/reagent/toxin/fentanyl = 3, /datum/reagent/medicine/epinephrine =3)
	required_temp = 370
	reaction_tags = REACTION_TAG_DRUG

/datum/chemical_reaction/nooartrium
	name = "Nooartrium"
	results = list(/datum/reagent/drug/nooartrium = 1)
	required_reagents = list(/datum/reagent/medicine/atropine = 1, /datum/reagent/medicine/morphine = 1, /datum/reagent/teslium = 1, /datum/reagent/medicine/tricordrazine =1)
	required_temp = 575
	reaction_tags = REACTION_TAG_DRUG
