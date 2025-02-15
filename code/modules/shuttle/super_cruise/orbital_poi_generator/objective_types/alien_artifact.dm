/datum/orbital_objective/artifact
	name = "Artifact Recovery"
	var/datum/weakref/weakref_artifact
	min_payout = 5000
	max_payout = 25000

/datum/orbital_objective/artifact/generate_objective_stuff(turf/chosen_turf)
	var/obj/item/xenoartifact/objective/linked_artifact = new(chosen_turf)
	weakref_artifact = WEAKREF(linked_artifact)

	var/list/turfs = RANGE_TURFS(30, linked_artifact)
	var/list/valid_turfs = list()
	for(var/turf/open/floor/F in turfs)
		if(locate(/obj/structure) in F)
			continue
		valid_turfs += F
	//Shuffle the list
	shuffle_inplace(valid_turfs)
	for(var/i in 1 to rand(4, 10))
		if(i > valid_turfs.len)
			message_admins("Ran out of valid turfs to create artifact defenses on.")
			return
		var/turf/selected_turf = valid_turfs[i]
		new /obj/structure/alien_artifact/watcher(selected_turf)

/datum/orbital_objective/artifact/get_text()
	. = "Outpost [station_name] is a research outpost with an extremely powerful alien artifact on board. \
		Recover the unknown artifact for a payout of [payout] credits."
	if(linked_beacon)
		. += " The station is located at the beacon marked [linked_beacon.name]. Good luck."

/datum/orbital_objective/artifact/check_failed()
	if(!weakref_artifact) // It looks fail-check is executed before we fully initialise the explo mission.
		return FALSE
	var/obj/item/xenoartifact/objective/linked_artifact = weakref_artifact.resolve()
	if(QDELETED(linked_artifact)) // failed to resolve or qdeleted means it never success
		return TRUE
	if(!(linked_artifact?.flags_1 & INITIALIZED_1)) // We checked this too early.
		return FALSE
	if(!is_station_level(linked_artifact.z)) // It's not a real failure. Let's wait...
		return FALSE

	complete_objective()
	return FALSE
