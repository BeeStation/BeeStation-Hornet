/datum/job/bartender
	title = JOB_NAME_BARTENDER
	description = "Brew a variety of drinks for the crew, cooperate with Botany and Chemistry for more exotic recipes, create a comfy atmosphere in your Bar."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/bartender

	base_access = list(
		ACCESS_BAR,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
	)
	extra_access = list(ACCESS_HYDROPONICS, ACCESS_KITCHEN, ACCESS_MORGUE)

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_EASY)

	display_order = JOB_DISPLAY_ORDER_BARTENDER
	rpg_title = "Tavernkeeper"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/bartender
	)

	lightup_areas = list(
		/area/hydroponics,
		/area/medical/morgue,
		/area/crew_quarters/kitchen
	)

	manuscript_jobs = list(
		JOB_NAME_BARTENDER,
		JOB_NAME_CHEMIST // why not
	)

/datum/outfit/job/bartender
	name = JOB_NAME_BARTENDER
	jobtype = /datum/job/bartender

	id = /obj/item/card/id/job/bartender
	glasses = /obj/item/clothing/glasses/sunglasses/advanced/reagent
	belt = /obj/item/modular_computer/tablet/pda/preset/bartender
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	l_hand = /obj/item/storage/box/beanbag
	shoes = /obj/item/clothing/shoes/laceup


/datum/outfit/job/bartender/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	ADD_TRAIT(H, TRAIT_SOMMELIER, ROUNDSTART_TRAIT)
