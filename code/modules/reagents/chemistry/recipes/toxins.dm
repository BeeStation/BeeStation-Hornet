
/datum/chemical_reaction/formaldehyde
	name = /datum/reagent/toxin/formaldehyde
	results = list(/datum/reagent/toxin/formaldehyde = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1, /datum/reagent/silver = 1)
	required_temp = 420
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_CHEMICAL | REACTION_TAG_ORGAN | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/fentanyl
	name = /datum/reagent/toxin/fentanyl
	results = list(/datum/reagent/toxin/fentanyl = 1)
	required_reagents = list(/datum/reagent/drug/space_drugs = 1)
	required_temp = 674
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_ORGAN | REACTION_TAG_TOXIN

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	results = list(/datum/reagent/toxin/cyanide = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/ammonia = 1, /datum/reagent/oxygen = 1)
	required_temp = 380
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_OXY | REACTION_TAG_TOXIN

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	results = list(/datum/reagent/toxin/itching_powder = 3)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/ammonia = 1, /datum/reagent/medicine/charcoal = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_BRUTE

/datum/chemical_reaction/facid
	name = "Fluorosulfuric acid"
	results = list(/datum/reagent/toxin/acid/fluacid = 4)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/fluorine = 1, /datum/reagent/hydrogen = 1, /datum/reagent/potassium = 1)
	required_temp = 380
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_PLANT | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN

/datum/chemical_reaction/sulfonal
	name = /datum/reagent/toxin/sulfonal
	results = list(/datum/reagent/toxin/sulfonal = 3)
	required_reagents = list(/datum/reagent/medicine/perfluorodecalin = 1, /datum/reagent/diethylamine = 1, /datum/reagent/sulfur = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/lipolicide
	name = /datum/reagent/toxin/lipolicide
	results = list(/datum/reagent/toxin/lipolicide = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/diethylamine = 1, /datum/reagent/medicine/ephedrine = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	results = list(/datum/reagent/toxin/mutagen = 3)
	required_reagents = list(/datum/reagent/uranium/radium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/chlorine = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_PLANT | REACTION_TAG_OTHER

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	results = list(/datum/reagent/toxin/lexorin = 4)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/sulfonal = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_OXY

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	results = list(/datum/reagent/toxin/chloralhydrate = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 3, /datum/reagent/water = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/whisper_toxin
	name = "Whisper Toxin"
	results = list(/datum/reagent/toxin/whispertoxin = 2)
	required_reagents = list(/datum/reagent/uranium = 2, /datum/reagent/water = 1, /datum/reagent/carbon = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_TOXIN

/datum/chemical_reaction/mutetoxin
	name = "Mute Toxin"
	results = list(/datum/reagent/toxin/mutetoxin = 2)
	required_reagents = list(/datum/reagent/toxin/whispertoxin = 1, /datum/reagent/medicine/earthsblood = 1)
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_TOXIN

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	results = list(/datum/reagent/toxin/zombiepowder = 2)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5, /datum/reagent/medicine/morphine = 5, /datum/reagent/copper = 5)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/ghoulpowder
	name = "Ghoul Powder"
	results = list(/datum/reagent/toxin/ghoulpowder = 2)
	required_reagents = list(/datum/reagent/toxin/zombiepowder = 1, /datum/reagent/medicine/epinephrine = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	results = list(/datum/reagent/toxin/mindbreaker = 5)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/hydrogen = 1, /datum/reagent/medicine/charcoal = 1)
	reaction_tags = REACTION_TAG_DRUG | REACTION_TAG_OTHER

/datum/chemical_reaction/heparin
	name = "Heparin"
	results = list(/datum/reagent/toxin/heparin = 4)
	required_reagents = list(/datum/reagent/toxin/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/chlorine = 1, /datum/reagent/lithium = 1)
	mix_message = span_danger("The mixture thins and loses all color.")
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_OTHER

/datum/chemical_reaction/rotatium
	name = "Rotatium"
	results = list(/datum/reagent/toxin/rotatium = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/teslium = 1, /datum/reagent/toxin/fentanyl = 1)
	mix_message = span_danger("After sparks, fire, and the smell of mindbreaker, the mix is constantly spinning with no stop in sight.")
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/anacea
	name = "Anacea"
	results = list(/datum/reagent/toxin/anacea = 3)
	required_reagents = list(/datum/reagent/medicine/haloperidol = 1, /datum/reagent/impedrezene = 1, /datum/reagent/uranium/radium = 1)
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/mimesbane
	name = "Mime's Bane"
	results = list(/datum/reagent/toxin/mimesbane = 3)
	required_reagents = list(/datum/reagent/uranium/radium = 1, /datum/reagent/toxin/mutetoxin = 1, /datum/reagent/consumable/nothing = 1)
	reaction_tags = REACTION_TAG_OTHER

/datum/chemical_reaction/bonehurtingjuice
	name = "Bone Hurting Juice"
	results = list(/datum/reagent/toxin/bonehurtingjuice = 5)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/toxin/itching_powder = 3, /datum/reagent/consumable/milk = 1)
	mix_message = span_danger("The mixture suddenly becomes clear and looks a lot like water. You feel a strong urge to drink it.")
	reaction_tags = REACTION_TAG_DAMAGING | REACTION_TAG_OTHER
