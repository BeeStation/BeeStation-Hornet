/*
	Flower
	Generic flower
*/
/datum/plant_feature/fruit/flower
	species_name = "oblivisci flos"
	name = "forget me not"
	icon_state = "flower_1"
	icon_uneven = TRUE
	seed_icon_state = "seed-forget_me_not"
	//colour_overlay = "flower_1_colour" //This and colour override are used to make flower's pretty. Keep as examples.
	fruit_product = /obj/item/food/grown/flower/forgetmenot
	plant_traits = list(/datum/plant_trait/nectar)
	//colour_override = "#ffffff"
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_VERY_FAST
	fast_reagents = list(/datum/reagent/medicine/kelotane = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/poppy)

/datum/plant_feature/fruit/flower/pink
	colour_override = "#ffc5e5"
	dictionary_override = /datum/plant_feature/fruit/flower

/datum/plant_feature/fruit/flower/yellow
	colour_override = "#fff23f"
	dictionary_override = /datum/plant_feature/fruit/flower


/*
	Poppy
*/
/datum/plant_feature/fruit/flower/poppy
	species_name = "flos ruber"
	name = "poppy"
	icon_state = "flower_3"
	colour_overlay = "flower_3_colour"
	colour_override = "#ee1e1e"
	seed_icon_state = "seed-poppy"
	fruit_product = /obj/item/food/grown/flower/poppy
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/morphine = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/flower/geranium, /datum/plant_feature/fruit/flower/lily)


/*
	Geranium
*/
/datum/plant_feature/fruit/flower/geranium
	species_name = "hyacinthum papaver"
	name = "geranium"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#33a4d8"
	seed_icon_state = "seed-geranium"
	fruit_product = /obj/item/food/grown/flower/geranium
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower)

/*
	Harebell
*/
/datum/plant_feature/fruit/flower/harebell
	species_name = "viriditas flos"
	name = "harebell"
	icon_state = "harebell"
	seed_icon_state = "seed-harebell"
	fruit_product = /obj/item/food/grown/flower/harebell

/*
	Lily
	See her everywhere in everything, dude
*/
/datum/plant_feature/fruit/flower/lily
	species_name = "sol lilium"
	name = "lily"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#ee601e"
	seed_icon_state = "seed-lily"
	fruit_product = /obj/item/food/grown/flower/lily
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/trumpet)

/*
	Spaceman's Trumpet
*/
/datum/plant_feature/fruit/flower/trumpet
	species_name = "tubae flos"
	name = "spaceman's trumpet"
	icon_state = "trumpet"
	seed_icon_state = "seed-trumpet"
	fruit_product = /obj/item/food/grown/flower/trumpet
	fast_reagents = list(/datum/reagent/medicine/polypyr = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/poppy)

/*
	Sun Flower
*/
/datum/plant_feature/fruit/flower/sun
	species_name = "sol flos"
	name = "sun flower"
	icon_state = "sun"
	seed_icon_state = "seed-sunflower"
	fruit_product = /obj/item/grown/sunflower
	fast_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/nova = 8)

/*
	Nova Flower
*/
/datum/plant_feature/fruit/flower/nova
	species_name = "flos nova"
	name = "nova flower"
	icon_state = "sun_colour"
	colour_override = "#ff4800"
	seed_icon_state = "seed-novaflower"
	fruit_product = /obj/item/grown/novaflower
	fast_reagents = list(/datum/reagent/consumable/condensedcapsaicin = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/capsaicin = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/moon = 3)

/*
	Moon Flower
*/
/datum/plant_feature/fruit/flower/moon
	species_name = "flos lunae"
	name = "moon flower"
	icon_state = "sun_colour"
	colour_override = "#9c90e0"
	seed_icon_state = "seed-moonflower"
	fruit_product = /obj/item/food/grown/flower/moonflower
	fast_reagents = list(/datum/reagent/consumable/ethanol/moonshine = PLANT_REAGENT_MEDIUM, /datum/reagent/acetone = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/flower/sun)

/*
	Rainbow Flower
*/
/datum/plant_feature/fruit/flower/rainbow
	species_name = "iris flos"
	name = "rainbow flower"
	icon_state = "flower_1"
	colour_overlay = "flower_1_colour"
	seed_icon_state = "seed-rainbowbunch"
	fruit_product = /obj/item/food/grown/flower/rainbow
	colour_override = list("#DA0000", "#FF9300", "#FFF200", "#A8E61D", "#00B7EF", "#DA00FF", "#1C1C1C", "#FFFFFF")

/*
	Spiral
*/
/datum/plant_feature/fruit/flower/spiral
	species_name = "sol flos sp I"
	name = "spiral flower"
	icon_state = "spiral"
	seed_icon_state = "seed-kirby"
	fruit_product = null

/*
	Orb
*/
/datum/plant_feature/fruit/flower/orb
	species_name = "sol flos sp II"
	name = "glow flower"
	icon_state = "orb"
	colour_override = "#FFF993"
	seed_icon_state = "seed-kirby"
	fruit_product = null

/datum/plant_feature/fruit/flower/orb/New(datum/component/plant/_parent)
	. = ..()
	var/mutable_appearance/emissive = emissive_appearance(icon, icon_state)
	emissive.color = colour_override
	emissive.filters += gauss_blur_filter(1)
	feature_appearance.add_overlay(emissive)
