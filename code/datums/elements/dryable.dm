// If an item has this element, it can be dried on a drying rack.
/datum/element/dryable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// The type of atom that is spawned by this element on drying.
	var/dry_result

/datum/element/dryable/Attach(datum/target, atom/dry_result)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.dry_result = dry_result

	RegisterSignal(target, COMSIG_ITEM_DRIED, PROC_REF(finish_drying))
	ADD_TRAIT(target, TRAIT_DRYABLE, ELEMENT_TRAIT(type))


/datum/element/dryable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_FOOD_CONSUMED)
	REMOVE_TRAIT(target, TRAIT_DRYABLE, ELEMENT_TRAIT(type))

/datum/element/dryable/proc/finish_drying(atom/source, datum/weakref/drying_user)
	SIGNAL_HANDLER
	var/atom/dried_atom = source
	if(dry_result == dried_atom.type)//if the dried type is the same as our currrent state, don't bother creating a whole new item, just re-color it.
		var/atom/movable/resulting_atom = dried_atom
		resulting_atom.add_atom_colour("#ad7257", FIXED_COLOUR_PRIORITY)
		apply_dried_status(resulting_atom, drying_user)
		resulting_atom.forceMove(source.drop_location())
		return

	else if(isstack(source)) //Check if its a sheet
		var/obj/item/stack/itemstack = dried_atom
		for(var/i in 1 to itemstack.amount)
			var/atom/movable/resulting_atom = new dry_result(source.drop_location())
			apply_dried_status(resulting_atom, drying_user)
		qdel(source)
		return
	else if(istype(source, /obj/item/food) && ispath(dry_result, /obj/item/food))
		var/obj/item/food/source_food = source
		var/obj/item/food/resulting_food = new dry_result(source.drop_location())
		source_food.reagents.trans_to(resulting_food, source_food.reagents.total_volume)
		apply_dried_status(resulting_food, drying_user)
		qdel(source)
		return
	else
		var/atom/movable/resulting_atom = new dry_result(source.drop_location())
		apply_dried_status(resulting_atom, drying_user)
		qdel(source)

/datum/element/dryable/proc/apply_dried_status(atom/target, datum/weakref/drying_user)
	ADD_TRAIT(target, TRAIT_DRIED, ELEMENT_TRAIT(type))
	var/datum/mind/user_mind = drying_user?.resolve()
	if(drying_user && istype(target, /obj/item/food))
		ADD_TRAIT(target, TRAIT_FOOD_CHEF_MADE, REF(user_mind))
