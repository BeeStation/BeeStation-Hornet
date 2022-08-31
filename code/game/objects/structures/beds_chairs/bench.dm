/obj/structure/chair/fancy/bench
	name = "bench"
	desc = "You sit in this. Either by will or force, but maybe not alone."
	icon = 'icons/obj/beds_chairs/benches.dmi'
	max_integrity = 250
	integrity_failure = 25
	icon_state = "bench_center"

/obj/structure/chair/fancy/bench/left
	icon_state = "bench_left"

/obj/structure/chair/fancy/bench/right
	icon_state = "bench_right"

/obj/structure/chair/fancy/bench/pew
	name = "wooden pew"
	desc = "Kneel here and pray."
	icon_state = "pewmiddle"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 3
	item_chair = null

/obj/structure/chair/fancy/bench/pew/left
	name = "left wooden pew end"
	icon_state = "pewend_left"

/obj/structure/chair/fancy/bench/pew/right
	name = "right wooden pew end"
	icon_state = "pewend_right"

// Bamboo benches
/obj/structure/chair/fancy/bench/bamboo
	name = "bamboo bench"
	desc = "A makeshift bench with a rustic aesthetic."
	icon_state = "bamboo_sofamiddle"
	resistance_flags = FLAMMABLE
	max_integrity = 60
	buildstacktype = /obj/item/stack/sheet/mineral/bamboo
	buildstackamount = 3

/obj/structure/chair/fancy/bench/bamboo/left
	icon_state = "bamboo_sofaend_left"

/obj/structure/chair/fancy/bench/bamboo/right
	icon_state = "bamboo_sofaend_right"

// Ported from tg ported from Skyrat
/obj/structure/chair/fancy/bench/corporate
	name = "corporate bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon_state = "corporate_bench_middle"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = "#af7d28"
	color = rgb(255,255,255)
	colorable = TRUE

/obj/structure/chair/fancy/bench/corporate/left
	icon_state = "corporate_bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/fancy/bench/corporate/right
	icon_state = "corporate_bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/fancy/bench/corporate/handle_layer()
	return
