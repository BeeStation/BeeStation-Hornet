/datum/job/security_officer
	title = JOB_NAME_SECURITYOFFICER
	description = "Follow Space Law, patrol the station, arrest criminals and bring them to the Brig."
	department_for_prefs = DEPT_NAME_SECURITY
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NAME_HEADOFSECURITY)
	supervisors = "the head of security, and the head of your assigned department (if applicable)"
	faction = "Station"
	dynamic_spawn_group = JOB_SPAWN_GROUP_DEPARTMENT
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 840
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/security_officer

	base_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_COURT, ACCESS_WEAPONS,
					ACCESS_MECH_SECURITY, ACCESS_MINERAL_STOREROOM) // See /datum/job/security_officer/get_access()
	// NOTE: ACCESS_MAINT_TUNNELS will be given by check_config_for_sec_maint() config

	/// These accesses will be given in after_spawn()
	var/list/dept_access_supply = list(ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_AUX_BASE)
	var/list/dept_access_medical = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING)
	var/list/dept_access_science = list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_AUX_BASE)
	var/list/dept_access_engineering = list(ACCESS_ENGINE, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_AUX_BASE)

	departments = DEPT_BITFLAG_SEC
	bank_account_department = ACCOUNT_SEC_BITFLAG
	payment_per_department = list(ACCOUNT_SEC_ID = PAYCHECK_HARD)
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM, TRAIT_SECURITY)

	display_order = JOB_DISPLAY_ORDER_SECURITY_OFFICER
	rpg_title = "Guard"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/security_officer
	)
	biohazard = 25 //clean your baton, man

	minimal_lightup_areas = list(/area/construction/mining/aux_base)

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

/datum/job/security_officer/after_spawn(mob/living/carbon/human/H, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	. = ..()
	// Assign department security
	var/department
	if(preference_source?.prefs)
		department = preference_source.prefs.read_character_preference(/datum/preference/choiced/security_department)
		if(!LAZYLEN(GLOB.available_depts) || department == "None")
			return
		if(!on_dummy && M.client) // The dummy should just use the preference always, and not remove departments.
			if(department in GLOB.available_depts)
				LAZYREMOVE(GLOB.available_depts, department)
			else
				department = pick_n_take(GLOB.available_depts)
	var/ears = null
	var/accessory = null
	var/list/dep_access = null
	var/destination = null
	var/spawn_point = null
	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_sec/alt/department/supply
			accessory = /obj/item/clothing/accessory/armband/cargo
			if(!on_dummy)
				dep_access = dept_access_supply
				destination = /area/security/checkpoint/supply
				spawn_point = locate(/obj/effect/landmark/start/depsec/supply) in GLOB.department_security_spawns
				minimal_lightup_areas |= GLOB.supply_lightup_areas
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_sec/alt/department/med
			accessory =  /obj/item/clothing/accessory/armband/medblue
			if(!on_dummy)
				dep_access = dept_access_medical
				destination = /area/security/checkpoint/medical
				spawn_point = locate(/obj/effect/landmark/start/depsec/medical) in GLOB.department_security_spawns
				minimal_lightup_areas |= GLOB.medical_lightup_areas
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_sec/alt/department/sci
			accessory = /obj/item/clothing/accessory/armband/science
			if(!on_dummy)
				dep_access = dept_access_science
				destination = /area/security/checkpoint/science
				spawn_point = locate(/obj/effect/landmark/start/depsec/science) in GLOB.department_security_spawns
				minimal_lightup_areas |= GLOB.science_lightup_areas
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_sec/alt/department/engi
			accessory = /obj/item/clothing/accessory/armband/engine
			if(!on_dummy)
				dep_access = dept_access_engineering
				destination = /area/security/checkpoint/engineering
				spawn_point = locate(/obj/effect/landmark/start/depsec/engineering) in GLOB.department_security_spawns
				minimal_lightup_areas |= GLOB.engineering_lightup_areas

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		U.attach_accessory(new accessory)
	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H),ITEM_SLOT_EARS)

	var/obj/item/card/id/W = H.wear_id
	W.access |= dep_access

	if(!M.client || on_dummy)
		return

	var/teleport = 0
	if(!CONFIG_GET(flag/sec_start_brig))
		if(destination || spawn_point)
			teleport = 1
	if(teleport)
		var/turf/T
		if(spawn_point)
			T = get_turf(spawn_point)
			H.Move(T)
		else
			var/safety = 0
			while(safety < 25)
				T = safepick(get_area_turfs(destination))
				if(T && !H.Move(T))
					safety += 1
					continue
				else
					break
	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")
	else
		to_chat(M, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")



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
	suit_store = /obj/item/gun/ballistic/automatic/pistol/security

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security

	backpack_contents = list(
		/obj/item/ammo_box/magazine/x200law = 1,
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
