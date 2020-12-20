//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle

/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small potion."
	icon_state = "bottle"
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30
	fill_icon_thresholds = list(0, 10, 30, 50, 70)

/obj/item/reagent_containers/glass/bottle/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_icon()

/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "epinephrine potion"
	desc = "A small potion. Contains epinephrine - used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30)

/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin potion"
	desc = "A small potion of toxins. Do not drink, it is poisonous."
	list_reagents = list(/datum/reagent/toxin = 30)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "cyanide potion"
	desc = "A small potion of cyanide. Bitter almonds?"
	list_reagents = list(/datum/reagent/toxin/cyanide = 30)

/obj/item/reagent_containers/glass/bottle/spewium
	name = "spewium potion"
	desc = "A small potion of spewium."
	list_reagents = list(/datum/reagent/toxin/spewium = 30)

/obj/item/reagent_containers/glass/bottle/morphine
	name = "morphine potion"
	desc = "A small potion of morphine."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list(/datum/reagent/medicine/morphine = 30)

/obj/item/reagent_containers/glass/bottle/chloralhydrate
	name = "chloral hydrate potion"
	desc = "A small potion of Choral Hydrate. Mickey's Favorite!"
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 15)

/obj/item/reagent_containers/glass/bottle/mannitol
	name = "mannitol potion"
	desc = "A small potion of Mannitol. Useful for healing brain damage."
	list_reagents = list(/datum/reagent/medicine/mannitol = 30)

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "charcoal potion"
	desc = "A small potion of charcoal, which removes toxins and other chemicals from the bloodstream."
	list_reagents = list(/datum/reagent/medicine/charcoal = 30)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen potion"
	desc = "A small potion of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	list_reagents = list(/datum/reagent/toxin/mutagen = 30)

/obj/item/reagent_containers/glass/bottle/plasma
	name = "liquid plasma potion"
	desc = "A small potion of liquid plasma. Extremely toxic and reacts with micro-organisms inside blood."
	list_reagents = list(/datum/reagent/toxin/plasma = 30)

/obj/item/reagent_containers/glass/bottle/synaptizine
	name = "synaptizine potion"
	desc = "A small potion of synaptizine."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde potion"
	desc = "A small potion of formaldehyde."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/cryostylane
	name = "cryostylane potion"
	desc = "A small potion of cryostylane. It feels cold to the touch"
	list_reagents = list(/datum/reagent/cryostylane = 30)

/obj/item/reagent_containers/glass/bottle/concentrated_bz
	name = "concentrated BZ potion"
	desc = "A small potion of concentrated BZ"
	list_reagents = list(/datum/reagent/concentrated_bz = 30)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia potion"
	desc = "A small potion of ammonia."
	list_reagents = list(/datum/reagent/ammonia = 30)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine potion"
	desc = "A small potion of diethylamine."
	list_reagents = list(/datum/reagent/diethylamine = 30)

/obj/item/reagent_containers/glass/bottle/facid
	name = "Fluorosulfuric Acid potion"
	desc = "A small potion. Contains a small amount of fluorosulfuric acid."
	list_reagents = list(/datum/reagent/toxin/acid/fluacid = 30)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine potion"
	desc = "A small potion. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 30)

/obj/item/reagent_containers/glass/bottle/viralbase
	name = "Highly potent Viral Base potion"
	desc = "A small potion. Contains a trace amount of a substance found by scientists that can be used to create extremely advanced diseases once exposed to uranium."
	list_reagents = list(/datum/reagent/consumable/virus_food/viralbase = 1)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin potion"
	desc = "A small potion. Contains hot sauce."
	list_reagents = list(/datum/reagent/consumable/capsaicin = 30)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil potion"
	desc = "A small potion. Contains cold sauce."
	list_reagents = list(/datum/reagent/consumable/frostoil = 30)

/obj/item/reagent_containers/glass/bottle/traitor
	name = "syndicate potion"
	desc = "A small potion. Contains a random nasty chemical."
	icon = 'icons/obj/chemical.dmi'
	var/extra_reagent = null

/obj/item/reagent_containers/glass/bottle/traitor/Initialize()
	. = ..()
	extra_reagent = pick(/datum/reagent/toxin/polonium, /datum/reagent/toxin/histamine, /datum/reagent/toxin/formaldehyde, /datum/reagent/toxin/venom, /datum/reagent/toxin/fentanyl, /datum/reagent/toxin/cyanide)
	reagents.add_reagent(extra_reagent, 3)

/obj/item/reagent_containers/glass/bottle/polonium
	name = "polonium potion"
	desc = "A small potion. Contains Polonium."
	list_reagents = list(/datum/reagent/toxin/polonium = 30)

/obj/item/reagent_containers/glass/bottle/magillitis
	name = "magillitis potion"
	desc = "A small potion. Contains a serum known only as 'magillitis'."
	list_reagents = list(/datum/reagent/magillitis = 5)

/obj/item/reagent_containers/glass/bottle/venom
	name = "venom potion"
	desc = "A small potion. Contains Venom."
	list_reagents = list(/datum/reagent/toxin/venom = 30)

/obj/item/reagent_containers/glass/bottle/fentanyl
	name = "fentanyl potion"
	desc = "A small potion. Contains Fentanyl."
	list_reagents = list(/datum/reagent/toxin/fentanyl = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde potion"
	desc = "A small potion. Contains Formaldehyde."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/initropidril
	name = "initropidril potion"
	desc = "A small potion. Contains initropidril."
	list_reagents = list(/datum/reagent/toxin/initropidril = 30)

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "pancuronium potion"
	desc = "A small potion. Contains pancuronium."
	list_reagents = list(/datum/reagent/toxin/pancuronium = 30)

/obj/item/reagent_containers/glass/bottle/sodium_thiopental
	name = "sodium thiopental potion"
	desc = "A small potion. Contains sodium thiopental."
	list_reagents = list(/datum/reagent/toxin/sodium_thiopental = 30)

/obj/item/reagent_containers/glass/bottle/coniine
	name = "coniine potion"
	desc = "A small potion. Contains coniine."
	list_reagents = list(/datum/reagent/toxin/coniine = 30)

/obj/item/reagent_containers/glass/bottle/curare
	name = "curare potion"
	desc = "A small potion. Contains curare."
	list_reagents = list(/datum/reagent/toxin/curare = 30)

/obj/item/reagent_containers/glass/bottle/amanitin
	name = "amanitin potion"
	desc = "A small potion. Contains amanitin."
	list_reagents = list(/datum/reagent/toxin/amanitin = 30)

/obj/item/reagent_containers/glass/bottle/histamine
	name = "histamine potion"
	desc = "A small potion. Contains Histamine."
	list_reagents = list(/datum/reagent/toxin/histamine = 30)

/obj/item/reagent_containers/glass/bottle/diphenhydramine
	name = "antihistamine potion"
	desc = "A small potion of diphenhydramine."
	list_reagents = list(/datum/reagent/medicine/diphenhydramine = 30)

/obj/item/reagent_containers/glass/bottle/potass_iodide
	name = "anti-radiation potion"
	desc = "A small potion of potassium iodide."
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 30)

/obj/item/reagent_containers/glass/bottle/salglu_solution
	name = "saline-glucose solution potion"
	desc = "A small potion of saline-glucose solution."
	icon_state = "bottle1"
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 30)

/obj/item/reagent_containers/glass/bottle/atropine
	name = "atropine potion"
	desc = "A small potion of atropine."
	list_reagents = list(/datum/reagent/medicine/atropine = 30)

/obj/item/reagent_containers/glass/bottle/romerol
	name = "romerol potion"
	desc = "A small potion of Romerol. The REAL zombie powder."
	list_reagents = list(/datum/reagent/romerol = 30)

/obj/item/reagent_containers/glass/bottle/random_virus
	name = "Experimental disease culture potion"
	desc = "A small potion. Contains an untested viral culture in synthblood medium."
	spawned_disease = /datum/disease/advance/random

/obj/item/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture potion"
	desc = "A small potion. Contains H0NI<42 virion culture in synthblood medium."
	spawned_disease = /datum/disease/pierrot_throat

/obj/item/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture potion"
	desc = "A small potion. Contains XY-rhinovirus culture in synthblood medium."
	spawned_disease = /datum/disease/advance/cold

/obj/item/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture potion"
	desc = "A small potion. Contains H13N1 flu virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/flu

/obj/item/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture potion"
	desc = "A small potion. Contains a retrovirus culture in a synthblood medium."
	spawned_disease = /datum/disease/dna_retrovirus

/obj/item/reagent_containers/glass/bottle/gbs
	name = "GBS culture potion"
	desc = "A small potion. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/gbs

/obj/item/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture potion"
	desc = "A small potion. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	spawned_disease = /datum/disease/fake_gbs

/obj/item/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture potion"
	desc = "A small potion. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon_state = "bottle3"
	spawned_disease = /datum/disease/brainrot

/obj/item/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture potion"
	desc = "A small potion. Contains a small dosage of Fukkos Miracos."
	spawned_disease = /datum/disease/magnitis

/obj/item/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture potion"
	desc = "A small potion. Contains a sample of Rincewindus Vulgaris."
	spawned_disease = /datum/disease/wizarditis

/obj/item/reagent_containers/glass/bottle/anxiety
	name = "Severe Anxiety culture potion"
	desc = "A small potion. Contains a sample of Lepidopticides."
	spawned_disease = /datum/disease/anxiety

/obj/item/reagent_containers/glass/bottle/beesease
	name = "Beesease culture potion"
	desc = "A small potion. Contains a sample of invasive Apidae."
	spawned_disease = /datum/disease/beesease

/obj/item/reagent_containers/glass/bottle/fluspanish
	name = "Spanish flu culture potion"
	desc = "A small potion. Contains a sample of Inquisitius."
	spawned_disease = /datum/disease/fluspanish

/obj/item/reagent_containers/glass/bottle/tuberculosis
	name = "Fungal Tuberculosis culture potion"
	desc = "A small potion. Contains a sample of Fungal Tubercle bacillus."
	spawned_disease = /datum/disease/tuberculosis

/obj/item/reagent_containers/glass/bottle/tuberculosiscure
	name = "BVAK potion"
	desc = "A small potion containing Bio Virus Antidote Kit."
	list_reagents = list(/datum/reagent/medicine/atropine = 5, /datum/reagent/medicine/epinephrine = 5, /datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/spaceacillin = 10)

/obj/item/reagent_containers/glass/bottle/necropolis_seed
	name = "bowl of blood"
	desc = "A clay bowl containing a fledgling Necropolis, preserved in blood. A robust virologist may be able to unlock its full potential..."
	icon_state = "mortar"
	spawned_disease = /datum/disease/advance/random/necropolis

/obj/item/reagent_containers/glass/bottle/felinid
	name = "Nano-Feline Assimilative Toxoplasmosis culture potion"
	desc = "A small potion. Contains a sample of nano-feline toxoplasma in synthblood medium"
	spawned_disease = /datum/disease/transformation/felinid/contagious

//Oldstation.dmm chemical storage potions

/obj/item/reagent_containers/glass/bottle/hydrogen
	name = "hydrogen potion"
	list_reagents = list(/datum/reagent/hydrogen = 30)

/obj/item/reagent_containers/glass/bottle/lithium
	name = "lithium potion"
	list_reagents = list(/datum/reagent/lithium = 30)

/obj/item/reagent_containers/glass/bottle/carbon
	name = "carbon potion"
	list_reagents = list(/datum/reagent/carbon = 30)

/obj/item/reagent_containers/glass/bottle/nitrogen
	name = "nitrogen potion"
	list_reagents = list(/datum/reagent/nitrogen = 30)

/obj/item/reagent_containers/glass/bottle/oxygen
	name = "oxygen potion"
	list_reagents = list(/datum/reagent/oxygen = 30)

/obj/item/reagent_containers/glass/bottle/fluorine
	name = "fluorine potion"
	list_reagents = list(/datum/reagent/fluorine = 30)

/obj/item/reagent_containers/glass/bottle/sodium
	name = "sodium potion"
	list_reagents = list(/datum/reagent/sodium = 30)

/obj/item/reagent_containers/glass/bottle/aluminium
	name = "aluminium potion"
	list_reagents = list(/datum/reagent/aluminium = 30)

/obj/item/reagent_containers/glass/bottle/silicon
	name = "silicon potion"
	list_reagents = list(/datum/reagent/silicon = 30)

/obj/item/reagent_containers/glass/bottle/phosphorus
	name = "phosphorus potion"
	list_reagents = list(/datum/reagent/phosphorus = 30)

/obj/item/reagent_containers/glass/bottle/sulfur
	name = "sulfur potion"
	list_reagents = list(/datum/reagent/sulfur = 30)

/obj/item/reagent_containers/glass/bottle/chlorine
	name = "chlorine potion"
	list_reagents = list(/datum/reagent/chlorine = 30)

/obj/item/reagent_containers/glass/bottle/potassium
	name = "potassium potion"
	list_reagents = list(/datum/reagent/potassium = 30)

/obj/item/reagent_containers/glass/bottle/iron
	name = "iron potion"
	list_reagents = list(/datum/reagent/iron = 30)

/obj/item/reagent_containers/glass/bottle/copper
	name = "copper potion"
	list_reagents = list(/datum/reagent/copper = 30)

/obj/item/reagent_containers/glass/bottle/mercury
	name = "mercury potion"
	list_reagents = list(/datum/reagent/mercury = 30)

/obj/item/reagent_containers/glass/bottle/radium
	name = "radium potion"
	list_reagents = list(/datum/reagent/uranium/radium = 30)

/obj/item/reagent_containers/glass/bottle/water
	name = "water potion"
	list_reagents = list(/datum/reagent/water = 30)

/obj/item/reagent_containers/glass/bottle/ethanol
	name = "ethanol potion"
	list_reagents = list(/datum/reagent/consumable/ethanol = 30)

/obj/item/reagent_containers/glass/bottle/sugar
	name = "sugar potion"
	list_reagents = list(/datum/reagent/consumable/sugar = 30)

/obj/item/reagent_containers/glass/bottle/sacid
	name = "sulphuric acid potion"
	list_reagents = list(/datum/reagent/toxin/acid = 30)

/obj/item/reagent_containers/glass/bottle/welding_fuel
	name = "welding fuel potion"
	list_reagents = list(/datum/reagent/fuel = 30)

/obj/item/reagent_containers/glass/bottle/silver
	name = "silver potion"
	list_reagents = list(/datum/reagent/silver = 30)

/obj/item/reagent_containers/glass/bottle/iodine
	name = "iodine potion"
	list_reagents = list(/datum/reagent/iodine = 30)

/obj/item/reagent_containers/glass/bottle/bromine
	name = "bromine potion"
	list_reagents = list(/datum/reagent/bromine = 30)

//Alchemy
/obj/item/reagent_containers/glass/bottle/alchemy
	name = "magic essence potion"
	list_reagents = list(/datum/reagent/magic = 30)

/obj/item/reagent_containers/glass/bottle/oil
	name = "oil potion"
	list_reagents = list(/datum/reagent/oil = 30)

/obj/item/reagent_containers/glass/bottle/blood
	name = "blood potion"
	list_reagents = list(/datum/reagent/blood = 30)

/obj/item/reagent_containers/glass/bottle/bluespace
	name = "bluespace dust potion"
	list_reagents = list(/datum/reagent/bluespace = 30)

//potion potions
/obj/item/reagent_containers/glass/bottle/lc
	name = "lively concotion potion"
	desc = "A powerful healing concotion that heals when injested or in contact with the skin."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	volume = 50
	list_reagents = list(/datum/reagent/magic/lc = 50)

/obj/item/reagent_containers/glass/bottle/levitatium
	name = "levitatium potion"
	desc = "Defensive potion that causes the user to levitate."
	list_reagents = list(/datum/reagent/magic/levitatium = 30)

/obj/item/reagent_containers/glass/bottle/acceleratium
	name = "acceleratium potion"
	desc = "Defensive potion that causes the user to move faster."
	list_reagents = list(/datum/reagent/magic/acceleratium = 30)

/obj/item/reagent_containers/glass/bottle/hastium
	name = "hastium potion"
	desc = "Defensive potion mix that causes the user to levitate and move faster."
	list_reagents = list(/datum/reagent/magic/acceleratium = 15,/datum/reagent/magic/levitatium = 15)

/obj/item/reagent_containers/glass/bottle/berserkium
	name = "berserkium potion"
	desc = "Defensive potion that causes the user to become immune to stuns, but attack nearby people."
	list_reagents = list(/datum/reagent/magic/berserkium = 30)

/obj/item/reagent_containers/glass/bottle/invisibilium
	name = "invisibilium potion"
	desc = "Defensive potion that causes the user to become invisible."
	list_reagents = list(/datum/reagent/magic/invisibilium = 30)

/obj/item/reagent_containers/glass/bottle/polymorphine
	name = "polymorphine potion"
	desc = "Offensive potion that transforms someone into a harmless critter when splashed or injested."
	list_reagents = list(/datum/reagent/magic/polymorphine = 30)

/obj/item/reagent_containers/glass/bottle/polymorphine_u
	name = "unstable polymorphine potion"
	desc = "Offensive potion that transforms someone into a hostile creature when splashed or injested."
	list_reagents = list(/datum/reagent/magic/polymorphine/unstable = 30)

/obj/item/reagent_containers/glass/bottle/polymorphine_c
	name = "chaotic polymorphine potion"
	desc = "Offensive potion that transforms someone into a random creature when splashed or injested."
	list_reagents = list(/datum/reagent/magic/polymorphine/chaotic = 30)

/obj/item/reagent_containers/glass/bottle/teleportarium
	name = "teleportarium potion"
	desc = "Defensive potion that causes the user to teleport forward."
	list_reagents = list(/datum/reagent/magic/teleportarium = 30)

/obj/item/reagent_containers/glass/bottle/teleportarium_u
	name = "unstable teleportarium potion"
	desc = "Offensive potion that teleports someone randomly when splashed or injested."
	list_reagents = list(/datum/reagent/magic/teleportarium/unstable = 30)