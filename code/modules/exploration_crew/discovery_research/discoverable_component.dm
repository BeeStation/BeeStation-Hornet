/datum/component/discoverable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	//Amount of discovery points awarded when researched.
	var/scanned = FALSE
	var/unique = FALSE
	var/point_reward = 0
	var/datum/callback/get_discover_id

/datum/component/discoverable/Initialize(point_reward, unique = FALSE, get_discover_id)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_CLICK, PROC_REF(tryScan))

	src.point_reward = point_reward
	src.unique = unique
	src.get_discover_id = get_discover_id

/datum/component/discoverable/proc/tryScan(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	var/mob/living/L = user
	if(istype(L.get_active_held_item(), /obj/item/discovery_scanner))
		INVOKE_ASYNC(L.get_active_held_item(), TYPE_PROC_REF(/obj/item/discovery_scanner, begin_scanning), user, src)

/datum/component/discoverable/proc/examine(datum/source, mob/user, atom/thing)
	SIGNAL_HANDLER
	if(!user.research_scanner)
		return
	to_chat(user, "<span class='notice'>Scientific data detected.</span>")
	to_chat(user, "<span class='notice'>Scanned: [scanned ? "True" : "False"].</span>")
	to_chat(user, "<span class='notice'>Discovery Value: [point_reward].</span>")

/datum/component/discoverable/proc/discovery_scan(datum/techweb/linked_techweb, mob/user)
	//Already scanned our atom.
	var/atom/A = parent
	if(scanned)
		to_chat(user, "<span class='warning'>[A] has already been analysed.</span>")
		return
	//Already scanned another of this type.
	var/discover_id = get_discover_id?.Invoke() || A.type
	if(linked_techweb.scanned_atoms[discover_id] && !unique)
		to_chat(user, "<span class='warning'>Datapoints about [A] already in system.</span>")
		return
	if(A.flags_1 & HOLOGRAM_1)
		to_chat(user, "<span class='warning'>[A] is holographic, no datapoints can be extracted.</span>")
		return
	scanned = TRUE
	linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, point_reward)
	linked_techweb.scanned_atoms[discover_id] = TRUE
	playsound(user, 'sound/machines/terminal_success.ogg', 60)
	to_chat(user, "<span class='notice'>New datapoint scanned, [point_reward] discovery points gained.</span>")
	pulse_effect(get_turf(A), 4)
