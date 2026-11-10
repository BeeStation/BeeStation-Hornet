/datum/job/cargo_technician
	title = JOB_NAME_CARGOTECHNICIAN
	description = "Push crates around, deliver bounty papers and mail around the station, make use of the Disposals network to make your life easier."
	department_for_prefs = DEPARTMENT_NAME_CARGO
	department_head_for_prefs = JOB_NAME_QUARTERMASTER
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the quartermaster and the head of personnel"
	faction = FACTION_STATION
	dynamic_spawn_group = JOB_SPAWN_GROUP_DEPARTMENT
	selection_color = "#dcba97"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/cargo_technician

	base_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_CARGO,
		ACCESS_MAILSORTING,
		ACCESS_MINERAL_STOREROOM
	)

	departments_list = list(
		/datum/department_group/cargo,
		)
	bank_account_department = ACCOUNT_CAR_BITFLAG
	payment_per_department = list(ACCOUNT_CAR_ID = PAYCHECK_EASY)

	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN

	job_flags = STATION_JOB_FLAGS
	rpg_title = "Merchantman"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/cargo_technician
	)
	biohazard = 25

	lightup_areas = list(/area/station/cargo/qm, /area/station/cargo/qm_bedroom)

/datum/outfit/job/cargo_technician
	name = JOB_NAME_CARGOTECHNICIAN
	jobtype = /datum/job/cargo_technician

	id = /obj/item/card/id/job/cargo_technician
	belt = /obj/item/modular_computer/tablet/pda/preset/cargo_technician
	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo/tech
	l_hand = /obj/item/export_scanner

/datum/outfit/job/cargo_technician/mod
	name = "Cargo Technician (MODsuit)"

	back = /obj/item/mod/control/pre_equipped/loader
