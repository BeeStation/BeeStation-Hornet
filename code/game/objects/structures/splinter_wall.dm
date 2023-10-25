/obj/structure/splinter_wall
	name = "splinter wall"
	desc = "A dense bush-like structure of splinter growth."
	icon = 'icons/obj/smooth_structures/splinter_wall.dmi'
	icon_state = "icon-0"
	base_icon_state = "icon"
	density = TRUE
	opacity = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	anchored = TRUE //initially is 0 for tile smoothing
	max_integrity = 10000
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100, STAMINA = 0)
	CanAtmosPass = ATMOS_PASS_NO
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SPLINTER_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SPLINTER_WALLS)
	flags_1 = PREVENT_CLICK_UNDER_1

/obj/structure/table/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/splinter_wall/proc/dismantle_splinter(mob/living/user)
	playsound(src, 'sound/weapons/chainsawhit.ogg', 100, 1)
	to_chat(user, "You tear through the [src]!")
	var/obj/effect/decal/cleanable/blood/remains = new /obj/effect/decal/cleanable/blood(get_turf(src))
	qdel(src)

/obj/structure/splinter_wall/attackby(obj/item/I, mob/living/user)
	if(I.tool_behaviour == TOOL_BFC)
		dismantle_splinter()
	else
		to_chat(user, "That does nothing to the [src]!")
		return
