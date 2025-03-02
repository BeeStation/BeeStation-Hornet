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
	to_chat(user, span_notice("Scientific data detected."))
	to_chat(user, span_notice("Scanned: [scanned ? "True" : "False"]."))
	to_chat(user, span_notice("Discovery Value: [point_reward]."))

/datum/component/discoverable/proc/discovery_scan(datum/techweb/linked_techweb, mob/user)
	//Already scanned our atom.
	var/atom/A = parent
	if(scanned)
		to_chat(user, span_warning("[A] has already been analysed."))
		return
	//Already scanned another of this type.
	var/discover_id = get_discover_id?.Invoke() || A.type
	if(linked_techweb.scanned_atoms[discover_id] && !unique)
		to_chat(user, span_warning("Datapoints about [A] already in system."))
		return
	if(A.flags_1 & HOLOGRAM_1)
		to_chat(user, span_warning("[A] is holographic, no datapoints can be extracted."))
		return
	scanned = TRUE
	linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, point_reward)
	linked_techweb.scanned_atoms[discover_id] = TRUE
	playsound(user, 'sound/machines/terminal_success.ogg', 60)
	to_chat(user, span_notice("New datapoint scanned, [point_reward] discovery points gained."))
	pulse_effect(get_turf(A), 4)

/*
	Equivilent for artifacts
	essentially looks at the artifact's traits
*/

/datum/component/discoverable/artifact

/datum/component/discoverable/artifact/discovery_scan(datum/techweb/linked_techweb, mob/user)
	//Already scanned our atom.
	var/atom/atom_parent = parent
	if(scanned)
		to_chat(user, "<span class='warning'>[atom_parent] has already been analysed.</span>")
		return
	//Is it *even* an artifact
	var/datum/component/xenoartifact/artifact_datum = atom_parent.GetComponent(/datum/component/xenoartifact)
	if(!artifact_datum)
		return
	//Loop through artfact traits
	var/total_payout = 0
	var/discovered_trait_count = 0
	for(var/trait in artifact_datum.traits_catagories)
		for(var/datum/xenoartifact_trait/trait_datum as anything in artifact_datum.traits_catagories[trait])
			//Already scanned another of this type.
			var/discover_id = get_discover_id?.Invoke() || trait_datum.type
			if(!unique && linked_techweb.scanned_atoms[discover_id])
				continue
			if(atom_parent.flags_1 & HOLOGRAM_1)
				continue
			total_payout += trait_datum.discovery_reward
			discovered_trait_count++
			linked_techweb.scanned_atoms[discover_id] = TRUE
	scanned = TRUE
	if(total_payout)
		linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, total_payout)
		playsound(user, 'sound/machines/terminal_success.ogg', 60)
		to_chat(user, "<span class='notice'>New datapoint scanned, [total_payout] discovery points gained.\n[discovered_trait_count] new traits discovered!</span>")
		pulse_effect(get_turf(atom_parent), 4)
	else
		playsound(user, 'sound/machines/uplinkerror.ogg', 60)
		to_chat(user, "<span class='warning'>No new traits detected in [atom_parent].</span>")
