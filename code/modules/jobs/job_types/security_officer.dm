/datum/job/security_officer
	title = JOB_NAME_SECURITYOFFICER
	description = "Follow Space Law, patrol the station, arrest criminals and bring them to the Brig."
	department_for_prefs = DEPARTMENT_NAME_SECURITY
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NAME_HEADOFSECURITY)
	supervisors = "the head of security, and the head of your assigned department (if applicable)"
	faction = FACTION_STATION
	dynamic_spawn_group = JOB_SPAWN_GROUP_DEPARTMENT
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 840
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/security_officer

	base_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_COURT, ACCESS_WEAPONS,
					ACCESS_MECH_SECURITY, ACCESS_MINERAL_STOREROOM) // See /datum/job/security_officer/get_access()
	// NOTE: ACCESS_MAINT_TUNNELS will be given by check_config_for_sec_maint() config

	/// These accesses will be given in after_spawn()
	var/list/dept_access_supply = list(ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_AUX_BASE)
	var/list/dept_access_medical = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING)
	var/list/dept_access_science = list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_AUX_BASE)
	var/list/dept_access_engineering = list(ACCESS_ENGINE, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_AUX_BASE)

	departments_list = list(
		/datum/department_group/security,
		)
	bank_account_department = ACCOUNT_SEC_BITFLAG
	payment_per_department = list(ACCOUNT_SEC_ID = PAYCHECK_HARD)
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM, TRAIT_SECURITY)

	display_order = JOB_DISPLAY_ORDER_SECURITY_OFFICER

	job_flags = STATION_JOB_FLAGS
	rpg_title = "Guard"
	alternate_titles = list(
		JOB_SECURITY_OFFICER_MEDICAL,
		JOB_SECURITY_OFFICER_ENGINEERING,
		JOB_SECURITY_OFFICER_SUPPLY,
		JOB_SECURITY_OFFICER_SCIENCE,
	)

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/security_officer
	)
	biohazard = 25 //clean your baton, man

	minimal_lightup_areas = list(/area/station/construction/mining/aux_base)

	manuscript_jobs = list(
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_ASSISTANT // they're used to be troubles
	)

/datum/job/security_officer/get_access()
	. = ..()
	LOWPOP_GRANT_ACCESS(JOB_NAME_DETECTIVE, ACCESS_FORENSICS_LOCKERS)
	LOWPOP_GRANT_ACCESS(JOB_NAME_DETECTIVE, ACCESS_MORGUE)
	LOWPOP_GRANT_ACCESS(JOB_NAME_BRIGPHYSICIAN, ACCESS_BRIGPHYS)
	if(check_config_for_sec_maint())
		. |= ACCESS_MAINT_TUNNELS
	if (SSjob.initial_players_to_assign < LOWPOP_JOB_LIMIT)
		. |= ACCESS_MAINT_TUNNELS
	if (SSjob.is_job_empty(JOB_NAME_WARDEN) && SSjob.is_job_empty(JOB_NAME_HEADOFSECURITY) && SSjob.initial_players_to_assign < COMMAND_POPULATION_MINIMUM)
		. |= ACCESS_ARMORY

GLOBAL_LIST_INIT(available_depts, list(SEC_DEPT_ENGINEERING, SEC_DEPT_MEDICAL, SEC_DEPT_SCIENCE, SEC_DEPT_SUPPLY))

/**
 * The department distribution of the security officers.
 *
 * Keys are refs of the security officer mobs. This is to preserve the list's structure even if the
 * mob gets deleted. This is also safe, as mobs are guaranteed to have a unique ref, as per /mob/GenerateTag().
 */
GLOBAL_LIST_EMPTY(security_officer_distribution)


/datum/job/security_officer/after_roundstart_spawn(mob/living/spawning, client/player_client)
	. = ..()
	if(ishuman(spawning))
		setup_department(spawning, player_client)


/datum/job/security_officer/after_latejoin_spawn(mob/living/spawning)
	. = ..()
	if(ishuman(spawning))
		var/department = setup_department(spawning, spawning.client)
		if(department)
			announce_latejoin(spawning, department, GLOB.security_officer_distribution)

/// Returns the department this mob was assigned to, if any.
/datum/job/security_officer/proc/setup_department(mob/living/carbon/human/spawning, client/player_client)
	var/department = player_client?.prefs?.read_character_preference(/datum/preference/choiced/security_department)
	if(!isnull(department))
		if(!LAZYLEN(GLOB.available_depts) || department == SEC_DEPT_NONE)
			department = null
		else if(department in GLOB.available_depts)
			LAZYREMOVE(GLOB.available_depts, department)
		else
			department = pick_n_take(GLOB.available_depts)
		GLOB.security_officer_distribution[REF(spawning)] = department

	var/ears = null
	var/accessory = null
	var/list/dep_access = null
	var/destination = null
	var/spawn_point = null
	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_sec/alt/department/supply
			accessory = /obj/item/clothing/accessory/armband/cargo
			dep_access = dept_access_supply
			destination = /area/station/security/checkpoint/supply
			spawn_point = locate(/obj/effect/landmark/start/depsec/supply) in GLOB.department_security_spawns
			minimal_lightup_areas |= GLOB.supply_lightup_areas
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_sec/alt/department/med
			accessory = /obj/item/clothing/accessory/armband/medblue
			dep_access = dept_access_medical
			destination = /area/station/security/checkpoint/medical
			spawn_point = locate(/obj/effect/landmark/start/depsec/medical) in GLOB.department_security_spawns
			minimal_lightup_areas |= GLOB.medical_lightup_areas
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_sec/alt/department/sci
			accessory = /obj/item/clothing/accessory/armband/science
			dep_access = dept_access_science
			destination = /area/station/security/checkpoint/science
			spawn_point = locate(/obj/effect/landmark/start/depsec/science) in GLOB.department_security_spawns
			minimal_lightup_areas |= GLOB.science_lightup_areas
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_sec/alt/department/engi
			accessory = /obj/item/clothing/accessory/armband/engine
			dep_access = dept_access_engineering
			destination = /area/station/security/checkpoint/engineering
			spawn_point = locate(/obj/effect/landmark/start/depsec/engineering) in GLOB.department_security_spawns
			minimal_lightup_areas |= GLOB.engineering_lightup_areas

	if(accessory)
		var/obj/item/clothing/under/worn_under = spawning.w_uniform
		worn_under.attach_accessory(new accessory)

	if(ears)
		if(spawning.ears)
			qdel(spawning.ears)
		spawning.equip_to_slot_or_del(new ears(spawning), ITEM_SLOT_EARS)

	if(dep_access)
		var/obj/item/card/id/worn_id = spawning.wear_id
		worn_id.access |= dep_access

	if(!CONFIG_GET(flag/sec_start_brig) && (destination || spawn_point))
		if(spawn_point)
			spawning.Move(get_turf(spawn_point))
		else
			var/list/possible_turfs = get_area_turfs(destination)
			while(length(possible_turfs))
				var/random_index = rand(1, length(possible_turfs))
				var/turf/target = possible_turfs[random_index]
				if(spawning.Move(target))
					break
				possible_turfs.Cut(random_index, random_index + 1)

	if(player_client)
		if(department)
			to_chat(player_client, "<b>You have been assigned to [department]!</b>")
		else
			to_chat(player_client, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")

	return department

/datum/job/security_officer/proc/announce_latejoin(mob/officer, department, list/distribution)
	var/obj/machinery/announcement_system/announcement_system = pick(GLOB.announcement_systems)
	if(isnull(announcement_system))
		return

	announcement_system.announce_officer(officer, department)

	var/list/partners = list()
	for(var/officer_ref in distribution)
		var/mob/partner = locate(officer_ref)
		if(!istype(partner) || distribution[officer_ref] != department)
			continue
		partners += partner.real_name

	if(!partners.len)
		return

	var/list/targets = list()
	for(var/obj/item/modular_computer/tablet in GLOB.TabletMessengers)
		if(!(tablet.saved_identification in partners))
			continue
		targets += tablet

	if(!targets.len)
		return

	var/datum/signal/subspace/messaging/tablet_msg/signal = new(announcement_system, list(
		"name" = "Security Department Update",
		"job" = "Automated Announcement System",
		"message" = "Officer [officer.real_name] has been assigned to your department, [department].",
		"targets" = targets,
		"automated" = TRUE,
	))
	signal.send_to_receivers()



/datum/outfit/job/security_officer
	name = JOB_NAME_SECURITYOFFICER
	jobtype = /datum/job/security_officer

	id = /obj/item/card/id/job/security_officer
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/officer
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/sec
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/modular_computer/tablet/pda/preset/security
	r_pocket = /obj/item/clothing/accessory/badge
	accessory = /obj/item/clothing/accessory/security_pager

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security

	backpack_contents = list(
		/obj/item/mining_voucher/security = 1,
		/obj/item/ammo_casing/taser = 1,
		)

	implants = list(/obj/item/implant/mindshield)

	chameleon_extras = list(/obj/item/gun/energy/disabler, /obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/head/helmet)
	//The helmet is necessary because /obj/item/clothing/head/helmet/sec is overwritten in the chameleon list by the standard helmet, which has the same name and icon state

/datum/outfit/job/security/mod
	name = "Security Officer (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/job/security_officer/bulletproof
	name = "Security Officer (Bulletproof)"
	head = /obj/item/clothing/head/helmet/alt
	suit = /obj/item/clothing/suit/armor/bulletproof


/obj/item/radio/headset/headset_sec/alt/department/Initialize(mapload)
	. = ..()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = list()
	recalculateChannels()

/obj/item/radio/headset/headset_sec/alt/department/engi
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_sec/alt/department/supply
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_sec/alt/department/med
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sec/alt/department/sci
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_sci

/// Returns the distribution of splitting the given security officers into departments.
/// Return value is an assoc list of candidate => SEC_DEPT_*.
/proc/get_officer_departments(list/preferences, list/departments)
	if (!preferences.len)
		return list()

	/**
	 * This is a pretty complicated algorithm, but it's one I'm rather proud of.
	 *
	 * This is the function that is responsible for taking the list of preferences,
	 * and spitting out what to put them in.
	 *
	 * However, it should, wherever possible, prevent solo departments.
	 * That means that if there's one medical officer, and one engineering officer,
	 * that they should be put onto the same department (either medical or engineering).
	 *
	 * The first step is to get the "distribution". This describes how many officers
	 * should be in each department, no matter what they are.
	 * This is handled in `get_distribution`. Examples of inputs/outputs are:
	 * get_distribution(1, 4) => [1]
	 * get_distribution(2, 4) => [2]
	 * get_distribution(3, 4) => [3] # If this returned [2, 1], then we'd get a loner.
	 * get_distribution(4, 4) => [2, 2] # We have enough to put into a separate group
	 *
	 * Once this distribution is received, the next step is to figure out where to put everyone.
	 *
	 * If all members have no preference, just make one an unused department (from the departments argument).
	 * Then, call ourselves again.
	 *
	 * Order the groups from most populated to least.
	 *
	 * If the top group has enough officers who actually *want* that department, then we give it to them.
	 * If there are any leftovers (for example, if 3 officers want medical, but we only want 2), then we
	 * update those to have no preference instead.
	 *
	 * If the top group does NOT have enough officers, then we kill the least popular group by setting
	 * them all to have no preference.
	 *
	 * Anyone in the most popular group will be removed from the list, and the final tally will be updated.
	 * In the case of not having enough officers, this is a no-op, as there won't be any in the most popular group yet.
	 *
	 * If there are any candidates left, then we call the algorithm again, but for everyone who hasn't been selected yet.
	 * We take the results from that run, and put them in the correct order.
	 *
	 * As an example, let's assume we have the following preferences:
	 * [engineer, medical, medical, medical, medical, cargo]
	 *
	 * The distribution of this is [2, 2, 2], meaning there will be 3 departments chosen and they will have 2 each.
	 * We order from most popular to least popular and get:
	 * - medical: 4
	 * - engineer: 1
	 * - cargo: 1
	 *
	 * We need 2 to fill the first group. There are enough medical staff to do it. Thus, we take the first 2 medical staff
	 * and update the output, making it now: [engineer, medical, medical, ?, ?, cargo].
	 *
	 * The remaining two want-to-be-medical officers are now updated to act as no preference. We run the algorithm again.
	 * This time, are candidates are [engineer, none, none, cargo].
	 * The distribution of this is [2, 2]. The frequency is:
	 * - engineer: 1
	 * - cargo: 1
	 * - no preference: 2
	 *
	 * We need 2 to fill the engineering group, but only have one who wants to do it.
	 * We have enough no preferences for it, making our result: [engineer, engineer, none, cargo].
	 * We run the algorithm again, but this time with: [none, cargo].
	 * Frequency is:
	 * - cargo: 1
	 * - no preference: 1
	 * Enough to fill cargo, etc, and we get [cargo, cargo].
	 *
	 * These are all then compounded into one list.
	 *
	 * In the case that all are no preference, it will pop the last department, and use that.
	 * For example, if `departments` is [engi, medical, cargo], and we have the preferences:
	 * [none, none, none]...
	 * Then we will just give them all cargo.
	 *
	 * One of the most important parts of this algorithm is IT IS DETERMINISTIC.
	 * That means that this proc is 100% testable.
	 * Instead, to get random results, the preferences and departments are shuffled
	 * before the proc is ever called.
	*/

	preferences = preferences.Copy()
	departments = departments.Copy()

	var/distribution = get_distribution(preferences.len, departments.len)
	var/selection[preferences.len]

	var/list/grouped = list()
	var/list/biggest_group
	var/biggest_preference
	var/list/indices = list()

	for (var/index in 1 to preferences.len)
		indices += index

		var/preference = preferences[index]
		if (!(preference in grouped))
			grouped[preference] = list()
		grouped[preference] += index

		var/list/preferred_group = grouped[preference]

		if (preference != SEC_DEPT_NONE && (isnull(biggest_group) || biggest_group.len < preferred_group.len))
			biggest_group = grouped[preference]
			biggest_preference = preference

	if (isnull(biggest_group))
		preferences[1] = pop(departments)
		return get_officer_departments(preferences, departments)

	if (biggest_group.len >= distribution[1])
		for (var/index in 1 to distribution[1])
			selection[biggest_group[index]] = biggest_preference

		if (biggest_group.len > distribution[1])
			for (var/leftover in (distribution[1] + 1) to biggest_group.len)
				preferences[leftover] = SEC_DEPT_NONE
	else
		var/needed = distribution[1] - biggest_group.len
		if (LAZYLEN(LAZYACCESS(grouped, SEC_DEPT_NONE)) >= needed)
			for (var/candidate_index in biggest_group)
				selection[candidate_index] = biggest_preference

			for (var/index in 1 to needed)
				selection[grouped[SEC_DEPT_NONE][index]] = biggest_preference
		else
			var/least_popular_index = grouped[grouped.len]
			if (least_popular_index == SEC_DEPT_NONE)
				least_popular_index = grouped[grouped.len - 1]
			var/least_popular = grouped[least_popular_index]
			for (var/candidate_index in least_popular)
				preferences[candidate_index] = SEC_DEPT_NONE

	// Remove all members of the most popular candidate from the list
	for (var/chosen in 1 to selection.len)
		if (selection[chosen] == biggest_preference)
			indices -= chosen
			preferences[chosen] = null

	list_clear_nulls(preferences)

	departments -= biggest_preference

	if (grouped.len != 1)
		var/list/next_step = get_officer_departments(preferences, departments)
		for (var/index in 1 to indices.len)
			var/place = indices[index]
			selection[place] = next_step[index]

	return selection

/proc/get_distribution(candidates, departments)
	var/number_of_twos = min(departments, round(candidates / 2))
	var/redistribute = candidates - (2 * number_of_twos)

	var/distribution[max(1, number_of_twos)]

	for (var/index in 1 to number_of_twos)
		distribution[index] = 2

	for (var/index in 0 to redistribute - 1)
		distribution[(index % departments) + 1] += 1

	return distribution

/proc/get_new_officer_distribution_from_late_join(
	preference,
	list/departments,
	list/distribution,
)
	/**
	 * For late joiners, we're forced to put them in an alone department at some point.
	 *
	 * This is because reusing the round-start algorithm would force existing officers into
	 * a different department in order to preserve having partners at all times.
	 *
	 * This would mean retroactively updating their access as well, which is too much
	 * of a headache for me to want to bother.
	 *
	 * So, here's the method. If any department currently has 1 officer, they are forced into
	 * that.
	 *
	 * Otherwise, the department with the least officers in it is chosen.
	 * Preference takes priority, meaning that if both medical and engineering have zero officers,
	 * and the preference is medical, then medical is what will be chosen.
	 *
	 * Just like `get_officer_departments`, this function is deterministic.
	 * Randomness should instead be handled in the shuffling of the `departments` argument.
	 */
	var/list/amount_in_departments = list()

	for (var/department in departments)
		amount_in_departments[department] = 0

	for (var/officer in distribution)
		var/department = distribution[officer]
		if (!isnull(department))
			amount_in_departments[department] += 1

	var/list/lowest_departments = list(departments[1])
	var/lowest_amount = INFINITY

	for (var/department in amount_in_departments)
		var/amount = amount_in_departments[department]

		if (amount == 1)
			return department
		else if (lowest_amount > amount)
			lowest_departments = list(department)
			lowest_amount = amount
		else if (lowest_amount == amount)
			lowest_departments += department

	return (preference in lowest_departments) ? preference : lowest_departments[1]
