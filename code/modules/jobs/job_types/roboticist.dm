/datum/job/roboticist
	title = JOB_NAME_ROBOTICIST
	description = "Create bots and utility mechs for helping out around the station. Construct war machines by the request of the Captain or Head of Security. Make new Cyborgs, give augmentations and implants to crew members."
	department_for_prefs = DEPT_NAME_SCIENCE
	department_head = list(JOB_NAME_RESEARCHDIRECTOR)
	faction = "Station"
	total_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/roboticist
	mind_traits = list(TRAIT_KNOW_ROBO_WIRES)

	base_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING,
						ACCESS_MECH_MEDICAL, ACCESS_MECH_ENGINE, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)
	extra_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_XENOBIOLOGY)

	departments = DEPT_BITFLAG_SCI
	bank_account_department = ACCOUNT_SCI_BITFLAG
	payment_per_department = list(ACCOUNT_SCI_ID = PAYCHECK_MEDIUM)

	display_order = JOB_DISPLAY_ORDER_ROBOTICIST
	rpg_title = "Golemancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/robotics
	)

	lightup_areas = list(/area/science/mixing, /area/science/storage)
	minimal_lightup_areas = list(
		/area/medical/morgue,
		/area/science/robotics,
		/area/storage/tech
	)

	manuscript_jobs = list(
		JOB_NAME_ROBOTICIST,
		JOB_NAME_MEDICALDOCTOR // because they have a surgery bed in the robotics for some reason...
	)

/datum/outfit/job/roboticist
	name = JOB_NAME_ROBOTICIST
	jobtype = /datum/job/roboticist

	id = /obj/item/card/id/job/roboticist
	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/modular_computer/tablet/pda/preset/roboticist
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/roboticist/mod
	name = "Roboticist (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/standard
	suit = null
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE
