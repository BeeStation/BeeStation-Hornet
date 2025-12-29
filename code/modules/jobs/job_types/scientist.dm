/datum/job/scientist
	title = JOB_NAME_SCIENTIST
	description = "Engage in Xenobiology, Xenoarchaeology, Nanites, and Toxins; research new technology; and upgrade the machine parts around the station."
	department_for_prefs = DEPT_NAME_SCIENCE
	department_head = list(JOB_NAME_RESEARCHDIRECTOR)
	supervisors = "the research director"
	faction = "Station"
	dynamic_spawn_group = JOB_SPAWN_GROUP_DEPARTMENT
	selection_color = "#ffeeff"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/scientist


	base_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MECH_SCIENCE,
						ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE, ACCESS_EXPLORATION)

	departments = DEPT_BITFLAG_SCI
	bank_account_department = ACCOUNT_SCI_BITFLAG
	payment_per_department = list(ACCOUNT_SCI_ID = PAYCHECK_MEDIUM)

	display_order = JOB_DISPLAY_ORDER_SCIENTIST
	rpg_title = "Thaumaturgist"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/science
	)
	biohazard = 35

	lightup_areas = list(/area/storage/tech, /area/science/robotics)
	minimal_lightup_areas = list(
		/area/science/explab,
		/area/science/misc_lab,
		/area/science/mixing,
		/area/science/nanite,
		/area/science/storage,
		/area/science/xenobiology
	)

	manuscript_jobs = list(
		JOB_NAME_SCIENTIST,
		JOB_NAME_ATMOSPHERICTECHNICIAN // thanks to maxcap, they're knowledgeable.
	)

/datum/job/scientist/get_access()
	. = ..()
	LOWPOP_GRANT_ACCESS(JOB_NAME_ROBOTICIST, ACCESS_ROBOTICS)
	LOWPOP_GRANT_ACCESS(JOB_NAME_EXPLORATIONCREW, ACCESS_EXPLORATION)
	if (SSjob.initial_players_to_assign < LOWPOP_JOB_LIMIT)
		. |= ACCESS_TECH_STORAGE
	if (SSjob.initial_players_to_assign < COMMAND_POPULATION_MINIMUM)
		. |= ACCESS_RD
		. |= ACCESS_RD_SERVER

/datum/outfit/job/scientist
	name = JOB_NAME_SCIENTIST
	jobtype = /datum/job/scientist

	id = /obj/item/card/id/job/scientist
	belt = /obj/item/modular_computer/tablet/pda/preset/science
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit = /obj/item/clothing/suit/toggle/labcoat/science

	r_pocket = /obj/item/discovery_scanner

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox
	duffelbag = /obj/item/storage/backpack/duffelbag/science

/datum/outfit/job/scientist/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(0.4))
		neck = /obj/item/clothing/neck/tie/horrible
