/* Tables and Racks
 * Contains:
 *		Tables
 *		Glass Tables
 *		Plasmaglass Tables
 *		Wooden Tables
 *		Reinforced Tables
 *		Racks
 *		Rack Parts
 */

/*
 * Tables
 */

/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/tables/table.dmi'
	icon_state = "table-0"
	base_icon_state = "table"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_TABLES)
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE | LETPASSTHROW
	layer = TABLE_LAYER
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/glass_shard_type = /obj/item/shard
	var/buildstack = /obj/item/stack/sheet/iron
	var/busy = FALSE
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = 1
	var/last_bump = 0
	var/can_climb = TRUE
	custom_materials = list(/datum/material/iron = 2000)
	max_integrity = 100
	integrity_failure = 0.33

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/table)

/obj/structure/table/Initialize(mapload, _buildstack)
	. = ..()
	if(_buildstack)
		buildstack = _buildstack
	if(can_climb)
		AddElement(/datum/element/climbable)

/obj/structure/table/Bumped(mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))
	if(!HAS_TRAIT(H, TRAIT_ALWAYS_STUBS) && (H.shoes || feetCover || H.body_position == LYING_DOWN || HAS_TRAIT(H, TRAIT_PIERCEIMMUNE) || H.m_intent == MOVE_INTENT_WALK || H.bodyshape & BODYSHAPE_DIGITIGRADE))
		return
	if(HAS_TRAIT(H, TRAIT_ALWAYS_STUBS) || ((world.time >= last_bump + 100) && prob(5)))
		to_chat(H, span_warning("You stub your toe on the [name]!"))
		H.stub_toe(2)
	last_bump = world.time //do the cooldown here so walking into a table only checks toestubs once

/obj/structure/table/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)

/obj/structure/table/proc/deconstruction_hints(mob/user)
	return span_notice("The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.")

/obj/structure/table/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/table/narsie_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/wood(A)

/obj/structure/table/ratvar_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/brass(A)

/obj/structure/table/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/table/attack_hand(mob/living/user)
	if(Adjacent(user) && user.pulling)
		if(isliving(user.pulling))
			var/mob/living/pushed_mob = user.pulling
			if(pushed_mob.buckled)
				to_chat(user, span_warning("[pushed_mob] is buckled to [pushed_mob.buckled]!"))
				return
			if(user.combat_mode)
				switch(user.grab_state)
					if(GRAB_PASSIVE)
						to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
						return
					if(GRAB_AGGRESSIVE)
						tablepush(user, pushed_mob)
					if(GRAB_NECK to GRAB_KILL)
						tableheadsmash(user, pushed_mob)
			else
				pushed_mob.visible_message("<span class='notice'>[user] begins to place [pushed_mob] onto [src]...</span>", \
									"<span class='userdanger'>[user] begins to place [pushed_mob] onto [src]...</span>")
				if(do_after(user, 35, target = pushed_mob))
					tableplace(user, pushed_mob)
				else
					return
			user.stop_pulling()
		else if(user.pulling.pass_flags & PASSTABLE)
			user.Move_Pulled(src)
			if (user.pulling.loc == loc)
				user.visible_message(span_notice("[user] places [user.pulling] onto [src]."),
					span_notice("You place [user.pulling] onto [src]."))
				user.stop_pulling()
	return ..()

/obj/structure/table/attack_tk(mob/user)
	return

/obj/structure/table/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE


/obj/structure/table/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags & PASSTABLE)
		return TRUE
	return FALSE

/obj/structure/table/proc/tableplace(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(loc)
	if(!isanimal(pushed_mob) || iscat(pushed_mob))
		pushed_mob.set_resting(TRUE, TRUE)
	pushed_mob.visible_message(span_notice("[user] places [pushed_mob] onto [src]."), \
								span_notice("[user] places [pushed_mob] onto [src]."))
	log_combat(user, pushed_mob, "places", null, "onto [src]", important = FALSE)

/obj/structure/table/proc/tablepush(mob/living/user, mob/living/pushed_mob)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_danger("Throwing [pushed_mob] onto the table might hurt them!"))
		return
	var/added_passtable = FALSE
	if(!(pushed_mob.pass_flags & PASSTABLE))
		added_passtable = TRUE
		pushed_mob.pass_flags |= PASSTABLE
	pushed_mob.Move(src.loc)
	if(added_passtable)
		pushed_mob.pass_flags &= ~PASSTABLE
	if(pushed_mob.loc != loc) //Something prevented the tabling
		return
	pushed_mob.Knockdown(30)
	pushed_mob.apply_damage(40, STAMINA)
	if(user.mind?.martial_art?.smashes_tables)
		deconstruct(FALSE)
	if(pushed_mob.nutrition > NUTRITION_LEVEL_FAT) //lol
		deconstruct(FALSE)
		playsound(pushed_mob, "sound/effects/meteorimpact.ogg", 90, TRUE)
		pushed_mob.visible_message(span_dangerbold("[user] slams [pushed_mob] onto \the [src], breaking it!"), \
									span_dangerbold("[user] slams you onto \the [src]!"))
		log_combat(user, pushed_mob, "tabled", null, "onto [src]", important = FALSE)
		SEND_SIGNAL(pushed_mob, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table_fat) //it's soul
		return
	playsound(pushed_mob, "sound/effects/tableslam.ogg", 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] slams [pushed_mob] onto \the [src]!"), \
								span_userdanger("[user] slams you onto \the [src]!"))
	log_combat(user, pushed_mob, "tabled", null, "onto [src]", important = FALSE)
	SEND_SIGNAL(pushed_mob, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table)

/obj/structure/table/proc/tableheadsmash(mob/living/user, mob/living/pushed_mob)
	pushed_mob.Knockdown(30)
	pushed_mob?.apply_damage(40, BRUTE, BODY_ZONE_HEAD)
	pushed_mob.apply_damage(60, STAMINA)
	take_damage(50)
	if(user.mind?.martial_art?.smashes_tables)
		deconstruct(FALSE)
	playsound(pushed_mob, "sound/effects/tableheadsmash.ogg", 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] smashes [pushed_mob]'s head against \the [src]!"),
								span_userdanger("[user] smashes your head against \the [src]"))
	log_combat(user, pushed_mob, "head slammed", null, "against [src]")
	SEND_SIGNAL(pushed_mob, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table_headsmash)

/obj/structure/table/attackby(obj/item/I, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if(!(flags_1 & NODECONSTRUCT_1) && LAZYACCESS(modifiers, RIGHT_CLICK))
		if(I.tool_behaviour == TOOL_SCREWDRIVER && deconstruction_ready)
			to_chat(user, span_notice("You start disassembling [src]..."))
			if(I.use_tool(src, user, 2 SECONDS, volume=50))
				deconstruct(TRUE)
			return

		if(I.tool_behaviour == TOOL_WRENCH && deconstruction_ready)
			to_chat(user, span_notice("You start deconstructing [src]..."))
			if(I.use_tool(src, user, 4 SECONDS, volume=50))
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
				deconstruct(TRUE, 1)
			return

	if(istype(I, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			I.atom_storage.remove_all(drop_location())
			user.visible_message("[user] empties [I] on [src].")
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(istype(I, /obj/item/riding_offhand))
		var/obj/item/riding_offhand/riding_item = I
		var/mob/living/carried_mob = riding_item.rider
		if(carried_mob == user) //Piggyback user.
			return
		if(user.combat_mode)
			user.unbuckle_mob(carried_mob)
			tableheadsmash(user, carried_mob)
		else
			var/tableplace_delay = 3.5 SECONDS
			var/skills_space = ""
			if(HAS_TRAIT(user, TRAIT_QUICKER_CARRY))
				tableplace_delay = 2 SECONDS
				skills_space = " expertly"
			else if(HAS_TRAIT(user, TRAIT_QUICK_CARRY))
				tableplace_delay = 2.75 SECONDS
				skills_space = " quickly"
			carried_mob.visible_message("<span class='notice'>[user] begins to[skills_space] place [carried_mob] onto [src]...</span>",
				"<span class='userdanger'>[user] begins to[skills_space] place [carried_mob] onto [src]...</span>")
			if(do_after(user, tableplace_delay, target = carried_mob))
				user.unbuckle_mob(carried_mob)
				tableplace(user, carried_mob)
		return TRUE

	if(!user.combat_mode && !(I.item_flags & ABSTRACT))
		if(user.transferItemToLoc(I, drop_location(), silent = FALSE))
			//Center the icon where the user clicked.
			if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)
			return TRUE
	else
		return ..()


/obj/structure/table/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(buildstack)
			new buildstack(T, buildstackamount)
		else
			for(var/i in custom_materials)
				var/datum/material/M = i
				new M.sheet_type(T, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
		if(!wrench_disassembly)
			new frame(T)
		else
			new framestack(T, framestackamount)
	qdel(src)

/obj/structure/table/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 24, "cost" = 16)
	return FALSE
/obj/structure/table/greyscale
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	buildstack = null //No buildstack, so generate from mat datums

/obj/structure/table/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the table."))
			qdel(src)
			return TRUE
	return FALSE

/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "What did I say about leaning on the glass tables? Now you need surgery."
	icon = 'icons/obj/smooth_structures/tables/glass_table.dmi'
	icon_state = "glass_table-0"
	base_icon_state = "glass_table"
	smoothing_groups = list(SMOOTH_GROUP_GLASS_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_GLASS_TABLES)
	buildstack = /obj/item/stack/sheet/glass
	canSmoothWith = null
	max_integrity = 70
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/table_glass
	var/list/debris = list()


/datum/armor/table_glass
	fire = 80
	acid = 100

/obj/structure/table/glass/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/glass/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!isliving(AM))
		return
	// Don't break if they're just flying past
	if(AM.throwing)
		addtimer(CALLBACK(src, PROC_REF(throw_check), AM), 5)
	else
		check_break(AM)

/obj/structure/table/glass/proc/throw_check(mob/living/M)
	if(M.loc == get_turf(src))
		check_break(M)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(M.has_gravity() && M.mob_size > MOB_SIZE_SMALL && !(M.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		table_shatter(M)

/obj/structure/table/glass/proc/table_shatter(mob/living/victim)
	visible_message(span_warning("[src] breaks!"),
		span_danger("You hear breaking glass."))
	playsound(loc, "shatter", 50, 1)
	new frame(loc)
	var/obj/item/shard/shard = new glass_shard_type(loc)
	shard.throw_impact(victim)
	victim.Paralyze(100)
	qdel(src)

/obj/structure/table/glass/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			..()
			return
		else
			var/turf/T = get_turf(src)
			playsound(T, "shatter", 50, 1)
			new frame(loc)
			new glass_shard_type(loc)
	qdel(src)

/obj/structure/table/glass/narsie_act()
	color = NARSIE_WINDOW_COLOUR

/*
 * Plasmaglass tables
 */
/obj/structure/table/glass/plasma
	name = "plasmaglass table"
	desc = "A glass table, but it's pink and more sturdy. What will Nanotrasen design next with plasma?"
	icon = 'icons/obj/smooth_structures/tables/plasmaglass_table.dmi'
	icon_state = "plasmaglass_table-0"
	base_icon_state = "plasmaglass_table"
	buildstack = /obj/item/stack/sheet/plasmaglass
	glass_shard_type = /obj/item/shard/plasma
	max_integrity = 270
	armor_type = /datum/armor/glass_plasma


/datum/armor/glass_plasma
	melee = 10
	bullet = 5
	bomb = 10
	fire = 80
	acid = 100

/obj/structure/table/glass/plasma/Initialize(mapload)
	. = ..()
	debris += new /obj/item/shard/plasma

/obj/structure/table/glass/plasma/check_break(mob/living/M)
	return

/*
 * Wooden tables
 */

/obj/structure/table/wood
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/tables/wood_table.dmi'
	icon_state = "wood_table-0"
	base_icon_state = "wood_table"
	smoothing_groups = list(SMOOTH_GROUP_WOOD_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_WOOD_TABLES)
	frame = /obj/structure/table_frame/wood
	framestack = /obj/item/stack/sheet/wood
	buildstack = /obj/item/stack/sheet/wood
	resistance_flags = FLAMMABLE
	max_integrity = 70

/obj/structure/table/wood/narsie_act(total_override = TRUE)
	if(!total_override)
		..()

/obj/structure/table/wood/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/tables/poker_table.dmi'
	icon_state = "poker_table-0"
	base_icon_state = "poker_table"
	buildstack = /obj/item/stack/tile/carpet

/obj/structure/table/wood/poker/narsie_act()
	..(FALSE)

/obj/structure/table/wood/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table.dmi'
	icon_state = "fancy_table-0"
	base_icon_state = "fancy_table"
	smoothing_groups = list(SMOOTH_GROUP_FANCY_WOOD_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES or SMOOTH_GROUP_WOOD_TABLES
	canSmoothWith = list(SMOOTH_GROUP_FANCY_WOOD_TABLES)
	frame = /obj/structure/table_frame
	framestack = /obj/item/stack/rods
	buildstack = /obj/item/stack/tile/carpet

/obj/structure/table/wood/fancy/black
	icon_state = "fancy_table_black-0"
	base_icon_state = "fancy_table_black"
	buildstack = /obj/item/stack/tile/carpet/black
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_black.dmi'

/obj/structure/table/wood/fancy/blue
	icon_state = "fancy_table_blue-0"
	base_icon_state = "fancy_table_blue"
	buildstack = /obj/item/stack/tile/carpet/blue
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_blue.dmi'

/obj/structure/table/wood/fancy/cyan
	icon_state = "fancy_table_cyan-0"
	base_icon_state = "fancy_table_cyan"
	buildstack = /obj/item/stack/tile/carpet/cyan
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_cyan.dmi'

/obj/structure/table/wood/fancy/green
	icon_state = "fancy_table_green-0"
	base_icon_state = "fancy_table_green"
	buildstack = /obj/item/stack/tile/carpet/green
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_green.dmi'

/obj/structure/table/wood/fancy/orange
	icon_state = "fancy_table_orange-0"
	base_icon_state = "fancy_table_orange"
	buildstack = /obj/item/stack/tile/carpet/orange
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_orange.dmi'

/obj/structure/table/wood/fancy/purple
	icon_state = "fancy_table_purple-0"
	base_icon_state = "fancy_table_purple"
	buildstack = /obj/item/stack/tile/carpet/purple
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_purple.dmi'

/obj/structure/table/wood/fancy/red
	icon_state = "fancy_table_red-0"
	base_icon_state = "fancy_table_red"
	buildstack = /obj/item/stack/tile/carpet/red
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_red.dmi'

/obj/structure/table/wood/fancy/royalblack
	icon_state = "fancy_table_royalblack-0"
	base_icon_state = "fancy_table_royalblack"
	buildstack = /obj/item/stack/tile/carpet/royalblack
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_royalblack.dmi'

/obj/structure/table/wood/fancy/royalblue
	icon_state = "fancy_table_royalblue-0"
	base_icon_state = "fancy_table_royalblue"
	buildstack = /obj/item/stack/tile/carpet/royalblue
	icon = 'icons/obj/smooth_structures/tables/fancy_tables/fancy_table_royalblue.dmi'

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table."
	icon = 'icons/obj/smooth_structures/tables/reinforced_table.dmi'
	icon_state = "reinforced_table-0"
	base_icon_state = "reinforced_table"
	deconstruction_ready = 0
	buildstack = /obj/item/stack/sheet/plasteel
	max_integrity = 200
	integrity_failure = 0.25
	armor_type = /datum/armor/table_reinforced


/datum/armor/table_reinforced
	melee = 10
	bullet = 30
	laser = 30
	energy = 100
	bomb = 20
	fire = 80
	acid = 70

/obj/structure/table/reinforced/deconstruction_hints(mob/user)
	if(deconstruction_ready)
		return span_notice("The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.")
	else
		return span_notice("The top cover is firmly <b>welded</b> on.")

/obj/structure/table/reinforced/attackby_secondary(obj/item/weapon, mob/user, params)
	if(weapon.tool_behaviour == TOOL_WELDER)
		if(weapon.tool_start_check(user, amount = 0))
			if(deconstruction_ready)
				to_chat(user, "<span class='notice'>You start strengthening the reinforced table...</span>")
				if (weapon.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>You strengthen the table.</span>")
					deconstruction_ready = FALSE
			else
				to_chat(user, "<span class='notice'>You start weakening the reinforced table...</span>")
				if (weapon.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>You weaken the table.</span>")
					deconstruction_ready = TRUE
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		. = ..()

/obj/structure/table/brass
	name = "brass table"
	desc = "A solid, slightly beveled brass table."
	icon = 'icons/obj/smooth_structures/tables/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	smoothing_groups = list(SMOOTH_GROUP_BRONZE_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_BRONZE_TABLES)
	frame = /obj/structure/table_frame/brass
	framestack = /obj/item/stack/sheet/brass
	buildstack = /obj/item/stack/sheet/brass
	framestackamount = 1
	buildstackamount = 1

/obj/structure/table/brass/ratvar_act()
	return

/obj/structure/table/brass/tablepush(mob/living/user, mob/living/pushed_mob)
	. = ..()
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/obj/structure/table/brass/narsie_act()
	take_damage(rand(15, 45), BRUTE)
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/table/bronze
	name = "bronze table"
	desc = "A solid table made out of bronze."
	icon = 'icons/obj/smooth_structures/tables/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	buildstack = /obj/item/stack/sheet/bronze
	smoothing_groups = list(SMOOTH_GROUP_BRONZE_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_BRONZE_TABLES)

/obj/structure/table/bronze/tablepush(mob/living/user, mob/living/pushed_mob)
	..()
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/*
 * Surgery Tables
 */

/obj/structure/table/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "optable"
	buildstack = /obj/item/stack/sheet/mineral/silver
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_buckle = TRUE
	buckle_lying = 90
	can_climb = FALSE
	var/mob/living/carbon/human/patient = null
	var/obj/machinery/computer/operating/computer = null

/obj/structure/table/optable/Initialize(mapload)
	. = ..()
	initial_link()

/obj/structure/table/optable/Destroy()
	. = ..()
	if(computer?.table == src)
		computer.table = null

/obj/structure/table/optable/examine(mob/user)
	. = ..()
	if(computer)
		. += span_notice("[src] is <b>linked</b> to an operating computer to the [dir2text(get_dir(src, computer))].")
	else
		. += span_notice("[src] is <b>NOT linked</b> to an operating computer.")

/obj/structure/table/optable/proc/initial_link()
	if(!QDELETED(computer))
		computer.table = src
		return
	for(var/direction in GLOB.alldirs)
		var/obj/machinery/computer/operating/found_computer = locate(/obj/machinery/computer/operating) in get_step(src, direction)
		if(found_computer)
			if(!found_computer.table)
				found_computer.link_with_table(new_table = src)
				break
			else if(found_computer.table == src)
				computer = found_computer
				break

/obj/structure/table/optable/post_buckle_mob(mob/living/M)
	get_patient()

/obj/structure/table/optable/post_unbuckle_mob(mob/living/M)
	get_patient()

/obj/structure/table/optable/proc/get_patient()
	if (!has_buckled_mobs())
		set_patient(null)
		return FALSE
	var/mob/living/carbon/M = buckled_mobs[1]
	set_patient(M)

/obj/structure/table/optable/proc/set_patient(new_patient)
	if(patient)
		UnregisterSignal(patient, COMSIG_QDELETING)
		UnregisterSignal(patient, COMSIG_LIVING_RESTING_UPDATED)
		REMOVE_TRAIT(patient, TRAIT_NO_BLEEDING, TABLE_TRAIT)
	patient = new_patient
	if(patient)
		RegisterSignal(patient, COMSIG_QDELETING, PROC_REF(patient_deleted))
		RegisterSignal(patient, COMSIG_LIVING_RESTING_UPDATED, PROC_REF(check_bleed_trait))
		check_bleed_trait()

/obj/structure/table/optable/proc/check_bleed_trait()
	SIGNAL_HANDLER
	if (!patient)
		return
	if (patient.buckled)
		ADD_TRAIT(patient, TRAIT_NO_BLEEDING, TABLE_TRAIT)
	else
		REMOVE_TRAIT(patient, TRAIT_NO_BLEEDING, TABLE_TRAIT)

/obj/structure/table/optable/proc/patient_deleted(datum/source)
	SIGNAL_HANDLER
	set_patient(null)

/obj/structure/table/optable/proc/check_eligible_patient()
	get_patient()
	if(!patient)
		return FALSE
	if (!patient.buckled)
		return FALSE
	if(ishuman(patient) || ismonkey(patient))
		return TRUE
	return FALSE

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW //You can throw objects over this, despite it's density.
	max_integrity = 20

/obj/structure/rack/examine(mob/user)
	. = ..()
	. += span_notice("It's held together by a couple of <b>bolts</b>.")

/obj/structure/rack/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return TRUE
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE
	return FALSE

/obj/structure/rack/MouseDrop_T(obj/O, mob/user)
	. = ..()
	if ((!( istype(O, /obj/item) ) || user.get_active_held_item() != O))
		return
	if(!user.dropItemToGround(O))
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/structure/rack/attackby(obj/item/W, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if (W.tool_behaviour == TOOL_WRENCH && !(flags_1 & NODECONSTRUCT_1) && LAZYACCESS(modifiers, RIGHT_CLICK))
		W.play_tool_sound(src)
		deconstruct(TRUE)
		return
	if(user.combat_mode)
		return ..()
	if(user.transferItemToLoc(W, drop_location()))
		return 1

/obj/structure/rack/attack_paw(mob/living/user)
	attack_hand(user)

/obj/structure/rack/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.body_position == LYING_DOWN || user.usable_legs < 2)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(span_danger("[user] kicks [src]."), null, null, COMBAT_MESSAGE_RANGE)
	take_damage(rand(4,8), BRUTE, MELEE, 1)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/dodgeball.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 40, 1)

/*
 * Rack destruction
 */

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(!(flags_1&NODECONSTRUCT_1))
		set_density(FALSE)
		var/obj/item/rack_parts/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	qdel(src)


/*
 * Rack Parts
 */

/obj/item/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "rack_parts"
	flags_1 = CONDUCT_1
	custom_materials = list(/datum/material/iron=2000)
	var/building = FALSE
	var/obj/construction_type = /obj/structure/rack

/obj/item/rack_parts/attackby(obj/item/W, mob/user, params)
	if (W.tool_behaviour == TOOL_WRENCH)
		new /obj/item/stack/sheet/iron(user.loc)
		qdel(src)
	else
		. = ..()

/obj/item/rack_parts/attack_self(mob/user)
	if(locate(construction_type) in get_turf(user))
		balloon_alert(user, "no room!")
		return
	if(building)
		return
	building = TRUE
	to_chat(user, span_notice("You start assembling [src]..."))
	if(do_after(user, 50, target = user))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		var/obj/structure/R = new construction_type(user.loc)
		user.visible_message(span_notice("[user] assembles \a [R]."), span_notice("You assemble \a [R]."))
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE
