/datum/reagent/consumable/pineapplejuice
	name = "Pineapple Juice"
	description = "Either you love it or you hate it."
	color = "#e9eb6b"
	taste_description = "pineapples"
	glass_icon_state = "lemonglass"
	glass_name = "glass of pineapple juice"
	glass_desc = "Either y- wait, IS THAT *cough*.. PINEAPPLE ?!"

/datum/reagent/consumable/salty_water
	name = "Salty Water"
	description = "Water and, hmm, salt?"
	color = "#ffe65b"
	taste_description = "salty water"
	glass_icon_state = "glass_clear"
	glass_name = "Water?"
	glass_desc = "Who would ask that, seriously"

/datum/reagent/consumable/salty_water/on_mob_add(mob/living/L)
	metabolization_rate = 2.5
	L.emote("scream")
	if(prob(50))
		L.adjustBruteLoss(5, 0)
		L.adjustFireLoss(5, 0)
		. = TRUE
	..()
