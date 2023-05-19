/turf/closed/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS)
	var/last_event = 0
	var/active = null
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = null

/turf/closed/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold_wall-0"
	base_icon_state = "gold_wall"
	sheet_type = /obj/item/stack/sheet/mineral/gold
	explosion_block = 0 //gold is a soft metal you dingus.
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_GOLD_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_GOLD_WALLS)

/turf/closed/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver_wall-0"
	base_icon_state = "silver_wall"
	sheet_type = /obj/item/stack/sheet/mineral/silver
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_SILVER_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SILVER_WALLS)
	custom_materials = list(/datum/material/silver = 4000)

/turf/closed/wall/mineral/copper
	name = "copper wall"
	desc = "A wall with copper plating. Shiny!"
	icon = 'icons/turf/walls/copper_wall.dmi'
	icon_state = "copper"
	sheet_type = /obj/item/stack/sheet/mineral/copper
	icon_state = "copper_wall-0"
	base_icon_state = "copper_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_COPPER_WALLS) //copper walls
	canSmoothWith = list(SMOOTH_GROUP_COPPER_WALLS)

/turf/closed/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	slicing_duration = 200   //diamond wall takes twice as much time to slice
	explosion_block = 3
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_DIAMOND_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_DIAMOND_WALLS)

/turf/closed/wall/mineral/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_BANANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_BANANIUM_WALLS)

/turf/closed/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	sheet_type = /obj/item/stack/sheet/mineral/sandstone
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_SANDSTONE_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SANDSTONE_WALLS)

/turf/closed/wall/mineral/uranium
	article = "a"
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_URANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_URANIUM_WALLS)


/turf/closed/wall/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			radiation_pulse(src, 40)
			for(var/turf/closed/wall/mineral/uranium/T in (RANGE_TURFS(1,src)-src))
				T.radiate()
			last_event = world.time
			active = null
			return
	return

/turf/closed/wall/mineral/uranium/attack_hand(mob/user)
	radiate()
	. = ..()

/turf/closed/wall/mineral/uranium/attackby(obj/item/W, mob/user, params)
	radiate()
	..()

/turf/closed/wall/mineral/uranium/Bumped(atom/movable/AM)
	radiate()
	..()

/turf/closed/wall/mineral/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	thermal_conductivity = 0.04
	canSmoothWith = list(/turf/closed/wall/mineral/plasma, /obj/structure/falsewall/plasma)

/turf/closed/wall/mineral/plasma/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		if(plasma_ignition(6))
			new /obj/structure/girder/displaced(loc)
	..()

/turf/closed/wall/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(exposed_temperature > 300)
		if(plasma_ignition(6))
			new /obj/structure/girder/displaced(loc)

/turf/closed/wall/mineral/plasma/bullet_act(obj/item/projectile/Proj)
	if(!(Proj.nodamage) && Proj.damage_type == BURN)
		if(plasma_ignition(6))
			new /obj/structure/girder/displaced(loc)
	. = ..()

/turf/closed/wall/mineral/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	sheet_type = /obj/item/stack/sheet/wood
	hardness = 70
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WOOD_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WOOD_WALLS)

/turf/closed/wall/mineral/wood/attackby(obj/item/W, mob/user)
	if(W.is_sharp() && W.force)
		var/duration = (48/W.force) * 2 //In seconds, for now.
		if(istype(W, /obj/item/hatchet) || istype(W, /obj/item/fireaxe))
			duration /= 4 //Much better with hatchets and axes.
		if(do_after(user, duration*10, target=src)) //Into deciseconds.
			dismantle_wall(FALSE,FALSE)
			return
	return ..()

/turf/closed/wall/mineral/wood/nonmetal
	desc = "A solidly wooden wall. It's a bit weaker than a wall made with metal."
	girder_type = /obj/structure/barricade/wooden
	hardness = 50

/turf/closed/wall/mineral/bamboo
	name = "bamboo wall"
	desc = "A wall with a bamboo finish."
	icon = 'icons/turf/walls/bamboo_wall.dmi'
	icon_state = "bamboo-0"
	base_icon_state = "bamboo"
	sheet_type = /obj/item/stack/sheet/bamboo
	hardness = 60
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_BAMBOO_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_BAMBOO_WALLS)

/turf/closed/wall/mineral/iron
	name = "rough iron wall"
	desc = "A wall with rough iron plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	sheet_type = /obj/item/stack/rods
	sheet_amount = 5
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_IRON_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_IRON_WALLS)

/turf/closed/wall/mineral/snow
	name = "packed snow wall"
	desc = "A wall made of densely packed snow blocks."
	icon = 'icons/turf/walls/snow_wall.dmi'
	icon_state = "snow_wall-0"
	base_icon_state = "snow_wall"
	smoothing_flags = SMOOTH_BITMASK
	hardness = 80
	explosion_block = 0
	slicing_duration = 30
	sheet_type = /obj/item/stack/sheet/snow

	girder_type = null
	bullet_sizzle = TRUE
	bullet_bounce_sound = null

/turf/closed/wall/mineral/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	sheet_type = /obj/item/stack/sheet/mineral/abductor
	slicing_duration = 200   //alien wall takes twice as much time to slice
	explosion_block = 3
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_ABDUCTOR_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ABDUCTOR_WALLS)

/////////////////////Titanium walls/////////////////////

/turf/closed/wall/mineral/titanium //has to use this path due to how building walls works
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle_wall-0"
	base_icon_state = "shuttle_wall"
	explosion_block = 3
	flags_1 = CAN_BE_DIRTY_1
	flags_ricochet = RICOCHET_SHINY | RICOCHET_HARD
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_TITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/wall/mineral/titanium/nodiagonal
	smoothing_flags = SMOOTH_BITMASK
	icon_state = "map-shuttle_nd"

/turf/closed/wall/mineral/titanium/nosmooth
	smoothing_flags = NONE
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"

/turf/closed/wall/mineral/titanium/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)

//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/closed/wall/mineral/titanium/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

/turf/closed/wall/mineral/titanium/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/turf/closed/wall/mineral/titanium/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "survival_pod_walls-0"
	base_icon_state = "survival_pod_walls"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/wall/mineral/titanium/survival/nodiagonal
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "survival_pod_walls-0"
	base_icon_state = "survival_pod_walls"
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/mineral/titanium/survival/pod
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_SURVIVAL_TIANIUM_POD)
	canSmoothWith = list(SMOOTH_GROUP_SURVIVAL_TIANIUM_POD)

/////////////////////Plastitanium walls/////////////////////

/turf/closed/wall/mineral/plastitanium
	name = "wall"
	desc = "A durable wall made of an alloy of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	explosion_block = 4
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_PLASTITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_PLASTITANIUM_WALLS, SMOOTH_GROUP_SYNDICATE_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/wall/mineral/plastitanium/try_destroy(obj/item/I, mob/user, turf/T)
	return FALSE

/turf/closed/wall/mineral/plastitanium/nodiagonal
	smoothing_flags = SMOOTH_BITMASK
	icon_state = "map-shuttle_nd"

/turf/closed/wall/mineral/plastitanium/nosmooth
	smoothing_flags = NONE
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"

/turf/closed/wall/mineral/plastitanium/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)

/turf/closed/wall/mineral/plastitanium/explosive/ex_act(severity)
	var/obj/item/bombcore/large/bombcore = new(get_turf(src))
	bombcore.detonate()
	..()

//have to copypaste this code
/turf/closed/wall/mineral/plastitanium/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

/turf/closed/wall/mineral/plastitanium/copyTurf(turf/T)
	. = ..()
	T.transform = transform
