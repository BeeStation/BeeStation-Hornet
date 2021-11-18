/datum/orbital_objective/artifact
	name = "Artifact Recovery"
	var/generated = FALSE
	//The blackbox required to recover.
	var/obj/item/alienartifact/objective/linked_artifact
	min_payout = 50000
	max_payout = 200000

/datum/orbital_objective/artifact/generate_objective_stuff(turf/chosen_turf)
	generated = TRUE
	linked_artifact = new(chosen_turf)
	var/list/turfs = RANGE_TURFS(30, chosen_turf)
	var/list/valid_turfs = list()
	for(var/turf/open/floor/F in turfs)
		if(locate(/obj/structure) in F)
			continue
		valid_turfs += F
	//Shuffle the list
	shuffle_inplace(valid_turfs)
	for(var/i in rand(6, 15))
		if(valid_turfs.len < i)
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
	if(!generated)
		return FALSE
	if(is_station_level(linked_artifact.z))
		complete_objective()
		return FALSE
	if(!QDELETED(linked_artifact))
		return FALSE
	return TRUE
