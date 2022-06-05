/obj/structure/chair/sofa //like it's brother fancy chair, this is the father of all sofas
	name = "old father sofa"
	desc = "Now extint, this kind of sofa shouldn't even exist anymore, if you see this rouge specimen, contact your local Nanotransen Anti-couch surfer department."
	icon_state = "sofamiddle"
	icon = 'icons/obj/sofa.dmi'
	buildstackamount = 1
	item_chair = null
	var/mutable_appearance/armrest

/obj/structure/chair/sofa/Initialize(mapload)
	armrest = mutable_appearance(icon, "[icon_state]_armrest", ABOVE_MOB_LAYER)
	return ..()
/obj/structure/chair/sofa/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/sofa/post_unbuckle_mob()
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/corner/handle_layer() //only the armrest/back of this chair should cover the mob.
	return

/obj/structure/chair/sofa/old
	name = "old sofa"
	desc = "A bit dated, but still does the job of being a sofa."
	icon_state = "sofamiddle"

//aaaahhh many sofa defs
/obj/structure/chair/sofa/old/white
	name = "white old sofa"
	color = rgb(212, 212, 212)
/obj/structure/chair/sofa/old/white/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/white/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/white/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/brown/
	name = "brown old sofa"
	color = rgb(136, 76, 26)
/obj/structure/chair/sofa/old/brown/left//would this even work???
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/brown/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/brown/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/beige/
	name = "beige old sofa"
	color = rgb(150, 126, 96)
/obj/structure/chair/sofa/old/beige/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/beige/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/beige/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/red/
	name = "red old sofa"
	color = rgb(130, 50, 46)
/obj/structure/chair/sofa/old/red/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/red/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/red/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/grey/
	name = "grey old sofa"
	color = rgb(128, 128, 128)
/obj/structure/chair/sofa/old/grey/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/grey/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/grey/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/black
	name = "black old sofa"
	color = rgb(48, 48, 48)
/obj/structure/chair/sofa/old/black/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/black/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/black/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/yellow
	name = "yellow old sofa"
	color = rgb(186, 150, 20)
/obj/structure/chair/sofa/old/yellow/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/yellow/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/yellow/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/lime
	name = "lime old sofa"
	color = rgb(180, 220, 10)
/obj/structure/chair/sofa/old/lime/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/lime/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/lime/corner
	icon_state = "sofacorner"

/obj/structure/chair/sofa/old/teal
	name = "teal old sofa"
	color = rgb(16, 176, 176)
/obj/structure/chair/sofa/old/teal/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/teal/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/teal/corner
	icon_state = "sofacorner"


/obj/structure/chair/sofa/old/blue
	name = "blue old sofa"
	color = rgb(42, 132, 190)
/obj/structure/chair/sofa/old/blue/left
	icon_state = "sofaend_left"
/obj/structure/chair/sofa/old/blue/right
	icon_state = "sofaend_right"
/obj/structure/chair/sofa/old/blue/corner
	icon_state = "sofacorner"

// Original icon ported from Eris(?) and updated to work here.
/obj/structure/chair/sofa/corp
	name = "sofa"
	desc = "Soft and cushy."
	icon_state = "corp_sofamiddle"

/obj/structure/chair/sofa/corp/left
	icon_state = "corp_sofaend_left"
/obj/structure/chair/sofa/corp/right
	icon_state = "corp_sofaend_right"
/obj/structure/chair/sofa/corp/corner
	icon_state = "corp_sofacorner"

// Bamboo benches
/obj/structure/chair/sofa/bamboo
	name = "bamboo bench"
	desc = "A makeshift bench with a rustic aesthetic."
	icon_state = "bamboo_sofamiddle"
	resistance_flags = FLAMMABLE
	max_integrity = 60
	buildstacktype = /obj/item/stack/sheet/mineral/bamboo
	buildstackamount = 3

/obj/structure/chair/sofa/bamboo/left
	icon_state = "bamboo_sofaend_left"
/obj/structure/chair/sofa/bamboo/right
	icon_state = "bamboo_sofaend_right"

// Ported from tg ported from Skyrat
/obj/structure/chair/sofa/bench
	name = "bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon_state = "bench_middle"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = "#af7d28"

/obj/structure/chair/sofa/bench/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left
	greyscale_colors = "#af7d28"

/obj/structure/chair/sofa/bench/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right
	greyscale_colors = "#af7d28"

/obj/structure/chair/sofa/bench/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner
	greyscale_colors = "#af7d28"
