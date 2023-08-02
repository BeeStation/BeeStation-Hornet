

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/consumable/orangejuice
	name = "Orange Juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "oranges"
	glass_icon_state = "glass_orange"
	glass_name = "glass of orange juice"
	glass_desc = "Vitamins! Yay!"

/datum/reagent/consumable/orangejuice/on_mob_life(mob/living/carbon/M)
	if(M.getOxyLoss() && prob(30))
		M.adjustOxyLoss(-1, 0)
		. = 1
	..()

/datum/reagent/consumable/tomatojuice
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "tomatoes"
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

/datum/reagent/consumable/tomatojuice/on_mob_life(mob/living/carbon/M)
	if(M.getFireLoss() && prob(20))
		M.heal_bodypart_damage(0,1, 0)
		. = 1
	..()

/datum/reagent/consumable/limejuice
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "unbearable sourness"
	glass_icon_state = "glass_green"
	glass_name = "glass of lime juice"
	glass_desc = "A glass of sweet-sour lime juice."

/datum/reagent/consumable/limejuice/on_mob_life(mob/living/carbon/M)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1*REM, 0)
		. = 1
	..()

/datum/reagent/consumable/carrotjuice
	name = "Carrot Juice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0
	chem_flags = CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "carrots"
	glass_icon_state = "carrotjuice"
	glass_name = "glass of  carrot juice"
	glass_desc = "It's just like a carrot but without crunching."

/datum/reagent/consumable/carrotjuice/on_mob_life(mob/living/carbon/M)
	M.adjust_blurriness(-1)
	M.adjust_blindness(-1)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(current_cycle-10))
				M.cure_nearsighted(list(EYE_DAMAGE))
	..()
	return

/datum/reagent/consumable/berryjuice
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" // rgb: 134, 51, 51
	chem_flags = NONE
	taste_description = "berries"
	glass_icon_state = "berryjuice"
	glass_name = "glass of berry juice"
	glass_desc = "Berry juice. Or maybe it's jam. Who cares?"

/datum/reagent/consumable/applejuice
	name = "Apple Juice"
	description = "The sweet juice of an apple, fit for all ages."
	color = "#ECFF56" // rgb: 236, 255, 86
	chem_flags = NONE
	taste_description = "apples"

/datum/reagent/consumable/poisonberryjuice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "berries"
	glass_icon_state = "poisonberryjuice"
	glass_name = "glass of berry juice"
	glass_desc = "Berry juice. Or maybe it's poison. Who cares?"

/datum/reagent/consumable/poisonberryjuice/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1, 0)
	. = 1
	..()

/datum/reagent/consumable/watermelonjuice
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
	chem_flags = NONE
	taste_description = "juicy watermelon"
	glass_icon_state = "glass_red"
	glass_name = "glass of watermelon juice"
	glass_desc = "A glass of watermelon juice."

/datum/reagent/consumable/lemonjuice
	name = "Lemon Juice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sourness"
	glass_icon_state  = "lemonglass"
	glass_name = "glass of lemon juice"
	glass_desc = "Sour..."

/datum/reagent/consumable/banana
	name = "Banana Juice"
	description = "The raw essence of a banana. HONK"
	color = "#863333" // rgb: 175, 175, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "banana"
	glass_icon_state = "banana"
	glass_name = "glass of banana juice"
	glass_desc = "The raw essence of a banana. HONK."

/datum/reagent/consumable/banana/on_mob_life(mob/living/carbon/M)
	if((ishuman(M) && M.job == JOB_NAME_CLOWN) || ismonkey(M))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/nothing
	name = "Nothing"
	description = "Absolutely nothing."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "nothing"
	glass_icon_state = "nothing"
	glass_name = "nothing"
	glass_desc = "Absolutely nothing."
	shot_glass_icon_state = "shotglass"


/datum/reagent/consumable/nothing/on_mob_life(mob/living/carbon/M)
	if(ishuman(M) && M.job == JOB_NAME_MIME)
		M.silent = max(M.silent, MIMEDRINK_SILENCE_DURATION)
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/laughter
	name = "Laughter"
	description = "Some say that this is the best medicine, but recent studies have proven that to be untrue."
	metabolization_rate = INFINITY
	color = "#FF4DD2"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "laughter"


/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/M)
	M.emote("laugh")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_laughter)
	..()

/datum/reagent/consumable/laughter/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	var/mob/living/carbon/human/reactor = M
	if(istype(reactor))
		var/datum/component/mood/mood = reactor.GetComponent(/datum/component/mood)
		if (mood.get_event("slipped"))
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "laughter", /datum/mood_event/funny_prank)
			SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "slipped")
			reactor.AdjustKnockdown(-20)

/datum/reagent/consumable/superlaughter
	name = "Super Laughter"
	description = "Funny until you're the one laughing."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#FF4DD2"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "laughter"

/datum/reagent/consumable/superlaughter/on_mob_life(mob/living/carbon/M)
	if(prob(30))
		M.visible_message("<span class='danger'>[M] bursts out into a fit of uncontrollable laughter!</span>", "<span class='userdanger'>You burst out in a fit of uncontrollable laughter!</span>")
		M.Stun(5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_superlaughter)
	..()

/datum/reagent/consumable/potato_juice
	name = "Potato Juice"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "irish sadness"
	glass_icon_state = "glass_brown"
	glass_name = "glass of potato juice"
	glass_desc = "Bleh..."

/datum/reagent/consumable/grapejuice
	name = "Grape Juice"
	description = "The juice of a bunch of grapes. Guaranteed non-alcoholic."
	color = "#290029" // dark purple
	chem_flags = NONE
	taste_description = "grape soda"

/datum/reagent/consumable/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "milk"
	glass_icon_state = "glass_white"
	glass_name = "glass of milk"
	glass_desc = "White and nutritious goodness!"
	overdose_threshold = 500 //High calcium intake is bad for bone health. OD is exactly like having taken a normal-ish bone hurt juice. If anyone hits the superoverdose, well I'll be damned

/datum/reagent/consumable/milk/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 2)
	..()

/*See block comment in ../milk/overdose_process(mob/living/M) for calculation and explanation of why this exists and why 5 was chosen
* For best results use in tandem with method outlined in this comment
*/
/datum/reagent/consumable/milk/overdose_start(mob/living/M)
	M.reagents.add_reagent(/datum/reagent/toxin/bonehurtingjuice, 5) //The integer here should match var/starting_amount in ../milk/overdose_process(mob/living/M)
	return ..()

/datum/reagent/consumable/milk/overdose_process(mob/living/M)
	var/datum/reagent/converted_reagent = /datum/reagent/toxin/bonehurtingjuice //Needed to get the metabolism for desired reagent, exists solely for brevity compared to /datum/reagent/category/reagent.metabolization_rate
	var/minimum_cycles = overdose_threshold/metabolization_rate //minimum_cycles is the number of ticks for an amount of units equal to the overdose threshold to process.
	var/amount_to_add = 45 / minimum_cycles + initial(converted_reagent.metabolization_rate) //amount_to_add is the calculated amount to add per tick to meet ensure that target_units after minimum_cycle ticks.
	M.reagents.add_reagent(/datum/reagent/toxin/bonehurtingjuice, amount_to_add)
	return ..()
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
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "soy milk"
	glass_icon_state = "glass_white"
	glass_name = "glass of soy milk"
	glass_desc = "White and nutritious soy goodness!"


/datum/reagent/consumable/soymilk/on_mob_add(mob/living/L)
	..()

	if (L.client)
		L.client.give_award(/datum/award/achievement/misc/soy, L)


/datum/reagent/consumable/soymilk/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	..()

/datum/reagent/consumable/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "creamy milk"
	glass_icon_state  = "glass_white"
	glass_name = "glass of cream"
	glass_desc = "Ewwww..."

/datum/reagent/consumable/cream/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	..()

/datum/reagent/consumable/coffee
	name = "Coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitterness"
	glass_icon_state = "glass_brown"
	glass_name = "glass of coffee"
	glass_desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."

/datum/reagent/consumable/coffee/overdose_process(mob/living/M)
	M.Jitter(5)
	..()

/datum/reagent/consumable/coffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	//310.15 is the normal bodytemp.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	..()
	. = 1

/datum/reagent/consumable/tea
	name = "Tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	taste_description = "tart black tea"
	glass_icon_state = "teaglass"
	glass_name = "glass of tea"
	glass_desc = "Drinking it from here would not seem right."

/datum/reagent/consumable/tea/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.AdjustSleeping(-20, FALSE)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1, 0)
	M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/lemonade
	name = "Lemonade"
	description = "Sweet, tangy lemonade. Good for the soul."
	color = "#daef60"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "sunshine and summertime"
	glass_icon_state = "lemonpitcher"
	glass_name = "pitcher of lemonade"
	glass_desc = "This drink leaves you feeling nostalgic for some reason."


/datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	description = "Encourages the patient to go golfing."
	color = "#FFB766"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	nutriment_factor = 2
	taste_description = "bitter tea"
	glass_icon_state = "arnold_palmer"
	glass_name = "Arnold Palmer"
	glass_desc = "You feel like taking a few golf swings after a few swigs of this."

/datum/reagent/consumable/tea/arnold_palmer/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		to_chat(M, "<span class = 'notice'>[pick("You remember to square your shoulders.","You remember to keep your head down.","You can't decide between squaring your shoulders and keeping your head down.","You remember to relax.","You think about how someday you'll get two strokes off your golf game.")]</span>")
	..()
	. = 1

/datum/reagent/consumable/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	chem_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 0
	taste_description = "bitter coldness"
	glass_icon_state = "icedcoffeeglass"
	glass_name = "iced coffee"
	glass_desc = "A drink to perk you up and refresh you!"

/datum/reagent/consumable/icecoffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/consumable/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/actor."
	color = "#104038" // rgb: 16, 64, 56
	chem_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	taste_description = "sweet tea"
	glass_icon_state = "icedteaglass"
	glass_name = "iced tea"
	glass_desc = "All natural, antioxidant-rich flavour sensation."

/datum/reagent/consumable/icetea/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.AdjustSleeping(-40, FALSE)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1, 0)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/space_cola
	name = "Cola"
	description = "A refreshing beverage."
	color = "#100800" // rgb: 16, 8, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cola"
	glass_icon_state  = "glass_brown"
	glass_name = "glass of Space Cola"
	glass_desc = "A glass of refreshing Space Cola."

/datum/reagent/consumable/space_cola/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-5)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "the future"
	glass_icon_state = "nuka_colaglass"
	glass_name = "glass of Nuka Cola"
	glass_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."

/datum/reagent/consumable/nuka_cola/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.25, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/consumable/nuka_cola/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/consumable/nuka_cola/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.set_drugginess(30)
	M.dizziness += 1.5
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.radiation += 4
	..()
	. = 1

/datum/reagent/consumable/grey_bull
	name = "Grey Bull"
	description = "Grey Bull, it gives you gloves!"
	color = "#EEFF00" // rgb: 238, 255, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "carbonated oil"
	glass_icon_state = "grey_bull_glass"
	glass_name = "glass of Grey Bull"
	glass_desc = "Surprisingly it isn't grey."

/datum/reagent/consumable/grey_bull/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_SHOCKIMMUNE, type)

/datum/reagent/consumable/grey_bull/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_SHOCKIMMUNE, type)
	..()

/datum/reagent/consumable/grey_bull/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.dizziness +=1
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/spacemountainwind
	name = "SM Wind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sweet citrus soda"
	glass_icon_state = "Space_mountain_wind_glass"
	glass_name = "glass of Space Mountain Wind"
	glass_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."

/datum/reagent/consumable/spacemountainwind/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-7)
	M.AdjustSleeping(-20, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/consumable/dr_gibb
	name = "Dr. Gibb"
	description = "A delicious blend of 42 different flavours."
	color = "#102000" // rgb: 16, 32, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cherry soda" // FALSE ADVERTISING
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of Dr. Gibb"
	glass_desc = "Dr. Gibb. Not as dangerous as the glass_name might imply."

/datum/reagent/consumable/dr_gibb/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-6)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/space_up
	name = "Space-Up"
	description = "Tastes like a hull breach in your mouth."
	color = "#00FF00" // rgb: 0, 255, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cherry soda"
	glass_icon_state = "space-up_glass"
	glass_name = "glass of Space-Up"
	glass_desc = "Space-up. It helps you keep your cool."


/datum/reagent/consumable/space_up/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	color = "#8CFF00" // rgb: 135, 255, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "tangy lime and lemon soda"
	glass_icon_state = "glass_yellow"
	glass_name = "glass of lemon-lime"
	glass_desc = "You're pretty certain a real fruit has never actually touched this."


/datum/reagent/consumable/lemon_lime/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/pwr_game
	name = "Pwr Game"
	description = "The only drink with the PWR that true gamers crave."
	color = "#9385bf" // rgb: 58, 52, 75
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sweet and salty tang"
	glass_icon_state = "glass_red"
	glass_name = "glass of Pwr Game"
	glass_desc = "Goes well with a Vlad's salad."

/datum/reagent/consumable/pwr_game/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/shamblers
	name = "Shambler's Juice"
	description = "~Shake me up some of that Shambler's Juice!~"
	color = "#f00060" // rgb: 94, 0, 38
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "carbonated metallic soda"
	glass_icon_state = "glass_red"
	glass_name = "glass of Shambler's juice"
	glass_desc = "Mmm mm, shambly."

/datum/reagent/consumable/shamblers/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
/datum/reagent/consumable/sodawater
	name = "Soda Water"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "carbonated water"
	glass_icon_state = "glass_clear"
	glass_name = "glass of soda water"
	glass_desc = "Soda water. Why not make a scotch and soda?"

/datum/reagent/consumable/sodawater/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/tonic
	name = "Tonic Water"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#0064C8" // rgb: 0, 100, 200
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "tart and fresh"
	glass_icon_state = "glass_clear"
	glass_name = "glass of tonic water"
	glass_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."

/datum/reagent/consumable/tonic/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/monkey_energy
	name = "Monkey Energy"
	description = "The only drink that will make you unleash the ape."
	color = "#f39b03" // rgb: 243, 155, 3
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "barbecue and nostalgia"
	glass_icon_state = "monkey_energy_glass"
	glass_name = "glass of Monkey Energy"
	glass_desc = "You can unleash the ape, but without the pop of the can?"

/datum/reagent/consumable/monkey_energy/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.dizziness +=1
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/monkey_energy/on_mob_metabolize(mob/living/L)
	..()
	if(ismonkey(L))
		L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.25, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/consumable/monkey_energy/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/consumable/ice
	name = "Ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "ice"
	glass_icon_state = "iceglass"
	glass_name = "glass of ice"
	glass_desc = "Generally, you're supposed to put something else in there too..."

/datum/reagent/consumable/ice/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "creamy coffee"
	glass_icon_state = "soy_latte"
	glass_name = "soy latte"
	glass_desc = "A nice and refreshing beverage while you're reading."

/datum/reagent/consumable/soy_latte/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.SetSleeping(0, FALSE)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	M.Jitter(5)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
	..()
	. = 1

/datum/reagent/consumable/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "bitter cream"
	glass_icon_state = "cafe_latte"
	glass_name = "cafe latte"
	glass_desc = "A nice, strong and refreshing beverage while you're reading."

/datum/reagent/consumable/cafe_latte/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.SetSleeping(0, FALSE)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	M.Jitter(5)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
	..()
	. = 1

/datum/reagent/consumable/doctor_delight
	name = "The Doctor's Delight"
	description = "A gulp a day keeps the Medibot away! A mixture of juices that heals most damage types fairly quickly at the cost of hunger."
	color = "#FF8CFF" // rgb: 255, 140, 255
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "homely fruit"
	glass_icon_state = "doctorsdelightglass"
	glass_name = "Doctor's Delight"
	glass_desc = "The space doctor's favorite. Guaranteed to restore bodily injury; side effects include cravings and hunger."

/datum/reagent/consumable/doctor_delight/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.5, 0)
	M.adjustFireLoss(-0.5, 0)
	M.adjustToxLoss(-0.5, 0)
	M.adjustOxyLoss(-0.5, 0)
	if(M.nutrition && (M.nutrition - 2 > 0))
		if(M.mind && !HAS_TRAIT(M.mind, TRAIT_MEDICAL_METABOLISM)) //Drains the nutrition of the holder. Not medical staff though, since it's the Doctor's Delight!
			M.adjust_nutrition(-2)
	..()
	. = 1

/datum/reagent/consumable/chocolatepudding
	name = "Chocolate Pudding"
	description = "A great dessert for chocolate lovers."
	color = "#800000"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "sweet chocolate"
	glass_icon_state = "chocolatepudding"
	glass_name = "chocolate pudding"
	glass_desc = "Tasty."

/datum/reagent/consumable/vanillapudding
	name = "Vanilla Pudding"
	description = "A great dessert for vanilla lovers."
	color = "#FAFAD2"
	quality = DRINK_VERYGOOD
	chem_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "sweet vanilla"
	glass_icon_state = "vanillapudding"
	glass_name = "vanilla pudding"
	glass_desc = "Tasty."

/datum/reagent/consumable/cherryshake
	name = "Cherry Shake"
	description = "A cherry flavored milkshake."
	color = "#FFB6C1"
	quality = DRINK_VERYGOOD
	chem_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "creamy cherry"
	glass_icon_state = "cherryshake"
	glass_name = "cherry shake"
	glass_desc = "A cherry flavored milkshake."

/datum/reagent/consumable/bluecherryshake
	name = "Blue Cherry Shake"
	description = "An exotic milkshake."
	color = "#00F1FF"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "creamy blue cherry"
	glass_icon_state = "bluecherryshake"
	glass_name = "blue cherry shake"
	glass_desc = "An exotic blue milkshake."


/datum/reagent/consumable/vanillashake
	name = "Vanilla Shake"
	description = "A vanilla flavored milkshake. The basics are still good."
	color = "#E9D2B2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet creamy vanilla"
	glass_icon_state = "vanillashake"
	glass_name = "vanilla shake"
	glass_desc = "A vanilla flavored milkshake."

/datum/reagent/consumable/caramelshake
	name = "Salted Caramel Shake"
	description = "A salted caramel flavored milkshake."
	color = "#E17C00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 10 * REAGENTS_METABOLISM
	taste_description = "salty caramel"
	glass_icon_state = "caramelshake"
	glass_name = "salted caramel shake"
	glass_desc = "A salted caramel flavored milkshake."

/datum/reagent/consumable/choccyshake
	name = "Chocolate Shake"
	description = "A frosty chocolate milkshake."
	color = "#541B00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet creamy chocolate"
	glass_icon_state = "choccyshake"
	glass_name = "chocolate shake"
	glass_desc = "A chocolate flavored milkshake."

/datum/reagent/consumable/strawberryshake
	name = "Strawberry Shake"
	description = "A strawberry milkshake."
	color = "#ff7b7b"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "sweet strawberries and milk"
	glass_icon_state = "strawberryshake"
	glass_name = "strawberry shake"
	glass_desc = "A strawberry flavored milkshake."

/datum/reagent/consumable/bananashake
	name = "Banana Shake"
	description = "A banana milkshake. Stuff that clowns drink at their honkday parties."
	color = "#f2d554"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8 * REAGENTS_METABOLISM
	taste_description = "thick banana"
	glass_icon_state = "bananashake"
	glass_name = "banana shake"
	glass_desc = "A banana flavored milkshake."

/datum/reagent/consumable/pumpkin_latte
	name = "Pumpkin Latte"
	description = "A mix of pumpkin juice and coffee."
	color = "#F4A460"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "creamy pumpkin"
	glass_icon_state = "pumpkin_latte"
	glass_name = "pumpkin latte"
	glass_desc = "A mix of coffee and pumpkin juice."

/datum/reagent/consumable/gibbfloats
	name = "Gibb Floats"
	description = "Ice cream on top of a Dr. Gibb glass."
	color = "#B22222"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "creamy cherry"
	glass_icon_state = "gibbfloats"
	glass_name = "Gibbfloat"
	glass_desc = "Dr. Gibb with ice cream on top."

/datum/reagent/consumable/pumpkinjuice
	name = "Pumpkin Juice"
	description = "Juiced from real pumpkin."
	color = "#FFA500"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "pumpkin"

/datum/reagent/consumable/blumpkinjuice
	name = "Blumpkin Juice"
	description = "Juiced from real blumpkin."
	color = "#00BFFF"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "a mouthful of pool water"

/datum/reagent/consumable/triple_citrus
	name = "Triple Citrus"
	description = "A solution."
	color = "#EEFF00"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "extreme bitterness"
	glass_icon_state = "triplecitrus" //needs own sprite mine are trash
	glass_name = "glass of triple citrus"
	glass_desc = "A mixture of citrus juices. Tangy, yet smooth."

/datum/reagent/consumable/grape_soda
	name = "Grape soda"
	description = "Beloved of children and teetotalers."
	color = "#E6CDFF"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "grape soda"
	glass_name = "glass of grape juice"
	glass_desc = "It's grape (soda)!"

/datum/reagent/consumable/grape_soda/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/milk/chocolate_milk
	name = "Chocolate Milk"
	description = "Milk for cool kids."
	color = "#7D4E29"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "chocolate milk"

/datum/reagent/consumable/menthol
	name = "Menthol"
	description = "Alleviates coughing symptoms one might have."
	color = "#80AF9C"
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "mint"
	glass_icon_state = "glass_green"
	glass_name = "glass of menthol"
	glass_desc = "Tastes naturally minty, and imparts a very mild numbing sensation."

/datum/reagent/consumable/menthol/on_mob_life(mob/living/L)
	L.apply_status_effect(/datum/status_effect/throat_soothed)
	..()

/datum/reagent/consumable/grenadine
	name = "Grenadine"
	description = "Not cherry flavored!"
	color = "#EA1D26"
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sweet pomegranates"
	glass_name = "glass of grenadine"
	glass_desc = "Delicious flavored syrup."

/datum/reagent/consumable/parsnipjuice
	name = "Parsnip Juice"
	description = "Why..."
	color = "#FFA500"
	chem_flags = NONE
	taste_description = "parsnip"
	glass_name = "glass of parsnip juice"

/datum/reagent/consumable/peachjuice //Intended to be extremely rare due to being the limiting ingredients in the blazaam drink
	name = "Peach Juice"
	description = "Just peachy."
	color = "#E78108"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "peaches"
	glass_name = "glass of peach juice"

/datum/reagent/consumable/pineapplejuice
	name = "Pineapple Juice"
	description = "Tart, tropical, and hotly debated."
	color = "#F7D435"
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "pineapple"
	glass_name = "glass of pineapple juice"
	glass_desc = "Tart, tropical, and hotly debated."

/datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	description = "A classic space-American vanilla flavored soft drink."
	color = "#dcb137"
	chem_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_VERYGOOD
	taste_description = "fizzy vanilla"
	glass_icon_state = "cream_soda"
	glass_name = "Cream Soda"
	glass_desc = "A classic space-American vanilla flavored soft drink."

/datum/reagent/consumable/cream_soda/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/red_queen
	name = "Red Queen"
	description = "DRINK ME."
	color = "#e6ddc3"
	chem_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_GOOD
	taste_description = "wonder"
	glass_icon_state = "red_queen"
	glass_name = "Red Queen"
	glass_desc = "DRINK ME."

	var/current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/consumable/red_queen/on_mob_life(mob/living/carbon/H)
	if(prob(75))
		return ..()
	var/newsize = pick(0.5, 0.75, 1, 1.50, 2)
	newsize *= RESIZE_DEFAULT_SIZE
	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	if(prob(40))
		H.emote("sneeze")
	..()

/datum/reagent/consumable/red_queen/on_mob_end_metabolize(mob/living/M)
	M.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	M.update_transform()
	..()

/datum/reagent/consumable/bungojuice
	name = "Bungo Juice"
	color = "#F9E43D"
	chem_flags = CHEMICAL_GOAL_BARTENDER_SERVING
	description = "Exotic! You feel like you are on vacation already."
	taste_description = "succulent bungo"
	glass_icon_state = "glass_yellow"
	glass_name = "glass of bungo juice"
	glass_desc = "Exotic! You feel like you are on vacation already."

/datum/reagent/consumable/beefbroth
	name = "Beef Broth"
	color = "#100800" // rgb: 16, 8, 0 , just like cola
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "Pure Beef Essence"
	glass_icon_state  = "glass_brown"
	glass_name = "glass of Space Cola?"
	glass_desc = "A glass of what appears to be refreshing Space Cola."

/datum/reagent/consumable/beefbroth/on_mob_metabolize(mob/living/M)
	to_chat(M, "<span class='warning'>That drink was way too beefy! You feel sick.</span>")
	M.adjust_disgust(30)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
	. = ..()
