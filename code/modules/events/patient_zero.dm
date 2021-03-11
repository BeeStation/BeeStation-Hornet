/datum/round_event_control/patient_zero
	name = "Patient Zero"
	typepath = /datum/round_event/ghost_role/patient_zero
	weight = 5
	max_occurrences = 1
	min_players = 20
	earliest_start = 50 MINUTES

/datum/round_event/ghost_role/patient_zero
	announceWhen	= 500
	minimum_required = 1
	role_name = "patient zero"
	fakeable = TRUE

/datum/round_event/ghost_role/patient_zero/announce(fake)
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/ai/aliens.ogg')

/datum/round_event/ghost_role/patient_zero/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		spawn_locs += (C.loc)
	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	
	var/mob/living/carbon/human/patient = new(pick(spawn_locs))
	var/datum/mind/Mind = new /datum/mind(selected.key)
	Mind.assigned_role = "Patient Zero"
	Mind.special_role = "Patient Zero"
	Mind.active = TRUE
	Mind.transfer_to(patient)
	patient.set_species(/datum/species/zombie/infectious)
	patient.equipOutfit(/datum/outfit/pzero)
	patient.dna.update_dna_identity()
	
	patient.throw_at(SSmapping.get_station_center(), 2, 2)
	
	message_admins("[ADMIN_LOOKUPFLW(patient)] has been spawned as Romerol Zombie by an event.")
	spawned_mobs += patient
	return SUCCESSFUL_SPAWN
	
/datum/outfit/pzero
	name = "Patient Zero"
	uniform = /obj/item/clothing/under/rank/security/detective
	ears = /obj/item/radio/headset
	suit = /obj/item/clothing/suit/jacket/miljacket
