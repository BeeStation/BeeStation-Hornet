// Chili
/obj/item/seeds/chili
	name = "pack of chili seeds"
	desc = "These seeds grow into chili plants. HOT! HOT! HOT!"
	icon_state = "seed-chili"
	species = "chili"
	plantname = "Chili Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/chili
	lifespan = 20
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "chili-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "chili-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/chili/ice, /obj/item/seeds/chili/ghost)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 6),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 6),
		/datum/reagent/consumable/capsaicin = list(25, 30))

/obj/item/reagent_containers/food/snacks/grown/chili
	seed = /obj/item/seeds/chili
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	filling_color = "#FF0000"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 20

// Ice Chili
/obj/item/seeds/chili/ice
	name = "pack of ice pepper seeds"
	desc = "These seeds grow into ice pepper plants."
	icon_state = "seed-icepepper"
	species = "chiliice"
	plantname = "Ice Pepper Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/icepepper
	lifespan = 25
	maturation = 4
	production = 4
	rarity = 20
	mutatelist = list(/obj/item/seeds/chili)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(2, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 8),
		/datum/reagent/consumable/frostoil = list(20, 30))

/obj/item/reagent_containers/food/snacks/grown/icepepper
	seed = /obj/item/seeds/chili/ice
	name = "ice pepper"
	desc = "It's a mutant strain of chili."
	icon_state = "icepepper"
	filling_color = "#0000CD"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 30
	discovery_points = 300

// Ghost Chili
/obj/item/seeds/chili/ghost
	name = "pack of ghost chili seeds"
	desc = "These seeds grow into a chili said to be the hottest in the galaxy."
	icon_state = "seed-chilighost"
	species = "chilighost"
	plantname = "Ghost Chili Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/ghost_chili
	endurance = 10
	maturation = 10
	production = 10
	yield = 3
	rarity = 20
	mutatelist = list(/obj/item/seeds/chili)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(2, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 8),
		/datum/reagent/consumable/capsaicin = list(25, 50),
		/datum/reagent/consumable/condensedcapsaicin = list(55, 70))

/obj/item/reagent_containers/food/snacks/grown/ghost_chili
	seed = /obj/item/seeds/chili/ghost
	name = "ghost chili"
	desc = "It seems to be vibrating gently."
	icon_state = "ghostchilipepper"
	var/mob/living/carbon/human/held_mob
	filling_color = "#F8F8FF"
	bitesize_mod = 4
	foodtype = FRUIT
	wine_power = 50
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/ghost_chili/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if( ismob(loc) )
		held_mob = loc
		START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/grown/ghost_chili/process(delta_time)
	if(held_mob && loc == held_mob)
		if(held_mob.is_holding(src))
			if(istype(held_mob) && held_mob.gloves)
				return
			held_mob.adjust_bodytemperature(7.5 * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time)
			if(DT_PROB(5, delta_time))
				to_chat(held_mob, "<span class='warning'>Your hand holding [src] burns!</span>")
	else
		held_mob = null
		..()
