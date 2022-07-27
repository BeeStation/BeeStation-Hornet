/datum/job/janitor
	title = JOB_NAME_JANITOR
	flag = JANITOR
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/janitor

	access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_JANITOR
	departments = DEPARTMENT_BITFLAG_SERVICE
	rpg_title = "Groundskeeper"
	biohazard = 20//cleaning up hazardous messes puts janitors at extra risk

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/janitor
	)

/datum/outfit/job/janitor
	name = JOB_NAME_JANITOR
	jobtype = /datum/job/janitor

	id = /obj/item/card/id/job/janitor
	belt = /obj/item/pda/janitor
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	backpack_contents = list(/obj/item/modular_computer/tablet/preset/advanced=1)

/datum/outfit/job/janitor/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(GARBAGEDAY in SSevents.holidays)
		l_pocket = /obj/item/gun/ballistic/revolver
		r_pocket = /obj/item/ammo_box/a357
