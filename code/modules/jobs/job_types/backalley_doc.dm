/datum/job/backalley_doc
	title = "Barber"
	flag = BARBER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "nobody"
	selection_color = "#d4ebf2"

	outfit = /datum/outfit/job/backalley_doc

	access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_ASSISTANT
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT

/datum/outfit/job/backalley_doc
	name = "Barber"
	jobtype = /datum/job/backalley_doc

	belt = /obj/item/pda/unlicensed
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/sl_suit
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor
	backpack_contents = list(/obj/item/handmirror=1)