/datum/job/clown/stage_magician
	g_jkey = JOB_KEY_STAGEMAGICIAN
	g_jtitle = JOB_TITLE_STAGEMAGICIAN
	job_bitflags = JOB_BITFLAG_GIMMICK
	department_head = list(JOB_TITLE_HEADOFPERSONNEL)
	total_positions = 0
	spawn_positions = 0

	outfit = /datum/outfit/job/stage_magician

	access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_MINIMAL)

	rpg_title = "Master Illusionist"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/magic
	)

	use_clown_name = FALSE

/datum/outfit/job/stage_magician
	name = JOB_KEY_STAGEMAGICIAN
	jobtype = /datum/job/clown/stage_magician
	id = /obj/item/card/id/job/stage_magician
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	head = /obj/item/clothing/head/that
	ears = /obj/item/radio/headset
	neck = /obj/item/bedsheet/magician
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	l_hand = /obj/item/cane
	backpack_contents = list(/obj/item/choice_beacon/magic=1)
	can_be_admin_equipped = TRUE

