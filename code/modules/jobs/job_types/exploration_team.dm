/datum/job/exploration_crew
	title = JOB_NAME_EXPLORATIONCREW
	description = "Go out into space to complete different missions for loads of cash. Find and deliver back research disks for rare technologies."
	department_for_prefs = DEPT_NAME_SCIENCE
	department_head = list(JOB_NAME_RESEARCHDIRECTOR)
	supervisors = "the research director"
	faction = "Station"
	total_positions = 3
	minimal_player_age = 3
	// Requires 1 round as a scientist to unlock, which itself reuqires
	// 2 hours as crew.
	exp_requirements = 60
	exp_type = EXP_TYPE_SCIENCE
	selection_color = "#ffeeff"

	outfit = /datum/outfit/job/exploration_crew

	base_access = list(ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_TOX, ACCESS_MECH_SCIENCE)
	extra_access = list(ACCESS_MAINT_TUNNELS, ACCESS_TOX_STORAGE, ACCESS_XENOBIOLOGY)

	departments = DEPT_BITFLAG_SCI
	bank_account_department = ACCOUNT_SCI_BITFLAG
	payment_per_department = list(ACCOUNT_SCI_ID = PAYCHECK_HARD)

	display_order = JOB_DISPLAY_ORDER_EXPLORATION
	rpg_title = "Sailor"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/exploration_crew
	)
	biohazard = 40//who knows what you'll find out there that could have nasties on it...

	lightup_areas = list(
		/area/science/mixing,
		/area/science/storage,
		/area/science/xenobiology
	)
	minimal_lightup_areas = list(/area/quartermaster/exploration_dock, /area/quartermaster/exploration_prep)

	manuscript_jobs = list(
		JOB_NAME_EXPLORATIONCREW,
		JOB_NAME_SHAFTMINER
	)

/datum/outfit/job/exploration_crew
	name = JOB_NAME_EXPLORATIONCREW
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/exploration_crew
	belt = /obj/item/modular_computer/tablet/pda/preset/exploration_crew
	ears = /obj/item/radio/headset/headset_exploration
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/rank/cargo/exploration
	backpack_contents = list(
		/obj/item/knife/combat/survival=1,\
		/obj/item/stack/marker_beacon/thirty=1,\
		/obj/item/mining_voucher/exploration=1)
	r_pocket = /obj/item/gun/energy/e_gun/mini/exploration

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag

	chameleon_extras = /obj/item/gun/energy/e_gun/mini/exploration

/datum/outfit/job/exploration_crew/engineer
	name = "Exploration Crew (Engineer)"

	belt = /obj/item/storage/belt/utility/full
	r_pocket = /obj/item/modular_computer/tablet/pda/preset/exploration_crew

	backpack_contents = list(
		/obj/item/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/gun/energy/e_gun/mini/exploration=1,
		/obj/item/grenade/exploration=3,				//Breaching charges for entering ruins
		/obj/item/exploration_detonator=1,				//Detonator for the breaching charges.
		/obj/item/discovery_scanner=1
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

/datum/outfit/job/exploration_crew/scientist
	name = "Exploration Crew (Scientist)"

	glasses = /obj/item/clothing/glasses/science

	backpack_contents = list(
		/obj/item/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/discovery_scanner=1,
		/obj/item/sbeacondrop/exploration=1,			//Spawns in a bluespace beacon
		/obj/item/research_disk_pinpointer=1			//Locates research disks
	)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

/datum/outfit/job/exploration_crew/medic
	name = "Exploration Crew (Medical Doctor)"

	backpack_contents = list(
		/obj/item/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/pinpointer/crew=1,
		/obj/item/sensor_device=1,
		/obj/item/discovery_scanner=1
	)

	r_hand = /obj/item/rollerbed
	l_hand = /obj/item/storage/firstaid/medical
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

/datum/outfit/job/exploration_crew/hardsuit
	name = "Exploration Crew (Hardsuit)"
	suit = /obj/item/clothing/suit/space/hardsuit/exploration
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/breath
