/*
	Tree
*/
/datum/plant_feature/body/tree
	species_name = "humilis arbor"
	name = "tree"
	icon_state = "tree"
	growth_prefix = "tree"
	growth_stages = 4
	overlay_positions = list(list(16, 30), list(9, 26), list(22, 24), list(15, 22), list(11, 17), list(21, 16))
	yields = PLANT_BODY_YIELD_LARGE
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_MEDIUM
	max_harvest = PLANT_BODY_HARVEST_MEDIUM
	growth_time = PLANT_BODY_GROWTH_SLOW
	mutations = list(/datum/plant_feature/body/tree/mini, /datum/plant_feature/body/tree/birch, /datum/plant_feature/body/tree/cherry)
	///What colour are our leaves for the growth transitions
	var/particle_leaf_colour = "#64A344"

/datum/plant_feature/body/tree/growth_step(step)
	. = ..()
	if(step > 2)
		playsound(parent.plant_item, 'sound/effects/rustle.ogg', 30, TRUE)
		var/obj/emitter/confetti/leaves/particles = parent.plant_item.add_emitter(/obj/emitter/confetti/leaves, "leaves", 10, lifespan = 20)
		particles.set_colour(particle_leaf_colour)
	parent.plant_item.add_emitter(/obj/emitter/plant_dust, "dust", 10, lifespan = 20)

/datum/plant_feature/body/tree/apple
	name = "apple tree"

/datum/plant_feature/body/tree/orange
	name = "orange tree"
	icon_state = "tree_2"

/*
	Birch
*/
/datum/plant_feature/body/tree/birch
	icon_state = "birch"
	growth_prefix = "birch"
	overlay_positions = list(list(7, 30), list(13, 25), list(23, 23), list(28, 19), list(13, 15))
	mutations = list(/datum/plant_feature/body/tree/mini)
	particle_leaf_colour = "#ffbb00"

/*
	Cherry
*/
/datum/plant_feature/body/tree/cherry
	icon_state = "cherry"
	growth_prefix = "cherry"
	overlay_positions = list(list(7, 30), list(13, 25), list(23, 23), list(28, 19), list(13, 15))
	mutations = list(/datum/plant_feature/body/tree/mini)
	particle_leaf_colour = "#ffacf1"

/*
	Mini
*/
/datum/plant_feature/body/tree/mini
	species_name = "infantem arbor"
	name = "fruit tree"
	icon_state = "bush"
	growth_stages = 3
	growth_time = PLANT_BODY_GROWTH_MEDIUM
	overlay_positions = list(list(17, 23), list(11, 20), list(23, 15), list(11, 13))
	mutations = list(/datum/plant_feature/body/tree/sparse)

/datum/plant_feature/body/tree/mini/cherry
	name = "cherry tree"

/datum/plant_feature/body/tree/mini/cocoa
	name = "cocoa tree"

/datum/plant_feature/body/tree/mini/lemon
	name = "lemon tree"

/datum/plant_feature/body/tree/mini/lime
	name = "lime tree"

/*
	Sparse
*/
/datum/plant_feature/body/tree/sparse
	species_name = "arbor sparsa"
	name = "sparse tree"
	icon_state = "menace"
	growth_prefix = "birch"
	growth_stages = 3
	overlay_positions = list()
	mutations = list(/datum/plant_feature/body/tree/gum)

/*
	Gum
*/
/datum/plant_feature/body/tree/gum
	species_name = "ignis arbor"
	name = "gum tree"
	icon_state = "gum"
	wither_state = "menace"
	growth_prefix = "birch"
	growth_stages = 3
	overlay_positions = list(list(19, 12), list(9, 23), list(3, 21), list(10, 30), list(15, 27), list(21, 28), list(27, 30))
	mutations = list(/datum/plant_feature/body/tree/palm)

/*
	Palm
*/
/datum/plant_feature/body/tree/palm
	species_name = "litus arbore"
	name = "palm tree"
	icon = 'icons/obj/hydroponics/features/body_tall.dmi'
	icon_state = "palm"
	overlay_positions = list(list(14, 28), list(19, 26))
	mutations = list(/datum/plant_feature/body/tree)

/datum/plant_feature/body/tree/palm/banana
	name = "banana palm"

/datum/plant_feature/body/tree/palm/coconut
	name = "coconut palm"
