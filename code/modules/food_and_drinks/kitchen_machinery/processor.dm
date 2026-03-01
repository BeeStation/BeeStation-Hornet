
/obj/machinery/processor
	name = "food processor"
	desc = "An industrial grinder used to process meat and other foods. Keep hands clear of intake area while operating."
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "processor1"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	circuit = /obj/item/circuitboard/machine/processor
	var/broken = FALSE
	var/processing = FALSE
	var/rating_speed = 1
	var/rating_amount = 1
	processing_flags = NONE

/obj/machinery/processor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		rating_amount = B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating_speed = M.rating

/obj/machinery/processor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Outputting <b>[rating_amount]</b> item(s) at <b>[rating_speed*100]%</b> speed.")

/obj/machinery/processor/proc/process_food(datum/food_processor_process/recipe, atom/movable/what)
	if (recipe.output && loc && !QDELETED(src))
		var/cached_multiplier = (recipe.food_multiplier * rating_amount)
		for(var/i in 1 to cached_multiplier)
			var/atom/processed_food = new recipe.output(drop_location())
			if(processed_food.reagents && what.reagents)
				processed_food.reagents.clear_reagents()
				what.reagents.copy_to(processed_food, what.reagents.total_volume, multiplier = 1 / cached_multiplier)

	if (isliving(what))
		var/mob/living/themob = what
		themob.gib(TRUE,TRUE,TRUE)
	else
		qdel(what)

/obj/machinery/processor/proc/select_recipe(input_item)
	var/most_specific_type = /atom
	for (var/datum/food_processor_process/recipe as anything in subtypesof(/datum/food_processor_process) - /datum/food_processor_process/mob)
		var/recipe_input = initial(recipe.input)
		if (istype(src, initial(recipe.required_machine)) && istype(input_item, recipe_input) && ispath(recipe_input, most_specific_type))
			most_specific_type = recipe_input
			. = new recipe()

/obj/machinery/processor/attackby(obj/item/O, mob/living/user, params)
	if(processing)
		to_chat(user, span_warning("[src] is in the process of processing!"))
		return TRUE
	if(default_deconstruction_screwdriver(user, "processor", "processor1", O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/T = O
		var/loaded = 0
		for(var/obj/S in T.contents)
			if(!IS_EDIBLE(S))
				continue
			var/datum/food_processor_process/P = select_recipe(S)
			if(P)
				if(T.atom_storage.attempt_remove(S, src))
					loaded++

		if(loaded)
			to_chat(user, span_notice("You insert [loaded] items into [src]."))
		return

	var/datum/food_processor_process/P = select_recipe(O)
	if(P)
		user.visible_message("[user] put [O] into [src].", \
			"You put [O] into [src].")
		user.transferItemToLoc(O, src, TRUE)
		return 1
	else if(!user.combat_mode)
		to_chat(user, "<span class='warning'>That probably won't blend!</span>")
		return 1
	else
		return ..()

/obj/machinery/processor/interact(mob/user)
	if(processing)
		to_chat(user, span_warning("[src] is in the process of processing!"))
		return TRUE
	if(ismob(user.pulling) && select_recipe(user.pulling))
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		var/mob/living/pushed_mob = user.pulling
		visible_message(span_warner("[user] stuffs [pushed_mob] into [src]!"))
		pushed_mob.forceMove(src)
		user.stop_pulling()
		return
	if(contents.len == 0)
		to_chat(user, span_warning("[src] is empty!"))
		return TRUE
	processing = TRUE
	user.visible_message("[user] turns on [src].", \
		span_notice("You turn on [src]."), \
		span_italics("You hear a food processor."))
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor doesn't have a suitable recipe. How did it get in there? Please report it immediately!!!")
			continue
		total_time += P.time
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = (total_time / rating_speed)*5) //start shaking
	sleep(total_time / rating_speed)
	for(var/atom/movable/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor doesn't have a suitable recipe. How do you put it in?")
			continue
		process_food(P, O)
	pixel_x = base_pixel_x //return to its spot after shaking
	processing = FALSE
	visible_message("\The [src] finishes processing.")

/obj/machinery/processor/verb/eject()
	set category = "Object"
	set name = "Eject Contents"
	set src in oview(1)
	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if (!usr.canUseTopic())
		return
	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_UI))
			return
	dump_inventory_contents()
	add_fingerprint(usr)

/obj/machinery/processor/container_resist(mob/living/user)
	user.forceMove(drop_location())
	user.visible_message(span_notice("[user] crawls free of the processor!"))

/obj/machinery/processor/slime
	name = "slime processor"
	desc = "An industrial grinder with a sticker saying appropriated for science department. Keep hands clear of intake area while operating."
	circuit = /obj/item/circuitboard/machine/processor/slime
	var/sbacklogged = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/machinery/processor/slime/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)

/obj/machinery/processor/slime/adjust_item_drop_location(atom/movable/AM)
	var/static/list/slimecores = subtypesof(/obj/item/slime_extract)
	var/i = 0
	if(!(i = slimecores.Find(AM.type))) // If the item is not found
		return
	if (i <= 16) // If in the first 12 slots
		AM.pixel_x = AM.base_pixel_x - 12 + ((i%4)*8)
		AM.pixel_y = AM.base_pixel_y - 12 + (round(i/4)*8)
		return i
	var/ii = i - 16
	AM.pixel_x = AM.base_pixel_x - 8 + ((ii%3)*8)
	AM.pixel_y = AM.base_pixel_y - 8 + (round(ii/3)*8)
	return i

/obj/machinery/processor/slime/interact(mob/user)
	. = ..()
	if(sbacklogged)
		for(var/mob/living/simple_animal/slime/AM in ohearers(1,src)) //fallback in case slimes got placed while processor was active triggers only after processing!!!!
			if(AM.stat == DEAD)
				visible_message("[AM] is sucked into [src].")
				AM.forceMove(src)
		sbacklogged = FALSE

/obj/machinery/processor/slime/HasProximity(mob/AM)
	if(!sbacklogged && istype(AM, /mob/living/simple_animal/slime) && AM.stat == DEAD)
		if(processing)
			sbacklogged = TRUE
		else
			visible_message("[AM] is sucked into [src].")
			AM.forceMove(src)

/obj/machinery/processor/slime/process_food(datum/food_processor_process/recipe, atom/movable/what)
	var/mob/living/simple_animal/slime/S = what
	if (istype(S))
		var/C = S.cores
		for(var/i in 1 to (C+rating_amount-1))
			var/obj/item/slime_extract/item = new S.coretype(drop_location())
			if(S.transformeffects & SLIME_EFFECT_GOLD)
				item.sparkly = TRUE
			adjust_item_drop_location(item)
			SSblackbox.record_feedback("tally", "slime_core_harvested", 1, S.colour)
	..()
