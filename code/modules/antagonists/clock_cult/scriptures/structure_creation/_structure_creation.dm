/datum/clockcult/scripture/create_structure
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
	SHOULD_CALL_PARENT(FALSE)
	// Spawn
	var/created_structure = new summoned_structure.type(get_turf(invoker))

	// Set owner
	var/obj/structure/destructible/clockwork/clockwork_structure = created_structure
	clockwork_structure?.owner = invoker.mind
	return ..()
