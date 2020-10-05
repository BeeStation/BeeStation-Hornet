/datum/reagent/invisium
	name = "Invisium"
	description = "a close to magic substance that turns the user invisible when consumed, your body will start whithering due to loss of reality"
	color = "#85E3E9"
	taste_description = "vanishing"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/invisium/on_mob_life(mob/living/carbon/M)

	if(M.alpha > 1)
		M.alpha -= 20
	else
		M.adjustBruteLoss(0.5,0)
		M.adjustFireLoss(0.5,0)
		M.adjustToxLoss(0.5,0)
		M.adjustCloneLoss(0.5,0)
	. = ..()

/datum/reagent/invisium/on_mob_end_metabolize(mob/living/L)
	L.alpha = 255
	L.Sleeping(20,0)
	. = ..()

/datum/reagent/bread
	name = "bread"
	description = "a strange as fuck substance that some fucking how turns you into a bread"
	color = "#d48b1e"
	taste_description = "tasty"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/bread/on_mob_life(mob/living/carbon/M)
	spawn_atom_to_turf(/obj/item/reagent_containers/food/snacks/store/bread/plain, M.loc, 1, FALSE)
	M.gib()
	. = ..()
