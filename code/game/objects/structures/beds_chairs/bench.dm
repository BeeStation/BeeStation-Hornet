/obj/structure/chair/fancy/bench
	name = "bench"
	desc = "You sit in this. Either by will or force, but maybe not alone."
	icon = 'icons/obj/beds_chairs/benches.dmi'
	max_integrity = 250
	integrity_failure = 25
	icon_state = "bench_center"
	buildstackamount = 1
	item_chair = null

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
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 3
	item_chair = null

///This proc adds the rotate component, overwrite this if you for some reason want to change some specific args.
/obj/structure/chair/fancy/bench/pew/MakeRotate()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH|ROTATION_IGNORE_ANCHORED)

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
	buildstacktype = /obj/item/stack/sheet/bamboo
	buildstackamount = 3

/obj/structure/chair/fancy/bench/bamboo/left
	icon_state = "bamboo_sofaend_left"

/obj/structure/chair/fancy/bench/bamboo/right
	icon_state = "bamboo_sofaend_right"

// Ported from tg ported from Skyrat, oh and this version is off Paradise, aka GAGless but almost GAGs!
/obj/structure/chair/fancy/bench/corporate
	name = "corporate bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon_state = "corporate_bench_middle_mapping"
	base_icon_state = "corporate_bench_middle"
	///icon for the cover seat
	var/image/cover
	///cover seat color, by default this one
	var/cover_color = rgb(175, 125, 40)
	color = null
	colorable = FALSE

/obj/structure/chair/fancy/bench/corporate/Initialize(mapload)
	icon_state = base_icon_state //so the rainbow seats for mapper clarity are not in-game
	GetCover()
	return ..()

/obj/structure/chair/fancy/bench/corporate/proc/GetCover()
	if(cover)
		cut_overlay(cover)
	cover = mutable_appearance('icons/obj/beds_chairs/benches.dmi', "[icon_state]_cover", color = cover_color) //this supports colouring, but not the base bench
	add_overlay(cover)

/obj/structure/chair/fancy/bench/corporate/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		cover_color = C.crayon_color
	if(cover_color)
		GetCover()

/obj/structure/chair/fancy/bench/corporate/handle_layer()
	return

/obj/structure/chair/fancy/bench/corporate/left
	icon_state = "corporate_bench_left_mapping"
	base_icon_state = "corporate_bench_left"

/obj/structure/chair/fancy/bench/corporate/right
	icon_state = "corporate_bench_right_mapping"
	base_icon_state = "corporate_bench_right"
