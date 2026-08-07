/**
 *Storage component used for RPEDs. Rather than manually setting everything with a get_part_rating() value, we just check if it has the variable required for insertion.
 */
/datum/storage/rped
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE
	max_slots = 50
	max_total_storage = 100
	max_specific_storage = WEIGHT_CLASS_NORMAL
	numerical_stacking = TRUE

/datum/storage/rped/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	. = ..()
	if(!to_insert.get_part_rating())
		return FALSE

/obj/item/storage/part_replacer/attack_self(mob/user)
	var/list/things = list()
	var/lowest_rating = INFINITY

	for(var/obj/item/stock_parts/part in contents)
		if(istype(part, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/cell = part
			lowest_rating = min(lowest_rating, cell.rating)
			things += part
			continue
		lowest_rating = min(lowest_rating, part.get_part_rating())
		things += part

	if(lowest_rating == INFINITY)
		to_chat(user, span_notice("There's no parts to dump out from [src]."))
		return

	for(var/obj/item/part in things)
		if(istype(part, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/cell = part
			if(cell.rating > lowest_rating)
				things.Remove(part)
		else if(part.get_part_rating() > lowest_rating)
			things.Remove(part)

	to_chat(user, span_notice("You dump out Tier [lowest_rating] parts from [src]."))

	var/atom/drop_location = drop_location()

	for(var/obj/item/part in things)
		part.forceMove(drop_location)
