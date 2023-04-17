//Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.
/obj/item/stack/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "bluespace_crystal"
	singular_name = "bluespace crystal"
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT)
	points = 63
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	refined_type = /obj/item/stack/ore/bluespace_crystal/refined
	grind_results = list(/datum/reagent/bluespace = 20)
	scan_state = "rock_BScrystal"
	novariants = FALSE
	max_amount = 50

/obj/item/stack/ore/bluespace_crystal/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/stack/ore/bluespace_crystal/update_icon()
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
	else if(amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
	else
		icon_state = "[initial(icon_state)]_3"

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

STACKSIZE_MACRO(/obj/item/stack/ore/bluespace_crystal)

//Artificial bluespace crystal, doesn't give you much research.
/obj/item/stack/ore/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	icon_state = "synthetic_bluespace_crystal"
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT*0.5)
	blink_range = 4 // Not as good as the REAL BSC!
	points = 1 //nice try, unfortunateley, they're cheap imitations, have a point for your effort.
	refined_type = null
	grind_results = list(/datum/reagent/bluespace = 10, /datum/reagent/silicon = 20)

STACKSIZE_MACRO(/obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/stack/ore/bluespace_crystal/refined
	name = "refined bluespace crystal"
	desc = "An refined bluespace crystal, it looks as delicate as pretty."
	icon_state = "refined_bluespace_crystal"
	points = 1
	refined_type = null

STACKSIZE_MACRO(/obj/item/stack/ore/bluespace_crystal/refined)
