/datum/job/atmospheric_technician
	title = JOB_NAME_ATMOSPHERICTECHNICIAN
	flag = ATMOSTECH
	department_head = list(JOB_NAME_CHIEFENGINEER)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/atmospheric_technician

	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
									ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)
	minimal_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	display_order = JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN
	departments = DEPARTMENT_BITFLAG_ENGINEERING
	rpg_title = "Aeromancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/atmospherics
	)

/datum/outfit/job/atmospheric_technician
	name = JOB_NAME_ATMOSPHERICTECHNICIAN
	jobtype = /datum/job/atmospheric_technician

	id = /obj/item/card/id/job/atmospheric_technician
	belt = /obj/item/storage/belt/utility/atmostech
	l_pocket = /obj/item/pda/atmospheric_technician
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	r_pocket = /obj/item/analyzer

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/engineer
	pda_slot = ITEM_SLOT_LPOCKET
	backpack_contents = list(/obj/item/modular_computer/tablet/preset/advanced/atmos=1)

/datum/outfit/job/atmospheric_technician/rig
	name = "Atmospheric Technician (Hardsuit)"

	mask = /obj/item/clothing/mask/gas
	suit = /obj/item/clothing/suit/space/hardsuit/engine/atmos
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
