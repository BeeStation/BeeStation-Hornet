/datum/job/psychiatrist

	title = JOB_NAME_PSYCHIATRIST
	description = "Provide therapy to the crew through talk sessions, psychoactive drugs, and careful consideration of their thoughts and feelings. Provide mental evaluations for Security."
	department_for_prefs = DEPT_NAME_MEDICAL
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#d4ebf2"

	outfit = /datum/outfit/job/psychiatrist

	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)
	extra_access = list()

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_EASY)
	mind_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_PSYCHIATRIST
	rpg_title = "Enchanter"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman //sadly there isn't any plasmaman outfit for these guys, they gotta do with what they have.
	)

	minimal_lightup_areas = list(
		/area/storage/eva,
		/area/medical/morgue,
		/area/medical/genetics/cloning,
		/area/medical/surgery
	)

/datum/outfit/job/psychiatrist //psychiatrist doesnt get much shit, but he has more access and a cushier paycheck
	name = JOB_NAME_PSYCHIATRIST
	jobtype = /datum/job/psychiatrist
	id = /obj/item/card/id/job/psychiatrist
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup
	backpack_contents = list(/obj/item/choice_beacon/pet/ems=1)
	can_be_admin_equipped = TRUE
