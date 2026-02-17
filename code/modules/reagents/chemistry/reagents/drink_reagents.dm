

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/consumable/orangejuice
	name = "Orange Juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "oranges"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/orangejuice

/datum/glass_style/has_foodtype/drinking_glass/orangejuice
	required_drink_type = /datum/reagent/consumable/orangejuice
	name = "glass of orange juice"
	desc = "Vitamins! Yay!"
	icon_state = "glass_orange"
	drink_type = FRUIT | BREAKFAST

/datum/glass_style/has_foodtype/juicebox/orangejuice
	required_drink_type = /datum/reagent/consumable/orangejuice
	name = "orange juice box"
	desc = "A great source of vitamins. Stay healthy!"
	icon_state = "orangebox"
	drink_type = FRUIT | BREAKFAST

/datum/reagent/consumable/orangejuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.getOxyLoss() && DT_PROB(16, delta_time))
		affected_mob.adjustOxyLoss(-1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/tomatojuice
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "tomatoes"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/tomatojuice

/datum/glass_style/shot_glass/blood
	required_drink_type = /datum/reagent/blood
	icon_state = "shotglassred"

/datum/glass_style/drinking_glass/blood
	required_drink_type = /datum/reagent/blood
	name = "glass of tomato juice"
	desc = "Are you sure this is tomato juice?"
	icon_state = "glass_red"

/datum/reagent/consumable/tomatojuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.getFireLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(burn = 1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/limejuice
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "unbearable sourness"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/limejuice

/datum/glass_style/drinking_glass/limejuice
	required_drink_type = /datum/reagent/consumable/limejuice
	name = "glass of lime juice"
	desc = "A glass of sweet-sour lime juice."
	icon_state = "glass_green"

/datum/reagent/consumable/limejuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.getToxLoss() && DT_PROB(10, delta_time))
		affected_mob.adjustToxLoss(-1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/carrotjuice
	name = "Carrot Juice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0
	chemical_flags = CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "carrots"

/datum/glass_style/drinking_glass/carrotjuice
	required_drink_type = /datum/reagent/consumable/carrotjuice
	name = "glass of  carrot juice"
	desc = "It's just like a carrot but without crunching."
	icon_state = "carrotjuice"

/datum/reagent/consumable/carrotjuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_eye_blur(-2 SECONDS * REM * delta_time)
	affected_mob.adjust_blindness(-1 * REM * delta_time)
	switch(current_cycle)
		if(21 to 110)
			if(DT_PROB(100 * (1 - (sqrt(110 - current_cycle) / 10)), delta_time))
				affected_mob.cure_nearsighted(list(EYE_DAMAGE))
		if(110 to INFINITY)
			affected_mob.cure_nearsighted(list(EYE_DAMAGE))

/datum/reagent/consumable/berryjuice
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" // rgb: 134, 51, 51
	chemical_flags = NONE
	taste_description = "berries"

/datum/glass_style/drinking_glass/berryjuice
	required_drink_type = /datum/reagent/consumable/berryjuice
	name = "glass of berry juice"
	desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/consumable/applejuice
	name = "Apple Juice"
	description = "The sweet juice of an apple, fit for all ages."
	color = "#ECFF56" // rgb: 236, 255, 86
	chemical_flags = NONE
	taste_description = "apples"

/datum/glass_style/has_foodtype/juicebox/applejuice
	required_drink_type = /datum/reagent/consumable/applejuice
	name = "apple juice box"
	desc = "Sweet apple juice. Don't be late for school!"
	icon_state = "juicebox"
	drink_type = FRUIT

/datum/reagent/consumable/poisonberryjuice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "berries"

/datum/glass_style/drinking_glass/poisonberryjuice
	required_drink_type = /datum/reagent/consumable/poisonberryjuice
	name = "glass of berry juice"
	desc = "Berry juice. Or maybe it's poison. Who cares?"

/datum/reagent/consumable/poisonberryjuice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/consumable/watermelonjuice
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
	chemical_flags = NONE
	taste_description = "juicy watermelon"

/datum/glass_style/drinking_glass/watermelonjuice
	required_drink_type = /datum/reagent/consumable/watermelonjuice
	name = "glass of watermelon juice"
	desc = "A glass of watermelon juice."
	icon_state = "glass_red"

/datum/reagent/consumable/lemonjuice
	name = "Lemon Juice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sourness"

/datum/glass_style/drinking_glass/lemonjuice
	required_drink_type = /datum/reagent/consumable/lemonjuice
	name = "glass of lemon juice"
	desc = "Sour..."
	icon_state = "lemonglass"

/datum/reagent/consumable/banana
	name = "Banana Juice"
	description = "The raw essence of a banana. HONK"
	color = "#863333" // rgb: 175, 175, 0
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "banana"

/datum/glass_style/drinking_glass/banana
	required_drink_type = /datum/reagent/consumable/banana
	name = "glass of banana juice"
	desc = "The raw essence of a banana. HONK."
	icon_state = "banana"

/datum/reagent/consumable/banana/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if((ishuman(affected_mob) && affected_mob.job == JOB_NAME_CLOWN) || ismonkey(affected_mob))
		affected_mob.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/nothing
	name = "Nothing"
	description = "Absolutely nothing."
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "nothing"

/datum/glass_style/shot_glass/nothing
	required_drink_type = /datum/reagent/consumable/nothing
	icon_state = "shotglass"

/datum/glass_style/drinking_glass/nothing
	required_drink_type = /datum/reagent/consumable/nothing
	name = "nothing"
	desc = "Absolutely nothing."
	icon_state = "nothing"

/datum/reagent/consumable/nothing/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(ishuman(affected_mob) && HAS_TRAIT(affected_mob, TRAIT_MIMING))
		affected_mob.set_silence_if_lower(MIMEDRINK_SILENCE_DURATION)
		affected_mob.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/laughter
	name = "Laughter"
	description = "Some say that this is the best medicine, but recent studies have proven that to be untrue."
	metabolization_rate = INFINITY
	color = "#FF4DD2"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "laughter"

/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.emote("laugh")
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_laughter)

/datum/reagent/consumable/laughter/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	if(!ishuman(exposed_mob))
		return

	var/mob/living/carbon/human/human = exposed_mob
	var/datum/component/mood/mood = human.GetComponent(/datum/component/mood)
	if(mood.get_event("slipped"))
		SEND_SIGNAL(human, COMSIG_ADD_MOOD_EVENT, "laughter", /datum/mood_event/funny_prank)
		SEND_SIGNAL(human, COMSIG_CLEAR_MOOD_EVENT, "slipped")
		human.AdjustKnockdown(-20)

/datum/reagent/consumable/superlaughter
	name = "Super Laughter"
	description = "Funny until you're the one laughing."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#FF4DD2"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "laughter"

/datum/reagent/consumable/superlaughter/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(16, delta_time))
		affected_mob.visible_message(
			span_danger("[affected_mob] bursts out into a fit of uncontrollable laughter!"),
			span_userdanger("You burst out in a fit of uncontrollable laughter!"),
		)
		affected_mob.Stun(5)
		SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_superlaughter)

/datum/reagent/consumable/potato_juice
	name = "Potato Juice"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chemical_flags = NONE
	taste_description = "irish sadness"

/datum/glass_style/drinking_glass/potato_juice
	required_drink_type = /datum/reagent/consumable/potato_juice
	name = "glass of potato juice"
	desc = "Bleh..."
	icon_state = "glass_brown"

/datum/reagent/consumable/grapejuice
	name = "Grape Juice"
	description = "The juice of a bunch of grapes. Guaranteed non-alcoholic."
	color = "#290029" // dark purple
	chemical_flags = NONE
	taste_description = "grape soda"

/datum/glass_style/has_foodtype/juicebox/grapejuice
	required_drink_type = /datum/reagent/consumable/grapejuice
	name = "grape juice box"
	desc = "Tasty grape juice in a fun little container. Non-alcoholic!"
	icon_state = "grapebox"
	drink_type = FRUIT

/datum/reagent/consumable/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "milk"
	overdose_threshold = 500 //High calcium intake is bad for bone health. OD is exactly like having taken a normal-ish bone hurt juice. If anyone hits the superoverdose, well I'll be damned
	default_container = /obj/item/reagent_containers/condiment/milk

/datum/glass_style/has_foodtype/drinking_glass/milk
	required_drink_type = /datum/reagent/consumable/milk
	name = "glass of milk"
	desc = "White and nutritious goodness!"
	icon_state = "glass_white"
	drink_type = DAIRY | BREAKFAST

/datum/glass_style/has_foodtype/juicebox/milk
	required_drink_type = /datum/reagent/consumable/milk
	name = "carton of milk"
	desc = "An excellent source of calcium for growing space explorers."
	icon_state = "milkbox"
	drink_type = DAIRY | BREAKFAST

/datum/reagent/consumable/milk/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.reagents.has_reagent(/datum/reagent/consumable/capsaicin))
		affected_mob.reagents.remove_reagent(/datum/reagent/consumable/capsaicin, 1 * delta_time)

	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/*See block comment in ../milk/overdose_process(mob/living/carbon/affected_mob) for calculation and explanation of why this exists and why 5 was chosen
* For best results use in tandem with method outlined in this comment
*/
/datum/reagent/consumable/milk/overdose_start(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.reagents.add_reagent(/datum/reagent/toxin/bonehurtingjuice, 5) //The integer here should match var/starting_amount in ../milk/overdose_process(mob/living/carbon/affected_mob)

/datum/reagent/consumable/milk/overdose_process(mob/living/carbon/affected_mob)
	. = ..()
	var/datum/reagent/converted_reagent = /datum/reagent/toxin/bonehurtingjuice //Needed to get the metabolism for desired reagent, exists solely for brevity compared to /datum/reagent/category/reagent.metabolization_rate
	var/minimum_cycles = overdose_threshold/metabolization_rate //minimum_cycles is the number of ticks for an amount of units equal to the overdose threshold to process.
	var/amount_to_add = 45 / minimum_cycles + initial(converted_reagent.metabolization_rate) //amount_to_add is the calculated amount to add per tick to meet ensure that target_units after minimum_cycle ticks.
	affected_mob.reagents.add_reagent(/datum/reagent/toxin/bonehurtingjuice, amount_to_add)
	/*In depth explanation by DatBoiTim
	* This number will not put more than 50u of BHJ into their system if only 500u(ie bare minimum OD).
	*  milk.overdose_threshold / milk.metabolization_rate = minimum_cycles = 1,250 cycles
	* (target_units / total_cycles) + BHJ.metabolization_rate = amount_to_add = .44
	* However, regular livers process 1u per tick of any toxin if it is under 3u. This does not account for others, since most others are likely upgrades, and having a workaround for those upgrades defeats their purpose.
	* Meaning we need a starting amount to offset this which is more than three. Ideally this should yield the lowest amount of decimal spaces to save space, while being as low as possible.
	* In this case starting_amount = 5.
	* ( (target_units - starting_amount) / minimum_cycles) + BHJ.metabolization_rate = amount_to_add = .436
	* Copy pasting the above and changing /datum/reagent/toxin/bonehurtingjuice as well as the documentation to be accurate for another type path will work so long as the reagent using this has an OD threshold.
	* You can just change the target units and should double check that the starting amount meets outlined criteria.
	*/

/datum/reagent/consumable/soymilk
	name = "Soy Milk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "soy milk"
	default_container = /obj/item/reagent_containers/condiment/soymilk

/datum/glass_style/drinking_glass/soymilk
	required_drink_type = /datum/reagent/consumable/soymilk
	name = "glass of soy milk"
	desc = "White and nutritious soy goodness!"
	icon_state = "glass_white"

/datum/reagent/consumable/soymilk/on_mob_add(mob/living/carbon/affected_mob, amount)
	. = ..()
	affected_mob.client?.give_award(/datum/award/achievement/misc/soy, affected_mob)

/datum/reagent/consumable/soymilk/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "creamy milk"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/cream

/datum/glass_style/drinking_glass/cream
	required_drink_type = /datum/reagent/consumable/cream
	name = "glass of cream"
	desc = "Ewwww..."
	icon_state = "glass_white"

/datum/reagent/consumable/cream/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/coffee
	name = "Coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	chemical_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitterness"

/datum/glass_style/drinking_glass/coffee
	required_drink_type = /datum/reagent/consumable/coffee
	name = "glass of coffee"
	desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
	icon_state = "glass_brown"

/datum/reagent/consumable/coffee/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)

/datum/reagent/consumable/coffee/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * delta_time)
	//310.15 is the normal bodytemp.
	affected_mob.adjust_bodytemperature(25 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.reagents.has_reagent(/datum/reagent/consumable/frostoil))
		affected_mob.reagents.remove_reagent(/datum/reagent/consumable/frostoil, 5 * REM * delta_time)

/datum/reagent/consumable/tea
	name = "Tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	chemical_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	taste_description = "tart black tea"
	default_container = /obj/item/reagent_containers/cup/glass/mug/tea

/datum/glass_style/drinking_glass/tea
	required_drink_type = /datum/reagent/consumable/tea
	name = "glass of tea"
	desc = "Drinking it from here would not seem right."
	icon_state = "teaglass"

/datum/reagent/consumable/tea/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-4 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-2 SECONDS * REM * delta_time)
	affected_mob.adjust_jitter(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-20 * REM * delta_time)
	affected_mob.adjust_bodytemperature(20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())

	if(affected_mob.getToxLoss() && DT_PROB(10, delta_time))
		affected_mob.adjustToxLoss(-1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/lemonade
	name = "Lemonade"
	description = "Sweet, tangy lemonade. Good for the soul."
	color = "#daef60"
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "sunshine and summertime"

/datum/glass_style/drinking_glass/lemonade
	required_drink_type = /datum/reagent/consumable/lemonade
	name = "pitcher of lemonade"
	desc = "This drink leaves you feeling nostalgic for some reason."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "lemonpitcher"

/datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	description = "Encourages the patient to go golfing."
	color = "#FFB766"
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	nutriment_factor = 10 * REAGENTS_METABOLISM
	taste_description = "bitter tea"

/datum/glass_style/drinking_glass/arnold_palmer
	required_drink_type = /datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	desc = "You feel like taking a few golf swings after a few swigs of this."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "arnold_palmer"

/datum/reagent/consumable/tea/arnold_palmer/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(2.5, delta_time))
		to_chat(affected_mob, span_notice(pick("You remember to square your shoulders.","You remember to keep your head down.","You can't decide between squaring your shoulders and keeping your head down.","You remember to relax.","You think about how someday you'll get two strokes off your golf game.")))

/datum/reagent/consumable/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	chemical_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 0
	taste_description = "bitter coldness"

/datum/glass_style/drinking_glass/icecoffee
	required_drink_type = /datum/reagent/consumable/icecoffee
	name = "iced coffee"
	desc = "A drink to perk you up and refresh you!"
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "icedcoffeeglass"

/datum/reagent/consumable/icecoffee/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)

/datum/reagent/consumable/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/actor."
	color = "#104038" // rgb: 16, 64, 56
	chemical_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	taste_description = "sweet tea"

/datum/glass_style/drinking_glass/icetea
	required_drink_type = /datum/reagent/consumable/icetea
	name = "iced tea"
	desc = "All natural, antioxidant-rich flavour sensation."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "icedteaglass"

/datum/reagent/consumable/icetea/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-4 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-2 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

	if(affected_mob.getToxLoss() && DT_PROB(10, delta_time))
		affected_mob.adjustToxLoss(-1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/space_cola
	name = "Cola"
	description = "A refreshing beverage."
	color = "#100800" // rgb: 16, 8, 0
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cola"

/datum/glass_style/drinking_glass/space_cola
	required_drink_type = /datum/reagent/consumable/space_cola
	name = "glass of Space Cola"
	desc = "A glass of refreshing Space Cola."
	icon_state = "glass_brown"

/datum/reagent/consumable/space_cola/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "the future"

/datum/glass_style/drinking_glass/nuka_cola
	required_drink_type = /datum/reagent/consumable/nuka_cola
	name = "glass of Nuka Cola"
	desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."
	icon = 'icons/obj/drinks/soda.dmi'
	icon_state = "nuka_colaglass"

/datum/reagent/consumable/nuka_cola/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)

/datum/reagent/consumable/nuka_cola/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)

/datum/reagent/consumable/nuka_cola/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(40 SECONDS * REM * delta_time)
	affected_mob.set_drugginess(1 MINUTES * REM * delta_time)
	affected_mob.adjust_dizzy(3 SECONDS * REM * delta_time)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-4 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

	if(SSradiation.can_irradiate_basic(affected_mob))
		var/datum/component/irradiated/irradiated_component = affected_mob.GetComponent(/datum/component/irradiated)
		if(!irradiated_component)
			irradiated_component = affected_mob.AddComponent(/datum/component/irradiated)
		irradiated_component.adjust_intensity(3 * REM * delta_time)

/datum/reagent/consumable/grey_bull
	name = "Grey Bull"
	description = "Grey Bull, it gives you gloves!"
	color = "#EEFF00" // rgb: 238, 255, 0
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "carbonated oil"
	metabolized_traits = list(TRAIT_SHOCKIMMUNE)

/datum/glass_style/drinking_glass/grey_bull
	required_drink_type = /datum/reagent/consumable/grey_bull
	name = "glass of Grey Bull"
	desc = "Surprisingly it isn't grey."
	icon_state = "grey_bull_glass"

/datum/reagent/consumable/grey_bull/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(40 SECONDS * REM * delta_time)
	affected_mob.adjust_dizzy(2 SECONDS * REM * delta_time)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/spacemountainwind
	name = "SM Wind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sweet citrus soda"

/datum/glass_style/drinking_glass/spacemountainwind
	required_drink_type = /datum/reagent/consumable/spacemountainwind
	name = "glass of Space Mountain Wind"
	desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
	icon_state = "Space_mountain_wind_glass"

/datum/reagent/consumable/spacemountainwind/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-14 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-2 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)

/datum/reagent/consumable/dr_gibb
	name = "Dr. Gibb"
	description = "A delicious blend of 42 different flavours."
	color = "#102000" // rgb: 16, 32, 0
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cherry soda" // FALSE ADVERTISING

/datum/glass_style/drinking_glass/dr_gibb
	required_drink_type = /datum/reagent/consumable/dr_gibb
	name = "glass of Dr. Gibb"
	desc = "Dr. Gibb. Not as dangerous as the container_name might imply."
	icon_state = "dr_gibb_glass"

/datum/reagent/consumable/dr_gibb/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-12 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/space_up
	name = "Space-Up"
	description = "Tastes like a hull breach in your mouth."
	color = COLOR_VIBRANT_LIME
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cherry soda"

/datum/glass_style/drinking_glass/space_up
	required_drink_type = /datum/reagent/consumable/space_up
	name = "glass of Space-Up"
	desc = "Space-up. It helps you keep your cool."
	icon_state = "space-up_glass"

/datum/reagent/consumable/space_up/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	color = "#8CFF00" // rgb: 135, 255, 0
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "tangy lime and lemon soda"

/datum/glass_style/drinking_glass/lemon_lime
	required_drink_type = /datum/reagent/consumable/lemon_lime
	name = "glass of lemon-lime"
	desc = "You're pretty certain a real fruit has never actually touched this."
	icon_state = "glass_yellow"

/datum/reagent/consumable/lemon_lime/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/pwr_game
	name = "Pwr Game"
	description = "The only drink with the PWR that true gamers crave."
	color = "#9385bf" // rgb: 58, 52, 75
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sweet and salty tang"

/datum/glass_style/drinking_glass/pwr_game
	required_drink_type = /datum/reagent/consumable/pwr_game
	name = "glass of Pwr Game"
	desc = "Goes well with a Vlad's salad."
	icon_state = "glass_red"

/datum/reagent/consumable/pwr_game/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/shamblers
	name = "Shambler's Juice"
	description = "~Shake me up some of that Shambler's Juice!~"
	color = "#f00060" // rgb: 94, 0, 38
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "carbonated metallic soda"

/datum/glass_style/drinking_glass/shamblers
	required_drink_type = /datum/reagent/consumable/shamblers
	name = "glass of Shambler's juice"
	desc = "Mmm mm, shambly."
	icon_state = "glass_red"

/datum/reagent/consumable/shamblers/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-8 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/sodawater
	name = "Soda Water"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "carbonated water"

/datum/glass_style/drinking_glass/sodawater
	required_drink_type = /datum/reagent/consumable/sodawater
	name = "glass of soda water"
	desc = "Soda water. Why not make a scotch and soda?"
	icon_state = "glass_clear"

/datum/reagent/consumable/sodawater/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/tonic
	name = "Tonic Water"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#0064C8" // rgb: 0, 100, 200
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "tart and fresh"

/datum/glass_style/drinking_glass/tonic
	required_drink_type = /datum/reagent/consumable/tonic
	name = "glass of tonic water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "glass_clear"

/datum/reagent/consumable/tonic/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/monkey_energy
	name = "Monkey Energy"
	description = "The only drink that will make you unleash the ape."
	color = "#f39b03" // rgb: 243, 155, 3
	chemical_flags = CHEMICAL_RNG_BOTANY
	taste_description = "barbecue and nostalgia"

/datum/glass_style/drinking_glass/monkey_energy
	required_drink_type = /datum/reagent/consumable/monkey_energy
	name = "glass of Monkey Energy"
	desc = "You can unleash the ape, but without the pop of the can?"
	icon_state = "monkey_energy_glass"

/datum/reagent/consumable/monkey_energy/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(80 SECONDS * REM * delta_time)
	affected_mob.adjust_dizzy(2 SECONDS * REM * delta_time)
	affected_mob.remove_status_effect(/datum/status_effect/drowsiness)
	affected_mob.AdjustSleeping(-40 * REM * delta_time)
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/monkey_energy/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(ismonkey(affected_mob))
		affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/monkey_energy)

/datum/reagent/consumable/monkey_energy/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/monkey_energy)

/datum/reagent/consumable/ice
	name = "Ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "ice"
	default_container = /obj/item/reagent_containers/cup/glass/ice

/datum/glass_style/drinking_glass/ice
	required_drink_type = /datum/reagent/consumable/ice
	name = "glass of ice"
	desc = "Generally, you're supposed to put something else in there too..."
	icon_state = "iceglass"

/datum/reagent/consumable/ice/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "creamy coffee"

/datum/glass_style/drinking_glass/soy_latte
	required_drink_type = /datum/reagent/consumable/soy_latte
	name = "soy latte"
	desc = "A nice and refreshing beverage while you're reading."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "soy_latte"

/datum/reagent/consumable/soy_latte/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-6 SECONDS * REM * delta_time)
	affected_mob.SetSleeping(0)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(brute = 1 * REM * delta_time, burn = 0, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/consumable/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "bitter cream"

/datum/glass_style/drinking_glass/cafe_latte
	required_drink_type = /datum/reagent/consumable/cafe_latte
	name = "cafe latte"
	desc = "A nice, strong and refreshing beverage while you're reading."
	icon = 'icons/obj/drinks/coffee.dmi'
	icon_state = "cafe_latte"

/datum/reagent/consumable/cafe_latte/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-10 SECONDS * REM * delta_time)
	affected_mob.adjust_drowsiness(-12 SECONDS * REM * delta_time)
	var/need_mob_update
	need_mob_update += affected_mob.SetSleeping(0)
	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		need_mob_update += affected_mob.heal_bodypart_damage(brute = 1 * REM * delta_time, burn = 0, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/doctor_delight
	name = "The Doctor's Delight"
	description = "A gulp a day keeps the Medibot away! A mixture of juices that heals most damage types fairly quickly at the cost of hunger."
	color = "#FF8CFF" // rgb: 255, 140, 255
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "homely fruit"

/datum/glass_style/drinking_glass/doctor_delight
	required_drink_type = /datum/reagent/consumable/doctor_delight
	name = "Doctor's Delight"
	desc = "The space doctor's favorite. Guaranteed to restore bodily injury; side effects include cravings and hunger."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "doctorsdelightglass"

/datum/reagent/consumable/doctor_delight/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	// Drains the nutrition of the affected_mob.reagents. Not medical staff though, since it's the Doctor's Delight!
	if(affected_mob.nutrition && (affected_mob.nutrition - 2 > 0))
		if(!HAS_MIND_TRAIT(affected_mob, TRAIT_MEDICAL_METABOLISM))
			affected_mob.adjust_nutrition(-2 * REM * delta_time)

	affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustFireLoss(-0.5 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustToxLoss(-0.5 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustOxyLoss(-0.5 * REM * delta_time, updating_health = FALSE)
	return UPDATE_MOB_HEALTH

/datum/reagent/consumable/chocolatepudding
	name = "Chocolate Pudding"
	description = "A great dessert for chocolate lovers."
	color = COLOR_MAROON
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "sweet chocolate"

/datum/glass_style/drinking_glass/chocolatepudding
	required_drink_type = /datum/reagent/consumable/chocolatepudding
	name = "chocolate pudding"
	desc = "Tasty."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "chocolatepudding"

/datum/reagent/consumable/vanillapudding
	name = "Vanilla Pudding"
	description = "A great dessert for vanilla lovers."
	color = "#FAFAD2"
	quality = DRINK_VERYGOOD
	chemical_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "sweet vanilla"

/datum/glass_style/drinking_glass/vanillapudding
	required_drink_type = /datum/reagent/consumable/vanillapudding
	name = "vanilla pudding"
	desc = "Tasty."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "vanillapudding"

/datum/reagent/consumable/cherryshake
	name = "Cherry Shake"
	description = "A cherry flavored milkshake."
	color = "#FFB6C1"
	quality = DRINK_VERYGOOD
	chemical_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "creamy cherry"

/datum/glass_style/drinking_glass/cherryshake
	required_drink_type = /datum/reagent/consumable/cherryshake
	name = "cherry shake"
	desc = "A cherry flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "cherryshake"

/datum/reagent/consumable/bluecherryshake
	name = "Blue Cherry Shake"
	description = "An exotic milkshake."
	color = "#00F1FF"
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "creamy blue cherry"

/datum/glass_style/drinking_glass/bluecherryshake
	required_drink_type = /datum/reagent/consumable/bluecherryshake
	name = "blue cherry shake"
	desc = "An exotic blue milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "bluecherryshake"

/datum/reagent/consumable/vanillashake
	name = "Vanilla Shake"
	description = "A vanilla flavored milkshake. The basics are still good."
	color = "#E9D2B2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet creamy vanilla"

/datum/glass_style/drinking_glass/vanillashake
	required_drink_type = /datum/reagent/consumable/vanillashake
	name = "vanilla shake"
	desc = "A vanilla flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "vanillashake"

/datum/reagent/consumable/caramelshake
	name = "Salted Caramel Shake"
	description = "A salted caramel flavored milkshake."
	color = "#E17C00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 10 * REAGENTS_METABOLISM
	taste_description = "salty caramel"

/datum/glass_style/drinking_glass/caramelshake
	required_drink_type = /datum/reagent/consumable/caramelshake
	name = "caramel shake"
	desc = "A caramel flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "caramelshake"

/datum/reagent/consumable/choccyshake
	name = "Chocolate Shake"
	description = "A frosty chocolate milkshake."
	color = "#541B00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet creamy chocolate"

/datum/glass_style/drinking_glass/choccyshake
	required_drink_type = /datum/reagent/consumable/choccyshake
	name = "chocolate shake"
	desc = "A chocolate flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "choccyshake"

/datum/reagent/consumable/strawberryshake
	name = "Strawberry Shake"
	description = "A strawberry milkshake."
	color = "#ff7b7b"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet strawberries and milk"

/datum/glass_style/drinking_glass/strawberryshake
	required_drink_type = /datum/reagent/consumable/strawberryshake
	name = "strawberry shake"
	desc = "A strawberry flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "strawberryshake"

/datum/reagent/consumable/bananashake
	name = "Banana Shake"
	description = "A banana milkshake. Stuff that clowns drink at their honkday parties."
	color = "#f2d554"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "thick banana"

/datum/glass_style/drinking_glass/bananashake
	required_drink_type = /datum/reagent/consumable/bananashake
	name = "banana shake"
	desc = "A banana flavored milkshake."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "bananashake"

/datum/reagent/consumable/pumpkin_latte
	name = "Pumpkin Latte"
	description = "A mix of pumpkin juice and coffee."
	color = "#F4A460"
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "creamy pumpkin"

/datum/glass_style/drinking_glass/pumpkin_latte
	required_drink_type = /datum/reagent/consumable/pumpkin_latte
	name = "pumpkin latte"
	desc = "A mix of coffee and pumpkin juice."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "pumpkin_latte"

/datum/reagent/consumable/gibbfloats
	name = "Gibb Floats"
	description = "Ice cream on top of a Dr. Gibb glass."
	color = "#B22222"
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "creamy cherry"

/datum/glass_style/drinking_glass/gibbfloats
	required_drink_type = /datum/reagent/consumable/gibbfloats
	name = "Gibbfloat"
	desc = "Dr. Gibb with ice cream on top."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "gibbfloats"

/datum/reagent/consumable/pumpkinjuice
	name = "Pumpkin Juice"
	description = "Juiced from real pumpkin."
	color = "#FFA500"
	chemical_flags = CHEMICAL_RNG_BOTANY
	taste_description = "pumpkin"

/datum/reagent/consumable/blumpkinjuice
	name = "Blumpkin Juice"
	description = "Juiced from real blumpkin."
	color = "#00BFFF"
	chemical_flags = CHEMICAL_RNG_BOTANY
	taste_description = "a mouthful of pool water"

/datum/reagent/consumable/triple_citrus
	name = "Triple Citrus"
	description = "A solution."
	color = "#EEFF00"
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "extreme bitterness"

/datum/glass_style/drinking_glass/triple_citrus
	required_drink_type = /datum/reagent/consumable/triple_citrus
	name = "glass of triple citrus"
	desc = "A mixture of citrus juices. Tangy, yet smooth."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "triplecitrus" //needs own sprite mine are trash //your sprite is great tho

/datum/reagent/consumable/grape_soda
	name = "Grape soda"
	description = "Beloved of children and teetotalers."
	color = "#E6CDFF"
	chemical_flags = CHEMICAL_RNG_BOTANY
	taste_description = "grape soda"

/datum/glass_style/drinking_glass/grape_soda
	required_drink_type = /datum/reagent/consumable/grape_soda
	name = "glass of grape juice"

/datum/reagent/consumable/grape_soda/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/milk/chocolate_milk
	name = "Chocolate Milk"
	description = "Milk for cool kids."
	color = "#7D4E29"
	chemical_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "chocolate milk"

/datum/glass_style/has_foodtype/juicebox/chocolate_milk
	required_drink_type = /datum/reagent/consumable/milk/chocolate_milk
	name = "carton of chocolate milk"
	desc = "Milk for cool kids!"
	icon_state = "chocolatebox"
	drink_type = SUGAR | DAIRY

/datum/reagent/consumable/hot_cocoa
	name = "Hot Coco"
	description = "Made with love! And coco beans."
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	taste_description = "creamy chocolate"
	chemical_flags = CHEMICAL_RNG_BOTANY

/datum/glass_style/has_foodtype/drinking_glass/hot_cocoa
	required_drink_type = /datum/reagent/consumable/hot_cocoa
	name = "glass of hot cocoa"
	desc = "A favorite winter drink to warm you up."
	icon_state = "chocolateglass"
	drink_type = SUGAR | DAIRY

/datum/reagent/consumable/hot_cocoa/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.reagents.has_reagent(/datum/reagent/consumable/capsaicin))
		affected_mob.reagents.remove_reagent(/datum/reagent/consumable/capsaicin, 2 * REM * delta_time)

	affected_mob.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, affected_mob.get_body_temp_normal())
	if(affected_mob.getBruteLoss() && DT_PROB(10, delta_time))
		affected_mob.heal_bodypart_damage(1, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/menthol
	name = "Menthol"
	description = "Alleviates coughing symptoms one might have."
	color = "#80AF9C"
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "mint"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/menthol

/datum/glass_style/drinking_glass/menthol
	required_drink_type = /datum/reagent/consumable/menthol
	name = "glass of menthol"
	desc = "Tastes naturally minty, and imparts a very mild numbing sensation."
	icon_state = "glass_green"

/datum/reagent/consumable/menthol/on_mob_life(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/throat_soothed)

/datum/reagent/consumable/grenadine
	name = "Grenadine"
	description = "Not cherry flavored!"
	color = "#EA1D26"
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sweet pomegranates"

/datum/glass_style/drinking_glass/grenadine
	required_drink_type = /datum/reagent/consumable/grenadine
	name = "glass of grenadine"
	desc = "Delicious flavored syrup."

/datum/reagent/consumable/parsnipjuice
	name = "Parsnip Juice"
	description = "Why..."
	color = "#FFA500"
	chemical_flags = NONE
	taste_description = "parsnip"

/datum/glass_style/has_foodtype/drinking_glass/parsnipjuice
	required_drink_type = /datum/reagent/consumable/parsnipjuice
	name = "glass of parsnip juice"
	drink_type = FRUIT

/datum/reagent/consumable/pineapplejuice
	name = "Pineapple Juice"
	description = "Tart, tropical, and hotly debated."
	color = "#F7D435"
	chemical_flags = CHEMICAL_BASIC_DRINK
	taste_description = "pineapple"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/juice/pineapplejuice

/datum/glass_style/has_foodtype/drinking_glass/pineapplejuice
	required_drink_type = /datum/reagent/consumable/pineapplejuice
	name = "glass of pineapple juice"
	desc = "Tart, tropical, and hotly debated."
	drink_type = FRUIT | PINEAPPLE

/datum/glass_style/has_foodtype/juicebox/pineapplejuice
	required_drink_type = /datum/reagent/consumable/pineapplejuice
	name = "pineapple juice box"
	desc = "Why would you even want this?"
	icon_state = "pineapplebox"
	drink_type = FRUIT | PINEAPPLE

/datum/reagent/consumable/peachjuice //Intended to be extremely rare due to being the limiting ingredients in the blazaam drink
	name = "Peach Juice"
	description = "Just peachy."
	color = "#E78108"
	chemical_flags = CHEMICAL_RNG_BOTANY
	taste_description = "peaches"

/datum/glass_style/has_foodtype/drinking_glass/peachjuice
	required_drink_type = /datum/reagent/consumable/peachjuice
	name = "glass of peach juice"
	drink_type = FRUIT

/datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	description = "A classic space-American vanilla flavored soft drink."
	color = "#dcb137"
	chemical_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_VERYGOOD
	taste_description = "fizzy vanilla"

/datum/glass_style/drinking_glass/cream_soda
	required_drink_type = /datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	desc = "A classic space-American vanilla flavored soft drink."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "cream_soda"

/datum/reagent/consumable/cream_soda/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, affected_mob.get_body_temp_normal())

/datum/reagent/consumable/sol_dry
	name = "Sol Dry"
	description = "A soothing, mellow drink made from ginger."
	color = "#f7d26a"
	quality = DRINK_NICE
	taste_description = "sweet ginger spice"
	chemical_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING

/datum/glass_style/drinking_glass/sol_dry
	required_drink_type = /datum/reagent/consumable/sol_dry
	name = "Sol Dry"
	desc = "A soothing, mellow drink made from ginger."
	icon_state = "soldry"

/datum/reagent/consumable/sol_dry/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_disgust(-5 * REM * delta_time)

/datum/reagent/consumable/red_queen
	name = "Red Queen"
	description = "DRINK ME."
	color = "#e6ddc3"
	chemical_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_GOOD
	taste_description = "wonder"

	var/current_size = RESIZE_DEFAULT_SIZE

/datum/glass_style/drinking_glass/red_queen
	required_drink_type = /datum/reagent/consumable/red_queen
	name = "Red Queen"
	desc = "DRINK ME."
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	icon_state = "red_queen"

/datum/reagent/consumable/red_queen/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(50, delta_time))
		return

	var/newsize = pick(0.5, 0.75, 1, 1.50, 2)
	newsize *= RESIZE_DEFAULT_SIZE
	affected_mob.resize = newsize / current_size
	current_size = newsize
	affected_mob.update_transform()
	if(DT_PROB(23, delta_time))
		affected_mob.emote("sneeze")

/datum/reagent/consumable/red_queen/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	affected_mob.update_transform()

/datum/reagent/consumable/bungojuice
	name = "Bungo Juice"
	color = "#F9E43D"
	chemical_flags = CHEMICAL_GOAL_BARTENDER_SERVING
	description = "Exotic! You feel like you are on vacation already."
	taste_description = "succulent bungo"

/datum/glass_style/drinking_glass/bungojuice
	required_drink_type = /datum/reagent/consumable/bungojuice
	name = "glass of bungo juice"
	desc = "Exotic! You feel like you are on vacation already."
	icon_state = "glass_yellow"

/datum/reagent/consumable/beefbroth
	name = "Beef Broth"
	color = "#100800" // rgb: 16, 8, 0 , just like cola
	chemical_flags = CHEMICAL_RNG_BOTANY
	taste_description = "Pure Beef Essence"

/datum/glass_style/drinking_glass/beefbroth
	required_drink_type = /datum/reagent/consumable/beefbroth
	name = "glass of Space Cola?"
	desc = "A glass of what appears to be refreshing Space Cola."
	icon_state = "glass_brown"

/datum/reagent/consumable/beefbroth/on_mob_metabolize(mob/living/carbon/affected_mob)
	var/obj/item/organ/tongue/tongue = affected_mob.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue.liked_foodtypes & MEAT)
		to_chat(affected_mob, span_notice("That drink was PERFECTLY beefy! It's great!."))
		SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_verygood)
	else
		to_chat(affected_mob, span_warning("That drink was way too beefy! You feel sick."))
		SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
		affected_mob.adjust_disgust(30)
	. = ..()

/datum/reagent/consumable/bubble_tea
	name = "Bubble Tea"
	description = "Refreshing! You aren't sure what those things in the bottom are."
	color = "#DFC7AB"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_VERYGOOD
	taste_description = "sweet, creamy and silky tea with chewy tapioca pearls"

/datum/glass_style/drinking_glass/bubbletea
	required_drink_type = /datum/reagent/consumable/bubble_tea
	name = "Bubble Tea"
	desc = "A cup of refreshing bubble tea."
	icon_state = "bubble_tea"

/datum/reagent/consumable/beeffizz
	name = "Beef Fizz"
	description = "This is beef fizz, BEEF FIZZ, THERE IS NO GOD"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = 0
	taste_description = "Nice and Salty Fizzless Beef Juice with a quick bite of lemon"

/datum/glass_style/drinking_glass/beeffizz
	required_drink_type = /datum/reagent/consumable/beeffizz
	name = "Beef Fizz"
	desc = "WHO THOUGHT THIS WAS A GOOD IDEA??"
	icon_state = "beef_fizz"

/datum/reagent/consumable/beeffizz/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	var/obj/item/organ/tongue/tongue = affected_mob.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue.liked_foodtypes & MEAT)
		to_chat(affected_mob, span_notice("That drink was like a liquid steak! It's amazing!."))
		SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_fantastic)
	else
		to_chat(affected_mob, span_warning("That drink was like drinking a steak! I think i'm gonna puke..."))
		SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
		affected_mob.adjust_disgust(35)

/datum/reagent/consumable/beeffizz/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(is_species(affected_mob, /datum/species/lizard))
		affected_mob.adjustBruteLoss(-1.5 * REM * delta_time, updating_health = FALSE)
		affected_mob.adjustFireLoss(-1.5 * REM * delta_time, updating_health = FALSE)
		affected_mob.adjustToxLoss(-1 * REM * delta_time, updating_health = FALSE)
		return UPDATE_MOB_HEALTH

//Coconut milk which is inside of the coconut when split open
/datum/reagent/consumable/coconutmilk
	name = "Coconut Milk"
	description = "A smooth, creamy liquid with a faint tropical aroma. Looks refreshing!"
	color = "#F0EDE5" //rgb(240, 237, 229)
	chemical_flags = NONE
	taste_description = "a creamy tropical paradise"

/datum/glass_style/drinking_glass/coconutmilk
	required_drink_type = /datum/reagent/consumable/coconutmilk
	name = "glass of coconut milk"
	desc = "A glass filled with rich, creamy coconut milk. It smells faintly of the tropics"
	icon_state = "glass_white"

//Coconut juice from juicing the coconut flesh when split
/datum/reagent/consumable/coconutjuice
	name = "Coconut Juice"
	description = "A slightly translucent, sweet coconut juice with a light, tropical scent"
	color = "#ddcec0" //rgb(221, 206, 192)
	chemical_flags = NONE
	taste_description = "a beach holiday in a glass"

/datum/glass_style/drinking_glass/coconutjuice
	required_drink_type = /datum/reagent/consumable/coconutjuice
	name = "glass of coconut juice"
	desc = "a glass of coconut juice"
	icon_state = "glass_white"
