/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = CIVILIAN
	head_announce = list(RADIO_CHANNEL_SUPPLY)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#d7b088"
	chat_color = "#C79C52"
	req_admin_notify = 1
	minimal_player_age = 3
	exp_requirements = 600
	exp_type = EXP_TYPE_SUPPLY
	exp_type_department = EXP_TYPE_SUPPLY

	outfit = /datum/outfit/job/quartermaster

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_HEADS, ACCESS_MINING, ACCESS_MECH_MINING,
			ACCESS_KEYCARD_AUTH, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_AUX_BASE, ACCESS_EXPLORATION,
			ACCESS_SEC_DOORS, ACCESS_RC_ANNOUNCE)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_HEADS, ACCESS_MINING, ACCESS_MECH_MINING,
			ACCESS_KEYCARD_AUTH, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_AUX_BASE, ACCESS_EXPLORATION,
			ACCESS_SEC_DOORS, ACCESS_RC_ANNOUNCE)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	departments = DEPARTMENT_CARGO | DEPARTMENT_COMMAND
	rpg_title = "Steward"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/cargo
	)

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/qm

	id = /obj/item/card/id/job/qm
	belt = /obj/item/pda/quartermaster
	ears = /obj/item/radio/headset/heads/qm
	uniform = /obj/item/clothing/under/rank/cargo/qm
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	l_hand = /obj/item/clipboard
	backpack_contents = list(/obj/item/melee/classic_baton/police/telescopic=1,
		/obj/item/modular_computer/tablet/preset/advanced/command=1)

	chameleon_extras = /obj/item/stamp/qm

