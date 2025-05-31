//here be (almost) all of the indestructible walls, they have been properly categorized under this file now.

/turf/closed/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	explosion_block = 50
	resistance_flags = INDESTRUCTIBLE

/turf/closed/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/closed/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/closed/indestructible/singularity_act()
	return

/turf/closed/indestructible/rust_heretic_act()
	return

/turf/closed/indestructible/turf_destruction(damage_flag, additional_damage)
	return

////Service "walls"////

//splash screen
/turf/closed/indestructible/splashscreen
	name = "Space Station 13"
	icon = 'icons/blanks/blank_title.png'
	icon_state = ""
	layer = FLY_LAYER
	bullet_bounce_sound = null

INITIALIZE_IMMEDIATE(/turf/closed/indestructible/splashscreen)

/turf/closed/indestructible/splashscreen/Initialize(mapload)
	. = ..()
	SStitle.splash_turf = src
	if(SStitle.icon)
		icon = SStitle.icon

/turf/closed/indestructible/splashscreen/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				SStitle.icon = icon

/turf/closed/indestructible/splashscreen/examine(mob/user)
	desc = pick(strings(SPLASH_DESC_FILE, "splashes"))
	. = ..()

//cordon "wall"
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
		var/obj/vehicle/sealed/mecha/fuckphazons = AM
		var/mob/living/carbon/interloper = fuckphazons.occupants
		interloper?.death()
		qdel(interloper)

	qdel(AM)

/turf/closed/indestructible/cordon/is_holy()
	return TRUE // The blessed cordon freeman

////non-smoothed walls////

//old shuttle
/turf/closed/indestructible/oldshuttle
	name = "strange shuttle wall"
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "block"

/turf/closed/indestructible/oldshuttle/corner
	icon_state = "corner"

/turf/closed/indestructible/abductor
	icon_state = "alien1" //they are var edited in map, to be changed later because who the hell tought it was a good idea to do so?

/turf/closed/indestructible/opshuttle
	icon_state = "wall3"

/turf/closed/indestructible/fakedoor
	name = "CentCom Access"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	icon_state = "fake_door"

/turf/closed/indestructible/rock
	name = "dense rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"

/turf/closed/indestructible/rock/snow
	name = "mountainside"
	desc = "An extremely densely-packed rock, sheeted over with centuries worth of ice and snow."
	icon_state = "snowrock"
	bullet_sizzle = TRUE
	bullet_bounce_sound = null

/turf/closed/indestructible/rock/snow/ice
	name = "iced rock"
	desc = "Extremely densely-packed sheets of ice and rock, forged over the years of the harsh cold."
	icon_state = "icerock"

/turf/closed/indestructible/rock/bedrock
	name = "bedrock rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_dense"

/turf/closed/indestructible/paper
	name = "thick paper wall"
	desc = "A wall layered with impenetrable sheets of paper."
	icon_state = "paperwall"

/turf/closed/indestructible/necropolis
	name = "necropolis wall"
	desc = "A seemingly impenetrable wall."
	icon_state = "necro"
	explosion_block = 50
	baseturfs = /turf/closed/indestructible/necropolis

/turf/closed/indestructible/necropolis/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "necro1"
	return TRUE

////smoothed walls////

/turf/closed/indestructible/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	smoothing_flags = SMOOTH_BITMASK
	baseturfs = /turf/closed/indestructible/sandstone

/turf/closed/indestructible/riveted
	icon = 'icons/turf/walls/riveted.dmi'
	icon_state = "riveted-0"
	base_icon_state = "riveted"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS)
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS)

/turf/closed/indestructible/syndicate
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_SYNDICATE_WALLS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SYNDICATE_WALLS, SMOOTH_GROUP_PLASTITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/indestructible/riveted/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/indestructible/fakeglass
	name = "window"
	icon = 'icons/obj/smooth_structures/windows/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	opacity = FALSE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	opacity = FALSE

/turf/closed/indestructible/fakeglass/Initialize(mapload)
	. = ..()
	icon_state = null //set the icon state to null, so our base state isn't visible
	underlays += mutable_appearance('icons/obj/structures.dmi', "grille") //add a grille underlay
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating") //add the plating underlay, below the grille

/turf/closed/indestructible/opsglass
	name = "window"
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	opacity = FALSE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM, SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM)
	opacity = FALSE
	icon = 'icons/obj/smooth_structures/windows/plastitanium_window.dmi'

/turf/closed/indestructible/opsglass/Initialize(mapload)
	. = ..()
	icon_state = null
	underlays += mutable_appearance('icons/obj/structures.dmi', "grille")
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating")

/turf/closed/indestructible/riveted/boss
	name = "necropolis wall"
	desc = "A thick, seemingly indestructible stone wall."
	icon = 'icons/turf/walls/boss_wall.dmi'
	icon_state = "boss_wall-0"
	base_icon_state = "boss_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_BOSS_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_BOSS_WALLS)
	explosion_block = 50
	baseturfs = /turf/closed/indestructible/riveted/boss

/turf/closed/indestructible/riveted/boss/see_through
	opacity = FALSE

/turf/closed/indestructible/riveted/boss/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt" //should it be basalt and *only* basalt if in the future we add different locations that have something else as a base ground?
	return TRUE

/turf/closed/indestructible/riveted/hierophant
	name = "wall"
	desc = "A wall made out of a strange metal. The squares on it pulse in a predictable pattern."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "wall"
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_HIERO_WALL)
	canSmoothWith = list(SMOOTH_GROUP_HIERO_WALL)


