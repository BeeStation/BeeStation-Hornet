/datum/round_event_control/zombie_outbreak
	name = "Zombie Outbreak"
	typepath = /datum/round_event/zombie_outbreak
	weight = 5
	max_occurrences = 1
	min_players = 30

/datum/round_event/zombie_outbreak
	fakeable = FALSE

/datum/round_event/zombie_outbreak/start()
	// The amount of infections among the crew depends on the amount of living, non-AFK, non-silicon players on the station
	var/list/living_crew = list()
	living_crew = get_living_station_crew()
	var/infection_count = round(length(living_crew) / 10)

	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(H.stat == DEAD)
			continue
		if(!SSjob.GetJob(H.mind.assigned_role) || (H.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_SILICON)))
			continue
		if(!H.get_organ_by_type(/obj/item/organ/brain))
			continue
		if(!(MOB_ORGANIC in H.mob_biotypes))
			continue
		if(!H.get_organ_slot(ORGAN_SLOT_ZOMBIE))
			var/obj/item/organ/zombie_infection/ZI = new()
			ZI.Insert(H)
		announce_to_ghosts(H)
		infection_count  --
		if (infection_count <= 0)
			break
