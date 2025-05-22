/obj/machinery/plumbing/grinder_chemical
	name = "chemical grinder"
	desc = "Chemical grinder. Can either grind or juice stuff you put in."
	icon_state = "grinder_chemical"
	layer = ABOVE_ALL_MOB_LAYER
	reagent_flags = TRANSPARENT | DRAINABLE
	rcd_cost = 30
	rcd_delay = 30
	buffer = 400
	active_power_usage = 80

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/plumbing/grinder_chemical)

/obj/machinery/plumbing/grinder_chemical/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_appearance() //so the input/output pipes will overlay properly during init

/obj/machinery/plumbing/grinder_chemical/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/storage/bag))
		to_chat(user, "<span class='notice'>You dump items from [weapon] into the grinder.</span>")
		for(var/obj/item/obj_item in weapon.contents)
			grind(obj_item)
	else
		to_chat(user, "<span class='notice'>You attempt to grind [weapon].</span>")
		grind(weapon)

	return TRUE

/obj/machinery/plumbing/grinder_chemical/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(!istype(mover, /obj/item))
		return FALSE
	return TRUE

/obj/machinery/plumbing/grinder_chemical/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(grind), AM)

/**
 * Grinds/Juices the atom
 * Arguments
 * * [AM][atom] - the atom to grind or juice
 */
/obj/machinery/plumbing/grinder_chemical/proc/grind(atom/AM)
	if(machine_stat & NOPOWER)
		return
	if(reagents.holder_full())
		return
	if(!isitem(AM))
		return

	if(istype(AM, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/reag_container = AM
		if(reag_container.prevent_grinding) // don't grind floorpill
			return

	var/obj/item/I = AM
	var/result
	if(I.grind_results || I.juice_typepath)
		use_power(active_power_usage)
		if(I.grind_results)
			result = I.grind(reagents, usr)
		else if (I.juice_typepath)
			result = I.juice(reagents, usr)
		if(result)
			qdel(I)

