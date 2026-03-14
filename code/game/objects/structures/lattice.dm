/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice. These hold our station together."
	icon = 'icons/obj/smooth_structures/catwalks/lattice.dmi'
	icon_state = "lattice-255"
	base_icon_state = "lattice"
	density = FALSE
	anchored = TRUE
	armor_type = /datum/armor/structure_lattice
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_LATTICE)
	canSmoothWith = list(SMOOTH_GROUP_OPEN_FLOOR, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_LATTICE)
	z_flags = Z_BLOCK_OUT_DOWN
	var/number_of_rods = 1
	var/list/give_turf_traits = list(TRAIT_CHASM_STOPPED, TRAIT_HYPERSPACE_STOPPED, TRAIT_TURF_IGNORE_SLOWDOWN, TRAIT_IMMERSE_STOPPED)

/datum/armor/structure_lattice
	melee = 50
	fire = 80
	acid = 50

/obj/structure/lattice/Initialize(mapload)
	. = ..()
	if (length(give_turf_traits))
		give_turf_traits = string_list(give_turf_traits)
		AddElement(/datum/element/give_turf_traits, give_turf_traits)

/obj/structure/lattice/examine(mob/user)
	. = ..()
	. += span_notice("The rods look like they could be <b>cut</b>. There's space for more <i>rods</i> or a <i>tile</i>.")

/obj/structure/lattice/blob_act(obj/structure/blob/B)
	return

/obj/structure/lattice/ratvar_act()
	new /obj/structure/lattice/clockwork(loc)

/obj/structure/lattice/attackby(obj/item/C, mob/user, params)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	if(C.tool_behaviour == TOOL_WIRECUTTER)
		to_chat(user, span_notice("Slicing [name] joints ..."))
		deconstruct()
	else
		var/turf/T = get_turf(src)
		return T.attackby(C, user) //hand this off to the turf instead (for building plating, catwalks, etc)

/obj/structure/lattice/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/rods(get_turf(src), number_of_rods)
	qdel(src)

/obj/structure/lattice/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
	return FALSE

/obj/structure/lattice/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL && isspaceturf(src.loc)) // Don't want it trying to place a tile over in-station catwalks.
		to_chat(user, span_notice("You build a floor."))
		log_attack("[key_name(user)] has constructed a floor over space at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		var/turf/T = src.loc
		T.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/obj/structure/lattice/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	if(current_size >= STAGE_FOUR)
		deconstruct()
