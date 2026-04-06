/datum/job/quartermaster
	title = JOB_NAME_QUARTERMASTER
	description = "Oversee and direct cargo technicians to fulfill requests for supplies and keep the station well stocked, request funds from department budgets to cover costs, deny frivolous orders when money is tight, and sell anything the station doesn't need."
	department_for_prefs = DEPT_NAME_CARGO
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	selection_color = "#d7b088"
	exp_requirements = 600
	exp_type = EXP_TYPE_SUPPLY

	outfit = /datum/outfit/job/quartermaster

	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_AUX_BASE, ACCESS_EXPLORATION, ACCESS_GATEWAY)
	extra_access = list()

	departments = DEPT_BITFLAG_CAR
	bank_account_department = ACCOUNT_CAR_BITFLAG
	payment_per_department = list(ACCOUNT_CAR_ID = PAYCHECK_MEDIUM)

	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	rpg_title = "Steward"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/cargo_technician
	)

	minimal_lightup_areas = list(
		/area/quartermaster/qm,
		/area/quartermaster/qm_bedroom,
		/area/quartermaster/exploration_prep,
		/area/quartermaster/exploration_dock
	)

	manuscript_jobs = list(
		JOB_NAME_QUARTERMASTER,
		JOB_NAME_CARGOTECHNICIAN,
		JOB_NAME_SHAFTMINER
	)

/datum/outfit/job/quartermaster
	name = JOB_NAME_QUARTERMASTER
	jobtype = /datum/job/quartermaster

	id = /obj/item/card/id/job/quartermaster
	belt = /obj/item/modular_computer/tablet/pda/preset/quartermaster
	ears = /obj/item/radio/headset/headset_quartermaster
	uniform = /obj/item/clothing/under/rank/cargo/quartermaster
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	l_hand = /obj/item/clipboard

	chameleon_extras = /obj/item/stamp/quartermaster

