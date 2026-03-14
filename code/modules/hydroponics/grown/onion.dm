//Onion
/obj/item/food/grown/onion
	seed = /obj/item/plant_seeds/preset/onion
	name = "onion"
	desc = "Nothing to cry over."
	icon_state = "onion"
	tastes = list("onions" = 1)
	wine_power = 30

/obj/item/food/grown/onion/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/onion_slice, 2, 15, screentip_verb = "Cut")

//Red
/obj/item/food/grown/onion/red
	name = "red onion"
	desc = "Purple despite the name."
	icon_state = "onion_red"
	wine_power = 60
	discovery_points = 300

/obj/item/food/grown/onion/red/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/onion_slice/red, 2, 15, screentip_verb = "Cut")

/obj/item/food/grown/onion/UsedforProcessing(mob/living/user, obj/item/I, list/chosen_option)
	var/datum/effect_system/smoke_spread/chem/S = new	//Since the onion is destroyed when it's sliced,
	var/splat_location = get_turf(src)	//we need to set up the smoke beforehand
	S.attach(splat_location)
	S.set_up(reagents, 0, splat_location, 0)
	S.start()
	qdel(S)
	return ..()

/obj/item/food/onion_slice
	name = "onion slices"
	desc = "Rings, not for wearing."
	icon_state = "onionslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	gender = PLURAL
	w_class = WEIGHT_CLASS_TINY
	microwaved_type = /obj/item/food/onionrings

/obj/item/food/onion_slice/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/onionrings, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/*
/obj/item/food/onion_slice/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/onionrings)
*/

/obj/item/food/onion_slice/red
	name = "red onion slices"
	desc = "They shine like exceptionally low quality amethyst."
	icon_state = "onionslice_red"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/tearjuice = 2.5
	)
