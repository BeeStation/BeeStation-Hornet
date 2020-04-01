/datum/job/cadet
	title = "Cadet"
	flag = CADET
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4 //Kept in for posterity
	spawn_positions = 4 //ditto
	supervisors = "the head of security, and the head of your assigned department"
	selection_color = "#ffeeee"
	minimal_player_age = 1
	exp_requirements = 420
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/cadet

	access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_SEC_DOORS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_OFFICER

/datum/outfit/job/cadet
	name = "Cadet"
	jobtype = /datum/job/cadet

	head = /obj/item/clothing/head/beret/sec/cadet
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/mallcop
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/security/full
	l_pocket = /obj/item/pda/security
    backpack_contents = list(/obj/item/melee/baton/loaded=1)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival

	implants = list(/obj/item/implant/mindshield)


/datum/job/cadet/get_access()
	var/list/L = list()
	L |= ..()
	return L

GLOBAL_LIST_INIT(available_cadet_depts, list(SEC_DEPT_ENGINEERING, SEC_DEPT_MEDICAL, SEC_DEPT_SCIENCE, SEC_DEPT_SUPPLY))

/datum/job/dcadet/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	// Assign dept
	var/department
	if(M && M.client && M.client.prefs)
		department = M.client.prefs.prefered_security_department
		if(!LAZYLEN(GLOB.available_cadet_depts)) //shouldn't ever get called, unless the HoP/admins bump the numbers up: 4 depts, 4 cadets
			return
		else if(department in GLOB.available_cadet_depts)
			LAZYREMOVE(GLOB.available_cadet_depts, department)
		else
			department = pick_n_take(GLOB.available_cadet_depts)
	var/ears = null
	var/head = null
	var/list/dep_access = null
	var/destination = null
	var/spawn_point = null
	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_sec/department/supply
			head = /obj/item/clothing/head/beret/sec/cadet/supply
            head_p = /obj/item/clothing/head/helmet/space/plasmaman/cargo
			dep_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION)
			destination = /area/security/checkpoint/supply
			spawn_point = locate(/obj/effect/landmark/start/depsec/supply) in GLOB.department_security_spawns
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_sec/department/engi
			head = /obj/item/clothing/head/beret/sec/cadet/engineering
            head_p = /obj/item/clothing/head/helmet/space/plasmaman/engineering
			dep_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS)
			destination = /area/security/checkpoint/engineering
            spawn_point = locate(/obj/effect/landmark/start/depsec/engineering) in GLOB.department_security_spawns
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_sec/department/med
			head = /obj/item/clothing/head/beret/sec/cadet/med
            head_p = /obj/item/clothing/head/helmet/space/plasmaman/medical
			dep_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_GENETICS)
			destination = /area/security/checkpoint/medical
			spawn_point = locate(/obj/effect/landmark/start/depsec/medical) in GLOB.department_security_spawns
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_sec/department/sci
			head = /obj/item/clothing/head/beret/sec/cadet/sci
            head_p = /obj/item/clothing/head/helmet/space/plasmaman/science
			dep_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MECH_SCIENCE)
			destination = /area/security/checkpoint/science
			spawn_point = locate(/obj/effect/landmark/start/depsec/science) in GLOB.department_security_spawns

	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H),SLOT_EARS)
	if(head)
        if(isplasmaman(H))
			head = head_p
		if(H.head)
			qdel(H.head)
		H.equip_to_slot_or_del(new head(H),SLOT_HEAD)

	var/obj/item/card/id/W = H.wear_id
	W.access |= dep_access

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




/obj/item/radio/headset/headset_sec/department/Initialize()
	. = ..()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = new
	recalculateChannels()

/obj/item/radio/headset/headset_sec/department/engi
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_sec/department/supply
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_sec/department/med
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sec/department/sci
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_sci