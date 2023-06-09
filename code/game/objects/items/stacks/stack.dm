/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

//stack recipe placement check types config
/// checks if there is an object of the result type in any of the cardinal directions
#define STACK_CHECK_CARDINALS "cardinals"
/// checks if there is an object of the result type within one tile
#define STACK_CHECK_ADJACENT "adjacent"

/*
 * Stacks
 */

/obj/item/stack
	icon = 'icons/obj/stacks/minerals.dmi'
	gender = PLURAL
	///The list recipes you can make with the stack
	var/list/datum/stack_recipe/recipes
	///The name of the thing when it's singular
	var/singular_name
	///The amount of thing in the stack
	var/amount = 1
	///also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/max_amount = 50
	///It's TRUE if module is used by a cyborg, and uses its storage
	var/is_cyborg = FALSE
	///Holder var for the cyborg energy source
	var/datum/robot_energy_storage/source
	///How much energy from storage it costs
	var/cost = 1
	///This path and its children should merge with this stack, defaults to src.type
	var/merge_type
	///The weight class the stack should have at amount > 2/3rds max_amount
	var/full_w_class = WEIGHT_CLASS_NORMAL
	//Determines whether the item should update it's sprites based on amount.
	var/novariants = TRUE
	///Stores table variant to be built from this stack
	var/obj/structure/table/tableVariant

	//NOTE: When adding grind_results, the amounts should be for an INDIVIDUAL ITEM - these amounts will be multiplied by the stack size in on_grind()

/obj/item/stack/on_grind()
	for(var/i in 1 to length(grind_results)) //This should only call if it's ground, so no need to check if grind_results exists
		grind_results[grind_results[i]] *= get_amount() //Gets the key at position i, then the reagent amount of that key, then multiplies it by stack size

/obj/item/stack/grind_requirements()
	if(is_cyborg)
		to_chat(usr, "<span class='danger'>[src] is electronically synthesized in your chassis and can't be ground up!</span>")
		return
	return TRUE

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(new_amount != null)
		amount = new_amount
	if(user)
		add_fingerprint(user)
	check_max_amount()
	if(!merge_type)
		merge_type = type
	if(merge)
		for(var/obj/item/stack/S in loc)
			if(S.merge_type == merge_type)
				merge(S)
				if(QDELETED(src))
					return
	update_weight()
	update_icon()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/stack/proc/check_max_amount()
	while(amount > max_amount)
		amount -= max_amount
		ui_update()
		new type(loc, max_amount, FALSE)

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1/3)))
		w_class = CLAMP(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if(amount <= (max_amount * (2/3)))
		w_class = CLAMP(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/update_icon()
	if(novariants)
		return ..()
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
	else if(amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
	else
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
	. += "<span class='notice'>Alt-click to take a custom amount.</span>"

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
		if(isnull(recipe))
			L += list(list(
				"spacer" = TRUE
			))
		if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/R = recipe
			L += list(list(
				"title" = R.title,
				"sub_recipes" = recursively_build_recipes(R.recipes),
			))
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/R = recipe
			L += list(build_recipe(R))
	return L

/**
  * Returns a list of properties of a given recipe
  *
  * Arguments:
  * * R - The stack recipe we are using to get a list of properties
  */
/obj/item/stack/proc/build_recipe(datum/stack_recipe/R)
	return list(
		"title" = R.title,
		"res_amount" = R.res_amount,
		"max_res_amount" = R.max_res_amount,
		"req_amount" = R.req_amount,
		"ref" = "\ref[R]",
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

/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Stack", name)
		ui.open()

/obj/item/stack/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = get_amount()
	return data

/obj/item/stack/ui_static_data(mob/user)
	var/list/data = list()
	data["recipes"] = recursively_build_recipes(recipes)
	return data

/obj/item/stack/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("make")
			if(get_amount() < 1 && !is_cyborg)
				qdel(src)
				return
			var/datum/stack_recipe/R = locate(params["ref"])
			if(!is_valid_recipe(R, recipes)) //href exploit protection
				return
			var/multiplier = text2num(params["multiplier"])
			if(!isnum_safe(multiplier) || (multiplier <= 0)) //href exploit protection
				return
			if(!building_checks(R, multiplier))
				return
			if(R.time)
				usr.visible_message("<span class='notice'>[usr] starts building \a [R.title].</span>", "<span class='notice'>You start building \a [R.title]...</span>")
				if(!do_after(usr, R.time, target = usr))
					return
				if(!building_checks(R, multiplier))
					return

			var/obj/O
			if(R.max_res_amount > 1) //Is it a stack?
				O = new R.result_type(usr.drop_location(), R.res_amount * multiplier)
			else if(ispath(R.result_type, /turf))
				var/turf/T = usr.drop_location()
				if(!isturf(T))
					return
				T.PlaceOnTop(R.result_type, flags = CHANGETURF_INHERIT_AIR)
			else
				O = new R.result_type(usr.drop_location())
			if(O)
				O.setDir(usr.dir)
			use(R.req_amount * multiplier)

			/* // We don't have R.applies_mats, leaving this in here for convenience in case we get it
			if(R.applies_mats && custom_materials && custom_materials.len)
				var/list/used_materials = list()
				for(var/i in custom_materials)
					used_materials[SSmaterials.GetMaterialRef(i)] = R.req_amount / R.res_amount * (MINERAL_MATERIAL_AMOUNT / custom_materials.len)
				O.set_custom_materials(used_materials)
			*/

			if(QDELETED(O))
				return //It's a stack and has already been merged

			if(isitem(O))
				usr.put_in_hands(O)
			O.add_fingerprint(usr)

			if(istype(O, /obj/item/storage))
				for(var/obj/item/I in O)
					qdel(I)
			return TRUE

/obj/item/stack/proc/building_checks(datum/stack_recipe/recipe, multiplier)
	if(get_amount() < recipe.req_amount*multiplier)
		if(recipe.req_amount*multiplier>1)
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [recipe.req_amount*multiplier] [recipe.title]\s!</span>")
		else
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [recipe.title]!</span>")
		return FALSE

	var/turf/dest_turf = get_turf(usr)

	// If we're making a window, we have some special snowflake window checks to do.
	if(ispath(recipe.result_type, /obj/structure/window))
		var/obj/structure/window/result_path = recipe.result_type
		if(!valid_window_location(dest_turf, usr.dir, is_fulltile = initial(result_path.fulltile)))
			to_chat(usr, "<span class='warning'>The [recipe.title] won't fit here!</span>")
			return FALSE

	if(recipe.one_per_turf && (locate(recipe.result_type) in dest_turf))
		to_chat(usr, "<span class='warning'>There is another [recipe.title] here!</span>")
		return FALSE

	if(recipe.on_floor)
		if(!isanyfloor(dest_turf))
			to_chat(usr, "<span class='warning'>\The [recipe.title] must be constructed on the floor!</span>")
			return FALSE

		for(var/obj/object in dest_turf)
			if(istype(object, /obj/structure/grille))
				continue
			if(istype(object, /obj/structure/table))
				continue
			if(istype(object, /obj/structure/window))
				var/obj/structure/window/window_structure = object
				if(!window_structure.fulltile)
					continue
			if(object.density)
				to_chat(usr, "<span class='warning'>There is \a [object.name] here. You cant make \a [recipe.title] here!</span>")
				return FALSE
	if(recipe.placement_checks)
		switch(recipe.placement_checks)
			if(STACK_CHECK_CARDINALS)
				var/turf/step
				for(var/direction in GLOB.cardinals)
					step = get_step(dest_turf, direction)
					if(locate(recipe.result_type) in step)
						to_chat(usr, "<span class='warning'>\The [recipe.title] must not be built directly adjacent to another!</span>")
						return FALSE
			if(STACK_CHECK_ADJACENT)
				if(locate(recipe.result_type) in range(1, dest_turf))
					to_chat(usr, "<span class='warning'>\The [recipe.title] must be constructed at least one tile away from others of its type!</span>")
					return FALSE
	return TRUE

/obj/item/stack/use(used, transfer = FALSE, check = TRUE) // return FALSE = borked; return TRUE = had enough
	if(check && zero_amount())
		return FALSE
	if(is_cyborg)
		return source.use_charge(used * cost)
	if(amount < used)
		return FALSE
	amount -= used
	if(check)
		zero_amount()
	update_icon()
	ui_update()
	update_weight()
	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		if(singular_name)
			if(amount > 1)
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name]\s to do this!</span>")
			else
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name] to do this!</span>")
		else
			to_chat(user, "<span class='warning'>You need at least [amount] to do this!</span>")
		return FALSE
	return TRUE

/obj/item/stack/proc/zero_amount()
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		qdel(src)
		return TRUE
	return FALSE

/obj/item/stack/proc/add(amount)
	if(is_cyborg)
		source.add_charge(amount * cost)
	else
		src.amount += amount
		check_max_amount()
	update_icon()
	update_weight()
	ui_update()

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	var/transfer = get_amount()
	if(S.is_cyborg)
		transfer = min(transfer, round((S.source.max_energy - S.source.energy) / S.cost))
	else
		transfer = min(transfer, S.max_amount - S.amount)
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	use(transfer, TRUE)
	S.add(transfer)
	return transfer

/obj/item/stack/proc/on_entered(datum/source, obj/O)
	SIGNAL_HANDLER

	if(merge_check(O) && !O.throwing)
		INVOKE_ASYNC(src, PROC_REF(merge), O)

/obj/item/stack/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(merge_check(AM))
		merge(AM)
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/user)
	if(user.get_inactive_held_item() == src)
		if(zero_amount())
			return
		return change_stack(user,1)
	else
		return ..()

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(is_cyborg)
		return
	else
		if(zero_amount())
			return
		//get amount from user
		var/max = get_amount()
		var/stackmaterial = round(input(user,"How many sheets do you wish to take out of this stack? (Maximum  [max])") as null|num)
		max = get_amount()
		stackmaterial = min(max, stackmaterial)
		if(!stackmaterial || stackmaterial < 0 || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			return
		else
			change_stack(user, stackmaterial)
			to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack.</span>")

/obj/item/stack/proc/change_stack(mob/user, amount)
	if(!use(amount, TRUE, FALSE))
		return FALSE
	var/obj/item/stack/F = new type(user ? user : drop_location(), amount, FALSE)
	. = F
	F.copy_evidences(src)
	if(user)
		if(!user.put_in_hands(F, merge_stacks = FALSE))
			F.forceMove(user.drop_location())
		add_fingerprint(user)
		F.add_fingerprint(user)
	zero_amount()

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(merge_check(W))
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
	else
		return ..()

/obj/item/stack/proc/merge_check(obj/O)
	if(istype(O,merge_type))
		if(!istype(O,/obj/item/stack)) //Not a stack, but can be stacked.
			return TRUE
		else
			var/obj/item/stack/ostack = O
			if(istype(src,ostack.merge_type)) //Merge types have to go in both directions, so inheritance != stackable together
				return TRUE
	return FALSE

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	add_blood_DNA(from.return_blood_DNA())
	add_fingerprint_list(from.return_fingerprints())
	add_hiddenprint_list(from.return_hiddenprints())
	fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty += amount

/*
 * Recipe datum
 */
/datum/stack_recipe
	///The name of the recipe
	var/title = "ERROR"
	///The thing we get from doing the recipe
	var/result_type
	///The amount of type of material we need
	var/req_amount = 1
	///The amount of thing we make
	var/res_amount = 1
	///The maximum amount of thing we can get from crafting
	var/max_res_amount = 1
	///The time it takes to make
	var/time = 0
	///Can we have only one instance of recipe result per turf?
	var/one_per_turf = FALSE
	///Can we make the result on non-solid turfs (space)
	var/on_floor = FALSE
	///Do we do placement checks while placing the recipe?
	var/placement_checks = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1,time = 0, one_per_turf = FALSE, on_floor = FALSE, window_checks = FALSE, placement_checks = FALSE )
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.placement_checks = placement_checks
/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes

#undef STACK_CHECK_CARDINALS
#undef STACK_CHECK_ADJACENT
