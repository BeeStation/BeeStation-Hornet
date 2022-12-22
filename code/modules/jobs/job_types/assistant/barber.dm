/datum/job/assistant/barber
	g_jpath = JOB_PATH_BARBER
	g_title = JOB_NAME_BARBER
	flag = BARBER
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"

	outfit = /datum/outfit/job/barber

	access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_ASSISTANT)

	rpg_title = "Scissorhands"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/barber
	name = JOB_PATH_BARBER
	jobtype = /datum/job/assistant/barber
	id = /obj/item/card/id/job/barber
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/suit/sl
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor
	can_be_admin_equipped = TRUE
