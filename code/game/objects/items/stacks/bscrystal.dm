//Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.
/obj/item/stack/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	singular_name = "bluespace crystal"
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT)
	points = 50
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	refined_type = /obj/item/stack/ore/bluespace_crystal/refined
	grind_results = list(/datum/reagent/bluespace = 20)
	scan_state = "rock_BScrystal"

/obj/item/stack/ore/bluespace_crystal/refined
	name = "refined bluespace crystal"
	points = 0
	refined_type = null

/obj/item/stack/ore/bluespace_crystal/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/stack/ore/bluespace_crystal/get_part_rating()
	return 1

/obj/item/stack/ore/bluespace_crystal/attack_self(mob/user)
	user.visible_message("<span class='warning'>[user] crushes [src]!</span>", "<span class='danger'>You crush [src]!</span>")
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, "sparks", 50, 1)
	blink_mob(user)
	use(1)

/obj/item/stack/ore/bluespace_crystal/proc/blink_mob(mob/living/L)
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/stack/ore/bluespace_crystal/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) // not caught in mid-air
		visible_message("<span class='notice'>[src] fizzles and disappears upon impact!</span>")
		var/turf/T = get_turf(hit_atom)
		new /obj/effect/particle_effect/sparks(T)
		playsound(loc, "sparks", 50, 1)
		if(isliving(hit_atom))
			blink_mob(hit_atom)
		use(1)

//Artificial bluespace crystal, doesn't give you much research.
/obj/item/stack/ore/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT*0.5)
	blink_range = 4 // Not as good as the organic stuff!
	points = 0 //nice try
	refined_type = null
	grind_results = list(/datum/reagent/bluespace = 10, /datum/reagent/silicon = 20)

/obj/item/stack/ore/bluespace_crystal/refined/fifty
	amount = 50

/obj/item/stack/ore/bluespace_crystal/refined/twenty
	amount = 20

/obj/item/stack/ore/bluespace_crystal/refined/five
	amount = 5
