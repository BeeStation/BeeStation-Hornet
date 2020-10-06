/datum/reagent/consumable/ethanol/vodka_cola
	name = "Vodka Cola"
	description = "Vodka, mixed with cola"
	color = "#3f2410" // rgb: 62, 27, 0
	boozepwr = 60
	quality = DRINK_NICE
	taste_description = "depression"
	glass_icon_state = "whiskeycolaglass"
	glass_name = "Vodka Cola"
	glass_desc = "You don't like rum ? Fine, there is Whiskey, wha.. You don't like that too ? Man.. Well, Vodka I guess ?"

/datum/reagent/consumable/ethanol/black_roulette
	name = "Black Roulette"
	description = "It's like the real one! Be careful"
	color = "#7c550bbe" // rgb: 102, 67, 0
	boozepwr = 40
	taste_description = "organ failure"
	glass_icon_state = "blackroulette"
	glass_name = "Black Roulette"
	glass_desc = "There is a bullet in the gun-looking drink, I don't feel like trying this."

/datum/reagent/consumable/ethanol/black_roulette/on_mob_add(mob/living/L)
	var/datum/disease/D = new /datum/disease/heart_failure
	metabolization_rate = 5
	if(prob(15) && iscarbon(L))
		L.playsound_local(L, 'sound/weapons/revolver357shot.ogg', 100, 80)
		L.ForceContractDisease(D)
		to_chat(L, "<span class='userdanger'>You're pretty sure you just felt your heart stop for a second there..</span>")
		L.playsound_local(L, 'sound/effects/singlebeat.ogg', 100, 0)
	..()

/datum/reagent/consumable/ethanol/triple_coke
	name = "Triple Coke"
	description = "A strange mixes of Rum, Whiskey, Vodka and cola, perfect when you need to get drunk without noticing it"
	color = "#7c550bbe" // rgb: 102, 67, 0
	boozepwr = 80
	quality = DRINK_NICE
	taste_description = "bad idea"
	glass_icon_state = "triplecoke"
	glass_name = "Triple Coke"
	glass_desc = "Is there cocaine in the drink ? I'm suspicious now.."

/datum/reagent/consumable/ethanol/triple_coke/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(20)
	M.emote("flip")
	M.emote("collapse")
	..()

/datum/reagent/consumable/salty_water
	name = "Salty Water"
	description = "Water and, hmm, salt?"
	color = "#ffe65b"
	quality = DRINK_NICE
	taste_description = "salt"
	glass_icon_state = "glass_clear"
	glass_name = "Water?"
	glass_desc = "Who would ask that, seriously"

/datum/reagent/consumable/salty_water/on_mob_add(mob/living/L)
	metabolization_rate = 5
	if(prob(100))
		L.emote("scream")
	..()

/datum/reagent/consumable/ethanol/fringe_weaver/on_mob_life(mob/living/carbon/M)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE) && (prob(10)))
		M.vomit()
	if(prob(5))
		M.emote("collapse")
	if(prob(5))
		M.drop_all_held_items()
	..()

/datum/reagent/consumable/ethanol/pina_colada
	name = "Piña Colada"
	description = "Sweet, strained, and fruity. Loveable."
	color = "#e9eb6b"
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "coconut, pineapple and some lime"
	glass_icon_state = "pina_colada"
	glass_name = "Piña Colada"
	glass_desc = "Smells like pineapple, oh there is rum too, seems good."

/datum/reagent/consumable/ethanol/death_afternoon
	name = "Death in the afternoon"
	description = "Icy, milky, scary"
	color = "#c4ffa9"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "bravery and life"
	glass_icon_state = "death_afternoon"
	glass_name = "Death in the afternoon"
	glass_desc = "You gotta drink it fast!"

/datum/reagent/consumable/ethanol/death_afternoon/on_mob_life(mob/living/carbon/M)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.adjustFireLoss(-3, 0)
	..()
	M.hallucination += 4
	..()

/datum/reagent/consumable/death_afternoon/on_mob_add(mob/living/L)
	L.hallucination = /datum/hallucination/death
