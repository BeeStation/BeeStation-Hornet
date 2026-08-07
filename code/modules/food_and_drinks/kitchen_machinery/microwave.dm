// Microwaving doesn't use recipes, instead it calls the microwave_act of the objects.
// For food, this creates something based on the food's cooked_type

/// Values based on microwave success
#define MICROWAVE_NORMAL 0
#define MICROWAVE_MUCK 1
#define MICROWAVE_PRE 2

/// Values for how broken the microwave is
#define NOT_BROKEN 0
#define KINDA_BROKEN 1
#define REALLY_BROKEN 2

/// The max amount of dirtiness a microwave can be
#define MAX_MICROWAVE_DIRTINESS 100

/obj/machinery/microwave
	name = "microwave oven"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/machines/microwave.dmi'
	icon_state = "map_icon"
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/microwave
	pass_flags = PASSTABLE
	light_color = LIGHT_COLOR_DIM_YELLOW
	light_power = 3
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	var/wire_disabled = FALSE // is its internal wire cut?
	var/operating = FALSE
	/// How dirty is it?
	var/dirty = 0
	var/dirty_anim_playing = FALSE
	/// How broken is it? NOT_BROKEN, KINDA_BROKEN, REALLY_BROKEN
	var/broken = NOT_BROKEN
	var/open = FALSE
	var/max_n_of_items = 10
	var/efficiency = 0
	var/datum/looping_sound/microwave/soundloop
	var/list/ingredients = list() // may only contain /atom/movables
	/// When this is the nth ingredient, whats its pixel_x?
	var/list/ingredient_shifts_x = list(
		-2,
		1,
		-5,
		2,
		-6,
		0,
		-4,
	)
	/// When this is the nth ingredient, whats its pixel_y?
	var/list/ingredient_shifts_y = list(
		-4,
		-2,
		-3,
	)
	var/static/radial_examine = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_eject")
	var/static/radial_use = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_use")

	// we show the button even if the proc will not work
	var/static/list/radial_options = list("eject" = radial_eject, "use" = radial_use)
	var/static/list/ai_radial_options = list("eject" = radial_eject, "use" = radial_use, "examine" = radial_examine)

/obj/machinery/microwave/Initialize(mapload)
	. = ..()

	wires = new /datum/wires/microwave(src)
	create_reagents(100)
	soundloop = new(src, FALSE)
	update_appearance(UPDATE_ICON)

/obj/machinery/microwave/Exited(atom/movable/gone, direction)
	if(gone in ingredients)
		ingredients -= gone
		if(!QDELING(gone) && ingredients.len && isitem(gone))
			var/obj/item/itemized_ingredient = gone
			if(!(itemized_ingredient.item_flags & NO_PIXEL_RANDOM_DROP))
				itemized_ingredient.pixel_x = itemized_ingredient.base_pixel_x + rand(-6, 6)
				itemized_ingredient.pixel_y = itemized_ingredient.base_pixel_y + rand(-5, 6)
	return ..()

/obj/machinery/microwave/on_deconstruction()
	eject()
	return ..()

/obj/machinery/microwave/Destroy()
	// Emptied first because qdelling an ingredient hits Exited(), which edits the list as we go
	var/list/lost_ingredients = ingredients.Copy()
	ingredients.Cut()
	QDEL_LIST(lost_ingredients)
	QDEL_NULL(wires)
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/microwave/RefreshParts()
	efficiency = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		efficiency += M.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		max_n_of_items = 10 * M.rating
		break

/obj/machinery/microwave/examine(mob/user)
	. = ..()
	if(!operating)
		. += span_notice("Right-click [src] to start cooking cycle.")

	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return
	if(operating)
		. += span_notice("\The [src] is operating.")
		return

	if(length(ingredients))
		if(issilicon(user))
			. += span_notice("\The [src] camera shows:")
		else
			. += span_notice("\The [src] contains:")
		var/list/items_counts = new
		for(var/i in ingredients)
			if(isstack(i))
				var/obj/item/stack/S = i
				items_counts[S.name] += S.amount
			else
				var/atom/movable/AM = i
				items_counts[AM.name]++
		for(var/O in items_counts)
			. += span_notice("- [items_counts[O]]x [O].")
	else
		. += span_notice("\The [src] is empty.")

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "[span_notice("The status display reads:")]\n"+\
		"[span_notice("- Capacity: <b>[max_n_of_items]</b> items.")]\n"+\
		span_notice("- Cook time reduced by <b>[(efficiency - 1) * 25]%</b>.")

#define MICROWAVE_INGREDIENT_OVERLAY_SIZE 24

/obj/machinery/microwave/update_overlays()
	. = ..()

	// All of these will use a full icon state instead
	if(panel_open || dirty >= MAX_MICROWAVE_DIRTINESS || broken || dirty_anim_playing)
		return .

	var/ingredient_count = 0

	for (var/atom/movable/ingredient as anything in ingredients)
		var/image/ingredient_overlay = image(ingredient, src)

		ingredient_overlay.transform = ingredient_overlay.transform.Scale(
			MICROWAVE_INGREDIENT_OVERLAY_SIZE / ingredient.get_cached_width(),
			MICROWAVE_INGREDIENT_OVERLAY_SIZE / ingredient.get_cached_height(),
		)

		ingredient_overlay.pixel_w = ingredient_shifts_x[(ingredient_count % ingredient_shifts_x.len) + 1]
		ingredient_overlay.pixel_z = ingredient_shifts_y[(ingredient_count % ingredient_shifts_y.len) + 1]
		ingredient_overlay.layer = FLOAT_LAYER
		ingredient_overlay.plane = FLOAT_PLANE
		ingredient_overlay.blend_mode = BLEND_INSET_OVERLAY

		ingredient_count += 1

		. += ingredient_overlay

	var/border_icon_state
	var/door_icon_state

	if(open)
		door_icon_state = "door_open"
		border_icon_state = "mwo"
	else if(operating)
		door_icon_state = "door_on"
		border_icon_state = "mw"
	else
		door_icon_state = "door_off"
		border_icon_state = "mw"

	. += mutable_appearance(
		icon,
		door_icon_state,
		alpha = ingredients.len > 0 ? 128 : 255,
	)

	. += border_icon_state

	if (!open)
		. += "door_handle"

	return .

#undef MICROWAVE_INGREDIENT_OVERLAY_SIZE

/obj/machinery/microwave/update_icon_state()
	if(broken)
		icon_state = "mwb"
	else if(dirty_anim_playing)
		icon_state = "mwbloody1"
	else if(dirty >= MAX_MICROWAVE_DIRTINESS)
		icon_state = open ? "mwbloodyo" : "mwbloody"
	else if(operating)
		icon_state = "back_on"
	else if(open)
		icon_state = "back_open"
	else if(panel_open)
		icon_state = "mw-o"
	else
		icon_state = "back_off"

	return ..()

/obj/machinery/microwave/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/wirecutter_act(mob/living/user, obj/item/tool)
	if(broken != REALLY_BROKEN)
		return

	user.visible_message(
		span_notice("[user] starts to fix part of [src]."),
		span_notice("You start to fix part of [src]..."),
	)

	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return TOOL_ACT_SIGNAL_BLOCKING

	user.visible_message(
		span_notice("[user] fixes part of [src]."),
		span_notice("You fix part of [src]."),
	)
	broken = KINDA_BROKEN // Fix it a bit
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/welder_act(mob/living/user, obj/item/tool)
	if(broken != KINDA_BROKEN)
		return

	user.visible_message(
		span_notice("[user] starts to fix part of [src]."),
		span_notice("You start to fix part of [src]..."),
	)

	if(!tool.use_tool(src, user, 2 SECONDS, amount = 1, volume = 50))
		return TOOL_ACT_SIGNAL_BLOCKING

	user.visible_message(
		span_notice("[user] fixes [src]."),
		span_notice("You fix [src]."),
	)
	broken = NOT_BROKEN
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/tool_act(mob/living/user, obj/item/tool, tool_type, is_right_clicking)
	if(operating)
		return
	if(dirty >= MAX_MICROWAVE_DIRTINESS)
		return

	. = ..()
	if(. & TOOL_ACT_MELEE_CHAIN_BLOCKING)
		return

	if(panel_open && is_wire_tool(tool))
		wires.interact(user)
		return TOOL_ACT_SIGNAL_BLOCKING

/obj/machinery/microwave/attackby(obj/item/item, mob/living/user, params)
	if(operating)
		return

	if(broken > NOT_BROKEN)
		if(IS_EDIBLE(item))
			balloon_alert(user, "it's broken!")
			return TRUE
		return ..()

	if(!anchored)
		if(IS_EDIBLE(item))
			balloon_alert(user, "not secured!")
			return TRUE
		return ..()

	if(dirty >= MAX_MICROWAVE_DIRTINESS) // The microwave is all dirty so can't be used!
		if(IS_EDIBLE(item))
			balloon_alert(user, "it's too dirty!")
			return TRUE
		return ..()

	if(istype(item, /obj/item/storage))
		var/obj/item/storage/tray = item
		var/loaded = 0

		if(!istype(item, /obj/item/storage/bag/tray))
			// Non-tray dumping requires a do_after
			to_chat(user, span_notice("You start dumping out the contents of [item] into [src]..."))
			if(!do_after(user, 2 SECONDS, target = tray))
				return

		for(var/obj/tray_item in tray.contents)
			if(!IS_EDIBLE(tray_item))
				continue
			if(ingredients.len >= max_n_of_items)
				balloon_alert(user, "it's full!")
				return TRUE
			if(tray.atom_storage.attempt_remove(tray_item, src))
				loaded++
				ingredients += tray_item
		if(loaded)
			open(autoclose = 0.6 SECONDS)
			to_chat(user, span_notice("You insert [loaded] items into \the [src]."))
			update_appearance()
		return

	if(item.w_class <= WEIGHT_CLASS_NORMAL && !istype(item, /obj/item/storage) && !user.combat_mode)
		if(ingredients.len >= max_n_of_items)
			balloon_alert(user, "it's full!")
			return TRUE
		if(!user.transferItemToLoc(item, src))
			balloon_alert(user, "it's stuck to your hand!")
			return FALSE

		ingredients += item
		open(autoclose = 0.6 SECONDS)
		user.visible_message(span_notice("[user] adds \a [item] to \the [src]."), span_notice("You add [item] to \the [src]."))
		update_appearance()
		return

	return ..()

/obj/machinery/microwave/attack_hand_secondary(mob/user, list/modifiers)
	if(user.canUseTopic(src, !issilicon(usr)))
		if(!length(ingredients))
			balloon_alert(user, "it's empty!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		start_cycle(user)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/microwave/ui_interact(mob/user)
	. = ..()

	if(!anchored)
		balloon_alert(user, "not secured!")
		return
	if(operating || panel_open || !user.canUseTopic(src, !issilicon(user)))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	if(!length(ingredients))
		if(isAI(user))
			examine(user)
		else
			balloon_alert(user, "it's empty!")
		return

	var/choice = show_radial_menu(user, src, isAI(user) ? ai_radial_options : radial_options, require_near = !issilicon(user))

	// post choice verification
	if(operating || panel_open || !anchored || !user.canUseTopic(src, !issilicon(user)))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	switch(choice)
		if("eject")
			eject()
		if("use")
			start_cycle(user)
		if("examine")
			examine(user)

/obj/machinery/microwave/wash(clean_types)
	. = ..()
	if(operating || !(clean_types & CLEAN_SCRUB))
		return .

	dirty = 0
	update_appearance()
	return . || TRUE

/obj/machinery/microwave/proc/eject()
	var/atom/drop_loc = drop_location()
	// Copied because forceMove hits Exited(), which pulls the ingredient out of the list as we go
	for(var/atom/movable/movable_ingredient as anything in ingredients.Copy())
		movable_ingredient.forceMove(drop_loc)
	open(autoclose = 1.4 SECONDS)

/obj/machinery/microwave/proc/start_cycle(mob/user)
	cook(user)

/**
 * Begins the process of cooking the included ingredients.
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/cook(mob/cooker)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(operating || broken > 0 || panel_open || !anchored || dirty >= MAX_MICROWAVE_DIRTINESS)
		return

	if(wire_disabled)
		audible_message("[src] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	if(prob(max((5 / efficiency) - 5, dirty * 5))) //a clean unupgraded microwave has no risk of failure
		muck()
		return

	// How many items are we cooking that aren't already food items
	var/non_food_ingedients = length(ingredients)
	for(var/atom/movable/potential_fooditem as anything in ingredients)
		if(IS_EDIBLE(potential_fooditem))
			non_food_ingedients--

	// If we're cooking non-food items we can fail randomly
	if(non_food_ingedients && prob(min(dirty * 5, 100)))
		start_can_fail(cooker)
		return

	start(cooker)

/obj/machinery/microwave/proc/wzhzhzh()
	visible_message(span_notice("\The [src] turns on."), null, span_hear("You hear a microwave humming."))
	operating = TRUE
	set_light(l_range = 1.5, l_power = 1.2, l_on = TRUE)
	soundloop.start()
	update_appearance()

/obj/machinery/microwave/proc/spark()
	visible_message(span_warning("Sparks fly around [src]!"))
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 1, src)
	sparks.start()

/**
 * The start of the cook loop
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start(mob/cooker)
	wzhzhzh()
	cook_loop(type = MICROWAVE_NORMAL, cycles = 10, cooker = cooker)

/**
 * The start of the cook loop, but can fail (result in a splat / dirty microwave)
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start_can_fail(mob/cooker)
	wzhzhzh()
	cook_loop(type = MICROWAVE_PRE, cycles = 4, cooker = cooker)

/obj/machinery/microwave/proc/muck()
	wzhzhzh()
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
	dirty_anim_playing = TRUE
	update_appearance()
	cook_loop(type = MICROWAVE_MUCK, cycles = 4)

/**
 * The actual cook loop started via [proc/start] or [proc/start_can_fail]
 *
 * * type - the type of cooking, determined via how this iteration of cook_loop is called, and determines the result
 * * time - how many loops are left, base case for recursion
 * * wait - deciseconds between loops
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/cook_loop(type, cycles, wait = max(12 - 2 * efficiency, 2), mob/cooker) // standard wait is 10
	if((machine_stat & BROKEN) && type == MICROWAVE_PRE)
		pre_fail()
		return

	if(cycles <= 0 || !length(ingredients))
		switch(type)
			if(MICROWAVE_NORMAL)
				loop_finish(cooker)
			if(MICROWAVE_MUCK)
				muck_finish()
			if(MICROWAVE_PRE)
				pre_success(cooker)
		return
	cycles--
	use_power(500)
	addtimer(CALLBACK(src, PROC_REF(cook_loop), type, cycles, wait, cooker), wait)

/obj/machinery/microwave/power_change()
	. = ..()
	if((machine_stat & NOPOWER) && operating)
		pre_fail()
		eject()

/**
 * Called when the cook_loop is done successfully, no dirty mess or whatever
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/loop_finish(mob/cooker)
	operating = FALSE

	var/iron_amount = 0
	// Copied because microwave_act() qdels the ingredient, which pulls it out of the list as we go
	for(var/obj/item/cooked_item in ingredients.Copy())
		var/sigreturn = cooked_item.microwave_act(src, cooker, randomize_pixel_offset = ingredients.len)
		if(sigreturn & COMPONENT_MICROWAVE_SUCCESS)
			if(isstack(cooked_item))
				var/obj/item/stack/cooked_stack = cooked_item
				dirty += cooked_stack.amount
			else
				dirty++

		iron_amount += (cooked_item.custom_materials?[SSmaterials.GetMaterialRef(/datum/material/iron)] || 0)

	if(iron_amount)
		spark()
		broken = REALLY_BROKEN
		if(prob(max(iron_amount / 2, 33)))
			explosion(src, heavy_impact_range = 1, light_impact_range = 2)

	after_finish_loop()

/obj/machinery/microwave/proc/pre_fail()
	broken = REALLY_BROKEN
	operating = FALSE
	spark()
	after_finish_loop()

/obj/machinery/microwave/proc/pre_success(mob/cooker)
	cook_loop(type = MICROWAVE_NORMAL, cycles = 10, cooker = cooker)

/obj/machinery/microwave/proc/muck_finish()
	visible_message(span_warning("\The [src] gets covered in muck!"))

	dirty = MAX_MICROWAVE_DIRTINESS
	dirty_anim_playing = FALSE
	operating = FALSE

	after_finish_loop()

/obj/machinery/microwave/proc/after_finish_loop()
	set_light(l_on = FALSE)
	soundloop.stop()
	eject()
	open(autoclose = 2 SECONDS)

/obj/machinery/microwave/proc/open(autoclose = 2 SECONDS)
	open = TRUE
	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(close)), autoclose)

/obj/machinery/microwave/proc/close()
	open = FALSE
	update_appearance()

#undef MICROWAVE_NORMAL
#undef MICROWAVE_MUCK
#undef MICROWAVE_PRE

#undef NOT_BROKEN
#undef KINDA_BROKEN
#undef REALLY_BROKEN

#undef MAX_MICROWAVE_DIRTINESS
