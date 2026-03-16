/turf/open/indestructible/reebe_void
	name = "void"
	icon_state = "reebe_void"
	layer = SPACE_LAYER
	baseturfs = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE
	bullet_bounce_sound = null //forever falling
	tiled_dirt = FALSE
	flags_1 = NOJAUNT_1

/turf/open/indestructible/reebe_void/Enter(atom/movable/AM, atom/old_loc)
	if(!..())
		return FALSE
	else
		if(istype(AM, /obj/structure/window))
			return FALSE
		if(istype(AM, /obj/projectile))
			return TRUE
		if((locate(/obj/structure/lattice) in src))
			return TRUE
		return FALSE

/turf/open/indestructible/reebe_void/lattices
	icon_state = "reebe_lattice"

/turf/open/indestructible/reebe_void/lattices/Initialize(mapload)
	. = ..()
	icon_state = "reebe_void"
	for(var/i in 1 to 3)
		if(prob(1))
			new /obj/item/clockwork/alloy_shards/large(src)
		if(prob(2))
			new /obj/item/clockwork/alloy_shards/medium(src)
		if(prob(3))
			new /obj/item/clockwork/alloy_shards/small(src)

	if(prob(2.5))
		new /obj/structure/lattice/catwalk/clockwork(src)
	else if(prob(5))
		new /obj/structure/lattice/clockwork(src)
