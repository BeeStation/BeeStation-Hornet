/datum/job/janitor
	title = JOB_NAME_JANITOR
	description = "Clean up vomit, trash, and other messes around the station. Put down signs to warn people of slipping hazards, and eradicate rodents when you find them. Keep the station clean and tidy."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 2
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/janitor

	base_access = list(
		ACCESS_JANITOR,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
	)
	extra_access = list()

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_EASY)

	display_order = JOB_DISPLAY_ORDER_JANITOR
	rpg_title = "Groundskeeper"
	biohazard = 40//cleaning up hazardous messes puts janitors at extra risk

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/janitor
	)

	minimal_lightup_areas = list(/area/janitor)

/datum/outfit/job/janitor
	name = JOB_NAME_JANITOR
	jobtype = /datum/job/janitor

	id = /obj/item/card/id/job/janitor
	belt = /obj/item/modular_computer/tablet/pda/preset/janitor
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/janitor

/datum/outfit/job/janitor/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(GARBAGEDAY in SSevents.holidays)
		l_pocket = /obj/item/gun/ballistic/revolver
		r_pocket = /obj/item/ammo_box/a357

/datum/outfit/job/janitor/get_types_to_preload()
	. = ..()
	if(GARBAGEDAY in SSevents.holidays)
		. += /obj/item/gun/ballistic/revolver
		. += /obj/item/ammo_box/a357
