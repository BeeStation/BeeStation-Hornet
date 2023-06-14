//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle

/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon_state = "bottle"
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30
	fill_icon_thresholds = list(0, 10, 30, 50, 70)

/obj/item/reagent_containers/glass/bottle/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_icon()

/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "epinephrine bottle"
	label_name = "epinephrine"
	desc = "A small bottle. Contains epinephrine - used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30)

/obj/item/reagent_containers/glass/bottle/tricordrazine
	name = "tricordrazine bottle"
	label_name = "tricordrazine"
	desc = "A small bottle of tricordrazine. Used to aid in patient recovery."
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 30)

/obj/item/reagent_containers/glass/bottle/spaceacillin
	name = "spaceacillin bottle"
	label_name = "spaceacillin"
	desc = "A small bottle of spaceacillin. Used to cure some diseases."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 30)

/obj/item/reagent_containers/glass/bottle/antitoxin
	name = "antitoxin bottle"
	label_name = "antitoxin"
	desc = "A small bottle of anti-toxin. Used to treat toxin damage."
	list_reagents = list(/datum/reagent/medicine/antitoxin = 30)

/obj/item/reagent_containers/glass/bottle/toxin/mutagen
	name = "mutagen toxin bottle"
	label_name = "mutagen toxin"
	desc = "A small bottle of mutagen toxins. Do not drink, Might cause unpredictable mutations."
	list_reagents = list(/datum/reagent/toxin/mutagen = 30)

/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	label_name = "toxin"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	list_reagents = list(/datum/reagent/toxin = 30)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	label_name = "cyanide"
	desc = "A small bottle of cyanide. Bitter almonds?"
	list_reagents = list(/datum/reagent/toxin/cyanide = 30)

/obj/item/reagent_containers/glass/bottle/spewium
	name = "spewium bottle"
	label_name = "spewium"
	desc = "A small bottle of spewium."
	list_reagents = list(/datum/reagent/toxin/spewium = 30)

/obj/item/reagent_containers/glass/bottle/morphine
	name = "morphine bottle"
	label_name = "morphine"
	desc = "A small bottle of morphine."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list(/datum/reagent/medicine/morphine = 30)

/obj/item/reagent_containers/glass/bottle/chloralhydrate
	name = "chloral hydrate bottle"
	label_name = "chloral hydrate"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 30)

/obj/item/reagent_containers/glass/bottle/mannitol
	name = "mannitol bottle"
	label_name = "mannitol"
	desc = "A small bottle of Mannitol. Useful for healing brain damage."
	list_reagents = list(/datum/reagent/medicine/mannitol = 30)

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "charcoal bottle"
	label_name = "charcoal"
	desc = "A small bottle of charcoal, which removes toxins and other chemicals from the bloodstream."
	list_reagents = list(/datum/reagent/medicine/charcoal = 30)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	label_name = "unstable mutagen"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	list_reagents = list(/datum/reagent/toxin/mutagen = 30)

/obj/item/reagent_containers/glass/bottle/plasma
	name = "liquid plasma bottle"
	label_name = "liquid plasma"
	desc = "A small bottle of liquid plasma. Extremely toxic and reacts with micro-organisms inside blood."
	list_reagents = list(/datum/reagent/toxin/plasma = 30)

/obj/item/reagent_containers/glass/bottle/synaptizine
	name = "synaptizine bottle"
	label_name = "synaptizine"
	desc = "A small bottle of synaptizine."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde bottle"
	label_name = "formaldehyde"
	desc = "A small bottle of formaldehyde."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/cryostylane
	name = "cryostylane bottle"
	label_name = "cryostylane"
	desc = "A small bottle of cryostylane. It feels cold to the touch."
	list_reagents = list(/datum/reagent/cryostylane = 30)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	label_name = "ammonia"
	desc = "A small bottle of ammonia."
	list_reagents = list(/datum/reagent/ammonia = 30)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	label_name = "diethylamine"
	desc = "A small bottle of diethylamine."
	list_reagents = list(/datum/reagent/diethylamine = 30)

/obj/item/reagent_containers/glass/bottle/facid
	name = "Fluorosulfuric Acid bottle"
	label_name = "Fluorosulfuric Acid"
	desc = "A small bottle. Contains a small amount of fluorosulfuric acid."
	list_reagents = list(/datum/reagent/toxin/acid/fluacid = 30)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine bottle"
	label_name = "Adminordrazine"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 30)

/obj/item/reagent_containers/glass/bottle/viralbase
	name = "Highly potent Viral Base bottle"
	label_name = "Highly potent Viral Base"
	desc = "A small bottle. Contains a trace amount of a substance found by scientists that can be used to create extremely advanced diseases once exposed to uranium."
	list_reagents = list(/datum/reagent/consumable/virus_food/viralbase = 1)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin bottle"
	label_name = "Capsaicin"
	desc = "A small bottle. Contains hot sauce."
	list_reagents = list(/datum/reagent/consumable/capsaicin = 30)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil bottle"
	label_name = "Frost Oil"
	desc = "A small bottle. Contains cold sauce."
	list_reagents = list(/datum/reagent/consumable/frostoil = 30)

/obj/item/reagent_containers/glass/bottle/traitor
	name = "syndicate bottle"
	label_name = "syndicate"
	desc = "A small bottle. Contains a random nasty chemical."
	icon = 'icons/obj/chemical.dmi'
	var/extra_reagent = null

/obj/item/reagent_containers/glass/bottle/traitor/Initialize(mapload)
	. = ..()
	extra_reagent = pick(/datum/reagent/toxin/polonium, /datum/reagent/toxin/histamine, /datum/reagent/toxin/formaldehyde, /datum/reagent/toxin/venom, /datum/reagent/toxin/fentanyl, /datum/reagent/toxin/cyanide)
	reagents.add_reagent(extra_reagent, 3)

/obj/item/reagent_containers/glass/bottle/polonium
	name = "polonium bottle"
	label_name = "polonium"
	desc = "A small bottle. Contains Polonium."
	list_reagents = list(/datum/reagent/toxin/polonium = 30)

/obj/item/reagent_containers/glass/bottle/magillitis
	name = "magillitis bottle"
	label_name = "magillitis"
	desc = "A small bottle. Contains a serum known only as 'magillitis'."
	list_reagents = list(/datum/reagent/magillitis = 5)

/obj/item/reagent_containers/glass/bottle/venom
	name = "venom bottle"
	label_name = "venom"
	desc = "A small bottle. Contains Venom."
	list_reagents = list(/datum/reagent/toxin/venom = 30)

/obj/item/reagent_containers/glass/bottle/fentanyl
	name = "fentanyl bottle"
	label_name = "fentanyl"
	desc = "A small bottle. Contains Fentanyl."
	list_reagents = list(/datum/reagent/toxin/fentanyl = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde bottle"
	label_name = "formaldehyde"
	desc = "A small bottle. Contains Formaldehyde."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/initropidril
	name = "initropidril bottle"
	label_name = "initropidril"
	desc = "A small bottle. Contains initropidril."
	list_reagents = list(/datum/reagent/toxin/initropidril = 30)

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "pancuronium bottle"
	label_name = "pancuronium"
	desc = "A small bottle. Contains pancuronium."
	list_reagents = list(/datum/reagent/toxin/pancuronium = 30)

/obj/item/reagent_containers/glass/bottle/sodium_thiopental
	name = "sodium thiopental bottle"
	label_name = "sodium thiopental"
	desc = "A small bottle. Contains sodium thiopental."
	list_reagents = list(/datum/reagent/toxin/sodium_thiopental = 30)

/obj/item/reagent_containers/glass/bottle/coniine
	name = "coniine bottle"
	label_name = "coniine"
	desc = "A small bottle. Contains coniine."
	list_reagents = list(/datum/reagent/toxin/coniine = 30)

/obj/item/reagent_containers/glass/bottle/curare
	name = "curare bottle"
	label_name = "curare"
	desc = "A small bottle. Contains curare."
	list_reagents = list(/datum/reagent/toxin/curare = 30)

/obj/item/reagent_containers/glass/bottle/amanitin
	name = "amanitin bottle"
	label_name = "amanitin"
	desc = "A small bottle. Contains amanitin."
	list_reagents = list(/datum/reagent/toxin/amanitin = 30)

/obj/item/reagent_containers/glass/bottle/histamine
	name = "histamine bottle"
	label_name = "histamine"
	desc = "A small bottle. Contains Histamine."
	list_reagents = list(/datum/reagent/toxin/histamine = 30)

/obj/item/reagent_containers/glass/bottle/diphenhydramine
	name = "antihistamine bottle"
	label_name = "antihistamine"
	desc = "A small bottle of diphenhydramine."
	list_reagents = list(/datum/reagent/medicine/diphenhydramine = 30)

/obj/item/reagent_containers/glass/bottle/potass_iodide
	name = "anti-radiation bottle"
	label_name = "anti-radiation"
	desc = "A small bottle of potassium iodide."
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 30)

/obj/item/reagent_containers/glass/bottle/salglu_solution
	name = "saline-glucose bottle"
	label_name = "saline-glucose"
	desc = "A small bottle of saline-glucose solution. Useful for patients lacking in blood volume."
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 30)

/obj/item/reagent_containers/glass/bottle/atropine
	name = "atropine bottle"
	label_name = "atropine"
	desc = "A small bottle of atropine."
	list_reagents = list(/datum/reagent/medicine/atropine = 30)

/obj/item/reagent_containers/glass/bottle/romerol
	name = "romerol bottle"
	label_name = "romerol"
	desc = "A small bottle of Romerol. The REAL zombie powder."
	list_reagents = list(/datum/reagent/romerol = 30)

/obj/item/reagent_containers/glass/bottle/random_virus/minor //for mail only...yet
	name = "Minor experimental disease culture bottle"
	label_name = "Minor experimental disease culture"
	desc = "A small bottle. Contains a weak version of an untested viral culture in synthblood medium."
	spawned_disease = /datum/disease/advance/random/minor

/obj/item/reagent_containers/glass/bottle/random_virus
	name = "Experimental disease culture bottle"
	label_name = "Experimental disease culture"
	desc = "A small bottle. Contains an untested viral culture in synthblood medium."
	spawned_disease = /datum/disease/advance/random

/obj/item/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	label_name = "Pierrot's Throat culture"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	spawned_disease = /datum/disease/pierrot_throat

/obj/item/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	label_name = "Rhinovirus culture"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	spawned_disease = /datum/disease/advance/cold

/obj/item/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture bottle"
	label_name = "Flu virion culture"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/flu

/obj/item/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture bottle"
	label_name = "Retrovirus culture"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	spawned_disease = /datum/disease/dna_retrovirus

/obj/item/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	label_name = "GBS culture"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/gbs

/obj/item/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	label_name = "GBS culture"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	spawned_disease = /datum/disease/fake_gbs

/obj/item/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	label_name = "Brainrot culture"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon_state = "bottle3"
	spawned_disease = /datum/disease/brainrot

/obj/item/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	label_name = "Magnitis culture"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	spawned_disease = /datum/disease/magnitis

/obj/item/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	label_name = "Wizarditis culture"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	spawned_disease = /datum/disease/wizarditis

/obj/item/reagent_containers/glass/bottle/anxiety
	name = "Severe Anxiety culture bottle"
	label_name = "Severe Anxiety culture"
	desc = "A small bottle. Contains a sample of Lepidopticides."
	spawned_disease = /datum/disease/anxiety

/obj/item/reagent_containers/glass/bottle/beesease
	name = "Beesease culture bottle"
	label_name = "Beesease culture"
	desc = "A small bottle. Contains a sample of invasive Apidae."
	spawned_disease = /datum/disease/beesease

/obj/item/reagent_containers/glass/bottle/fluspanish
	name = "Spanish flu culture bottle"
	label_name = "Spanish flu culture"
	desc = "A small bottle. Contains a sample of Inquisitius."
	spawned_disease = /datum/disease/fluspanish

/obj/item/reagent_containers/glass/bottle/tuberculosis
	name = "Fungal Tuberculosis culture bottle"
	label_name = "Fungal Tuberculosis culture"
	desc = "A small bottle. Contains a sample of Fungal Tubercle bacillus."
	spawned_disease = /datum/disease/tuberculosis

/obj/item/reagent_containers/glass/bottle/tuberculosiscure
	name = "BVAK bottle"
	label_name = "BVAK"
	desc = "A small bottle containing Bio Virus Antidote Kit."
	list_reagents = list(/datum/reagent/medicine/atropine = 5, /datum/reagent/medicine/epinephrine = 5, /datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/spaceacillin = 10)

/obj/item/reagent_containers/glass/bottle/necropolis_seed
	name = "bowl of blood"
	label_name = "blood"
	desc = "A clay bowl containing a fledgling Necropolis, preserved in blood. A robust virologist may be able to unlock its full potential..."
	icon_state = "mortar"
	spawned_disease = /datum/disease/advance/random/necropolis

/obj/item/reagent_containers/glass/bottle/felinid
	name = "Nano-Feline Assimilative Toxoplasmosis culture bottle"
	label_name = "Nano-Feline Assimilative Toxoplasmosis culture"
	desc = "A small bottle. Contains a sample of nano-feline toxoplasma in synthblood medium."
	spawned_disease = /datum/disease/transformation/felinid/contagious

/obj/item/reagent_containers/glass/bottle/advanced_felinid
	name = "Feline Hysteria culture bottle"
	label_name = "Feline Hysteria culture"
	desc = "A small bottle. Contains a sample of a dangerous A.R.C. experimental disease"
	spawned_disease = /datum/disease/advance/feline_hysteria

//Oldstation.dmm chemical storage bottles

/obj/item/reagent_containers/glass/bottle/hydrogen
	name = "hydrogen bottle"
	label_name = "hydrogen"
	list_reagents = list(/datum/reagent/hydrogen = 30)

/obj/item/reagent_containers/glass/bottle/lithium
	name = "lithium bottle"
	label_name = "lithium"
	list_reagents = list(/datum/reagent/lithium = 30)

/obj/item/reagent_containers/glass/bottle/carbon
	name = "carbon bottle"
	label_name = "carbon"
	list_reagents = list(/datum/reagent/carbon = 30)

/obj/item/reagent_containers/glass/bottle/nitrogen
	name = "nitrogen bottle"
	label_name = "nitrogen"
	list_reagents = list(/datum/reagent/nitrogen = 30)

/obj/item/reagent_containers/glass/bottle/oxygen
	name = "oxygen bottle"
	label_name = "oxygen"
	list_reagents = list(/datum/reagent/oxygen = 30)

/obj/item/reagent_containers/glass/bottle/fluorine
	name = "fluorine bottle"
	label_name = "fluorine"
	list_reagents = list(/datum/reagent/fluorine = 30)

/obj/item/reagent_containers/glass/bottle/sodium
	name = "sodium bottle"
	label_name = "sodium"
	list_reagents = list(/datum/reagent/sodium = 30)

/obj/item/reagent_containers/glass/bottle/aluminium
	name = "aluminium bottle"
	label_name = "aluminium"
	list_reagents = list(/datum/reagent/aluminium = 30)

/obj/item/reagent_containers/glass/bottle/silicon
	name = "silicon bottle"
	label_name = "silicon"
	list_reagents = list(/datum/reagent/silicon = 30)

/obj/item/reagent_containers/glass/bottle/phosphorus
	name = "phosphorus bottle"
	label_name = "phosphorus"
	list_reagents = list(/datum/reagent/phosphorus = 30)

/obj/item/reagent_containers/glass/bottle/sulfur
	name = "sulfur bottle"
	label_name = "sulfur"
	list_reagents = list(/datum/reagent/sulfur = 30)

/obj/item/reagent_containers/glass/bottle/chlorine
	name = "chlorine bottle"
	label_name = "chlorine"
	list_reagents = list(/datum/reagent/chlorine = 30)

/obj/item/reagent_containers/glass/bottle/potassium
	name = "potassium bottle"
	label_name = "potassium"
	list_reagents = list(/datum/reagent/potassium = 30)

/obj/item/reagent_containers/glass/bottle/iron
	name = "iron bottle"
	label_name = "iron"
	list_reagents = list(/datum/reagent/iron = 30)

/obj/item/reagent_containers/glass/bottle/copper
	name = "copper bottle"
	label_name = "copper"
	list_reagents = list(/datum/reagent/copper = 30)

/obj/item/reagent_containers/glass/bottle/mercury
	name = "mercury bottle"
	label_name = "mercury"
	list_reagents = list(/datum/reagent/mercury = 30)

/obj/item/reagent_containers/glass/bottle/radium
	name = "radium bottle"
	label_name = "radium"
	list_reagents = list(/datum/reagent/uranium/radium = 30)

/obj/item/reagent_containers/glass/bottle/water
	name = "water bottle"
	label_name = "water"
	list_reagents = list(/datum/reagent/water = 30)

/obj/item/reagent_containers/glass/bottle/ethanol
	name = "ethanol bottle"
	label_name = "ethanol"
	list_reagents = list(/datum/reagent/consumable/ethanol = 30)

/obj/item/reagent_containers/glass/bottle/sugar
	name = "sugar bottle"
	label_name = "sugar"
	list_reagents = list(/datum/reagent/consumable/sugar = 30)

/obj/item/reagent_containers/glass/bottle/sacid
	name = "sulfuric acid bottle"
	label_name = "sulfuric acid"
	list_reagents = list(/datum/reagent/toxin/acid = 30)

/obj/item/reagent_containers/glass/bottle/welding_fuel
	name = "welding fuel bottle"
	label_name = "welding fuel"
	list_reagents = list(/datum/reagent/fuel = 30)

/obj/item/reagent_containers/glass/bottle/silver
	name = "silver bottle"
	label_name = "silver"
	list_reagents = list(/datum/reagent/silver = 30)

/obj/item/reagent_containers/glass/bottle/iodine
	name = "iodine bottle"
	label_name = "iodine"
	list_reagents = list(/datum/reagent/iodine = 30)

/obj/item/reagent_containers/glass/bottle/bromine
	name = "bromine bottle"
	label_name = "bromine"
	list_reagents = list(/datum/reagent/bromine = 30)

// Bottles for mail goodies.

/obj/item/reagent_containers/glass/bottle/clownstears
	name = "bottle of distilled clown misery"
	label_name = "distilled clown misery"
	desc = "A small bottle. Contains a mythical liquid used by sublime bartenders; made from the unhappiness of clowns."
	list_reagents = list(/datum/reagent/consumable/clownstears = 30)

/obj/item/reagent_containers/glass/bottle/saltpetre
	name = "saltpetre bottle"
	label_name = "saltpetre"
	desc = "A small bottle. Contains saltpetre."
	list_reagents = list(/datum/reagent/saltpetre = 30)

/obj/item/reagent_containers/glass/bottle/flash_powder
	name = "flash powder bottle"
	label_name = "flash powder"
	desc = "A small bottle. Contains flash powder."
	list_reagents = list(/datum/reagent/flash_powder = 30)

/obj/item/reagent_containers/glass/bottle/caramel
	name = "bottle of caramel"
	label_name = "caramel"
	desc = "A bottle containing caramalized sugar, also known as caramel. Do not lick."
	list_reagents = list(/datum/reagent/consumable/caramel = 30)

/obj/item/reagent_containers/glass/bottle/ketamine
	name = "ketamine bottle"
	label_name = "ketamine"
	desc = "A small bottle. Contains ketamine, why?"
	list_reagents = list(/datum/reagent/drug/ketamine = 30)
