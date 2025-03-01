//////////PIZZA//////////

/obj/item/food/pizza
	icon = 'icons/obj/food/pizza.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 28,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2
	/// what pizza you end up with when you cut it
	var/cut_pizza
	///What label pizza boxes use if this pizza spawns in them.
	var/boxtag = ""

//////////RAW PIZZA//////////

/obj/item/food/pizza/raw
	foodtypes =  GRAIN | DAIRY | VEGETABLES | RAW
	cut_pizza = null
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/make_processable()
	if(cut_pizza)
		AddElement(/datum/element/processable, TOOL_KNIFE, cut_pizza, 1, 3 SECONDS, table_required = TRUE, /*screentip_verb = "Slice"*/)
		AddElement(/datum/element/processable, TOOL_SAW, cut_pizza, 1, 4.5 SECONDS, table_required = TRUE, /*screentip_verb = "Slice"*/)
		AddElement(/datum/element/processable, TOOL_SCALPEL, cut_pizza, 1, 6 SECONDS, table_required = TRUE, /*screentip_verb = "Slice"*/)

//////////PIZZA SLICE//////////

/obj/item/food/pizzaslice
	icon = 'icons/obj/food/pizza.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtypes = GRAIN | DAIRY | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	decomp_type = /obj/item/food/pizzaslice/moldy
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/make_processable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, 1, 1 SECONDS, table_required = TRUE, /*screentip_verb = "Flatten"*/)

/obj/item/food/pizza/cut // Pizza cut versions, gives at slice until it runs out of slices to give, does not use pizza/nameofthepizza/cut, but rather pizza/cut/nameofthepizza
	name = "Cut Pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut" //we use the margherita one as template
	var/slices = 8
	var/obj/item/food/pizza/cut/slice_type
	/// this var used to be used for spawning 6 slices when cutting a pizza(for some reason, it's common sense pizzas are cut in 8), but now it determines
	/// what type of slice you pull out of each pizza when right clicking. It was originally on the whole pizzas, but now is on the cut versions

/obj/item/food/pizza/cut/attack_hand_secondary(mob/living/user)
	. = ..()
	user.visible_message(span_notice("[user] takes a slice of pizza from [src]."), span_notice("You take a slice of pizza from [src]."))
	slice_type = new(get_turf(src))
	user.put_in_hands(slice_type)
	slices--
	if(slices <= 0)
		qdel(src)
	else
		icon_state = "[initial(icon_state)][slices]"
		update_appearance()
	return

//////////PIZZA TYPES//////////
//////////MARGHERITA//////////

/obj/item/food/pizza/margherita
	name = "pizza margherita"
	desc = "The most cheezy pizza in galaxy."
	icon_state = "pizzamargherita"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	cut_pizza = /obj/item/food/pizza/cut/margherita
	boxtag = "Margherita Deluxe"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/margherita/raw
	name = "raw pizza margherita"
	icon_state = "pizzamargherita_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	cut_pizza = null

/obj/item/food/pizza/margherita/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/margherita, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizza/margherita/robo
	food_reagents = list(
		/datum/reagent/nanomachines = 70,
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)

/obj/item/food/pizzaslice/margherita
	name = "margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizzaslice/margherita/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, null, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 12)

/obj/item/food/pizza/cut/margherita
	name = "pizza margherita"
	icon_state = "pizzamargherita8"
	slice_type = /obj/item/food/pizzaslice/margherita


//////////MEAT//////////

/obj/item/food/pizza/meat
	name = "meatpizza"
	desc = "Greasy pizza with delicious meat."
	icon_state = "meatpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 8
	)
	foodtypes = GRAIN | VEGETABLES| DAIRY | MEAT
	cut_pizza = /obj/item/food/pizza/cut/meat
	boxtag = "Meatlovers' Supreme"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/meat/raw
	name = "raw meatpizza"
	icon_state = "meatpizza_raw"
	foodtypes =  GRAIN | VEGETABLES| DAIRY | MEAT | RAW
	cut_pizza = null

/obj/item/food/pizza/meat/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/meat, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/meat
	name = "meatpizza slice"
	desc = "A nutritious slice of meatpizza."
	icon_state = "meatpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/cut/meat
	name = "meatpizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/meat

//////////MUSHROOM//////////

/obj/item/food/pizza/mushroom
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 28,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	cut_pizza = /obj/item/food/pizza/cut/mushroom
	boxtag = "Mushroom Special"
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/mushroom/raw
	name = "raw mushroom pizza"
	icon_state = "mushroompizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	cut_pizza = null

/obj/item/food/pizza/mushroom/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/mushroom, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/mushroom
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizza/cut/mushroom
	name = "Mushroom pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/mushroom

//////////VEGETABLE//////////

/obj/item/food/pizza/vegetable
	name = "vegetable pizza"
	desc = "Not one of the Tomatos Sapiens were harmed during the making of this pizza."
	icon_state = "vegetablepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	cut_pizza = /obj/item/food/pizza/cut/vegetable
	boxtag = "Gourmet Vegetable"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/vegetable/raw
	name = "raw vegetable pizza"
	icon_state = "vegetablepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	cut_pizza = null

/obj/item/food/pizza/vegetable/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/vegetable, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/vegetable
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/cut/vegetable
	name = "Vegetable pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/vegetable

//////////DONKPOCKET//////////

/obj/item/food/pizza/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 15,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/medicine/omnizine = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD
	cut_pizza = /obj/item/food/pizza/cut/donkpocket
	boxtag = "Bangin' Donk"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/donkpocket/raw
	name = "raw donkpocket pizza"
	icon_state = "donkpocketpizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD | RAW
	cut_pizza = null

/obj/item/food/pizza/donkpocket/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/donkpocket, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/cut/donkpocket
	name = "Donkpocket pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/donkpocket

//////////DANK//////////

/obj/item/food/pizza/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/doctor_delight = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	cut_pizza = /obj/item/food/pizza/cut/dank
	boxtag = "Fresh Herb"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/dank/raw
	name = "raw dank pizza"
	icon_state = "dankpizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | RAW
	cut_pizza = null

/obj/item/food/pizza/dank/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/dank, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/cut/dank
	name = "Dank pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/dank

//////////SASSYSAGE//////////

/obj/item/food/pizza/sassysage
	name = "sassysage pizza"
	desc = "You can almost taste the sassiness."
	icon_state = "sassysagepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 15,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	cut_pizza = /obj/item/food/pizza/cut/sassysage
	boxtag = "Sausage Lovers"
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/sassysage/raw
	name = "raw sassysage pizza"
	icon_state = "sassysagepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | RAW
	cut_pizza = null

/obj/item/food/pizza/sassysage/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/sassysage, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/cut/sassysage
	name = "Sassysage pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/sassysage

//////////PINEAPPLE//////////

/obj/item/food/pizza/pineapple
	name = "\improper Hawaiian pizza"
	desc = "The pizza equivalent of Einstein's riddle."
	icon_state = "pineapplepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/pineapplejuice = 8
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	cut_pizza = /obj/item/food/pizza/cut/pineapple
	boxtag = "Honolulu Chew"
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizza/pineapple/raw
	name = "raw Hawaiian pizza"
	icon_state = "pineapplepizza_raw"
	foodtypes =  GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE | RAW
	cut_pizza = null

/obj/item/food/pizza/pineapple/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/pineapple, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/pizzaslice/pineapple
	name = "\improper Hawaiian pizza slice"
	desc = "A slice of delicious controversy."
	icon_state = "pineapplepizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizza/cut/pineapple
	name = "Hawaiian pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/pineapple

//////////ARNOLD//////////

/obj/item/food/pizza/arnold
	name = "\improper Arnold pizza"
	desc = "Hello, you've reached Arnold's pizza shop. I'm not here now, I'm out killing pepperoni."
	icon_state = "arnoldpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/iron = 10,
		/datum/reagent/medicine/omnizine = 30
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	cut_pizza = /obj/item/food/pizza/cut/arnold
	boxtag = "9mm Pepperoni"
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizza/arnold/raw
	name = "raw Arnold pizza"
	icon_state = "arnoldpizza_raw"
	foodtypes =  GRAIN | DAIRY | VEGETABLES | RAW
	cut_pizza = null

/obj/item/food/pizza/arnold/raw/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/pizza/arnold, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/food/proc/try_break_off(mob/living/M, mob/living/user) //maybe i give you a pizza maybe i break off your arm
	if(prob(50) || (M != user) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return
	var/obj/item/bodypart/l_arm = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = user.get_bodypart(BODY_ZONE_R_ARM)
	var/did_the_thing = (l_arm?.dismember() || r_arm?.dismember()) //not all limbs can be removed, so important to check that we did. the. thing.
	if(!did_the_thing)
		return
	to_chat(user, span_userdanger("Maybe I'll give you a pizza, maybe I'll break off your arm.")) //makes the reference more obvious
	user.visible_message(span_warning("\The [src] breaks off [user]'s arm!"), span_warning("\The [src] breaks off your arm!"))
	playsound(user,pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg','sound/misc/desecration-01.ogg') ,50, TRUE, -1)

/obj/item/food/proc/i_kill_you(obj/item/I, mob/user)
	if(istype(I, /obj/item/food/pineappleslice))
		to_chat(user, "<font color='red' size='7'>If you want something crazy like pineapple, I'll kill you.</font>") //this is in bigger text because it's hard to spam something that gibs you, and so that you're perfectly aware of the reason why you died
		user.investigate_log("has been gibbed by putting pineapple on an arnold pizza.", INVESTIGATE_DEATHS)
		user.gib() //if you want something crazy like pineapple, i'll kill you
	else if(istype(I, /obj/item/food/grown/mushroom) && iscarbon(user))
		to_chat(user, span_userdanger("So, if you want mushroom, shut up.")) //not as large as the pineapple text, because you could in theory spam it
		var/mob/living/carbon/shutup = user
		shutup.gain_trauma(/datum/brain_trauma/severe/mute)

/obj/item/food/pizza/arnold/attack(mob/living/M, mob/living/user)
	. = ..()
	try_break_off(M, user)

/obj/item/food/pizza/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

/obj/item/food/pizzaslice/arnold
	name = "\improper Arnold pizza slice"
	desc = "I come over, maybe I give you a pizza, maybe I break off your arm."
	icon_state = "arnoldpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	foodtypes = GRAIN | VEGETABLES | DAIRY | MEAT
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/pizzaslice/arnold/attack(mob/living/M, mob/living/user)
	. =..()
	try_break_off(M, user)

/obj/item/food/pizzaslice/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

/obj/item/food/pizza/cut/arnold
	name = "Arnold pizza"
	desc = "A cut pizza. Get your slice!"
	icon_state = "pizzamargheritacut"
	slice_type = /obj/item/food/pizzaslice/arnold

//////////MOLDY PIZZA//////////
// NOT Used in cytobiology.
/obj/item/food/pizzaslice/moldy
	name = "moldy pizza slice"
	desc = "This was once a perfectly good slice of pizza pie, but now it lies here, rancid and bursting with spores. \
		What a bummer! But we should not dwell on the past, only look towards the future."
	icon_state = "moldy_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/tomatojuice = 1,
		/datum/reagent/toxin/amatoxin = 2,
	)
	tastes = list("stale crust" = 1, "rancid cheese" = 2, "mushroom" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | GROSS
	preserved_food = TRUE

/obj/item/food/pizzaslice/moldy/bacteria
	name = "bacteria rich moldy pizza slice"
	desc = "Not only is this once delicious pizza encrusted with a layer of spore-spewing fungus, it also seems to shift and slide when unattended, teeming with new life."

//////////ANT PIZZA//////////
//now with more ants.
/obj/item/food/pizzaslice/ants
	name = "\improper Ant Party pizza slice"
	desc = "The key to a perfect slice of pizza is not to overdo it with the ants."
	icon_state = "antpizzaslice"
	food_reagents = list(
		/datum/reagent/ants = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)
	foodtypes = GRAIN | VEGETABLES | DAIRY | BUGS
