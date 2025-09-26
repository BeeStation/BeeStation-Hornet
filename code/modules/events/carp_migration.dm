/datum/round_event_control/carp_migration
	name = "Carp Migration"
	description = "Summons a school of space carp."
	category = EVENT_CATEGORY_ENTITIES
	typepath = /datum/round_event/carp_migration
	weight = 15
	min_players = 2
	earliest_start = 10 MINUTES
	max_occurrences = 6
	admin_setup = list(/datum/event_admin_setup/carp_migration)

/datum/round_event_control/carp_migration/New()
	. = ..()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		return
	weight *= 3
	max_occurrences *= 2
	earliest_start *= 0.5

/datum/round_event/carp_migration
	announce_when	= 3
	start_when = 50
	var/hasAnnounced = FALSE

/datum/round_event/carp_migration/setup()
	start_when = rand(40, 60)

/datum/round_event/carp_migration/announce(fake)
	priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert", SSstation.announcer.get_rand_alert_sound())


/datum/round_event/carp_migration/start()
	var/mob/living/simple_animal/hostile/carp/fish
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(prob(95))
			fish = new (C.loc)
		else
			fish = new /mob/living/simple_animal/hostile/carp/megacarp(C.loc)

			fishannounce(fish) //Prefer to announce the megacarps over the regular fishies
	fishannounce(fish)

/datum/round_event/carp_migration/proc/fishannounce(atom/fish)
	if (!hasAnnounced)
		announce_to_ghosts(fish) //Only anounce the first fish
		hasAnnounced = TRUE

/datum/event_admin_setup/carp_migration
	/// Admin set list of turfs for carp to travel to for each z level
	var/list/targets_per_z = list()

/datum/event_admin_setup/carp_migration/prompt_admins()
	targets_per_z = list()
	if (tgui_alert(usr, "Direct carp to your current location? Only applies to your current Z level.", "Carp Direction", list("Yes", "No")) != "Yes")
		return
	record_admin_location()
	while (tgui_alert(usr, "Add additional locations? Only applies to your current Z level.", "More Carp Direction", list("Yes", "No")) == "Yes")
		record_admin_location()

/// Stores the admin's current location corresponding to the z level of that location
/datum/event_admin_setup/carp_migration/proc/record_admin_location()
	var/turf/aimed_turf = get_turf(usr)
	var/z_level_key = "[aimed_turf.z]"
	if (!targets_per_z[z_level_key])
		targets_per_z[z_level_key] = list()
	targets_per_z[z_level_key] += WEAKREF(aimed_turf)

/datum/event_admin_setup/carp_migration/apply_to_event(datum/round_event/carp_migration/event)
	event.z_migration_paths = targets_per_z
