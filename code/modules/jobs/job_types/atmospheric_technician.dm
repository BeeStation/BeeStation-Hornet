/datum/job/atmospheric_technician
	title = JOB_NAME_ATMOSPHERICTECHNICIAN
	description = "Maintain the air distribution loop to ensure adequate atmospheric conditions in the station, re-pressurize areas after hull breaches, and be a firefighter if necessary."
	department_for_prefs = DEPT_NAME_ENGINEERING
	department_head = list(JOB_NAME_CHIEFENGINEER)
	supervisors = "the chief engineer"
	faction = "Station"
	total_positions = 3
	selection_color = "#fff5cc"
	// Requires advanced knowledge of the engineering department
	// and can easilly disrupt large portions of the station
	exp_requirements = 120
	exp_type = EXP_TYPE_ENGINEERING

	outfit = /datum/outfit/job/atmospheric_technician

	base_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)
	extra_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_EXTERNAL_AIRLOCKS)

	departments = DEPT_BITFLAG_ENG
	bank_account_department = ACCOUNT_ENG_BITFLAG
	payment_per_department = list(ACCOUNT_ENG_ID = PAYCHECK_MEDIUM)

	display_order = JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN
	rpg_title = "Aeromancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/atmospherics
	)

	minimal_lightup_areas = list(/area/engine/atmos)

	manuscript_jobs = list(
		JOB_NAME_ATMOSPHERICTECHNICIAN,
		JOB_NAME_STATIONENGINEER // they're identical in some way
	)

/datum/outfit/job/atmospheric_technician
	name = JOB_NAME_ATMOSPHERICTECHNICIAN
	jobtype = /datum/job/atmospheric_technician

	id = /obj/item/card/id/job/atmospheric_technician
	belt = /obj/item/storage/belt/utility/atmostech
	l_pocket = /obj/item/modular_computer/tablet/pda/preset/atmospheric_technician
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	r_pocket = /obj/item/analyzer

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/atmospheric_technician/mod
	name = "Atmospheric Technician (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/atmospheric
	mask = /obj/item/clothing/mask/gas/atmos
	internals_slot = ITEM_SLOT_SUITSTORE
