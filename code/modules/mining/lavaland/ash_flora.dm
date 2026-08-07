//*******************Contains everything related to the flora on lavaland.*******************************
//This includes: The structures, their produce, their seeds and the crafting recipe for the mushroom bowl

/obj/structure/flora/ash
	name = "large mushrooms"
	desc = "A number of large mushrooms, covered in a faint layer of ash and what can only be spores."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom1"
	base_icon_state = "l_mushroom"
	// What kinda of flora does this helper plant
	var/obj/item/plant_seeds/seed_type = /obj/item/plant_seeds/preset/inocybe
	var/datum/component/plant/plant_component

/obj/structure/flora/ash/Initialize(mapload)
	. = ..()
// Setup our visuals
	base_icon_state = "[base_icon_state][rand(1, 4)]"
	icon_state = base_icon_state
// Make ourselves a real plant
	seed_type = new seed_type(src)
	plant_component = AddComponent(/datum/component/plant, src, seed_type.plant_features, _use_body_appearance = FALSE)
	// Add some bonus traits to it
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		// Remove possible duplicates - kind of a fucked up way of doing it tbh
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			if(trait.allow_multiple)
				continue
			// Essentially just remove ourselves from the pool of possible random traits - Don't worry, this gets refilled!
			if(!SSbotany.unused_random_traits["[feature.trait_type_shortcut]"]) //For nectar, and any other weirdo future traits
				continue
			SSbotany.unused_random_traits["[feature.trait_type_shortcut]"] -= trait.type
		var/datum/plant_trait/trait = SSbotany.get_random_trait("[feature.trait_type_shortcut]")
		trait = new trait(feature)
		if(!QDELING(trait))
			feature.plant_traits += trait
	// Update species ID to reflect new traits
	plant_component.compile_species_id()

/obj/structure/flora/ash/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant_component.plant_features
	if(!length(fruit_feature?.fruits))
		to_chat(user, span_warning("[src] isn't ready to harvest!"))

/obj/structure/flora/ash/tall_shroom //exists only so that the spawning check doesn't allow these spawning near other things - Joan Lung. Circa 2016 Sept 9th

/obj/structure/flora/ash/leaf_shroom
	name = "leafy mushrooms"
	desc = "A number of mushrooms, each of which surrounds a greenish sporangium with a number of leaf-like structures."
	icon_state = "s_mushroom1"
	base_icon_state = "s_mushroom"
	seed_type = /obj/item/plant_seeds/preset/porcini

/obj/structure/flora/ash/cap_shroom
	name = "tall mushrooms"
	desc = "Several mushrooms, the larger of which have a ring of conks at the midpoint of their stems."
	icon_state = "r_mushroom1"
	base_icon_state = "r_mushroom"
	seed_type = /obj/item/plant_seeds/preset/inocybe

/obj/structure/flora/ash/stem_shroom
	name = "numerous mushrooms"
	desc = "A large number of mushrooms, some of which have long, fleshy stems. They're radiating light!"
	icon_state = "t_mushroom1"
	base_icon_state = "t_mushroom"
	seed_type = /obj/item/plant_seeds/preset/embershroom


/obj/structure/flora/ash/cacti
	name = "fruiting cacti"
	desc = "Several prickly cacti, brimming with ripe fruit and covered in a thin layer of ash."
	icon_state = "cactus1"
	base_icon_state = "cactus"
	seed_type = /obj/item/plant_seeds/preset/cactus

/obj/structure/flora/ash/cacti/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 3, max_damage = 6, probability = 70)

//SNACKS

/obj/item/food/grown/ash_flora
	name = "mushroom shavings"
	desc = "Some shavings from a tall mushroom. With enough, might serve as a bowl."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_shavings"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 100
	seed = /obj/item/plant_seeds/preset/polypore
	wine_power = 20

/obj/item/food/grown/ash_flora/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/item/food/grown/ash_flora/shavings //So we can't craft bowls from everything.

/obj/item/food/grown/ash_flora/mushroom_leaf
	name = "mushroom leaf"
	desc = "A leaf, from a mushroom."
	icon_state = "mushroom_leaf"
	seed = /obj/item/plant_seeds/preset/porcini
	wine_power = 40

/obj/item/food/grown/ash_flora/mushroom_cap
	name = "mushroom cap"
	desc = "The cap of a large mushroom."
	icon_state = "mushroom_cap"
	seed = /obj/item/plant_seeds/preset/inocybe
	wine_power = 70

/obj/item/food/grown/ash_flora/mushroom_stem
	name = "mushroom stem"
	desc = "A long mushroom stem. It's slightly glowing."
	icon_state = "mushroom_stem"
	seed = /obj/item/plant_seeds/preset/embershroom
	wine_power = 60

/obj/item/food/grown/ash_flora/cactus_fruit
	name = "cactus fruit"
	desc = "A cactus fruit covered in a thick, reddish skin. And some ash."
	icon_state = "cactus_fruit"
	seed = /obj/item/plant_seeds/preset/cactus
	wine_power = 50

//CRAFTING

/obj/item/reagent_containers/cup/bowl/mushroom_bowl
	name = "mushroom bowl"
	desc = "A bowl made out of mushrooms. Not food, though it might have contained some at some point."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"

/obj/item/reagent_containers/cup/bowl/mushroom_bowl/update_icon()
	cut_overlays()
	if(reagents?.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/lavaland/ash_flora.dmi', "fullbowl")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
	else
		icon_state = "mushroom_bowl"
