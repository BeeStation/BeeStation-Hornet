/datum/job/research_director
	title = JOB_NAME_RESEARCHDIRECTOR
	description = "Oversee the scientists and roboticists and keep up with their research projects, take care of any issues with the station's AI that may arise, ensure research is being prioritized in accordance with the needs of the station."
	department_for_prefs = DEPT_NAME_SCIENCE
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list(JOB_NAME_CAPTAIN)
	supervisors = "the captain"
	head_announce = list("Science")
	faction = "Station"
	total_positions = 1
	selection_color = "#ffddff"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 1200
	exp_type = EXP_TYPE_SCIENCE
	min_pop = COMMAND_POPULATION_MINIMUM

	outfit = /datum/outfit/job/research_director

	base_access = list(ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_MORGUE, ACCESS_EXPLORATION,
						ACCESS_TOX_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING, ACCESS_MECH_MEDICAL, ACCESS_MECH_ENGINE,
						ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
						ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM,
						ACCESS_TECH_STORAGE, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_NETWORK, ACCESS_AUX_BASE, ACCESS_RD_SERVER, ACCESS_WEAPONS)
	extra_access = list()

	departments = DEPT_BITFLAG_SCI | DEPT_BITFLAG_COM
	bank_account_department = ACCOUNT_SCI_BITFLAG | ACCOUNT_COM_BITFLAG
	payment_per_department = list(
		ACCOUNT_COM_ID = PAYCHECK_COMMAND_NT,
		ACCOUNT_SCI_ID = PAYCHECK_COMMAND_DEPT)

	display_order = JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR
	rpg_title = "Archmagister"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/rd
	)
	biohazard = 40

	minimal_lightup_areas = list(
		/area/crew_quarters/heads/hor,
		/area/science/explab,
		/area/science/misc_lab,
		/area/science/mixing,
		/area/science/nanite,
		/area/science/robotics,
		/area/science/server,
		/area/science/storage,
		/area/science/xenobiology
	)

	manuscript_jobs = list(
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_SCIENTIST,
		JOB_NAME_EXPLORATIONCREW,
		JOB_NAME_ROBOTICIST
	)

/datum/outfit/job/research_director
	name = JOB_NAME_RESEARCHDIRECTOR
	jobtype = /datum/job/research_director

	id = /obj/item/card/id/job/research_director
	belt = /obj/item/modular_computer/tablet/pda/preset/heads/research_director
	ears = /obj/item/radio/headset/heads/research_director
	uniform = /obj/item/clothing/under/rank/rnd/research_director
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/toggle/labcoat/research_director
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/laser_pointer
	backpack_contents = list(/obj/item/melee/baton/telescopic=1)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox
	duffelbag = /obj/item/storage/backpack/duffelbag/science

	chameleon_extras = /obj/item/stamp/research_director

/datum/outfit/job/research_director/mod
	name = "Research Director (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/research
	suit = null
	head = null
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE
