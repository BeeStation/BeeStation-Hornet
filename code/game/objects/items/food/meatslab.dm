/obj/item/food/meat
	//custom_materials = list(/datum/material/meat = MINERAL_MATERIAL_AMOUNT * 4)
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/meat.dmi'
	var/subjectname = ""
	var/subjectjob = null

/obj/item/food/meat/slab
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	//dried_type = /obj/item/food//sosjerky/healthy
	microwaved_type = /obj/item/food/meat/steak/plain
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/cooking_oil = 2
	) //Meat has fats that a food processor can process into cooking oil
	tastes = list("meat" = 1)
	foodtypes = MEAT | RAW
	///Legacy code, handles the coloring of the overlay of the cutlets made from this.
	var/slab_color = "#FF0000"

/*
/obj/item/food/meat/slab/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/plain)
*/

/obj/item/food/meat/slab/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/plain, 3, 30)

///////////////////////////////////// HUMAN MEATS //////////////////////////////////////////////////////

/obj/item/food/meat/slab/human
	name = "meat"
	microwaved_type = /obj/item/food/meat/steak/plain/human
	tastes = list("tender meat" = 1)
	foodtypes = MEAT | RAW | GORE

/*
/obj/item/food/meat/slab/human/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/plain/human)
*/

/obj/item/food/meat/slab/human/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/plain/human, 3, 30)

/obj/item/food/meat/slab/human/mutant/slime
	icon_state = "slimemeat"
	desc = "Because jello wasn't offensive enough to vegans."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/toxin/slimejelly = 3
	)
	tastes = list("slime" = 1, "jelly" = 1)
	foodtypes = MEAT | RAW | TOXIC

/obj/item/food/meat/slab/human/mutant/golem
	icon_state = "golemmeat"
	desc = "Edible rocks, welcome to the future."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/iron = 3
	)
	tastes = list("rock" = 1)
	foodtypes = MEAT | RAW | GROSS

/obj/item/food/meat/slab/human/mutant/golem/adamantine
	icon_state = "agolemmeat"
	desc = "From the slime pen to the rune to the kitchen, science."
	foodtypes = MEAT | RAW | GROSS

/obj/item/food/meat/slab/human/mutant/lizard
	icon_state = "lizardmeat"
	desc = "Delicious dino damage."
	microwaved_type = /obj/item/food/meat/steak/plain/human/lizard
	tastes = list("meat" = 4, "scales" = 1)
	foodtypes = MEAT | RAW | GORE

/*
/obj/item/food/meat/slab/human/mutant/lizard/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/plain/human/lizard)
*/

/obj/item/food/meat/slab/human/mutant/plant
	icon_state = "plantmeat"
	desc = "All the joys of healthy eating with all the fun of cannibalism."
	tastes = list("salad" = 1, "wood" = 1)
	foodtypes = VEGETABLES

/obj/item/food/meat/slab/human/mutant/shadow
	icon_state = "shadowmeat"
	desc = "Ow, the edge."
	tastes = list("darkness" = 1, "meat" = 1)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/slab/human/mutant/fly
	icon_state = "flymeat"
	desc = "Nothing says tasty like maggot filled radioactive mutant flesh."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/uranium = 3
	)
	tastes = list("maggots" = 1, "the inside of a reactor" = 1)
	foodtypes = MEAT | RAW | GROSS | GORE

/obj/item/food/meat/slab/human/mutant/moth
	icon_state = "mothmeat"
	desc = "Unpleasantly powdery and dry. Kind of pretty, though."
	tastes = list("dust" = 1, "powder" = 1, "meat" = 2)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/slab/human/mutant/skeleton
	name = "bone"
	icon_state = "skeletonmeat"
	desc = "There's a point where this needs to stop, and clearly we have passed it."
	tastes = list("bone" = 1)
	foodtypes = GROSS | GORE

/obj/item/food/meat/slab/human/mutant/skeleton/make_processable()
	return //skeletons dont have cutlets. Its a bone, Genius.

/obj/item/food/meat/slab/human/mutant/zombie
	name = " meat (rotten)"
	icon_state = "rottenmeat"
	desc = "Halfway to becoming fertilizer for your garden."
	tastes = list("brains" = 1, "meat" = 1)
	foodtypes = RAW | MEAT | TOXIC | GORE | GROSS // who the hell would eat this

/obj/item/food/meat/slab/human/mutant/ethereal
	icon_state = "etherealmeat"
	desc = "So shiny you feel like ingesting it might make you shine too"
	food_reagents = list(/datum/reagent/consumable/liquidelectricity = 3)
	tastes = list("pure electricity" = 2, "meat" = 1)
	foodtypes = RAW | MEAT | TOXIC | GORE

/obj/item/food/meat/slab/human/mutant/apid
	icon_state = "apidmeat"
	desc = "Smells like flowers, hopefully doesn't taste like one."
	tastes = list("honey" = 1, "flowers" = 1, "meat" = 2)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/slab/human/mutant/psyphoza
	icon_state = "psyphoza_meat"
	desc = "Psychically awaiting consumption, spooky."
	food_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 3)
	tastes = list("pop candy" = 1, "meat" = 1)
	foodtypes = VEGETABLES | RAW | GORE
	microwaved_type = /obj/item/food/meat/steak/plain/human/psyphoza

////////////////////////////////////// OTHER MEATS ////////////////////////////////////////////////////////


/obj/item/food/meat/slab/synthmeat
	name = "synthmeat"
	desc = "A synthetic slab of... ethical* meat?"
	foodtypes = RAW | MEAT // If it looks like a duck, quacks like a duck, its probably...

/obj/item/food/meat/slab/meatproduct
	name = "meat product"
	//icon_state = "meatproduct"
	microwaved_type = /obj/item/food/meat/steak/meatproduct
	desc = "A slab of station reclaimed and chemically processed meat product."
	tastes = list("meat flavoring" = 2, "modified starches" = 2, "natural & artificial dyes" = 1, "butyric acid" = 1) // its supposed to be various processed chemicals seen in very processed food. Butyric acid is a reference to how a certain North American Candymaker puts a chemical commonly seen in vomit into chocolate
	foodtypes = RAW | MEAT

/*
/obj/item/food/meat/slab/meatproduct/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/meatproduct)
*/

/obj/item/food/meat/slab/monkey
	name = "monkey meat"
	foodtypes = RAW | MEAT

/obj/item/food/meat/slab/mouse
	name = "mouse meat"
	desc = "A slab of mouse meat. Best not eat it raw."
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/corgi
	name = "corgi meat"
	desc = "Tastes like... well you know..."
	tastes = list("meat" = 4, "a fondness for wearing hats" = 1)
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/pug
	name = "pug meat"
	desc = "Tastes like... well you know..."
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/hamster
	name = "hamster meat"
	desc = "Hey, they eat eachother, so its justified... right..?"
	tastes = list("meat" = 4, "fluffly adorableness" = 1)
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/killertomato
	name = "killer tomato meat"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	microwaved_type = /obj/item/food/meat/steak/killertomato
	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("tomato" = 1)
	foodtypes = FRUIT // Yeah, tomatoes are FRUIT. Bite me.

/*
/obj/item/food/meat/slab/killertomato/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/killertomato)
*/

/obj/item/food/meat/slab/killertomato/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/killertomato, 3, 30)

/obj/item/food/meat/slab/bear
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	microwaved_type = /obj/item/food/meat/steak/bear
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 16,
		/datum/reagent/medicine/morphine = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/cooking_oil = 6
	)
	tastes = list("meat" = 1, "salmon" = 1)
	foodtypes = RAW | MEAT

/*
/obj/item/food/meat/slab/bear/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/bear)
*/

/obj/item/food/meat/slab/bear/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/bear, 3, 30)

/obj/item/food/meat/slab/xeno
	name = "xeno meat"
	desc = "A slab of meat."
	icon_state = "xenomeat"
	microwaved_type = /obj/item/food/meat/steak/xeno
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 4
	tastes = list("meat" = 1, "acid" = 1)
	foodtypes = RAW | MEAT

/*
/obj/item/food/meat/slab/xeno/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/xeno)
*/

/obj/item/food/meat/slab/xeno/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/xeno, 3, 30)

/obj/item/food/meat/slab/spider
	name = "spider meat"
	desc = "A slab of spider meat. That is so Kafkaesque."
	icon_state = "spidermeat"
	microwaved_type = /obj/item/food/meat/steak/spider
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/toxin = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("cobwebs" = 1)
	foodtypes = RAW | MEAT | TOXIC

/*
/obj/item/food/meat/slab/spider/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/spider)
*/

/obj/item/food/meat/slab/spider/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/spider, 3, 30)

/obj/item/food/meat/slab/goliath
	name = "goliath meat"
	desc = "A slab of goliath meat. It's not very edible now, but it cooks great in lava."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/toxin = 5,
		/datum/reagent/consumable/cooking_oil = 3
	)
	icon_state = "goliathmeat"
	tastes = list("meat" = 1)
	foodtypes = RAW | MEAT | TOXIC

/obj/item/food/meat/slab/goliath/burn()
	visible_message("<span class='notice'>[src] finishes cooking!</span>")
	new /obj/item/food/meat/steak/goliath(loc)
	qdel(src)

/obj/item/food/meat/slab/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/cooking_oil = 1
	)
	icon_state = "meatwheat_clump"
	bite_consumption = 4
	tastes = list("meat" = 1, "wheat" = 1)
	foodtypes = GRAIN

/obj/item/food/meat/slab/gorilla
	name = "gorilla meat"
	desc = "Much meatier than monkey meat."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/cooking_oil = 5 //Plenty of fat!
	)

/obj/item/food/meat/rawbacon
	name = "raw piece of bacon"
	desc = "A raw piece of bacon."
	icon_state = "bacon"
	microwaved_type = /obj/item/food/meat/bacon
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/cooking_oil = 3
	)
	tastes = list("bacon" = 1)
	foodtypes = RAW | MEAT | BREAKFAST

/*
/obj/item/food/meat/rawbacon/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/bacon)
*/

/obj/item/food/meat/bacon
	name = "piece of bacon"
	desc = "A delicious piece of bacon."
	icon_state = "baconcooked"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/cooking_oil = 2
	)
	tastes = list("bacon" = 1)
	foodtypes = MEAT | BREAKFAST

/obj/item/food/meat/slab/gondola
	name = "gondola meat"
	desc = "According to legends of old, consuming raw gondola flesh grants one inner peace."
	microwaved_type = /obj/item/food/meat/steak/gondola
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/tranquility = 5,
		/datum/reagent/consumable/cooking_oil = 3
	)
	tastes = list("meat" = 4, "tranquility" = 1)
	foodtypes = RAW | MEAT

/*
/obj/item/food/meat/slab/gondola/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/gondola)
*/

/obj/item/food/meat/slab/gondola/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/gondola, 3, 30)

/obj/item/food/meat/slab/penguin
	name = "penguin meat"
	//icon_state = "birdmeat"
	microwaved_type = /obj/item/food/meat/steak/penguin
	desc = "A slab of penguin meat."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/cooking_oil = 3
	)
	tastes = list("beef" = 1, "cod fish" = 1)

/*
/obj/item/food/meat/slab/penguin/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/penguin)
*/

/obj/item/food/meat/slab/penguin/make_processable()
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/penguin, 3, 30)

/obj/item/food/meat/rawcrab
	name = "raw crab meat"
	desc = "A pile of raw crab meat."
	icon_state = "crabmeatraw"
	microwaved_type = /obj/item/food/meat/crab
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/cooking_oil = 3
	)
	tastes = list("raw crab" = 1)
	foodtypes = RAW | MEAT

/*
/obj/item/food/meat/rawcrab/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/crab)
*/

/obj/item/food/meat/crab
	name = "crab meat"
	desc = "Some deliciously cooked crab meat."
	icon_state = "crabmeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/cooking_oil = 2
	)
	tastes = list("crab" = 1)
	foodtypes = MEAT

/obj/item/food/meat/slab/chicken
	name = "chicken meat"
	//icon_state = "birdmeat"
	microwaved_type = /obj/item/food/meat/steak/chicken
	desc = "A slab of raw chicken. Remember to wash your hands!"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6
	) //low fat
	tastes = list("chicken" = 1)
/*
/obj/item/food/meat/slab/chicken/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/steak/chicken)
*/

/obj/item/food/meat/slab/chicken/make_processable()
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/chicken, 3, 30)

/obj/item/food/meat/slab/mothroach
	name = "mothroach meat"
	desc = "a light slab of mothroach meat"
	tastes = list("gross" = 1)
	foodtypes = RAW | MEAT | GORE

/obj/item/food/meat/slab/dolphinmeat
	name = "uncooked dolphin fillet"
	desc = "A fillet of spess dolphin meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 6
	tastes = list("fish" = 1,"cruelty" = 2)
	foodtypes = MEAT | RAW


////////////////////////////////////// MEAT STEAKS ///////////////////////////////////////////////////////////
/obj/item/food/meat/steak
	name = "steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	foodtypes = MEAT
	tastes = list("meat" = 1)

/obj/item/food/meat/steak/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))

/obj/item/food/meat/steak/proc/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency = 1)
	SIGNAL_HANDLER

	name = "[source_item.name] steak"

/obj/item/food/meat/steak/plain
	foodtypes = MEAT

/obj/item/food/meat/steak/plain/human
	tastes = list("tender meat" = 1)
	foodtypes = MEAT | GORE

///Make sure the steak has the correct name
/obj/item/food/meat/steak/plain/human/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency = 1)
	. = ..()
	if(!istype(source_item, /obj/item/food/meat))
		return

	var/obj/item/food/meat/origin_meat = source_item
	subjectname = origin_meat.subjectname
	subjectjob = origin_meat.subjectjob
	if(subjectname)
		name = "[origin_meat.subjectname] meatsteak"
	else if(subjectjob)
		name = "[origin_meat.subjectjob] meatsteak"

/obj/item/food/meat/steak/killertomato
	name = "killer tomato steak"
	tastes = list("tomato" = 1)
	foodtypes = FRUIT // And dont let anybody tell you otherwise!

/obj/item/food/meat/steak/bear
	name = "bear steak"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/food/meat/steak/xeno
	name = "xeno steak"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/food/meat/steak/spider
	name = "spider steak"
	tastes = list("cobwebs" = 1)

/obj/item/food/meat/steak/goliath
	name = "goliath steak"
	desc = "A delicious, lava cooked steak."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "goliathsteak"
	trash_type = null
	tastes = list("meat" = 1, "rock" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/gondola
	name = "gondola steak"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/food/meat/steak/penguin
	name = "penguin steak"
	//icon_state = "birdsteak"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/food/meat/steak/chicken
	name = "chicken steak" //Can you have chicken steaks? Maybe this should be renamed once it gets new sprites. //I concur
	//icon_state = "birdsteak"
	tastes = list("chicken" = 1)

/obj/item/food/meat/steak/plain/human/lizard
	name = "lizard steak"
	//icon_state = "birdsteak"
	tastes = list("juicy chicken" = 3, "scales" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/plain/human/psyphoza
	name = "psyphoza steak"
	icon_state = "psyphoza_meat_cooked"
	tastes = list("dirt" = 3, "wood" = 1)
	foodtypes = VEGETABLES

/obj/item/food/meat/steak/meatproduct
	name = "thermally processed meat product"
	//icon_state = "meatproductsteak"
	tastes = list("enhanced char" = 2, "suspicious tenderness" = 2, "natural & artificial dyes" = 2, "emulsifying agents" = 1)

/obj/item/food/meat/steak/synth
	name = "synthsteak"
	desc = "A synthetic meat steak. It doesn't look quite right, now does it?"
	icon_state = "meatsteak"
	tastes = list("meat" = 4, "cryoxandone" = 1)

/obj/item/food/meat/steak/ashflake
	name = "ashflaked steak"
	desc = "A common delicacy among miners."
	icon_state = "ashsteak"
	food_reagents = list(
		/datum/reagent/consumable/vitfro = 2
	)
	tastes = list("tough meat" = 2, "bubblegum" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/dolphinmeat
	name = "dolphin fillet"
	desc = "A fillet of spess dolphin meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 6
	tastes = list("fish" = 1,"cruelty" = 2)
	foodtypes = MEAT

//////////////////////////////// MEAT CUTLETS ///////////////////////////////////////////////////////

//Raw cutlets

/obj/item/food/meat/rawcutlet
	name = "raw cutlet"
	desc = "A raw meat cutlet."
	icon_state = "rawcutlet"
	microwaved_type = /obj/item/food/meat/cutlet/plain
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 1
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT | RAW
	var/meat_type = "meat"

/*
/obj/item/food/meat/rawcutlet/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/plain)
*/

/obj/item/food/meat/rawcutlet/OnCreatedFromProcessing(mob/living/user, obj/item/work_tool, list/chosen_option, atom/original_atom)
	. = ..()
	if(istype(original_atom, /obj/item/food/meat/slab))
		var/obj/item/food/meat/slab/original_slab = original_atom
		var/mutable_appearance/filling = mutable_appearance(icon, "rawcutlet_coloration")
		filling.color = original_slab.slab_color
		add_overlay(filling)
		name = "raw [original_atom.name] cutlet"
		meat_type = original_atom.name

/obj/item/food/meat/rawcutlet/plain
	foodtypes = MEAT

/obj/item/food/meat/rawcutlet/plain/human
	microwaved_type = /obj/item/food/meat/cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtypes = MEAT | RAW | GORE

/*
/obj/item/food/meat/rawcutlet/plain/human/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/plain/human)
*/

/obj/item/food/meat/rawcutlet/plain/human/OnCreatedFromProcessing(mob/living/user, obj/item/I, list/chosen_option, atom/original_atom)
	. = ..()
	if(istype(original_atom, /obj/item/food/meat))
		var/obj/item/food/meat/origin_meat = original_atom
		subjectname = origin_meat.subjectname
		subjectjob = origin_meat.subjectjob
		if(subjectname)
			name = "raw [origin_meat.subjectname] cutlet"
		else if(subjectjob)
			name = "raw [origin_meat.subjectjob] cutlet"

/obj/item/food/meat/rawcutlet/killertomato
	name = "raw killer tomato cutlet"
	tastes = list("tomato" = 1)
	foodtypes = FRUIT
	microwaved_type = /obj/item/food/meat/cutlet/killertomato

/*
/obj/item/food/meat/rawcutlet/killertomato/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/killertomato)
*/

/obj/item/food/meat/rawcutlet/bear
	name = "raw bear cutlet"
	tastes = list("meat" = 1, "salmon" = 1)
	microwaved_type = /obj/item/food/meat/cutlet/bear

/*
/obj/item/food/meat/rawcutlet/bear/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/bear)
*/

/obj/item/food/meat/rawcutlet/xeno
	name = "raw xeno cutlet"
	tastes = list("meat" = 1, "acid" = 1)
	microwaved_type = /obj/item/food/meat/cutlet/xeno

/*
/obj/item/food/meat/rawcutlet/xeno/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/xeno)
*/

/obj/item/food/meat/rawcutlet/spider
	name = "raw spider cutlet"
	tastes = list("cobwebs" = 1)
	microwaved_type = /obj/item/food/meat/cutlet/spider

/*
/obj/item/food/meat/rawcutlet/spider/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/spider)
*/

/obj/item/food/meat/rawcutlet/gondola
	name = "raw gondola cutlet"
	tastes = list("meat" = 1, "tranquility" = 1)
	microwaved_type = /obj/item/food/meat/cutlet/gondola

/*
/obj/item/food/meat/rawcutlet/gondola/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/gondola)
*/

/obj/item/food/meat/rawcutlet/penguin
	name = "raw penguin cutlet"
	tastes = list("beef" = 1, "cod fish" = 1)
	microwaved_type = /obj/item/food/meat/cutlet/penguin

/*
/obj/item/food/meat/rawcutlet/penguin/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/penguin)
*/

/obj/item/food/meat/rawcutlet/chicken
	name = "raw chicken cutlet"
	tastes = list("chicken" = 1)
	microwaved_type = /obj/item/food/meat/cutlet/chicken

/*
/obj/item/food/meat/rawcutlet/chicken/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/chicken)
*/

/obj/item/food/meat/rawcutlet/grub //grub meat is small, so its in cutlets
	name = "redgrub cutlet"
	desc = "A tough, slimy cut of raw Redgrub. Very toxic, and probably infectious, but delicious when cooked. Do not handle without proper biohazard equipment."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "grubmeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/toxin/slimejelly = 2
	)
	bite_consumption = 1
	tastes = list("slime" = 1, "grub" = 1)
	foodtypes = RAW | MEAT | TOXIC
	microwaved_type = /obj/item/food/meat/cutlet/grub

/*
/obj/item/food/meat/rawcutlet/grub/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/meat/cutlet/grub)
*/

//Cooked cutlets

//Cooked cutlets

/obj/item/food/meat/cutlet
	name = "cutlet"
	desc = "A cooked meat cutlet."
	icon_state = "cutlet"
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT

/obj/item/food/meat/cutlet/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))

///This proc handles setting up the correct meat name for the cutlet, this should definitely be changed with the food rework.
/obj/item/food/meat/cutlet/proc/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency)
	SIGNAL_HANDLER

	if(!istype(source_item, /obj/item/food/meat/rawcutlet))
		return

	var/obj/item/food/meat/rawcutlet/original_cutlet = source_item
	name = "[original_cutlet.meat_type] cutlet"

/obj/item/food/meat/cutlet/plain

/obj/item/food/meat/cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtypes = MEAT | GORE

/obj/item/food/meat/cutlet/plain/human/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency)
	. = ..()
	if(!istype(source_item, /obj/item/food/meat))
		return

	var/obj/item/food/meat/origin_meat = source_item
	if(subjectname)
		name = "[origin_meat.subjectname] [initial(name)]"
	else if(subjectjob)
		name = "[origin_meat.subjectjob] [initial(name)]"

/obj/item/food/meat/cutlet/killertomato
	name = "killer tomato cutlet"
	tastes = list("tomato" = 1)
	foodtypes = FRUIT

/obj/item/food/meat/cutlet/bear
	name = "bear cutlet"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/food/meat/cutlet/xeno
	name = "xeno cutlet"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/food/meat/cutlet/spider
	name = "spider cutlet"
	tastes = list("cobwebs" = 1)

/obj/item/food/meat/cutlet/gondola
	name = "gondola cutlet"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/food/meat/cutlet/penguin
	name = "penguin cutlet"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/food/meat/cutlet/chicken
	name = "chicken cutlet"
	tastes = list("chicken" = 1)

/obj/item/food/meat/cutlet/grub
	name = "redgrub rind"
	desc = "Cooking redgrub meat causes it to 'pop', and renders it non-toxic, crunchy and deliciously sweet"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "grubsteak"
	trash_type = null
	bite_consumption = 1
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/medicine/regen_jelly = 1
	)
	tastes = list("jelly" = 1, "sweet meat" = 1, "oil" = 1)
	foodtypes = MEAT
