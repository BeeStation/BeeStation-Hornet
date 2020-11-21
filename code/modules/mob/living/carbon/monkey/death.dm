/mob/living/carbon/monkey/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-m")

/mob/living/carbon/monkey/dust_animation() // Fuck monkeys, they don't abide by the laws of filter physics
	new /obj/effect/temp_visual/dust_animation(loc, "dust-m")
	return 1

/mob/living/carbon/monkey/death(gibbed)
	walk(src,0) // Stops dead monkeys from fleeing their attacker or climbing out from inside His Grace
	. = ..()
