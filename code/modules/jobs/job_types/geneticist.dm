/datum/job/geneticist
	title = JOB_NAME_GENETICIST
	description = "Discover useful mutations and give them out to the crew at CMO's approval, oversee Cloning, create humanized monkeys for replacement organs and bodyparts if needed."
	department_for_prefs = DEPT_NAME_MEDICAL
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 2
	selection_color = "#d4ebf2"
	// Requires a round in medical, this is a decent role for new players but is poorly
	// communicated. Once the onboarding is better for this role, playtime requirements
	// should be removed.
	exp_requirements = 120
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/geneticist

	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MECH_MEDICAL)
	extra_access = list(ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(
		ACCOUNT_MED_ID = PAYCHECK_MEDIUM
	)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_GENETICIST
	rpg_title = "Genemancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/genetics
	)
	biohazard = 25

	lightup_areas = list(
		/area/medical/surgery,
		/area/medical/virology,
		/area/medical/chemistry,
		/area/medical/apothecary
	)
	minimal_lightup_areas = list(/area/medical/morgue, /area/medical/genetics)

	manuscript_jobs = list(
		JOB_NAME_GENETICIST,
		JOB_NAME_SCIENTIST // credit to the old age when they're a member of R&D
	)

/datum/outfit/job/geneticist
	name = JOB_NAME_GENETICIST
	jobtype = /datum/job/geneticist

	id = /obj/item/card/id/job/geneticist
	belt = /obj/item/modular_computer/tablet/pda/preset/geneticist
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/geneticist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/genetics
	suit_store =  /obj/item/flashlight/pen
	l_pocket = /obj/item/sequence_scanner

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel/gen
	duffelbag = /obj/item/storage/backpack/duffelbag/med

