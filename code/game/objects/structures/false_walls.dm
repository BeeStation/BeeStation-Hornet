/*
 * False Walls
 */
/obj/structure/falsewall
	anchored = TRUE
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS)
	layer = LOW_OBJ_LAYER
	density = TRUE
	can_be_unanchored = FALSE
	///This variable is used to preserve real_wall if the false wall is deleted via being bolted down instead of actually destroyed.
	var/bolting_back_down = FALSE
	var/mineral = /obj/item/stack/sheet/iron
	var/mineral_amount = 2
	var/walltype = /turf/closed/wall
	var/girder_type = /obj/structure/girder/displaced
	var/opening = FALSE
	var/turf/real_wall

/obj/structure/falsewall/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)
	place_real_wall()
	desc = real_wall.desc
	name = real_wall.name
	max_integrity = real_wall.max_integrity
	icon = real_wall.icon
	icon_state = real_wall.icon_state
	base_icon_state = real_wall.base_icon_state
	smoothing_flags = real_wall.smoothing_flags
	smoothing_groups = real_wall.smoothing_groups.Copy()
	canSmoothWith = real_wall.canSmoothWith.Copy()
	resistance_flags = real_wall.resistance_flags

/obj/structure/falsewall/Destroy()
	if(!QDELETED(real_wall) && !bolting_back_down)
		real_wall.ScrapeAway()
		var/turf/underneath = get_turf(src)
		if(!isfloorturf(underneath)) //These can only be built on floors anyway, but the linter screams at me because space is left behind when they are forcibly deleted under some arcane conditions I can't replicate.
			underneath.PlaceOnTop(/turf/open/floor/plating)
	real_wall = null
	return ..()

/obj/structure/falsewall/ratvar_act()
	new /obj/structure/falsewall/brass(loc)
	qdel(src)

/obj/structure/falsewall/attack_hand(mob/user, list/modifiers)
	if(opening)
		return
	. = ..()
	if(.)
		return

	opening = TRUE
	update_icon()
	if(!density)
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = FALSE
			return
	else
		real_wall.ScrapeAway() //Remove the real wall when we start to open
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/falsewall, toggle_open)), 5)

/obj/structure/falsewall/proc/toggle_open()
	if(!QDELETED(src))
		set_density(!density)
		opening = FALSE
		update_icon()
		if(density)
			place_real_wall()

/obj/structure/falsewall/proc/place_real_wall()
	var/turf/our_turf = get_turf(src) //Get the turf the false wall is on and temporarily store it
	real_wall = our_turf.PlaceOnTop(walltype) //Place the real wall where the false wall is

/obj/structure/falsewall/update_icon()//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	if(opening)
		if(density)
			icon_state = "fwall_opening"
			smoothing_flags = NONE
			clear_smooth_overlays()
		else
			icon_state = "fwall_closing"
	else
		if(density)
			icon_state = initial(icon_state)
			smoothing_flags = SMOOTH_CORNERS
			icon_state = "[base_icon_state]-[smoothing_junction]"
			smoothing_flags = SMOOTH_BITMASK
			QUEUE_SMOOTH(src)
		else
			icon_state = "fwall_open"

/obj/structure/falsewall/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER)
		if(W.use_tool(src, user, 0, volume=50))
			dismantle(user, TRUE)
	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		W.play_tool_sound(src)
		dismantle(user, TRUE)
	else
		return ..()

/obj/structure/falsewall/wrench_act(mob/living/user, obj/item/tool)
	if(opening)
		to_chat(user, span_warning("You must wait until the door has stopped moving!"))
	else if(!density)
		to_chat(user, span_warning("You can't reach, close it first!"))
	else if(density)
		user.visible_message(span_notice("[user] tightens some bolts on the wall."), span_notice("You tighten the bolts on the wall."))
		bolting_back_down = TRUE
		qdel(src)
		return TRUE
	return ..()

/obj/structure/falsewall/proc/dismantle(mob/user, disassembled=TRUE, obj/item/tool = null)
	user.visible_message("[user] dismantles the false wall.", span_notice("You dismantle the false wall."))
	if(tool)
		tool.play_tool_sound(src, 100)
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
	deconstruct(disassembled)

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new girder_type(loc)
		if(mineral_amount)
			for(var/i in 1 to mineral_amount)
				new mineral(loc)
	qdel(src)

/obj/structure/falsewall/get_dumping_location()
	return null

/obj/structure/falsewall/examine_status(mob/user) //So you can't detect falsewalls by examine.
	to_chat(user, span_notice("The outer plating is <b>welded</b> firmly in place."))
	return null

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	smoothing_flags = SMOOTH_BITMASK
	walltype = /turf/closed/wall/r_wall
	mineral = /obj/item/stack/sheet/plasteel

/obj/structure/falsewall/reinforced/examine_status(mob/user)
	to_chat(user, span_notice("The outer <b>grille</b> is fully intact."))
	return null

/obj/structure/falsewall/reinforced/attackby(obj/item/tool, mob/user)
	..()
	if(tool.tool_behaviour == TOOL_WIRECUTTER)
		dismantle(user, TRUE, tool)

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	mineral = /obj/item/stack/sheet/mineral/uranium
	walltype = /turf/closed/wall/mineral/uranium

	COOLDOWN_DECLARE(radiate_cooldown)

/obj/structure/falsewall/uranium/attackby(obj/item/attacking_item, mob/user, params)
	radiate()
	return ..()

/obj/structure/falsewall/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	return ..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!COOLDOWN_FINISHED(src, radiate_cooldown))
		return

	COOLDOWN_START(src, radiate_cooldown, 1.5 SECONDS)
	radiation_pulse(
		src,
		max_range = 2,
		threshold = RAD_LIGHT_INSULATION,
		intensity = URANIUM_IRRADIATION_INTENSITY,
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)

	for(var/turf/closed/wall/mineral/uranium/uranium_wall in (RANGE_TURFS(1, src) - src))
		uranium_wall.radiate()
/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	mineral = /obj/item/stack/sheet/mineral/gold
	walltype = /turf/closed/wall/mineral/gold

/obj/structure/falsewall/silver
	mineral = /obj/item/stack/sheet/mineral/silver
	walltype = /turf/closed/wall/mineral/silver

/obj/structure/falsewall/copper
	mineral = /obj/item/stack/sheet/mineral/copper
	walltype = /turf/closed/wall/mineral/copper

/obj/structure/falsewall/diamond
	mineral = /obj/item/stack/sheet/mineral/diamond
	walltype = /turf/closed/wall/mineral/diamond

/obj/structure/falsewall/plasma
	mineral = /obj/item/stack/sheet/mineral/plasma
	walltype = /turf/closed/wall/mineral/plasma

/obj/structure/falsewall/plasma/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

/obj/structure/falsewall/plasma/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300)
		if(plasma_ignition(6, user))
			new /obj/structure/girder/displaced(loc)

	else
		return ..()

/obj/structure/falsewall/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/falsewall/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(plasma_ignition(6))
		new /obj/structure/girder/displaced(loc)

/obj/structure/falsewall/plasma/bullet_act(obj/projectile/Proj)
	if(!(Proj.nodamage) && Proj.damage_type == BURN)
		if(plasma_ignition(6, Proj?.firer))
			new /obj/structure/girder/displaced(loc)
	. = ..()

/obj/structure/falsewall/bananium
	mineral = /obj/item/stack/sheet/mineral/bananium
	walltype = /turf/closed/wall/mineral/bananium

/obj/structure/falsewall/sandstone
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/sandstone
	canSmoothWith = list() //Sandstone walls

/obj/structure/falsewall/wood
	mineral = /obj/item/stack/sheet/wood
	walltype = /turf/closed/wall/mineral/wood

/obj/structure/falsewall/bamboo
	mineral = /obj/item/stack/sheet/bamboo
	walltype = /turf/closed/wall/mineral/bamboo

/obj/structure/falsewall/iron
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	walltype = /turf/closed/wall/mineral/iron

/obj/structure/falsewall/abductor
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/closed/wall/mineral/abductor

/obj/structure/falsewall/titanium
	mineral = /obj/item/stack/sheet/mineral/titanium
	walltype = /turf/closed/wall/mineral/titanium

/obj/structure/falsewall/plastitanium
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	walltype = /turf/closed/wall/mineral/plastitanium

/obj/structure/falsewall/brass
	mineral_amount = 1
	girder_type = /obj/structure/girder/bronze
	walltype = /turf/closed/wall/clockwork
	mineral = /obj/item/stack/sheet/brass

/obj/structure/falsewall/brass/New(loc)
	..()
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/ratvar/wall/false(T)
	new /obj/effect/temp_visual/ratvar/beam/falsewall(T)
