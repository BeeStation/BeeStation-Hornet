/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/proc/do_sparks(number, cardinal_only, datum/source)

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(number, cardinal_only, source)
	sparks.autocleanup = TRUE
	sparks.start()


/obj/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	anchored = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.5
	light_color = LIGHT_COLOR_FIRE
	light_flags = LIGHT_NO_LUMCOUNT

/obj/effect/particle_effect/sparks/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/particle_effect/sparks/LateInitialize()
	flick(icon_state, src) // replay the animation
	playsound(src, "sparks", 100, TRUE)
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks

/obj/effect/particle_effect/sparks/red // Dark Red light for fun!
	name = "red sparks"
	icon_state = "sparks_white"
	light_color = COLOR_RED_LIGHT

/obj/effect/particle_effect/sparks/blue // Dark Red light for fun!
	name = "blue sparks"
	icon_state = "sparks_white"
	light_color = LIGHT_COLOR_LIGHT_CYAN

//electricity

/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"

/datum/effect_system/lightning_spread
	effect_type = /obj/effect/particle_effect/sparks/electricity

// shield sparks
/obj/effect/particle_effect/sparks/shield
	name = "shield sparks"
	icon_state = "shieldsparkles"

/obj/effect/particle_effect/sparks/shield/Initialize(mapload)
	. = ..()
	// every particle has a little different color
	var/generator/gen_color = generator("color", COLOR_WHITE, LIGHT_COLOR_ELECTRIC_CYAN)
	var/rand_color = gen_color.Rand()
	color = rand_color
	set_light_color(rand_color)

