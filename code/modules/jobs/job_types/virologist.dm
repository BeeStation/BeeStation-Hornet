/datum/job/virologist
	title = JOB_NAME_VIROLOGIST
	description = "Collect virus samples from dormant viruses, old blood, and crusty vomit from around the station, isolate the symptoms and use them to create useful healing viruses for the crew."
	department_for_prefs = DEPT_NAME_MEDICAL
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 2
	selection_color = "#d4ebf2"
	exp_requirements = 180
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/virologist

	base_access = list(ACCESS_MEDICAL, ACCESS_VIROLOGY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	extra_access = list(ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_CLONING)

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_VIROLOGIST
	rpg_title = "Plague Doctor"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/virologist
	)
	biohazard = 75 //duh

	lightup_areas = list(
		/area/medical/morgue,
		/area/medical/surgery,
		/area/medical/genetics,
		/area/medical/chemistry,
		/area/medical/apothecary
	)
	minimal_lightup_areas = list(/area/medical/virology)

/datum/job/virologist/config_check()
	return CONFIG_GET(flag/allow_virologist)

/datum/outfit/job/virologist
	name = JOB_NAME_VIROLOGIST
	jobtype = /datum/job/virologist

	id = /obj/item/card/id/job/virologist
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/virologist
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/virologist
	suit_store =  /obj/item/flashlight/pen
	r_pocket = /obj/item/modular_computer/tablet/pda/preset/virologist

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel/vir
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	pda_slot = ITEM_SLOT_RPOCKET
