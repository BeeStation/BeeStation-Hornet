/* Stack type objects!
 * Contains:
 * Stacks
 * Recipe datum
 * Recipe list datum
 */

/*
 * Stacks
 */

/obj/item/stack
	icon = 'icons/obj/stacks/minerals.dmi'
	gender = PLURAL
	material_modifier = 0.05 //5%, so that a 50 sheet stack has the effect of 5k materials instead of 100k.
	max_demand = 500
	/// What's the name of just 1 of this stack. You have a stack of leather, but one piece of leather
	var/singular_name
	/// How much is in this stack?
	var/amount = 1
	/// How much is allowed in this stack?
	// Also see stack recipes initialisation. "max_res_amount" must be equal to this max_amount
	var/max_amount = 50
	/// If TRUE, this stack is a module used by a cyborg (doesn't run out like normal / etc)
	var/is_cyborg = FALSE
	/// Related to above. If present, the energy we draw from when using stack items, for cyborgs
	var/datum/robot_energy_storage/source
	/// Related to above. How much energy it costs from storage to use stack items
	var/cost = 1
	/// This path and its children should merge with this stack, defaults to src.type
	var/merge_type = null
	/// The weight class the stack has at amount > 2/3rds max_amount
	var/full_w_class = WEIGHT_CLASS_NORMAL
	/// Determines whether the item should update it's sprites based on amount.
	var/novariants = TRUE
	/// List that tells you how much is in a single unit.
	var/list/mats_per_unit
	/// Datum material type that this stack is made of
	var/material_type
	/// Does this stack require a unique girder in order to make a wall?
	var/has_unique_girder = FALSE
	/// Amount of matter for RCD
	var/matter_amount = 0
	/// Does this stack require a unique girder in order to make a wall?
	//var/has_unique_girder = FALSE
	/// What typepath table we create from this stack
	var/obj/structure/table/tableVariant
	/// If TRUE, we'll use a radial instead when displaying recipes
	var/use_radial = FALSE
	/// If use_radial is TRUE, this is the radius of the radial
	var/radial_radius = 52
	/// Base price of the item PER AMOUNT. 1 amount will be 1 custom_price
	var/base_price = 1

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack)

/obj/item/stack/Initialize(mapload, new_amount = amount, merge = TRUE, mob/user = null)
	amount = new_amount
	if(amount <= 0)
		stack_trace("invalid amount [amount]!")
		return INITIALIZE_HINT_QDEL
	if(user)
		add_fingerprint(user)
	check_max_amount()
	if(!merge_type)
		merge_type = type

	if(LAZYLEN(mats_per_unit))
		set_mats_per_unit(mats_per_unit, 1)
	else if(LAZYLEN(custom_materials))
		set_mats_per_unit(custom_materials, amount ? 1/amount : 1)

	. = ..()

	if(merge)
		. = INITIALIZE_HINT_LATELOAD

	update_weight()
	update_appearance()

/obj/item/stack/LateInitialize()
	merge_with_loc()

/obj/item/stack/Destroy()
	mats_per_unit = null
	return ..()

/obj/item/stack/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_left_click_action("Open stack crafting")
	context.add_right_click_action("Split Stack")

/obj/item/stack/Moved(atom/old_loc, dir)
	. = ..()
	if((!throwing || throwing.target_turf == loc) && old_loc != loc && (flags_1 & INITIALIZED_1))
		merge_with_loc(merge_into_ourselves = !isnull(pulledby))
	if(ismob(loc) || ismob(old_loc) || loc?.atom_storage || old_loc?.atom_storage)
		update_appearance(UPDATE_NAME)

/** Sets the amount of materials per unit for this stack.
  *
  * Arguments:
  * - [mats][/list]: The value to set the mats per unit to.
  * - multiplier: The amount to multiply the mats per unit by. Defaults to 1.
  */
/obj/item/stack/proc/set_mats_per_unit(list/mats, multiplier=1)
	mats_per_unit = SSmaterials.FindOrCreateMaterialCombo(mats, multiplier)
	update_custom_materials()

/** Updates the custom materials list of this stack.
  */
/obj/item/stack/proc/update_custom_materials()
	set_custom_materials(mats_per_unit, amount, is_update=TRUE)

/obj/item/stack/proc/find_other_stack(list/already_found, merge_into_ourselves = FALSE)
	if(QDELETED(src) || isnull(loc))
		return
	for(var/obj/item/stack/item_stack in loc)
		if(item_stack == src || QDELING(item_stack) || (item_stack.amount >= item_stack.max_amount))
			continue
		if(!(item_stack.flags_1 & INITIALIZED_1))
			continue
		var/stack_ref = REF(item_stack)
		if(already_found[stack_ref])
			continue
		if(merge_into_ourselves ? item_stack.can_merge(src) : can_merge(item_stack))
			already_found[stack_ref] = TRUE
			return item_stack

/// Tries to merge the stack with everything on the same tile.
/obj/item/stack/proc/merge_with_loc(merge_into_ourselves = FALSE)
	var/list/already_found = list() // change to alist whenever dreamchecker and such finally supports that
	var/obj/item/stack/other_stack = find_other_stack(already_found, merge_into_ourselves)
	var/sanity = max_amount // just in case
	while(other_stack && sanity > 0)
		sanity--
		if(!merge_into_ourselves)
			if(merge(other_stack))
				return FALSE
		else if (other_stack.merge(src) && !QDELETED(other_stack))
			return FALSE
		other_stack = find_other_stack(already_found, TRUE)
	return TRUE

/**
 * Override to make things like metalgen accurately set custom materials
 */
/obj/item/stack/set_custom_materials(list/materials, multiplier=1, is_update=FALSE)
	return is_update ? ..() : set_mats_per_unit(materials, multiplier/(amount || 1))

/obj/item/stack/grind_requirements()
	if(is_cyborg)
		to_chat(usr, span_warning("[src] is electronically synthesized in your chassis and can't be ground up!"))
		return
	return TRUE

/obj/item/stack/grind(datum/reagents/target_holder, mob/user)
	var/current_amount = get_amount()
	if(current_amount <= 0 || QDELETED(src)) //just to get rid of this 0 amount/deleted stack we return success
		return TRUE
	if(on_grind() == -1)
		return FALSE
	if(isnull(target_holder))
		return TRUE

	if(reagents)
		reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)
	var/available_volume = target_holder.maximum_volume - target_holder.total_volume

	//compute total volume of reagents that will be occupied by grind_results
	var/total_volume = 0
	for(var/reagent in grind_results)
		total_volume += grind_results[reagent]

	//compute number of pieces(or sheets) from available_volume
	var/available_amount = min(current_amount, round(available_volume / total_volume))
	if(available_amount <= 0)
		return FALSE

	//Now transfer the grind results scaled by available_amount
	var/list/grind_reagents = grind_results.Copy()
	for(var/reagent in grind_reagents)
		grind_reagents[reagent] *= available_amount
	target_holder.add_reagent_list(grind_reagents)

	/**
	 * use available_amount of sheets/pieces, return TRUE only if all sheets/pieces of this stack were used
	 * we don't delete this stack when it reaches 0 because we expect the all in one grinder, etc to delete
	 * this stack if grinding was successfull
	 */
	use(available_amount, check = FALSE)
	return available_amount == current_amount

/obj/item/stack/proc/check_max_amount()
	while(amount > max_amount)
		amount -= max_amount
		ui_update()
		new type(loc, max_amount, FALSE)

/// DO NOT CALL PARENT EVER. Each material should call individual material recipe
/obj/item/stack/proc/get_recipes()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1/3)))
		w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if(amount <= (max_amount * (2/3)))
		w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/update_icon_state()
	if(novariants)
		return
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
		return ..()
	if(amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
		return ..()
	icon_state = "[initial(icon_state)]_3"
	return ..()

/obj/item/stack/examine(mob/user)
	. = ..()
	if(is_cyborg)
		if(singular_name)
			. += "There is enough energy for [get_amount()] [singular_name]\s."
		else
			. += "There is enough energy for [get_amount()]."
		return
	if(singular_name)
		if(get_amount() > 1)
			. += "There are [get_amount()] [singular_name]\s in the stack."
		else
			. += "There is [get_amount()] [singular_name] in the stack."
	else if(get_amount() > 1)
		. += "There are [get_amount()] in the stack."
	else
		. += "There is [get_amount()] in the stack."
	. += span_notice("<b>Right-click</b> with an empty hand to take a custom amount.")

/obj/item/stack/proc/get_amount()
	if(is_cyborg)
		. = round(source?.energy / cost)
	else
		. = (amount)

/**
  * Builds all recipes in a given recipe list and returns an association list containing them
  *
  * Arguments:
  * * recipe_to_iterate - The list of recipes we are using to build recipes
  */
/obj/item/stack/proc/recursively_build_recipes(list/recipe_to_iterate)
	var/list/L = list()
	for(var/recipe in recipe_to_iterate)
		if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/R = recipe
			L["[R.title]"] = recursively_build_recipes(R.recipes)
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/R = recipe
			L["[R.title]"] = build_recipe(R)
	return L

/**
  * Returns a list of properties of a given recipe
  *
  * Arguments:
  * * R - The stack recipe we are using to get a list of properties
  */
/obj/item/stack/proc/build_recipe(datum/stack_recipe/R)
	return list(
		"res_amount" = R.res_amount,
		"max_res_amount" = R.max_res_amount,
		"req_amount" = R.req_amount,
		"ref" = text_ref(R),
	)

/**
  * Checks if the recipe is valid to be used
  *
  * Arguments:
  * * R - The stack recipe we are checking if it is valid
  * * recipe_list - The list of recipes we are using to check the given recipe
  */
/obj/item/stack/proc/is_valid_recipe(datum/stack_recipe/R, list/recipe_list)
	for(var/S in recipe_list)
		if(S == R)
			return TRUE
		if(istype(S, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/L = S
			if(is_valid_recipe(R, L.recipes))
				return TRUE
	return FALSE

/obj/item/stack/interact(mob/user)
	if(use_radial)
		show_construction_radial(user)
	else
		ui_interact(user)

/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackCrafting", name)
		ui.open()

/obj/item/stack/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = get_amount()
	return data

/obj/item/stack/ui_static_data(mob/user)
	var/list/data = list()
	data["recipes"] = recursively_build_recipes(get_recipes())
	return data

/obj/item/stack/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("make")
			var/datum/stack_recipe/recipe = locate(params["ref"])
			var/multiplier = text2num(params["multiplier"])

			return make_item(usr, recipe, multiplier)

/// The key / title for a radial option that shows the entire list of buildables (uses the old menu)
#define FULL_LIST "view full list"

/// Shows a radial consisting of every radial recipe we have in our list.
/obj/item/stack/proc/show_construction_radial(mob/builder)
	var/list/options = list()
	var/list/titles_to_recipes = list()

	for(var/datum/stack_recipe/radial/recipe in get_recipes())
		var/datum/radial_menu_choice/option = new()
		option.image = image(
			icon = initial(recipe.result_type.icon),
			icon_state = initial(recipe.result_type.icon_state),
		)

		if(recipe.desc)
			option.info = recipe.desc

		options[recipe.title] = option
		titles_to_recipes[recipe.title] = recipe

	// After everything's been added to the radial, add an option
	// that lets the user see the whole list of buildables
	options[FULL_LIST] = image(
		icon = 'icons/hud/radials/radial_generic.dmi',
		icon_state = "radial_full_list",
	)

	var/selection = show_radial_menu(
		user = builder,
		anchor = builder,
		choices = options,
		custom_check = CALLBACK(src, PROC_REF(radial_check), builder),
		radius = radial_radius,
		tooltips = TRUE,
	)

	if(!selection)
		return
	// Run normal UI interact if we wanna see the full list
	if(selection == FULL_LIST)
		ui_interact(builder)
		return

	// Otherwise go straight to building
	var/datum/stack_recipe/picked_recipe = titles_to_recipes[selection]
	if(!istype(picked_recipe))
		return

	make_item(builder, picked_recipe, 1)

/// Used as a callback for radial building.
/obj/item/stack/proc/radial_check(mob/builder)
	if(QDELETED(builder) || QDELETED(src))
		return FALSE
	if(builder.incapacitated)
		return FALSE
	if(!builder.is_holding(src))
		return FALSE
	return TRUE

#undef FULL_LIST

/// Makes the item with the given recipe.
/obj/item/stack/proc/make_item(mob/builder, datum/stack_recipe/recipe, multiplier)
	if(get_amount() < 1 && !is_cyborg) //sanity check as this shouldn't happen
		qdel(src)
		return
	if(!is_valid_recipe(recipe, get_recipes())) //href exploit protection
		return
	if(!multiplier || multiplier < 1 || !IS_FINITE(multiplier)) //href exploit protection
		return
	if(!building_checks(builder, recipe, multiplier))
		return
	if(recipe.time)
		var/adjusted_time = 0
		builder.balloon_alert(builder, "building...")
		builder.visible_message(
			span_notice("[builder] starts building \a [recipe.title]."),
			span_notice("You start building \a [recipe.title]..."),
		)
		if(HAS_TRAIT(builder, recipe.trait_booster))
			adjusted_time = (recipe.time * recipe.trait_modifier)
		else
			adjusted_time = recipe.time
		if(!do_after(builder, adjusted_time, target = builder))
			builder.balloon_alert(builder, "interrupted!")
			return
		if(!building_checks(builder, recipe, multiplier))
			return

	var/atom/created
	if(recipe.max_res_amount > 1) // Is it a stack?
		created = new recipe.result_type(builder.drop_location(), recipe.res_amount * multiplier)
		builder.balloon_alert(builder, "built items")

	else if(ispath(recipe.result_type, /turf))
		var/turf/covered_turf = builder.drop_location()
		if(!isturf(covered_turf))
			return
		covered_turf.PlaceOnTop(recipe.result_type, flags = CHANGETURF_INHERIT_AIR)
		builder.balloon_alert(builder, "placed [ispath(recipe.result_type, /turf/open) ? "floor" : "wall"]")

	else
		created = new recipe.result_type(builder.drop_location())
		builder.balloon_alert(builder, "built item")

	if(created)
		created.setDir(builder.dir)

	// Use up the material
	use(recipe.req_amount * multiplier)
	builder.investigate_log("[key_name(builder)] crafted [recipe.title]", INVESTIGATE_CRAFTING)

	// Apply mat datums
	if((recipe.crafting_flags & CRAFT_APPLIES_MATS) && LAZYLEN(mats_per_unit))
		if(isstack(created))
			var/obj/item/stack/crafted_stack = created
			crafted_stack.set_mats_per_unit(mats_per_unit, recipe.req_amount / recipe.res_amount)
		else
			created.set_custom_materials(mats_per_unit, recipe.req_amount / recipe.res_amount)

	// We could be qdeleted - like if it's a stack and has already been merged
	if(QDELETED(created))
		return TRUE

	// Add fingerprints first, otherwise created might already be deleted because of stack merging
	created.add_fingerprint(builder)
	if(isitem(created))
		builder.put_in_hands(created)

	//BubbleWrap - so newly formed boxes are empty
	if(istype(created, /obj/item/storage))
		for (var/obj/item/thing in created)
			qdel(thing)
	//BubbleWrap END

	return TRUE

/// Checks if we can build here, validly.
/obj/item/stack/proc/building_checks(mob/builder, datum/stack_recipe/recipe, multiplier)
	if (get_amount() < recipe.req_amount * multiplier)
		builder.balloon_alert(builder, "not enough material!")
		return FALSE
	var/turf/dest_turf = get_turf(builder)

	if((recipe.crafting_flags & CRAFT_ONE_PER_TURF) && (locate(recipe.result_type) in dest_turf))
		builder.balloon_alert(builder, "already one here!")
		return FALSE

	if(recipe.crafting_flags & CRAFT_CHECK_DIRECTION)
		if(!valid_build_direction(dest_turf, builder.dir, is_fulltile = (recipe.crafting_flags & CRAFT_IS_FULLTILE)))
			builder.balloon_alert(builder, "won't fit here!")
			return FALSE

	if(recipe.crafting_flags & CRAFT_ON_SOLID_GROUND)
		if(isclosedturf(dest_turf))
			builder.balloon_alert(builder, "cannot be made on a wall!")
			return FALSE

		if(is_type_in_typecache(dest_turf, GLOB.turfs_without_ground))
			builder.balloon_alert(builder, "must be made on solid ground!")
			return FALSE

	if(recipe.crafting_flags & CRAFT_CHECK_DENSITY)
		for(var/obj/object in dest_turf)
			if(object.density && !(object.obj_flags & IGNORE_DENSITY) || object.obj_flags & BLOCKS_CONSTRUCTION)
				builder.balloon_alert(builder, "something is in the way!")
				return FALSE

	if(recipe.placement_checks & STACK_CHECK_CARDINALS)
		var/turf/nearby_turf
		for(var/direction in GLOB.cardinals)
			nearby_turf = get_step(dest_turf, direction)
			if(locate(recipe.result_type) in nearby_turf)
				to_chat(builder, span_warning("\The [recipe.title] must not be built directly adjacent to another!"))
				builder.balloon_alert(builder, "can't be adjacent to another!")
				return FALSE

	if(recipe.placement_checks & STACK_CHECK_ADJACENT)
		if(locate(recipe.result_type) in range(1, dest_turf))
			builder.balloon_alert(builder, "can't be near another!")
			return FALSE

	return TRUE

/obj/item/stack/use(used, transfer = FALSE, check = TRUE) // return FALSE = borked; return TRUE = had enough
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return FALSE
	if(is_cyborg)
		return source.use_charge(used * cost)
	if(amount < used)
		return FALSE
	amount -= used
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return TRUE
	if(length(mats_per_unit))
		update_custom_materials()
	update_appearance()
	ui_update()
	update_weight()
	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		// general balloon alert that says they don't have enough
		user.balloon_alert(user, "not enough material!")
		// then a more specific message about how much they need and what they need specifically
		if(singular_name)
			if(amount > 1)
				to_chat(user, span_warning("You need at least [amount] [singular_name]\s to do this!"))
			else
				to_chat(user, span_warning("You need at least [amount] [singular_name] to do this!"))
		else
			to_chat(user, span_warning("You need at least [amount] to do this!"))
		return FALSE
	return TRUE

/**
 * Returns TRUE if the item stack is the equivalent of a 0 amount item.
 *
 * Also deletes the item if delete_if_zero is TRUE and the stack does not have
 * is_cyborg set to true.
 */
/obj/item/stack/proc/is_zero_amount(delete_if_zero = TRUE)
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		if(delete_if_zero)
			qdel(src)
		return TRUE
	return FALSE

/** Adds some number of units to this stack.
  *
  * Arguments:
  * - _amount: The number of units to add to this stack.
  */
/obj/item/stack/proc/add(_amount)
	if (is_cyborg)
		source.add_charge(_amount * cost)
	else
		amount += _amount
	if(length(mats_per_unit))
		update_custom_materials()
	update_appearance()
	update_weight()
	ui_update()

/** Checks whether this stack can merge itself into another stack.
  *
  * Arguments:
  * - [check][/obj/item/stack]: The stack to check for mergeability.
  */
/obj/item/stack/proc/can_merge(obj/item/stack/check)
	if(!istype(check, merge_type))
		return FALSE
	if(mats_per_unit != check.mats_per_unit)
		return FALSE
	if(is_cyborg)	// No merging cyborg stacks into other stacks
		return FALSE
	return TRUE

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This calls use() without check = FALSE, preventing the item from qdeling itself if it reaches 0 stack size.
 *
 * As a result, this proc can leave behind a 0 amount stack.
 */
/obj/item/stack/proc/merge_without_del(obj/item/stack/target_stack, limit)
	// Cover edge cases where multiple stacks are being merged together and haven't been deleted properly.
	// Also cover edge case where a stack is being merged into itself, which is supposedly possible.
	if(QDELETED(target_stack))
		CRASH("Stack merge attempted on qdeleted target stack.")
	if(QDELETED(src))
		CRASH("Stack merge attempted on qdeleted source stack.")
	if(target_stack == src)
		CRASH("Stack attempted to merge into itself.")

	var/transfer = get_amount()
	if(target_stack.is_cyborg)
		transfer = min(transfer, round((target_stack.source.max_energy - target_stack.source.energy) / target_stack.cost))
	else
		transfer = min(transfer, (limit ? limit : target_stack.max_amount) - target_stack.amount)
	if(pulledby)
		pulledby.start_pulling(target_stack)
	target_stack.copy_evidences(src)
	use(transfer, transfer = TRUE, check = FALSE)
	target_stack.add(transfer)
	return transfer

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This proc deletes src if the remaining amount after the transfer is 0.
 */
/obj/item/stack/proc/merge(obj/item/stack/target_stack, limit)
	. = merge_without_del(target_stack, limit)
	is_zero_amount(delete_if_zero = TRUE)
	ui_update() //merging into stack wont update stackcrafting menu otherwise

/obj/item/stack/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(can_merge(AM))
		merge(AM)
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() == src)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		return split_stack(user, 1)
	else
		. = ..()

//If we attack ourselves with the same hand
/obj/item/stack/attack_self_secondary(mob/user, modifiers)
	. = ..()
	src.attack_hand_secondary(user, modifiers)

//If we attack ourselves with a different hand
/obj/item/stack/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(is_cyborg || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	if(is_zero_amount(delete_if_zero = TRUE))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/max = get_amount()
	var/stackmaterial = tgui_input_number(user, "How many sheets do you wish to take out of this stack?", "Stack Split", max_value = max)
	if(!stackmaterial || QDELETED(user) || QDELETED(src) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK, !iscyborg(user)))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	split_stack(user, stackmaterial)
	to_chat(user, span_notice("You take [stackmaterial] sheets out of the stack."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/** Splits the stack into two stacks.
  *
  * Arguments:
  * - [user][/mob]: The mob splitting the stack.
  * - amount: The number of units to split from this stack.
  */
/obj/item/stack/proc/split_stack(mob/user, amount)
	if(!use(amount, TRUE, FALSE))
		return null
	var/obj/item/stack/F = new type(user ? user : drop_location(), amount, FALSE)
	. = F
	F.set_mats_per_unit(mats_per_unit, 1) // Required for greyscale sheets and tiles.
	F.copy_evidences(src)
	loc.atom_storage?.refresh_views()
	if(user)
		if(!user.put_in_hands(F, merge_stacks = FALSE))
			F.forceMove(user.drop_location())
		add_fingerprint(user)
		F.add_fingerprint(user)

	is_zero_amount(delete_if_zero = TRUE)

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(can_merge(W))
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, span_notice("Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s."))
	else
		return ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	add_blood_DNA(GET_ATOM_BLOOD_DNA(from))
	add_fingerprint_list(GET_ATOM_FINGERPRINTS(from))
	add_hiddenprint_list(GET_ATOM_HIDDENPRINTS(from))
	fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty += amount

#undef STACK_CHECK_CARDINALS
#undef STACK_CHECK_ADJACENT
