/datum/clockcult/scripture/create_structure
	category = SPELLTYPE_STRUCTURES

	/// The structure to spawn
	var/obj/structure/destructible/clockwork/summoned_structure

/datum/clockcult/scripture/create_structure/can_invoke()
	. = ..()
	if(!.)
		return FALSE

	for(var/obj/structure/destructible/clockwork/structure in get_turf(invoker))
		invoker.balloon_alert(invoker, "space already occupied!")
		return FALSE

/datum/clockcult/scripture/create_structure/on_invoke_success()
	summoned_structure = new(get_turf(invoker))
	summoned_structure.owner = invoker.mind
	. = ..()
