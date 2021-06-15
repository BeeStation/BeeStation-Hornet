#define VAT_GROWTH_RATE 4

////////////////////////////////
//// 		VERTEBRATES		////
////////////////////////////////

/datum/micro_organism/cell_line/mouse //nuisance cell line designed to complicate the growing of animal type cell lines.
	desc = "Murine cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
							/datum/reagent/growthserum = 2,
							/datum/reagent/liquidgibs = 2,
							/datum/reagent/consumable/cornoil = 2,
							/datum/reagent/consumable/nutriment = 1,
							/datum/reagent/consumable/nutriment/vitamin = 1,
							/datum/reagent/consumable/sugar = 1,
							/datum/reagent/consumable/cooking_oil = 1,
							/datum/reagent/consumable/rice = 1,
							/datum/reagent/consumable/eggyolk = 1)

	suppressive_reagents = list(
							/datum/reagent/toxin/heparin = -6,
							/datum/reagent/consumable/astrotame = -4, //Saccarin gives rats cancer.
							/datum/reagent/consumable/ethanol/rubberneck = -3,
							/datum/reagent/consumable/grey_bull = -1)

	virus_suspectibility = 2
	growth_rate = VAT_GROWTH_RATE
	resulting_atoms = list(/mob/living/simple_animal/mouse = 2)

/datum/micro_organism/cell_line/chicken //basic cell line designed as a good source of protein and eggyolk.
	desc = "Galliform skin cells."
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
							/datum/reagent/consumable/rice = 4,
							/datum/reagent/growthserum = 3,
							/datum/reagent/consumable/eggyolk = 1,
							/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(/datum/reagent/fuel/oil = -4,
								/datum/reagent/toxin = -2)

	virus_suspectibility = 1
	growth_rate = VAT_GROWTH_RATE
	resulting_atoms = list(/mob/living/simple_animal/chicken = 1)

/datum/micro_organism/cell_line/cow
	desc = "Bovine stem cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/consumable/nutriment,
						/datum/reagent/cellulose)

	supplementary_reagents = list(
						/datum/reagent/growthserum = 4,
						/datum/reagent/consumable/nutriment/vitamin = 2,
						/datum/reagent/consumable/rice = 2,
						/datum/reagent/consumable/flour = 1)

	suppressive_reagents = list(/datum/reagent/toxin = -2,
							/datum/reagent/toxin/carpotoxin = -5)

	virus_suspectibility = 1
	resulting_atoms = list(/mob/living/simple_animal/cow = 1)

/datum/micro_organism/cell_line/cat
	desc = "Feliform cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/liquidgibs
						)
	supplementary_reagents = list(
						/datum/reagent/growthserum = 3,
						/datum/reagent/consumable/nutriment/vitamin = 2,
						/datum/reagent/medicine/oculine = 2,
						/datum/reagent/consumable/milk = 1) //milkies
	suppressive_reagents = list(
						/datum/reagent/consumable/coco = -4,
						/datum/reagent/consumable/hot_coco = -2,
						/datum/reagent/consumable/chocolatepudding = -2,
						/datum/reagent/consumable/milk/chocolate_milk = -1)

	virus_suspectibility = 1.5
	resulting_atoms = list(/mob/living/simple_animal/pet/cat = 1) //The basic cat mobs are all male, so you mightt need a gender swap potion if you want to fill the fortress with kittens.

/datum/micro_organism/cell_line/corgi
	desc = "Canid cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/liquidgibs)

	supplementary_reagents = list(
						/datum/reagent/growthserum = 3,
						/datum/reagent/barbers_aid = 3,
						/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
						/datum/reagent/consumable/garlic = -2,
						/datum/reagent/consumable/tearjuice = -3,
						/datum/reagent/consumable/coco = -2)
	virus_suspectibility = 1
	resulting_atoms = list(/mob/living/simple_animal/pet/dog/corgi = 1)

/datum/micro_organism/cell_line/pug
	desc = "Squat canid cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/liquidgibs)

	supplementary_reagents = list(
						/datum/reagent/growthserum = 2,
						/datum/reagent/consumable/nutriment/vitamin = 3)

	suppressive_reagents = list(
						/datum/reagent/consumable/garlic = -2,
						/datum/reagent/consumable/tearjuice = -3,
						/datum/reagent/consumable/coco = -2)

	virus_suspectibility = 3
	resulting_atoms = list(/mob/living/simple_animal/pet/dog/pug = 1)

/datum/micro_organism/cell_line/bear //bears can't really compete directly with more powerful creatures, so i made it possible to grow them real fast.
	desc = "Ursine cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/liquidgibs,
						/datum/reagent/medicine/c2/synthflesh) //Nuke this if the dispenser becomes xenobio meta.

	supplementary_reagents = list(
						/datum/reagent/consumable/honey = 8, //Hunny.
						/datum/reagent/growthserum = 5,
						/datum/reagent/medicine/morphine = 4, //morphine is a vital nutrient for space bears, but it is better as a supplemental for gameplay reasons.
						/datum/reagent/consumable/nutriment/vitamin = 3)

	suppressive_reagents = list(
						/datum/reagent/consumable/condensedcapsaicin = -4, //bear mace, steal it from the sec checkpoint.
						/datum/reagent/toxin/carpotoxin = -2,
						/datum/reagent/medicine/insulin = -2) //depletes hunny.

	virus_suspectibility = 2
	resulting_atoms = list(/mob/living/simple_animal/hostile/bear = 1)

/datum/micro_organism/cell_line/carp
	desc = "Cyprinid cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/consumable/nutriment)

	supplementary_reagents = list(
						/datum/reagent/consumable/cornoil = 4, //Carp are oily fish
						/datum/reagent/toxin/carpotoxin = 3,
						/datum/reagent/consumable/cooking_oil = 2,
						/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
						/datum/reagent/toxin/bungotoxin = -6,
						/datum/reagent/mercury = -4,
						/datum/reagent/oxygen = -3)

	virus_suspectibility = 2
	resulting_atoms = list(/mob/living/simple_animal/hostile/carp = 1)

/datum/micro_organism/cell_line/megacarp
	desc = "Cartilaginous cyprinid cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/medicine/c2/synthflesh,
						/datum/reagent/consumable/nutriment)

	supplementary_reagents = list(
						/datum/reagent/consumable/cornoil = 4,
						/datum/reagent/growthserum = 3,
						/datum/reagent/toxin/carpotoxin = 2,
						/datum/reagent/consumable/cooking_oil = 2,
						/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
						/datum/reagent/toxin/bungotoxin = -6,
						/datum/reagent/oxygen = -3)

	virus_suspectibility = 1
	resulting_atoms = list(/mob/living/simple_animal/hostile/carp/megacarp = 1)

/datum/micro_organism/cell_line/snake
	desc = "Ophidic cells"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/liquidgibs)

	supplementary_reagents = list(
						/datum/reagent/growthserum = 3,
						/datum/reagent/consumable/nutriment/peptides = 3,
						/datum/reagent/consumable/eggyolk = 2,
						/datum/reagent/consumable/nutriment/vitamin = 2)

	suppressive_reagents = list(
						/datum/reagent/consumable/corn_syrup = -6,
						/datum/reagent/sulfur = -3) //sulfur repels snakes according to professor google.

	resulting_atoms = list(/mob/living/simple_animal/hostile/retaliate/poison/snake = 1)


///////////////////////////////////////////
/// 		SLIMES, OOZES & BLOBS  		///
//////////////////////////////////////////

/datum/micro_organism/cell_line/slime
	desc = "Slime particles"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
	 					/datum/reagent/toxin/slimejelly = 2,
	 					/datum/reagent/liquidgibs = 2,
						/datum/reagent/consumable/enzyme = 1)

	suppressive_reagents = list(
						/datum/reagent/consumable/frostoil = -4,
						/datum/reagent/cryostylane = -4,
						/datum/reagent/medicine/morphine = -2,
						/datum/reagent/consumable/ice = -2) //Brrr!

	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/slime = 1)

/datum/micro_organism/cell_line/blob_spore //shitty cell line to dilute the pool, feel free to make easier to grow if it doesn't interfer with growing the powerful mobs enough.
	desc = "Immature blob spores"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)

	supplementary_reagents = list(
	 					/datum/reagent/consumable/nutriment/vitamin = 3,
	 					/datum/reagent/liquidgibs = 2,
	 					/datum/reagent/sulfur = 2)

	suppressive_reagents = list(
						/datum/reagent/consumable/tinlux = -6,
						/datum/reagent/napalm = -4)
	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/hostile/blob/blobspore/independent = 2) //These are useless so we might as well spawn 2.

/datum/micro_organism/cell_line/blobbernaut
	desc = "Blobular myocytes"
	required_reagents = list(
	 					/datum/reagent/consumable/nutriment/protein,
	 					/datum/reagent/medicine/c2/synthflesh,
	 					/datum/reagent/sulfur) //grind flares to get this

	supplementary_reagents = list(
	 					/datum/reagent/growthserum = 3,
	 					/datum/reagent/consumable/nutriment/vitamin = 2,
	 					/datum/reagent/liquidgibs = 2,
	 					/datum/reagent/consumable/eggyolk = 2,
	 					/datum/reagent/consumable/shamblers = 1)

	suppressive_reagents = list(/datum/reagent/consumable/tinlux = -6)

	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/hostile/blob/blobbernaut/independent = 1)

/datum/micro_organism/cell_line/gelatinous_cube
	desc = "Cubic ooze particles"
	required_reagents = list(
	 					/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/toxin/slimejelly,
						/datum/reagent/yuck,
						/datum/reagent/consumable/enzyme) //Powerful enzymes helps the cube digest prey.

	supplementary_reagents = list(
						/datum/reagent/water/hollowwater = 4,
						/datum/reagent/consumable/corn_syrup = 3,
						/datum/reagent/gold = 2, //This is why they eat so many adventurers.
						/datum/reagent/consumable/nutriment/peptides = 2,
						/datum/reagent/consumable/potato_juice = 1,
						/datum/reagent/liquidgibs = 1,
						/datum/reagent/consumable/nutriment/vitamin = 1)

	suppressive_reagents = list(
						/datum/reagent/toxin/minttoxin = -3,
						/datum/reagent/consumable/frostoil = -2,
						/datum/reagent/consumable/ice = -1)
	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/hostile/ooze/gelatinous = 1)

/datum/micro_organism/cell_line/sholean_grapes
	desc = "Globular ooze particles"
	required_reagents = list(
	 					/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/toxin/slimejelly,
						/datum/reagent/yuck,
						/datum/reagent/consumable/vitfro)

	supplementary_reagents = list(
						/datum/reagent/medicine/omnizine = 4,
						/datum/reagent/consumable/nutriment/peptides = 3,
						/datum/reagent/consumable/corn_syrup = 2,
						/datum/reagent/consumable/ethanol/squirt_cider = 2,
						/datum/reagent/consumable/doctor_delight = 1,
						/datum/reagent/medicine/salglu_solution = 1,
						/datum/reagent/liquidgibs = 1,
						/datum/reagent/consumable/nutriment/vitamin = 1)

	suppressive_reagents = list(
						/datum/reagent/toxin/carpotoxin = -3,
						/datum/reagent/toxin/coffeepowder = -2,
						/datum/reagent/consumable/frostoil = -2,
						/datum/reagent/consumable/ice = -1)
	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/hostile/ooze/grapes = 1)

////////////////////
////	MISC	////
////////////////////
/datum/micro_organism/cell_line/cockroach //nuisance cell line designed to complicate the growing of slime type cell lines.
	desc = "Blattodeoid anthropod cells"
	required_reagents = list(/datum/reagent/consumable/nutriment/protein)
	supplementary_reagents = list(
							/datum/reagent/yuck = 4,
							/datum/reagent/growthserum = 2,
							/datum/reagent/toxin/slimejelly = 2,
							/datum/reagent/consumable/nutriment/vitamin = 1)

	suppressive_reagents = list(
							/datum/reagent/toxin/pestkiller = -2,
							/datum/reagent/consumable/poisonberryjuice = -4,
							/datum/reagent/consumable/ethanol/bug_spray = -4)

	virus_suspectibility = 0
	resulting_atoms = list(/mob/living/simple_animal/hostile/cockroach = 5)

/datum/micro_organism/cell_line/pine
	desc = "Coniferous plant cells"
	required_reagents = list(
							/datum/reagent/ammonia,
							/datum/reagent/ash,
							/datum/reagent/plantnutriment/robustharvestnutriment) //A proper source of phosphorous like would be thematically more appropriate but this is what we have.

	supplementary_reagents = list(
							/datum/reagent/saltpetre = 5,
							/datum/reagent/carbondioxide = 2,
							/datum/reagent/consumable/nutriment = 2,
							/datum/reagent/consumable/space_cola = 2, //A little extra phosphorous
							/datum/reagent/water/holywater = 2,
							/datum/reagent/water = 1,
							/datum/reagent/cellulose = 1)

	suppressive_reagents = list(/datum/reagent/toxin/plantbgone = -8)
	virus_suspectibility = 1
	resulting_atoms = list(/mob/living/simple_animal/hostile/tree = 1)

/datum/micro_organism/cell_line/vat_beast
	desc = "Hypergenic xenocytes"
	required_reagents = list(
						/datum/reagent/consumable/nutriment/protein,
						/datum/reagent/consumable/nutriment/vitamin,
						/datum/reagent/consumable/nutriment/peptides,
						/datum/reagent/consumable/liquidelectricity,
						/datum/reagent/growthserum,
						/datum/reagent/yuck)

	supplementary_reagents = list(
						/datum/reagent/medicine/rezadone = 3,
						/datum/reagent/consumable/entpoly = 3,
						/datum/reagent/consumable/red_queen = 2,
						/datum/reagent/consumable/peachjuice = 2,
						/datum/reagent/uranium = 1,
						/datum/reagent/liquidgibs = 1)

	suppressive_reagents = list(
						/datum/reagent/consumable/sodiumchloride = -3,
						/datum/reagent/medicine/c2/syriniver = -2)
	virus_suspectibility = 0.5
	resulting_atoms = list(/mob/living/simple_animal/hostile/vatbeast = 1)

/datum/micro_organism/cell_line/vat_beast/succeed_growing(obj/machinery/plumbing/growing_vat/vat)
	. = ..()
	qdel(vat)

#undef VAT_GROWTH_RATE
