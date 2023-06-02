/datum/job/medical_doctor/psychiatrist
	g_jkey = JOB_KEY_PSYCHIATRIST
	g_jtitle = JOB_TITLE_PSYCHIATRIST
	job_bitflags = JOB_BITFLAG_GIMMICK
	total_positions = 0
	spawn_positions = 0

	outfit = /datum/outfit/job/psychiatrist

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)


	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_EASY)
	mind_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_MEDICAL_METABOLISM)

	rpg_title = "Enchanter"


	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/psychiatrist //psychiatrist doesnt get much shit, but he has more access and a cushier paycheck
	name = JOB_KEY_PSYCHIATRIST
	jobtype = /datum/job/medical_doctor/psychiatrist
	id = /obj/item/card/id/job/psychiatrist
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup
	backpack_contents = list(/obj/item/choice_beacon/pet/ems=1)
	can_be_admin_equipped = TRUE
