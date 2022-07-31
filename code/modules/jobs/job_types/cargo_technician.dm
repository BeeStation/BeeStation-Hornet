/datum/job/cargo_technician
	title = JOB_NAME_CARGOTECHNICIAN
	flag = CARGOTECH
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/cargo_technician

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN
	departments = DEPARTMENT_BITFLAG_CARGO
	rpg_title = "Merchantman"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/cargo_technician
	)
	biohazard = 15

/datum/outfit/job/cargo_technician
	name = JOB_NAME_CARGOTECHNICIAN
	jobtype = /datum/job/cargo_technician

	id = /obj/item/card/id/job/cargo_technician
	belt = /obj/item/pda/cargo_technician
	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo/tech
	l_hand = /obj/item/export_scanner

