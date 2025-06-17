////////////////////////////////////////////SNACKS FROM VENDING MACHINES////////////////////////////////////////////
//in other words: junk food
//don't even bother looking for recipes for these

/obj/item/food/candy
	name = "candy"
	desc = "Nougat love it or hate it."
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "candy"
	trash_type = /obj/item/trash/candy
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 3
	)
	junkiness = 25
	tastes = list("candy" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash_type = /obj/item/trash/sosjerky
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/sodiumchloride = 2
	)
	junkiness = 25
	tastes = list("dried meat" = 1)
	w_class = WEIGHT_CLASS_SMALL
	foodtypes = JUNKFOOD | MEAT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/sosjerky/healthy
	name = "homemade beef jerky"
	desc = "Homemade beef jerky made from the finest space cows."
	icon_state = "sosjerky_homemade"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	crafting_complexity = FOOD_COMPLEXITY_2
	junkiness = 0

/obj/item/food/sosjerky/healthy/lean
	name = "lean beef jerky"
	desc = "Homemade beef jerky made from the finest space cows. Special lean cuts edition!"
	icon_state = "sosjerky_lowfat"
	tastes = list("dried meat" = 3, "chicken" = 1)	//is it really chicken, or something else?....

/obj/item/food/sosjerky/healthy/lizard
	name = "dinosaur jerky"
	desc = "Homemade jerky made from the finest dinosaurs of Sauria. Natural dinosaur flavour!"
	icon_state = "sosjerky_dinosaur"
	tastes = list("dried meat" = 1, "scales" = 1)

/obj/item/food/sosjerky/healthy/pig
	name = "pork jerky"
	desc = "Homemade jerky made from the cleanliest pigs in the sector."
	icon_state = "sosjerky_pig"
	tastes = list("dried meat" = 1, "acorns" = 1)
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/fat = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)

/obj/item/food/sosjerky/healthy/mouse
	name = "lizard treats"
	desc = "Homemade jerky made from the locally-sourced space mice. \n20% of all proceeds go to pest control efforts of underfunded space stations. \n100% of meat goes to your pet lizard's happiness!"
	icon_state = "sosjerky_lizard_treats"
	tastes = list("dried meat" = 1, "pests" = 1)
	foodtypes = JUNKFOOD | MEAT | GORE

/obj/item/food/sosjerky/pemmican
	name = "\improper Space Pemmican(tm) ration pack"
	desc = "Meat product processed chemically, dehydrated, preserved.\nMay contain Azodicarbonamide, Propylparaben, Erythrosine.\nConsists of more than 35% connective tissue. \nSpace Pemmican(tm) is deemed unfit for human consumption in Jupiter II Europan Outer Solar System Economic Zone."
	icon_state = "sosjerky_synth_pemmican"
	tastes = list("meat flavoring" = 2, "bloodmeal" = 2, "natural & artificial dyes" = 1, "gastronomical anxiety" = 1)
	foodtypes = JUNKFOOD | MEAT | GROSS
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/fat = 2
	)
	junkiness = 45	//At least Scaredy's Private Reserve is made from real meat! What the hell is this?! Is this even food at this point?!

/obj/item/food/sosjerky/healthy/bugs
	name = "bug snacks"
	desc = "Homemade high-protein snacks made from an assortment of insects. Thank you for supporting the path towards sustainable foods!"
	icon_state = "sosjerky_bugs"
	tastes = list("crispy tissue" = 4, "progressiveness" = 1)

/obj/item/food/sosjerky/healthy/bees
	name = "bee snacks"
	desc = "Homemade high-protein snacks made from 100% bees."
	icon_state = "sosjerky_bees"
	tastes = list("crispy tenderness" = 4, "pollen" = 1)

/obj/item/food/sosjerky/healthy/synthmeat
	name = "cruelty-free jerky"
	desc = "Homemade jerky made from synthetic meat. Not a single animal suffered during the creation of this product."
	icon_state = "sosjerky_synth"
	tastes = list("dried meat" = 3, "blue" = 1)

/obj/item/food/sosjerky/healthy/monkey
	name = "ape jerky"
	desc = "Homemade jerky made from ape meat. \nNaturally contains banana flavour. \nHIV vaccine-free."
	icon_state = "sosjerky_monkey"
	tastes = list("dried meat" = 1, "bananas" = 1)

/obj/item/food/sosjerky/healthy/diona
	name = "vegetable jerky"
	desc = "Homemade meat-imitating vegetable jerky. \nThis product has NOT been approved by the ethics commitee. \nMay be offensive to some plant-based crewmembers."
	icon_state = "sosjerky_vegan"
	tastes = list("dried beets" = 3, "fermented tomatoes" = 2, "lettuce" = 2, "vegetarian guilt" = 1)
	foodtypes = JUNKFOOD | VEGETABLES
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 6	//very healthy! go butcher your diona coworker!
	)

/obj/item/food/sosjerky/healthy/mushroom
	name = "dried mushrooms"
	desc = "An assortment of dried mushroom slices. Should not be poisonous."
	icon_state = "sosjerky_mushroom"
	tastes = list("dried mushrooms" = 3, "earth" = 1)
	foodtypes = JUNKFOOD | VEGETABLES
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,	//fungi are heterotrophs
		/datum/reagent/consumable/nutriment/vitamin = 3,	//still healthy
		/datum/reagent/drug/mushroomhallucinogen = 3
	)

/obj/item/food/sosjerky/healthy/mushroom/Initialize(mapload)
	. = ..()
	if(rand(1, 100) == 1)
		for(var/datum/reagent/R in reagents.reagent_list)
			var/amount = R.volume
			reagents.remove_reagent(R.type, amount)
		reagents.add_reagent(/datum/reagent/toxin/amanitin, 10) //don't trust random mushrooms! (this is about 90 tox)
		reagents.add_reagent(/datum/reagent/drug/mushroomhallucinogen, 3)

/obj/item/food/sosjerky/healthy/jelly
	name = "dried jelly strips"
	desc = "Homemade dried jelly strips. \nMay be toxic to most lifeforms."
	icon_state = "sosjerky_jelly"
	tastes = list("jelly" = 2, "jello" = 2, "sourness" = 1)
	foodtypes = JUNKFOOD | TOXIC | SUGAR
	food_reagents = list(
		/datum/reagent/toxin/slimejelly = 3,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment = 3
	)

/obj/item/food/sosjerky/healthy/ethereal
	name = "dried static charge"
	desc = "This is what's left when you dry out electricity itself. \nMay cause static shocks."
	icon_state = "sosjerky_electric"
	tastes = list("static charge" = 2, "electrodynamics" = 2, "surging regret" = 1)
	foodtypes = JUNKFOOD
	food_reagents = list(
		/datum/reagent/consumable/liquidelectricity = 6
	)

/obj/item/food/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps."
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "chips"
	trash_type = /obj/item/trash/chips
	bite_consumption = 1
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/sodiumchloride = 1
	)
	junkiness = 20
	tastes = list("salt" = 1, "crisps" = 1)
	foodtypes = JUNKFOOD | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/no_raisin
	name = "\improper 4no raisins"
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash_type = /obj/item/trash/raisins
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 4
	)
	junkiness = 25
	tastes = list("dried raisins" = 1)
	foodtypes = JUNKFOOD | FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	custom_price = PAYCHECK_MEDIUM * 0.7
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/no_raisin/healthy
	name = "homemade raisins"
	desc = "Homemade raisins, the best in all of spess."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	junkiness = 0
	foodtypes = FRUIT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/spacetwinkie
	name = "\improper Space Twinkie"
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer than you will."
	food_reagents = list(
		/datum/reagent/consumable/sugar = 4
	)
	junkiness = 25
	foodtypes = JUNKFOOD | GRAIN | SUGAR
	food_flags = FOOD_FINGER_FOOD
	custom_price = PAYCHECK_EASY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/cheesiehonkers
	name = "\improper Cheesie Honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "cheesie_honkers"
	trash_type = /obj/item/trash/cheesie
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 3
	)
	junkiness = 25
	tastes = list("cheese" = 5, "crisps" = 2)
	foodtypes = JUNKFOOD | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/syndicake
	name = "\improper Syndi-Cakes"
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	trash_type = /obj/item/trash/syndi_cakes
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/doctor_delight = 5
	)
	tastes = list("sweetness" = 3, "cake" = 1)
	foodtypes = GRAIN | FRUIT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/energybar
	name = "\improper High-power energy bars"
	icon = 'icons/obj/food/snacks.dmi'
	icon_state = "energybar"
	desc = "An energy bar with a lot of punch, you probably shouldn't eat this if you're not an Ethereal."
	trash_type = /obj/item/trash/energybar
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/liquidelectricity = 10
	)
	tastes = list("pure electricity" = 3, "fitness" = 2)
	foodtypes = TOXIC
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1
