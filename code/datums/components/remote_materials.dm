/*
This component allows machines to connect remotely to a material container
(namely an /obj/machinery/ore_silo) elsewhere. It offers optional graceful
fallback to a local material storage in case remote storage is unavailable, and
handles linking back and forth.
*/

/datum/component/remote_materials
	// Three possible states:
	// 1. silo exists, materials is parented to silo
	// 2. silo is null, materials is parented to parent
	// 3. silo is null, materials is null
	var/obj/machinery/ore_silo/silo
	var/datum/component/material_container/mat_container
	var/category
	var/allow_standalone
	var/local_size = INFINITY

/datum/component/remote_materials/Initialize(category, mapload, allow_standalone = TRUE, force_connect = FALSE)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.category = category
	src.allow_standalone = allow_standalone

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(OnAttackBy))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(check_z_disconnect))

	var/turf/T = get_turf(parent)
	if (force_connect || (mapload && is_station_level(T.z)))
		addtimer(CALLBACK(src, PROC_REF(LateInitialize)))
	else if (allow_standalone)
		_MakeLocal()

/datum/component/remote_materials/proc/LateInitialize()
	set_silo(GLOB.ore_silo_default)
	if (silo)
		silo.connected += src
		mat_container = silo.GetComponent(/datum/component/material_container)
	else
		_MakeLocal()

/datum/component/remote_materials/Destroy()
	if (silo)
		silo.connected -= src
		silo.updateUsrDialog()
		set_silo(null)
		mat_container = null
	else if (mat_container)
		// specify explicitly in case the other component is deleted first
		var/atom/P = parent
		mat_container.retrieve_all(P.drop_location())
	return ..()

/datum/component/remote_materials/proc/_MakeLocal()
	set_silo(null)

	var/static/list/allowed_mats = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/copper,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
		/datum/material/plastic,
		)

	mat_container = parent.AddComponent(/datum/component/material_container, allowed_mats, local_size, allowed_types=/obj/item/stack)

/datum/component/remote_materials/proc/set_local_size(size)
	local_size = size
	if (!silo && mat_container)
		mat_container.max_amount = size

// called if disconnected by ore silo UI, or destruction
/datum/component/remote_materials/proc/disconnect_from(obj/machinery/ore_silo/old_silo)
	if (!old_silo || silo != old_silo)
		return
	set_silo(null)
	mat_container = null
	if (allow_standalone)
		_MakeLocal()
	SEND_SIGNAL(parent, COMSIG_REMOTE_MATERIALS_CHANGED)
	return TRUE

/datum/component/remote_materials/proc/is_valid_link(atom/targeta, atom/targetb = silo)
	return ((is_station_level(targeta.z) && is_station_level(targetb.z)) || (targeta.get_virtual_z_level() == targetb.get_virtual_z_level()))


/datum/component/remote_materials/proc/check_z_disconnect()
	SIGNAL_HANDLER
	if(!silo) //No silo?
		return
	var/atom/P = parent
	if(!is_valid_link(P))
		graceful_disconnect()

// like disconnect_from, but does proper cleanup instead of simple deletion.
/datum/component/remote_materials/proc/graceful_disconnect()
	var/obj/machinery/ore_silo/old_silo = silo
	if(!disconnect_from(old_silo))
		return
	old_silo.connected -= src
	old_silo.updateUsrDialog()
	var/atom/P = parent
	P.visible_message("<span class='warning'>[parent]'s material manager blinks orange: Disconnected.</span>")

/datum/component/remote_materials/proc/OnAttackBy(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER

	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!I.multitool_check_buffer(user, I))
			return COMPONENT_NO_AFTERATTACK
		var/obj/item/multitool/M = I
		if (!QDELETED(M.buffer) && istype(M.buffer, /obj/machinery/ore_silo))
			var/atom/P = parent
			if (!is_valid_link(P, M.buffer))
				to_chat(usr, "<span class='warning'>[parent]'s material manager blinks red: Out of Range.</span>")
				return COMPONENT_NO_AFTERATTACK
			if (silo == M.buffer)
				to_chat(user, "<span class='notice'>[parent] is already connected to [silo].</span>")
				return COMPONENT_NO_AFTERATTACK
			if (silo)
				silo.connected -= src
				silo.updateUsrDialog()
			else if (mat_container)
				mat_container.retrieve_all()
				qdel(mat_container)
			set_silo(M.buffer)
			silo.connected += src
			silo.updateUsrDialog()
			mat_container = silo.GetComponent(/datum/component/material_container)
			to_chat(user, "<span class='notice'>You connect [parent] to [silo] from the multitool's buffer.</span>")
			SEND_SIGNAL(parent, COMSIG_REMOTE_MATERIALS_CHANGED)
			return COMPONENT_NO_AFTERATTACK

	else if (silo && istype(I, /obj/item/stack))
		if (silo.remote_attackby(parent, user, I))
			return COMPONENT_NO_AFTERATTACK

/datum/component/remote_materials/proc/on_hold()
	return silo && silo.holds["[get_area(parent)]/[category]"]

/datum/component/remote_materials/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats)
	if (silo)
		silo.silo_log(M || parent, action, amount, noun, mats)

/datum/component/remote_materials/proc/format_amount()
	if (mat_container)
		return "[mat_container.total_amount] / [mat_container.max_amount == INFINITY ? "Unlimited" : mat_container.max_amount] ([silo ? "remote" : "local"])"
	else
		return "0 / 0"

/// Ejects the given material ref and logs it, or says out loud the problem.
/datum/component/remote_materials/proc/eject_sheets(datum/material/material_ref, eject_amount)
	var/atom/movable/movable_parent = parent
	if (!istype(movable_parent))
		return 0

	if (!mat_container)
		movable_parent.say("No access to material storage, please contact the quartermaster.")
		return 0
	if (on_hold())
		movable_parent.say("Mineral access is on hold, please contact the quartermaster.")
		return 0
	var/count = mat_container.retrieve_sheets(eject_amount, material_ref, movable_parent.drop_location())
	var/list/matlist = list()
	matlist[material_ref] = eject_amount
	silo_log(parent, "ejected", -count, "sheets", matlist)
	return count

/datum/component/remote_materials/proc/set_silo(obj/machinery/ore_silo/new_silo)
	if(silo)
		UnregisterSignal(silo, COMSIG_MATERIAL_CONTAINER_CHANGED)

	silo = new_silo

	if(!QDELETED(silo))
		RegisterSignal(silo, COMSIG_MATERIAL_CONTAINER_CHANGED, PROC_REF(propagate_signal))

/datum/component/remote_materials/proc/propagate_signal()
	SIGNAL_HANDLER
	SEND_SIGNAL(parent, COMSIG_REMOTE_MATERIALS_CHANGED)
