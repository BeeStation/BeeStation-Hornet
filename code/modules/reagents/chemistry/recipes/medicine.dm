
/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = /datum/reagent/medicine/leporazine
	results = list(/datum/reagent/medicine/leporazine = 2)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/copper = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = /datum/reagent/medicine/rezadone
	results = list(/datum/reagent/medicine/rezadone = 3)
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 1, /datum/reagent/cryptobiolin = 1, /datum/reagent/copper = 1)

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = /datum/reagent/medicine/spaceacillin
	results = list(/datum/reagent/medicine/spaceacillin = 2)
	required_reagents = list(/datum/reagent/cryptobiolin = 1, /datum/reagent/medicine/epinephrine = 1)

/datum/chemical_reaction/inacusiate
	name = /datum/reagent/medicine/inacusiate
	id = /datum/reagent/medicine/inacusiate
	results = list(/datum/reagent/medicine/inacusiate = 2)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/charcoal = 1)

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = /datum/reagent/medicine/synaptizine
	results = list(/datum/reagent/medicine/synaptizine = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	id = /datum/reagent/medicine/charcoal
	results = list(/datum/reagent/medicine/charcoal = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/sodiumchloride = 1)
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = /datum/reagent/medicine/silver_sulfadiazine
	results = list(/datum/reagent/medicine/silver_sulfadiazine = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/salglu_solution
	name = "Saline-Glucose Solution"
	id = /datum/reagent/medicine/salglu_solution
	results = list(/datum/reagent/medicine/salglu_solution = 3)
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/water = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/mine_salve
	name = "Miner's Salve"
	id = /datum/reagent/medicine/mine_salve
	results = list(/datum/reagent/medicine/mine_salve = 3)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/water = 1, /datum/reagent/iron = 1)

/datum/chemical_reaction/mine_salve2
	name = "Miner's Salve"
	id = /datum/reagent/medicine/mine_salve
	results = list(/datum/reagent/medicine/mine_salve = 15)
	required_reagents = list(/datum/reagent/toxin/plasma = 5, /datum/reagent/iron = 5, /datum/reagent/consumable/sugar = 1) // A sheet of plasma, a twinkie and a sheet of metal makes four of these

/datum/chemical_reaction/synthflesh
	name = "Synthflesh"
	id = /datum/reagent/medicine/synthflesh
	results = list(/datum/reagent/medicine/synthflesh = 4)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/carbon = 1, /datum/reagent/medicine/styptic_powder = 1, /datum/reagent/medicine/silver_sulfadiazine = 1)

/datum/chemical_reaction/styptic_powder
	name = "Styptic Powder"
	id = /datum/reagent/medicine/styptic_powder
	results = list(/datum/reagent/medicine/styptic_powder = 4)
	required_reagents = list(/datum/reagent/aluminium = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)
	mix_message = "The solution yields an astringent powder."

/datum/chemical_reaction/calomel
	name = "Calomel"
	id = /datum/reagent/medicine/calomel
	results = list(/datum/reagent/medicine/calomel = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/chlorine = 1)
	required_temp = 374

/datum/chemical_reaction/potass_iodide
	name = "Potassium Iodide"
	id = /datum/reagent/medicine/potass_iodide
	results = list(/datum/reagent/medicine/potass_iodide = 2)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/iodine = 1)

/datum/chemical_reaction/pen_acid
	name = "Pentetic Acid"
	id = /datum/reagent/medicine/pen_acid
	results = list(/datum/reagent/medicine/pen_acid = 6)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/chlorine = 1, /datum/reagent/ammonia = 1, /datum/reagent/toxin/formaldehyde = 1, /datum/reagent/sodium = 1, /datum/reagent/toxin/cyanide = 1)

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	id = /datum/reagent/medicine/sal_acid
	results = list(/datum/reagent/medicine/sal_acid = 5)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/phenol = 1, /datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/oxandrolone
	name = "Oxandrolone"
	id = /datum/reagent/medicine/oxandrolone
	results = list(/datum/reagent/medicine/oxandrolone = 6)
	required_reagents = list(/datum/reagent/carbon = 3, /datum/reagent/phenol = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	id = /datum/reagent/medicine/salbutamol
	results = list(/datum/reagent/medicine/salbutamol = 5)
	required_reagents = list(/datum/reagent/medicine/sal_acid = 1, /datum/reagent/lithium = 1, /datum/reagent/aluminium = 1, /datum/reagent/bromine = 1, /datum/reagent/ammonia = 1)

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = /datum/reagent/medicine/perfluorodecalin
	results = list(/datum/reagent/medicine/perfluorodecalin = 3)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, /datum/reagent/oil = 1)
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."

/datum/chemical_reaction/ephedrine
	name = "Ephedrine"
	id = /datum/reagent/medicine/ephedrine
	results = list(/datum/reagent/medicine/ephedrine = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/oil = 1, /datum/reagent/hydrogen = 1, /datum/reagent/diethylamine = 1)
	mix_message = "The solution fizzes and gives off toxic fumes."

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	id = /datum/reagent/medicine/diphenhydramine
	results = list(/datum/reagent/medicine/diphenhydramine = 4)
	required_reagents = list(/datum/reagent/oil = 1, /datum/reagent/carbon = 1, /datum/reagent/bromine = 1, /datum/reagent/diethylamine = 1, /datum/reagent/consumable/ethanol = 1)
	mix_message = "The mixture dries into a pale blue powder."

/datum/chemical_reaction/oculine
	name = "Oculine"
	id = /datum/reagent/medicine/oculine
	results = list(/datum/reagent/medicine/oculine = 3)
	required_reagents = list(/datum/reagent/medicine/charcoal = 1, /datum/reagent/carbon = 1, /datum/reagent/hydrogen = 1)
	mix_message = "The mixture sputters loudly and becomes a pale pink color."

/datum/chemical_reaction/atropine
	name = "Atropine"
	id = /datum/reagent/medicine/atropine
	results = list(/datum/reagent/medicine/atropine = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/phenol = 1, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/epinephrine
	name = "Epinephrine"
	id = /datum/reagent/medicine/epinephrine
	results = list(/datum/reagent/medicine/epinephrine = 6)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/diethylamine = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1, /datum/reagent/hydrogen = 1)

/datum/chemical_reaction/strange_reagent
	name = "Strange Reagent"
	id = /datum/reagent/medicine/strange_reagent
	results = list(/datum/reagent/medicine/strange_reagent = 3)
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/water/holywater = 1, /datum/reagent/toxin/mutagen = 1)

/datum/chemical_reaction/mannitol
	name = "Mannitol"
	id = /datum/reagent/medicine/mannitol
	results = list(/datum/reagent/medicine/mannitol = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/hydrogen = 1, /datum/reagent/water = 1)
	mix_message = "The solution slightly bubbles, becoming thicker."

/datum/chemical_reaction/neurine
	name = "Neurine"
	id = /datum/reagent/medicine/neurine
	results = list(/datum/reagent/medicine/neurine = 3)
	required_reagents = list(/datum/reagent/medicine/mannitol = 1, /datum/reagent/acetone = 1, /datum/reagent/oxygen = 1)

/datum/chemical_reaction/mutadone
	name = "Mutadone"
	id = /datum/reagent/medicine/mutadone
	results = list(/datum/reagent/medicine/mutadone = 3)
	required_reagents = list(/datum/reagent/toxin/mutagen = 1, /datum/reagent/acetone = 1, /datum/reagent/bromine = 1)

/datum/chemical_reaction/antihol
	name = /datum/reagent/medicine/antihol
	id = /datum/reagent/medicine/antihol
	results = list(/datum/reagent/medicine/antihol = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/charcoal = 1, /datum/reagent/copper = 1)

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = /datum/reagent/medicine/cryoxadone
	results = list(/datum/reagent/medicine/cryoxadone = 3)
	required_reagents = list(/datum/reagent/stable_plasma = 1, /datum/reagent/acetone = 1, /datum/reagent/toxin/mutagen = 1)

/datum/chemical_reaction/pyroxadone
	name = "Pyroxadone"
	id = /datum/reagent/medicine/pyroxadone
	results = list(/datum/reagent/medicine/pyroxadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/toxin/slimejelly = 1)

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = /datum/reagent/medicine/clonexadone
	results = list(/datum/reagent/medicine/clonexadone = 2)
	required_reagents = list(/datum/reagent/medicine/cryoxadone = 1, /datum/reagent/sodium = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)

/datum/chemical_reaction/haloperidol
	name = "Haloperidol"
	id = /datum/reagent/medicine/haloperidol
	results = list(/datum/reagent/medicine/haloperidol = 5)
	required_reagents = list(/datum/reagent/chlorine = 1, /datum/reagent/fluorine = 1, /datum/reagent/aluminium = 1, /datum/reagent/medicine/potass_iodide = 1, /datum/reagent/oil = 1)

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = /datum/reagent/medicine/bicaridine
	results = list(/datum/reagent/medicine/bicaridine = 3)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = "dexalin"
	results = list(/datum/reagent/medicine/dexalin = 5)
	required_reagents = list(/datum/reagent/oxygen = 5)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	results = list(/datum/reagent/medicine/dexalinp = 3)
	required_reagents = list(/datum/reagent/medicine/dexalin = 1, /datum/reagent/carbon = 1, /datum/reagent/iron = 1)

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = /datum/reagent/medicine/kelotane
	results = list(/datum/reagent/medicine/kelotane = 2)
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/silicon = 1)

/datum/chemical_reaction/antitoxin
	name = "Antitoxin"
	id = /datum/reagent/medicine/antitoxin
	results = list(/datum/reagent/medicine/antitoxin = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/silicon = 1, /datum/reagent/potassium = 1)

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = /datum/reagent/medicine/tricordrazine
	results = list(/datum/reagent/medicine/tricordrazine = 3)
	required_reagents = list(/datum/reagent/medicine/bicaridine = 1, /datum/reagent/medicine/kelotane = 1, /datum/reagent/medicine/antitoxin = 1)

/datum/chemical_reaction/regen_jelly
	name = "Regenerative Jelly"
	id = /datum/reagent/medicine/regen_jelly
	results = list(/datum/reagent/medicine/regen_jelly = 2)
	required_reagents = list(/datum/reagent/medicine/tricordrazine = 1, /datum/reagent/toxin/slimejelly = 1)

/datum/chemical_reaction/corazone
	name = "Corazone"
	id = /datum/reagent/medicine/corazone
	results = list(/datum/reagent/medicine/corazone = 3)
	required_reagents = list(/datum/reagent/phenol = 2, /datum/reagent/lithium = 1)

/datum/chemical_reaction/morphine
	name = "Morphine"
	id = /datum/reagent/medicine/morphine
	results = list(/datum/reagent/medicine/morphine = 2)
	required_reagents = list(/datum/reagent/carbon = 2, /datum/reagent/hydrogen = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1)
	required_temp = 480

/datum/chemical_reaction/modafinil
	name = "Modafinil"
	id = /datum/reagent/medicine/modafinil
	results = list(/datum/reagent/medicine/modafinil = 5)
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/ammonia = 1, /datum/reagent/phenol = 1, /datum/reagent/acetone = 1, /datum/reagent/toxin/acid = 1)
	required_catalysts = list(/datum/reagent/bromine = 1) // as close to the real world synthesis as possible

/datum/chemical_reaction/psicodine
	name = "Psicodine"
	id = /datum/reagent/medicine/psicodine
	results = list(/datum/reagent/medicine/psicodine = 5)
	required_reagents = list( /datum/reagent/medicine/mannitol = 2, /datum/reagent/water = 2, /datum/reagent/impedrezene = 1)

/datum/chemical_reaction/system_cleaner
	name = "System Cleaner"
	id = /datum/reagent/medicine/system_cleaner
	results = list(/datum/reagent/medicine/system_cleaner = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 1, /datum/reagent/phenol = 2, /datum/reagent/potassium = 1)

/datum/chemical_reaction/liquid_solder
	name = "Liquid Solder"
	id = /datum/reagent/medicine/liquid_solder
	results = list(/datum/reagent/medicine/liquid_solder = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/copper = 1, /datum/reagent/silver = 1)
	required_temp = 370
	mix_message = "The mixture becomes a metallic slurry."

/datum/chemical_reaction/carthatoline
	name = "Carthatoline"
	id = "carthatoline"
	results = list(/datum/reagent/medicine/carthatoline = 3)
	required_reagents = list(/datum/reagent/medicine/antitoxin = 1, /datum/reagent/carbon = 2)
	required_catalysts = list(/datum/reagent/toxin/plasma = 1)

/datum/chemical_reaction/hepanephrodaxon
	name = "Hepanephrodaxon"
	id = "hepanephrodaxon"
	results = list(/datum/reagent/medicine/hepanephrodaxon = 5)
	required_reagents = list(/datum/reagent/medicine/carthatoline = 2, /datum/reagent/carbon = 2, /datum/reagent/lithium = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)
