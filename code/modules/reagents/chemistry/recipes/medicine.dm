
/datum/chemical_reaction/leporazine
	name = "Leporazine"
	results = list(/datum/reagent/medicine/leporazine = 2)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/copper = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	results = list(/datum/reagent/medicine/rezadone = 3)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 1, /datum/reagent/cryptobiolin = 1, /datum/reagent/copper = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_CLONE

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	results = list(/datum/reagent/medicine/spaceacillin = 2)
	required_reagents = list(/datum/reagent/cryptobiolin = 1, /datum/reagent/medicine/epinephrine = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/inacusiate
	name = /datum/reagent/medicine/inacusiate
	results = list(/datum/reagent/medicine/inacusiate = 2)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/charcoal = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	results = list(/datum/reagent/medicine/synaptizine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	results = list(/datum/reagent/medicine/charcoal = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/sodiumchloride = 1)
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	results = list(/datum/reagent/medicine/silver_sulfadiazine = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BURN

/datum/chemical_reaction/salglu_solution
	name = "Saline-Glucose Solution"
	results = list(/datum/reagent/medicine/salglu_solution = 3)
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/water = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_ORGAN | REACTION_TAG_OTHER

/datum/chemical_reaction/mine_salve
	name = "Miner's Salve"
	results = list(/datum/reagent/medicine/mine_salve = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/water = 1, /datum/reagent/iron = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/mine_salve2
	name = "Miner's Salve"
	results = list(/datum/reagent/medicine/mine_salve = 15)
	required_reagents = list(/datum/reagent/toxin/plasma = 5, /datum/reagent/iron = 5, /datum/reagent/consumable/sugar = 1) // A sheet of plasma, a twinkie and a sheet of metal makes four of these
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN

/datum/chemical_reaction/synthflesh
	name = "Synthflesh"
	results = list(/datum/reagent/medicine/synthflesh = 4)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/styptic_powder = 1, /datum/reagent/medicine/silver_sulfadiazine = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_OTHER

/datum/chemical_reaction/styptic_powder
	name = "Styptic Powder"
	results = list(/datum/reagent/medicine/styptic_powder = 4)
	required_reagents = list(/datum/reagent/aluminium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)
	mix_message = "The solution yields an astringent powder."
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE

/datum/chemical_reaction/calomel
	name = "Calomel"
	results = list(/datum/reagent/medicine/calomel = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/chlorine = 1)
	required_temp = 374
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/potass_iodide
	name = "Potassium Iodide"
	results = list(/datum/reagent/medicine/potass_iodide = 2)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/iodine = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/pen_acid
	name = "Pentetic Acid"
	results = list(/datum/reagent/medicine/pen_acid = 6)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/chlorine = 1, /datum/reagent/ammonia = 1, /datum/reagent/toxin/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/toxin/cyanide = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	results = list(/datum/reagent/medicine/sal_acid = 5)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/phenol = 1, /datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE

/datum/chemical_reaction/oxandrolone
	name = "Oxandrolone"
	results = list(/datum/reagent/medicine/oxandrolone = 6)
	required_reagents = list(/datum/reagent/carbon = 3, /datum/reagent/phenol = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BURN

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	results = list(/datum/reagent/medicine/salbutamol = 5)
	required_reagents = list(/datum/reagent/medicine/sal_acid = 1, /datum/reagent/lithium = 1, /datum/reagent/aluminium = 1, /datum/reagent/bromine = 1, /datum/reagent/ammonia = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OXY

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	results = list(/datum/reagent/medicine/perfluorodecalin = 3)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, /datum/reagent/oil = 1)
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OXY | REACTION_TAG_ORGAN | REACTION_TAG_TOXIN

/datum/chemical_reaction/ephedrine
	name = "Ephedrine"
	results = list(/datum/reagent/medicine/ephedrine = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/oil = 1, /datum/reagent/hydrogen = 1, /datum/reagent/diethylamine = 1)
	mix_message = "The solution fizzes and gives off toxic fumes."
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	results = list(/datum/reagent/medicine/diphenhydramine = 4)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/carbon = 1, /datum/reagent/bromine = 1, /datum/reagent/diethylamine = 1, /datum/reagent/consumable/ethanol = 1)
	mix_message = "The mixture dries into a pale blue powder."
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/oculine
	name = "Oculine"
	results = list(/datum/reagent/medicine/oculine = 3)
	required_reagents = list(/datum/reagent/medicine/charcoal = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	mix_message = "The mixture sputters loudly and becomes a pale pink color."
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/atropine
	name = "Atropine"
	results = list(/datum/reagent/medicine/atropine = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/phenol = 1, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/epinephrine
	name = "Epinephrine"
	results = list(/datum/reagent/medicine/epinephrine = 6)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1, /datum/reagent/hydrogen = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_OTHER

/datum/chemical_reaction/strange_reagent
	name = "Strange Reagent"
	results = list(/datum/reagent/medicine/strange_reagent = 3)
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/water/holywater = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/mannitol
	name = "Mannitol"
	results = list(/datum/reagent/medicine/mannitol = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/hydrogen = 1, /datum/reagent/water = 1)
	mix_message = "The solution slightly bubbles, becoming thicker."
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/neurine
	name = "Neurine"
	results = list(/datum/reagent/medicine/neurine = 3)
	required_reagents = list(/datum/reagent/medicine/mannitol = 1, /datum/reagent/acetone = 1, /datum/reagent/oxygen = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_ORGAN | REACTION_TAG_OTHER

/datum/chemical_reaction/mutadone
	name = "Mutadone"
	results = list(/datum/reagent/medicine/mutadone = 3)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/acetone = 1, /datum/reagent/bromine = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/antihol
	name = /datum/reagent/medicine/antihol
	results = list(/datum/reagent/medicine/antihol = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/charcoal = 1, /datum/reagent/copper = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	results = list(/datum/reagent/medicine/cryoxadone = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/acetone = 1, /datum/reagent/toxin/mutagen = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_PLANT | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_CLONE

/datum/chemical_reaction/pyroxadone
	name = "Pyroxadone"
	results = list(/datum/reagent/medicine/pyroxadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/toxin/slimejelly = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY | REACTION_TAG_CLONE

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	results = list(/datum/reagent/medicine/clonexadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/sodium = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_CLONE | REACTION_TAG_OTHER

/datum/chemical_reaction/haloperidol
	name = "Haloperidol"
	results = list(/datum/reagent/medicine/haloperidol = 5)
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/fluorine = 1, /datum/reagent/aluminium = 1, /datum/reagent/medicine/potass_iodide = 1, /datum/reagent/oil = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	results = list(/datum/reagent/medicine/bicaridine = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	results = list(/datum/reagent/medicine/dexalin = 5)
	required_reagents = list(/datum/reagent/oxygen = 5, /datum/reagent/nitrogen = 5)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OXY

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	results = list(/datum/reagent/medicine/dexalinp = 3)
	required_reagents = list(/datum/reagent/medicine/dexalin = 1, /datum/reagent/carbon = 1, /datum/reagent/iron = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OXY

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	results = list(/datum/reagent/medicine/kelotane = 2)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/silicon = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BURN

/datum/chemical_reaction/antitoxin
	name = "Antitoxin"
	results = list(/datum/reagent/medicine/antitoxin = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/silicon = 1, /datum/reagent/potassium = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	results = list(/datum/reagent/medicine/tricordrazine = 3)
	required_reagents = list(/datum/reagent/medicine/bicaridine = 1, /datum/reagent/medicine/kelotane = 1, /datum/reagent/medicine/antitoxin = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE | REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/regen_jelly
	name = "Regenerative Jelly"
	results = list(/datum/reagent/medicine/regen_jelly = 2)
	required_reagents = list(/datum/reagent/medicine/tricordrazine = 1, /datum/reagent/toxin/slimejelly = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_BRUTE |REACTION_TAG_BURN | REACTION_TAG_TOXIN | REACTION_TAG_OXY

/datum/chemical_reaction/corazone
	name = "Corazone"
	results = list(/datum/reagent/medicine/corazone = 3)
	required_reagents = list(/datum/reagent/phenol = 2, /datum/reagent/lithium = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_ORGAN

/datum/chemical_reaction/morphine
	name = "Morphine"
	results = list(/datum/reagent/medicine/morphine = 2)
	required_reagents = list(/datum/reagent/carbon = 2, /datum/reagent/hydrogen = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1)
	required_temp = 480
	reaction_tags = REACTION_TAG_OTHER | REACTION_TAG_DRUG

/datum/chemical_reaction/modafinil
	name = "Modafinil"
	results = list(/datum/reagent/medicine/modafinil = 5)
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/ammonia = 1, /datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/toxin/acid = 1)
	required_catalysts = list(/datum/reagent/bromine = 1) // as close to the real world synthesis as possible
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/psicodine
	name = "Psicodine"
	results = list(/datum/reagent/medicine/psicodine = 5)
	required_reagents = list( /datum/reagent/medicine/mannitol = 2, /datum/reagent/water = 2, /datum/reagent/impedrezene = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/system_cleaner
	name = "System Cleaner"
	results = list(/datum/reagent/medicine/system_cleaner = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 1, /datum/reagent/phenol = 2, /datum/reagent/potassium = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/liquid_solder
	name = "Liquid Solder"
	results = list(/datum/reagent/medicine/liquid_solder = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/copper = 1, /datum/reagent/silver = 1)
	required_temp = 370
	mix_message = "The mixture becomes a metallic slurry."
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_ORGAN | REACTION_TAG_OTHER

/datum/chemical_reaction/carthatoline
	name = "Carthatoline"
	results = list(/datum/reagent/medicine/carthatoline = 3)
	required_reagents = list(/datum/reagent/medicine/antitoxin = 1, /datum/reagent/carbon = 2)
	required_catalysts = list(/datum/reagent/toxin/plasma = 1)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/meclizine
	name = "Meclizine"
	results = list(/datum/reagent/medicine/meclizine = 4)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/chlorine = 1, /datum/reagent/carbon = 2)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN | REACTION_TAG_OTHER

/datum/chemical_reaction/hepanephrodaxon
	name = "Hepanephrodaxon"
	results = list(/datum/reagent/medicine/hepanephrodaxon = 5)
	required_reagents = list(/datum/reagent/medicine/carthatoline = 2, /datum/reagent/carbon = 2, /datum/reagent/lithium = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
	reaction_tags = REACTION_TAG_HEALING | REACTION_TAG_TOXIN | REACTION_TAG_ORGAN

/datum/chemical_reaction/liquidelectricity
	name = "Liquid Electricity"
	results = list(/datum/reagent/consumable/liquidelectricity = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 3, /datum/reagent/consumable/liquidelectricity = 1, /datum/reagent/toxin/plasma = 1)
	mix_message = "The mixture sparks and then subsides."
