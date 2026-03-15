/obj/effect/landmark
	name = "landmark"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	layer = TURF_LAYER
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/landmark/singularity_act()
	return

/obj/effect/landmark/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

INITIALIZE_IMMEDIATE(/obj/effect/landmark)

/obj/effect/landmark/Initialize(mapload)
	. = ..()
	GLOB.landmarks_list += src

/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER
	var/jobspawn_override = FALSE
	var/delete_after_roundstart = TRUE
	var/used = FALSE

/obj/effect/landmark/start/proc/after_round_start()
	if(delete_after_roundstart)
		qdel(src)

/obj/effect/landmark/start/Initialize(mapload)
	. = ..()
	GLOB.start_landmarks_list += src
	if(jobspawn_override)
		LAZYADDASSOCLIST(GLOB.jobspawn_overrides, name, src)
	if(name != "start")
		tag = "start*[name]"

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	if(jobspawn_override)
		LAZYREMOVEASSOC(GLOB.jobspawn_overrides, name, src)
	return ..()

// START LANDMARKS FOLLOW. Don't change the names unless
// you are refactoring shitty landmark code.
/obj/effect/landmark/start/assistant
	name = "Assistant"
	icon_state = "Assistant"

/obj/effect/landmark/start/assistant/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/janitor
	name = "Janitor"
	icon_state = "Janitor"

/obj/effect/landmark/start/prisoner
	name = "Prisoner"
	icon_state = "prisoner"
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/cargo_technician
	name = "Cargo Technician"
	icon_state = "Cargo Technician"

/obj/effect/landmark/start/bartender
	name = "Bartender"
	icon_state = "Bartender"

/obj/effect/landmark/start/clown
	name = "Clown"
	icon_state = "Clown"

/obj/effect/landmark/start/mime
	name = "Mime"
	icon_state = "Mime"

/obj/effect/landmark/start/quartermaster
	name = "Quartermaster"
	icon_state = "Quartermaster"

/obj/effect/landmark/start/atmospheric_technician
	name = "Atmospheric Technician"
	icon_state = "Atmospheric Technician"

/obj/effect/landmark/start/cook
	name = "Cook"
	icon_state = "Cook"

/obj/effect/landmark/start/shaft_miner
	name = "Shaft Miner"
	icon_state = "Shaft Miner"

/obj/effect/landmark/start/exploration
	name = "Exploration Crew"
	icon_state = "Exploration Crew"

/obj/effect/landmark/start/security_officer
	name = "Security Officer"
	icon_state = "Security Officer"

/obj/effect/landmark/start/botanist
	name = "Botanist"
	icon_state = "Botanist"

/obj/effect/landmark/start/head_of_security
	name = "Head of Security"
	icon_state = "Head of Security"

/obj/effect/landmark/start/captain
	name = "Captain"
	icon_state = "Captain"

/obj/effect/landmark/start/detective
	name = "Detective"
	icon_state = "Detective"

/obj/effect/landmark/start/warden
	name = "Warden"
	icon_state = "Warden"

/obj/effect/landmark/start/chief_engineer
	name = "Chief Engineer"
	icon_state = "Chief Engineer"

/obj/effect/landmark/start/head_of_personnel
	name = "Head of Personnel"
	icon_state = "Head of Personnel"

/obj/effect/landmark/start/librarian
	name = "Curator"
	icon_state = "Curator"

/obj/effect/landmark/start/lawyer
	name = "Lawyer"
	icon_state = "Lawyer"

/obj/effect/landmark/start/station_engineer
	name = "Station Engineer"
	icon_state = "Station Engineer"

/obj/effect/landmark/start/medical_doctor
	name = "Medical Doctor"
	icon_state = "Medical Doctor"

/obj/effect/landmark/start/paramedic
	name = "Paramedic"
	icon_state = "Medical Doctor"

/obj/effect/landmark/start/scientist
	name = "Scientist"
	icon_state = "Scientist"

/obj/effect/landmark/start/chemist
	name = "Chemist"
	icon_state = "Chemist"

/obj/effect/landmark/start/roboticist
	name = "Roboticist"
	icon_state = "Roboticist"

/obj/effect/landmark/start/research_director
	name = "Research Director"
	icon_state = "Research Director"

/obj/effect/landmark/start/geneticist
	name = "Geneticist"
	icon_state = "Geneticist"

/obj/effect/landmark/start/chief_medical_officer
	name = "Chief Medical Officer"
	icon_state = "Chief Medical Officer"

/obj/effect/landmark/start/virologist
	name = "Virologist"
	icon_state = "Virologist"

/obj/effect/landmark/start/chaplain
	name = "Chaplain"
	icon_state = "Chaplain"

/obj/effect/landmark/start/cyborg
	name = "Cyborg"
	icon_state = "Cyborg"

/obj/effect/landmark/start/ai
	name = "AI"
	icon_state = "AI"
	delete_after_roundstart = FALSE
	var/primary_ai = TRUE
	var/latejoin_active = TRUE

/obj/effect/landmark/start/ai/after_round_start()
	if(latejoin_active && !used)
		new /obj/structure/AIcore/latejoin_inactive(loc)
	return ..()

/obj/effect/landmark/start/ai/secondary
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "ai_spawn"
	primary_ai = FALSE
	latejoin_active = FALSE

/obj/effect/landmark/start/brig_physician
	name = "Brig Physician"

/obj/effect/landmark/start/randommaint
	name = "maintjobstart"
	icon_state = "x3"
	var/job = "Gimmick" //put the title of the job here.

/obj/effect/landmark/start/randommaint/New() //automatically opens up a job slot when the job's spawner loads in
	..()
	var/datum/job/J = SSjob.GetJob(job)
	J.total_positions += 1
	SSjob.job_manager_blacklisted -= J.title

/obj/effect/landmark/start/randommaint/backalley_doc
	name = "Barber"
	job = "Barber"

/obj/effect/landmark/start/randommaint/magician
	name = "Stage Magician"
	job = "Stage Magician"

/obj/effect/landmark/start/randommaint/psychiatrist
	name = "Psychiatrist"
	job = "Psychiatrist"

/obj/effect/landmark/start/randommaint/vip
	name = "VIP"
	job = "VIP"

/obj/effect/landmark/start/randommaint/experiment
	name = "Experiment"
	job = "Experiment"

/obj/effect/landmark/start/randommaint/virologist
	name = "Virologist"
	icon_state = "Virologist"
	job= "Virologist"

//Department Security spawns

/obj/effect/landmark/start/depsec
	name = "department_sec"
	icon_state = "Security Officer"

/obj/effect/landmark/start/depsec/Initialize(mapload)
	. = ..()
	GLOB.department_security_spawns += src

/obj/effect/landmark/start/depsec/Destroy()
	GLOB.department_security_spawns -= src
	return ..()

/obj/effect/landmark/start/depsec/supply
	name = "supply_sec"

/obj/effect/landmark/start/depsec/medical
	name = "medical_sec"

/obj/effect/landmark/start/depsec/engineering
	name = "engineering_sec"

/obj/effect/landmark/start/depsec/science
	name = "science_sec"

//Antagonist spawns

/obj/effect/landmark/start/wizard
	name = "wizard"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "wiznerd_spawn"

/obj/effect/landmark/start/wizard/Initialize(mapload)
	..()
	GLOB.wizardstart += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop
	name = "nukeop"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_spawn"

/obj/effect/landmark/start/nukeop/Initialize(mapload)
	..()
	GLOB.nukeop_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop_leader
	name = "nukeop leader"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_leader_spawn"

/obj/effect/landmark/start/nukeop_leader/Initialize(mapload)
	..()
	GLOB.nukeop_leader_start += loc
	return INITIALIZE_HINT_QDEL

// Must be immediate because players will
// join before SSatom initializes everything.
INITIALIZE_IMMEDIATE(/obj/effect/landmark/start/new_player)

/obj/effect/landmark/start/new_player
	name = "New Player"

/obj/effect/landmark/start/new_player/Initialize(mapload)
	..()
	if (SStitle.newplayer_start_loc)
		forceMove(SStitle.newplayer_start_loc)
	GLOB.newplayer_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/latejoin
	name = "JoinLate"

/obj/effect/landmark/latejoin/Initialize(mapload)
	..()
	SSjob.latejoin_trackers += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/prisonspawn
	name = "prisonspawn"
	icon_state = "error"
	/* Milviu's sin
	icon_state = "prison_spawn"
	*/

/obj/effect/landmark/prisonspawn/Initialize(mapload)
	..()
	GLOB.prisonspawn += loc
	return INITIALIZE_HINT_QDEL

//space carps, magicarps, lone ops, slaughter demons, possibly revenants spawn here
/obj/effect/landmark/carpspawn
	name = "carpspawn"
	icon_state = "carp_spawn"

/obj/effect/landmark/loneops
	name = "lone ops"
	icon_state = "lone_ops"

//observer start
/obj/effect/landmark/observer_start
	name = "Observer-Start"
	icon_state = "observer_start"

//xenos, morphs and nightmares spawn here
/obj/effect/landmark/xeno_spawn
	name = "xeno_spawn"
	icon_state = "xeno_spawn"

/obj/effect/landmark/xeno_spawn/Initialize(mapload)
	..()
	GLOB.xeno_spawn += loc
	return INITIALIZE_HINT_QDEL

//objects with the stationloving component (nuke disk) respawn here.
//also blobs that have their spawn forcemoved (running out of time when picking their spawn spot), santa and respawning devils
/obj/effect/landmark/blobstart
	name = "blobstart"
	icon_state = "blob_start"

/obj/effect/landmark/blobstart/Initialize(mapload)
	..()
	GLOB.blobstart += loc
	return INITIALIZE_HINT_QDEL

//spawns sec equipment lockers depending on the number of sec officers
/obj/effect/landmark/secequipment
	name = "secequipment"
	icon_state = "secequipment"

/obj/effect/landmark/secequipment/Initialize(mapload)
	..()
	GLOB.secequipment += loc
	return INITIALIZE_HINT_QDEL

//players that get put in admin jail show up here
/obj/effect/landmark/prisonwarp
	name = "prisonwarp"
	icon_state = "prisonwarp"

/obj/effect/landmark/prisonwarp/Initialize(mapload)
	..()
	GLOB.prisonwarp += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/ert_spawn
	name = "Emergencyresponseteam"
	icon_state = "ert_spawn"

/obj/effect/landmark/ert_spawn/Initialize(mapload)
	..()
	GLOB.emergencyresponseteamspawn += loc
	return INITIALIZE_HINT_QDEL

//ninja energy nets teleport victims here
/obj/effect/landmark/holding_facility
	name = "Holding Facility"
	icon_state = "holding_facility"

/obj/effect/landmark/holding_facility/Initialize(mapload)
	..()
	GLOB.holdingfacility += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/observe
	name = "tdomeobserve"
	icon_state = "tdome_observer"

/obj/effect/landmark/thunderdome/observe/Initialize(mapload)
	..()
	GLOB.tdomeobserve += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/one
	name = "tdome1"
	icon_state = "tdome_t1"

/obj/effect/landmark/thunderdome/one/Initialize(mapload)
	..()
	GLOB.tdome1	+= loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/two
	name = "tdome2"
	icon_state = "tdome_t2"

/obj/effect/landmark/thunderdome/two/Initialize(mapload)
	..()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/admin
	name = "tdomeadmin"
	icon_state = "tdome_admin"

/obj/effect/landmark/thunderdome/admin/Initialize(mapload)
	..()
	GLOB.tdomeadmin += loc
	return INITIALIZE_HINT_QDEL

//Servant spawn locations
/obj/effect/landmark/servant_of_ratvar
	name = "servant of ratvar spawn"
	icon_state = "clockwork_orange"
	layer = MOB_LAYER

/obj/effect/landmark/servant_of_ratvar/Initialize(mapload)
	..()
	GLOB.servant_spawns += loc
	return INITIALIZE_HINT_QDEL

//City of Cogs entrances
/obj/effect/landmark/city_of_cogs
	name = "city of cogs entrance"
	icon_state = "city_of_cogs"

/obj/effect/landmark/city_of_cogs/Initialize(mapload)
	..()
	GLOB.city_of_cogs_spawns += loc
	return INITIALIZE_HINT_QDEL

//handles clockwork portal+eminence teleport destinations
/obj/effect/landmark/event_spawn
	name = "generic event spawn"
	icon_state = "generic_event"
	layer = OBJ_LAYER


/obj/effect/landmark/event_spawn/Initialize(mapload)
	. = ..()
	GLOB.generic_event_spawns += src

/obj/effect/landmark/event_spawn/Destroy()
	GLOB.generic_event_spawns -= src
	return ..()

/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/landmark/ruin)

/obj/effect/landmark/ruin/Initialize(mapload, my_ruin_template)
	. = ..()
	name = "ruin_[GLOB.ruin_landmarks.len + 1]"
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	. = ..()

/// Marks the bottom left of the testing zone.
/// In landmarks.dm and not unit_test.dm so it is always active in the mapping tools.
/obj/effect/landmark/unit_test_bottom_left
	name = "unit test zone bottom left"

/// Marks the top right of the testing zone.
/// In landmarks.dm and not unit_test.dm so it is always active in the mapping tools.
/obj/effect/landmark/unit_test_top_right
	name = "unit test zone top right"

/obj/effect/spawner/hangover_spawn
	name = "hangover spawner"

	/// A list of everything this hangover spawn created as part of the hangover station trait
	var/list/hangover_debris = list()

	/// A list of everything this hangover spawn created as part of the birthday station trait
	var/list/party_debris = list()

/obj/effect/spawner/hangover_spawn/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/hangover_spawn/LateInitialize()
	. = ..()
	// Birthday
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BIRTHDAY))
		party_debris += new /obj/effect/decal/cleanable/confetti(get_turf(src))
		var/list/bonus_confetti = GLOB.alldirs
		for(var/confettis in bonus_confetti)
			var/party_turf_to_spawn_on = get_step(src, confettis)
			if(!isopenturf(party_turf_to_spawn_on))
				continue
			var/dense_object = FALSE
			for(var/atom/content in party_turf_to_spawn_on)
				if(content.density)
					dense_object = TRUE
					break
			if(dense_object)
				continue
			if(prob(50))
				party_debris += new /obj/effect/decal/cleanable/confetti(party_turf_to_spawn_on)
			if(prob(10))
				party_debris += new /obj/item/toy/balloon(party_turf_to_spawn_on)
	// Hangover
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_HANGOVER))
		if(prob(60))
			hangover_debris += new /obj/effect/decal/cleanable/vomit(get_turf(src))
		if(prob(70))
			var/bottle_count = rand(1, 3)
			for(var/index in 1 to bottle_count)
				var/turf/turf_to_spawn_on = get_step(src, pick(GLOB.alldirs))
				if(!isopenturf(turf_to_spawn_on))
					continue
				var/dense_object = FALSE
				for(var/atom/content in turf_to_spawn_on.contents)
					if(content.density)
						dense_object = TRUE
						break
				if(dense_object)
					continue
				hangover_debris += new /obj/item/reagent_containers/cup/glass/bottle/beer/almost_empty(turf_to_spawn_on)

	qdel(src)

/obj/effect/spawner/hangover_spawn/Destroy()
	hangover_debris = null
	party_debris = null
	return ..()

//Landmark that creates destinations for the navigate verb to path to
/obj/effect/landmark/navigate_destination
	name = "navigate verb destination"
	icon_state = "navigate"
	layer = OBJ_LAYER

	/// navigation_id automatically sets to its area name (Bridge, Hydroponics, etc)
	/// If you want to use a dedicated name for a specific area, set this value in DMM.
	/// example) navigation_id = "Bartender's storage"
	var/navigation_id

	// Note: if multiple area needs a standard name, use "navigation_area_name"

/obj/effect/landmark/navigate_destination/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/navigate_destination/LateInitialize()
	. = ..()

	if(!navigation_id)
		var/area/linked_area = get_area(loc)
		if(!isarea(linked_area))
			stack_trace("The navigation landmark failed to get an area.")
			qdel(src)
			return
		navigation_id = linked_area.get_navigation_area_name()
	if(!navigation_id)
		navigation_id = "Unnamed area"

	var/fail_assoc_count
	var/actual_key = navigation_id
	while(GLOB.navigate_destinations[actual_key])
		actual_key = "[navigation_id] ([++fail_assoc_count])"
	GLOB.navigate_destinations[actual_key] = src

/// Checks if this destination is available to a user.
/obj/effect/landmark/navigate_destination/proc/is_available_to_user(mob/user)
	if(!isatom(src) || !compare_z_with(user) || get_dist(get_turf(src), user) > MAX_NAVIGATE_RANGE)
		return FALSE
	return TRUE

/// Checks if each z of this destination and a user.
/// * FALSE: target destination doesn't exist, or z-groups are different (i.e. Station to Lavaland)
/// * 1: very exactly same z
/// * 16 (UP): target destination is above the user
/// * 32 (DOWN): target destination is below the user
/obj/effect/landmark/navigate_destination/proc/compare_z_with(mob/user)
	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return FALSE

	var/target_z = src.get_virtual_z_level()
	var/user_z = user.get_virtual_z_level()
	if(!compare_z(target_z, user_z)) // gets null or FALSE: z-level groups are different
		return FALSE

	if(target_z == user_z)
		return 1 // same z
	return target_z > user_z ? UP : DOWN // returns direction from user to target


/obj/effect/landmark/navigate_destination/Destroy()
	. = ..()
	GLOB.navigate_destinations -= navigation_id
