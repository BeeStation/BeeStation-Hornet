/datum/job/chief_engineer
	title = JOB_NAME_CHIEFENGINEER
	flag = CHIEF
	description = "Oversee the engineers and atmospheric technicians, keep a watchful eye on the station's engine, gravity generator, and telecomms. Send your staff to repair hull breaches and damaged equipment as necessary."
	department_for_prefs = DEPT_BITFLAG_ENG
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list(JOB_NAME_CAPTAIN)
	supervisors = "the captain"
	head_announce = list("Engineering")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 1200
	exp_type = EXP_TYPE_ENGINEERING
	exp_type_department = EXP_TYPE_ENGINEERING

	outfit = /datum/outfit/job/chief_engineer

	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EVA, ACCESS_AUX_BASE,
			            ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS, ACCESS_MINISAT, ACCESS_MECH_ENGINE,
			            ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EVA, ACCESS_AUX_BASE,
			            ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS, ACCESS_MINISAT, ACCESS_MECH_ENGINE,
			            ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM, ACCESS_WEAPONS)

	department_flag = ENGSEC
	departments = DEPT_BITFLAG_ENG | DEPT_BITFLAG_COM
	bank_account_department = ACCOUNT_ENG_BITFLAG | ACCOUNT_COM_BITFLAG
	payment_per_department = list(
		ACCOUNT_COM_ID = PAYCHECK_COMMAND_NT,
		ACCOUNT_ENG_ID = PAYCHECK_COMMAND_DEPT)


	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	rpg_title = "High Crystallomancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/chief_engineer
	)

	minimal_lightup_areas = list(/area/crew_quarters/heads/chief, /area/engine/atmos)

/datum/outfit/job/chief_engineer
	name = JOB_NAME_CHIEFENGINEER
	jobtype = /datum/job/chief_engineer

	id = /obj/item/card/id/job/chief_engineer
	belt = /obj/item/storage/belt/utility/chief/full
	l_pocket = /obj/item/modular_computer/tablet/pda/heads/chief_engineer
	ears = /obj/item/radio/headset/heads/chief_engineer
	uniform = /obj/item/clothing/under/rank/engineering/chief_engineer
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hardhat/white
	gloves = /obj/item/clothing/gloves/color/black
	backpack_contents = list(/obj/item/melee/classic_baton/police/telescopic=1)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET
	chameleon_extras = /obj/item/stamp/chief_engineer

/datum/outfit/job/chief_engineer/rig
	name = "Chief Engineer (Hardsuit)"

	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/engine/elite
	shoes = /obj/item/clothing/shoes/magboots/advance
	suit_store = /obj/item/tank/internals/oxygen
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/color/yellow
	head = null
	internals_slot = ITEM_SLOT_SUITSTORE
