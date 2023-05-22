/turf/closed/wall/mineral/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult_wall-0"
	base_icon_state = "cult_wall"
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = null
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult

/turf/closed/wall/mineral/cult/Initialize(mapload)
	new /obj/effect/temp_visual/cult/turf(src)
	. = ..()

/turf/closed/wall/mineral/cult/devastate_wall()
	new sheet_type(get_turf(src), sheet_amount)

/turf/closed/wall/mineral/cult/try_destroy(obj/item/I, mob/user, turf/T)
	return FALSE

/turf/closed/wall/mineral/cult/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /mob/living/simple_animal/hostile/construct/harvester)) //harvesters can go through cult walls, dragging something with
		var/mob/living/simple_animal/hostile/construct/harvester/H = gone
		var/atom/movable/stored_pulling = H.pulling
		if(stored_pulling)
			stored_pulling.setDir(direction)
			stored_pulling.forceMove(src)
			H.start_pulling(stored_pulling, supress_message = TRUE)

/turf/closed/wall/mineral/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/closed/wall/mineral/cult/artificer/break_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))
	return null //excuse me we want no runed metal here

/turf/closed/wall/mineral/cult/artificer/devastate_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))

/turf/closed/wall/vault
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"

/turf/closed/wall/ice
	icon = 'icons/turf/walls/icedmetal_wall.dmi'
	icon_state = "icedmetal_wall-0"
	base_icon_state = "icedmetal_wall"
	smoothing_flags = SMOOTH_BITMASK
	desc = "A wall covered in a thick sheet of ice."
	canSmoothWith = null
	hardness = 35
	slicing_duration = 150 //welding through the ice+metal
	bullet_sizzle = TRUE

/turf/closed/wall/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_ORANGE

/turf/closed/wall/rust/Initialize(mapload)
	. = ..()
	color = null

/turf/closed/wall/rust/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rust)

/turf/closed/wall/rust/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ScrapeAway()
	return TRUE

/turf/closed/wall/r_wall/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_ORANGE

/turf/closed/wall/r_wall/rust/Initialize(mapload)
	. = ..()
	color = null

/turf/closed/wall/r_wall/rust/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rust)

/turf/closed/wall/r_wall/rust/rust_heretic_act()
	if(prob(50))
		return TRUE
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ScrapeAway()
	return TRUE

/turf/closed/wall/mineral/bronze
	name = "clockwork wall"
	desc = "A huge chunk of bronze, decorated like gears and cogs."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	sheet_type = /obj/item/stack/sheet/bronze
	sheet_amount = 2
	girder_type = /obj/structure/girder/bronze


/turf/closed/indestructible/cordon
	name = "cordon"
	desc = "The final word in problem solving."
	icon_state = "cordon"

//Will this look good? No. Will it work? Probably.

/turf/closed/indestructible/cordon/Entered(atom/movable/AM)
	. = ..()
	if(isobserver(AM))
		return
	if(ismob(AM))
		var/mob/interloper = AM
		interloper.death()
	if(ismecha(AM))
		var/obj/mecha/fuckphazons = AM
		var/mob/living/carbon/interloper = fuckphazons.occupant
		interloper?.death()
		qdel(interloper)

	qdel(AM)
