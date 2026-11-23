/obj/structure/platform
	name = "platform ledge"
	desc = "The ledge of a raised surface. Beyond it waits a steep fall."
	icon = 'icons/obj/platforms.dmi'
	icon_state = "platform_gray"
	flags_1 = ON_BORDER_1
	density = TRUE
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	pass_flags_self = LETPASSTHROW|PASSSTRUCTURE
	var/reverse = FALSE //for end pieces which block all but one dir of movement
	var/blocking_dir

	armor_type = /datum/armor/structure_platform
	max_integrity = 60

	var/climbable = TRUE

/datum/armor/structure_platform
	melee = 50
	bullet = 90
	laser = 90
	energy = 100
	bomb = 20

/obj/structure/platform/black
	icon_state = "platform_black"

/obj/structure/platform/white
	icon_state = "platform_white"

/obj/structure/platform/wood
	icon_state = "platform_wood"

/obj/structure/platform/warning
	icon_state = "platform_warning"

/obj/structure/platform/gray/corner
	icon_state = "platform_gray_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/platform/black/corner
	icon_state = "platform_black_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/platform/white/corner
	icon_state = "platform_white_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/platform/wood/corner
	icon_state = "platform_wood_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/platform/warning/corner
	icon_state = "platform_warning_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/platform/gray/end
	icon_state = "platform_gray_end"
	reverse = TRUE

/obj/structure/platform/black/end
	icon_state = "platform_black_end"
	reverse = TRUE

/obj/structure/platform/white/end
	icon_state = "platform_white_end"
	reverse = TRUE

/obj/structure/platform/wood/end
	icon_state = "platform_wood_end"
	reverse = TRUE

/obj/structure/platform/warning/end
	icon_state = "platform_warning_end"
	reverse = TRUE

/obj/structure/platform/gray/stair_cutoff
	icon_state = "platform_gray_stairs"
	blocking_dir = NORTH

/obj/structure/platform/black/stair_cutoff
	icon_state = "platform_black_stairs"
	blocking_dir = NORTH

/obj/structure/platform/white/stair_cutoff
	icon_state = "platform_white_stairs"
	blocking_dir = NORTH

/obj/structure/platform/wood/stair_cutoff
	icon_state = "platform_wood_stairs"
	blocking_dir = NORTH

/obj/structure/platform/warning/stair_cutoff
	icon_state = "platform_warning_stairs"
	blocking_dir = NORTH

/obj/structure/platform/Initialize(mapload)
	. = ..()
	if(!blocking_dir)
		if(reverse)
			blocking_dir = (NORTH | SOUTH | EAST | WEST) - REVERSE_DIR(dir)
		else
			blocking_dir = dir
	if(climbable)
		AddElement(/datum/element/climbable)

	if(density && (flags_1 & ON_BORDER_1)) // blocks normal movement from and to the direction it's facing.
		var/static/list/loc_connections = list(
			COMSIG_ATOM_EXIT = PROC_REF(on_exit),
		)
		AddElement(/datum/element/connect_loc, loc_connections)

	if(!climbable) //janky way of distinguishing corners from everything else
		if(dir == WEST || dir == SOUTH)
			layer = ABOVE_MOB_LAYER
	else
		var/mutable_appearance/overlay = mutable_appearance(initial(icon), icon_state, ABOVE_MOB_LAYER)
		switch(blocking_dir) //depending on the direction, either sets the layer of the whole object to above the mob or adds a partial overlay so some parts may still be blow the mob
			if(SOUTH)
				layer = ABOVE_MOB_LAYER
			if(EAST,NORTHEAST)
				overlay.filters += filter(type="alpha",icon=icon(icon, "platform_gray", dir = EAST))
			if(WEST,NORTHWEST)
				overlay.filters += filter(type="alpha",icon=icon(icon, "platform_gray", dir = WEST))
			if(SOUTHEAST, NORTH|SOUTH|EAST)
				overlay.filters += filter(type="alpha",icon=icon(icon, "platform_gray", dir = SOUTHEAST))
			if(SOUTHWEST, NORTH|SOUTH|WEST)
				overlay.filters += filter(type="alpha",icon=icon(icon, "platform_gray", dir = SOUTHWEST))
			if(SOUTH|WEST|EAST, NORTH|WEST|EAST)
				overlay.filters += filter(type="alpha",icon=icon(icon, "platform_gray_end", dir = SOUTH))
		if(overlay.filters.len)
			add_overlay(overlay)

/obj/structure/platform/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir & blocking_dir)
		return . || mover.throwing || mover.movement_type & MOVETYPES_NOT_TOUCHING_GROUND
	return TRUE

/obj/structure/platform/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return // Let's not block ourselves.

	if(!(direction & blocking_dir))
		return

	if (!density)
		return

	if (leaving.throwing)
		return

	if (leaving.movement_type & (PHASING | MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if (leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT
