/*
	Cabbage
	Medium Fruit that grows averagely
*/
/datum/plant_feature/fruit/cabbage
	species_name = "brassica infantem"
	name = "cabbage"
	icon_state = "cabbage"
	fruit_product = /obj/item/food/grown/cabbage
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST//PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/*
	Dionae Pod
*/
/datum/plant_feature/fruit/cabbage/diona
	species_name = "brassica homo"
	name = "diona pod"
	icon_state = "invincible"
	fruit_product = /mob/living/simple_animal/hostile/retaliate/nymph
	can_copy = FALSE
	can_remove = FALSE
	whitelist_features = list(/datum/plant_feature/body/diona_pod, /datum/plant_feature/roots)
	///Do we have a mind associated with this feature?
	var/datum/mind/our_mind

/datum/plant_feature/fruit/cabbage/diona/build_fruit()
	. = ..()
	var/mob/living/simple_animal/hostile/retaliate/nymph/child = .
	if(istype(child))
		child.is_ghost_spawn = TRUE
