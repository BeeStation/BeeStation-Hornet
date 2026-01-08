/datum/job/station_engineer
	title = JOB_NAME_STATIONENGINEER
	description = "Ensure the station has an adequate power supply, repair and build new machinery, repair wiring chewed up by mice."
	department_for_prefs = DEPT_NAME_ENGINEERING
	department_head = list(JOB_NAME_CHIEFENGINEER)
	supervisors = "the chief engineer"
	faction = "Station"
	dynamic_spawn_group = JOB_SPAWN_GROUP_DEPARTMENT
	selection_color = "#fff5cc"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/engineer

	base_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
						ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)

	departments = DEPT_BITFLAG_ENG
	bank_account_department = ACCOUNT_ENG_BITFLAG
	payment_per_department = list(ACCOUNT_ENG_ID = PAYCHECK_MEDIUM)

	display_order = JOB_DISPLAY_ORDER_STATION_ENGINEER
	rpg_title = "Crystallomancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/engineering
	)

	lightup_areas = list(/area/engine/atmos)

	manuscript_jobs = list(
		JOB_NAME_STATIONENGINEER,
		JOB_NAME_ATMOSPHERICTECHNICIAN // they're identical in some way
	)

/datum/job/station_engineer/get_access()
	. = ..()
	LOWPOP_GRANT_ACCESS(JOB_NAME_ATMOSPHERICTECHNICIAN, ACCESS_ATMOSPHERICS)
	if (SSjob.initial_players_to_assign < COMMAND_POPULATION_MINIMUM)
		. |= ACCESS_CE

/datum/outfit/job/engineer
	name = JOB_NAME_STATIONENGINEER
	jobtype = /datum/job/station_engineer

	id =  /obj/item/card/id/job/station_engineer
	belt = /obj/item/storage/belt/utility/full/engi
	l_pocket = /obj/item/modular_computer/tablet/pda/preset/station_engineer
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/utility/hardhat
	r_pocket = /obj/item/t_scanner

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/engineer/gloved
	name = "Station Engineer (Gloves)"
	gloves = /obj/item/clothing/gloves/color/yellow

/datum/outfit/job/engineer/mod
	name = "Station Engineer (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/engineering
	head = null
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE

