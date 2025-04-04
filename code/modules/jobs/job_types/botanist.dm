/datum/job/botanist
	title = JOB_NAME_BOTANIST
	description = "Grow plants for the Kitchen, Bar and Chemistry. Sell cannabis and other goods to the crew."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	selection_color = "#bbe291"
	exp_requirements = 120 //High grief percentage
	exp_type = EXP_TYPE_SERVICE
	exp_type_department = EXP_TYPE_SERVICE
	outfit = /datum/outfit/job/botanist

	base_access = list(ACCESS_HYDROPONICS, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)
	extra_access = list(ACCESS_BAR, ACCESS_KITCHEN)

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_EASY)

	display_order = JOB_DISPLAY_ORDER_BOTANIST
	rpg_title = "Gardener"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/botany
	)

	minimal_lightup_areas = list(/area/hydroponics, /area/medical/morgue)

/datum/outfit/job/botanist
	name = JOB_NAME_BOTANIST
	jobtype = /datum/job/botanist

	id = /obj/item/card/id/job/botanist
	belt = /obj/item/modular_computer/tablet/pda/service
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/botanic_leather
	suit_store = /obj/item/plant_analyzer

	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel/hyd


