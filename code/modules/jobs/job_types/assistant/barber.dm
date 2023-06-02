/datum/job/assistant/barber
	g_jkey = JOB_KEY_BARBER
	g_jtitle = JOB_TITLE_BARBER
	job_bitflags = JOB_BITFLAG_GIMMICK
	department_head = list(JOB_TITLE_HEADOFPERSONNEL)
	total_positions = 0
	spawn_positions = 0

	outfit = /datum/outfit/job/barber

	access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_ASSISTANT)

	list_of_job_keys_to_mob_mind = list(JOB_KEY_ASSISTANT)
	// their nature is assistant. They'll have two jobs(barber, assistant) in their mind role.

	rpg_title = "Scissorhands"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/barber
	name = JOB_KEY_BARBER
	jobtype = /datum/job/assistant/barber
	id = /obj/item/card/id/job/barber
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/suit/sl
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor
	can_be_admin_equipped = TRUE
