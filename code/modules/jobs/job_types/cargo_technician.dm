/datum/job/cargo_technician
	title = JOB_NAME_CARGOTECHNICIAN
	flag = CARGOTECH
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the quartermaster and the head of personnel"
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/cargo_technician

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_CAR
	bank_account_department = ACCOUNT_CAR_BITFLAG
	payment_per_department = list(ACCOUNT_CAR_ID = PAYCHECK_EASY)


	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN
	rpg_title = "Merchantman"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/cargo_technician
	)
	biohazard = 25

/datum/outfit/job/cargo_technician
	name = JOB_NAME_CARGOTECHNICIAN
	jobtype = /datum/job/cargo_technician

	id = /obj/item/card/id/job/cargo_technician
	belt = /obj/item/modular_computer/tablet/pda/cargo_technician
	ears = /obj/item/radio_abstract/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo/tech
	l_hand = /obj/item/export_scanner

