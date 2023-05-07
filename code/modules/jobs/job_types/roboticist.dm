/datum/job/roboticist
	title = JOB_NAME_ROBOTICIST
	flag = ROBOTICIST
	department_head = list(JOB_NAME_RESEARCHDIRECTOR)
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/roboticist

	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_MECH_SCIENCE,
					ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_XENOBIOLOGY, ACCESS_AUX_BASE)
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MECH_SCIENCE,
					ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)

	department_flag = MEDSCI
	departments = DEPT_BITFLAG_SCI
	bank_account_department = ACCOUNT_SCI_BITFLAG
	payment_per_department = list(ACCOUNT_SCI_ID = PAYCHECK_MEDIUM)

	display_order = JOB_DISPLAY_ORDER_ROBOTICIST
	rpg_title = "Golemancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/robotics
	)

/datum/outfit/job/roboticist
	name = JOB_NAME_ROBOTICIST
	jobtype = /datum/job/roboticist

	id = /obj/item/card/id/job/roboticist
	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/modular_computer/tablet/pda/roboticist
	ears = /obj/item/radio_abstract/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	pda_slot = ITEM_SLOT_LPOCKET
