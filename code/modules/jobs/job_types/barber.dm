/*
The barber is currently disabled via config. When or if you decide to turn them back on to be picked as normal crew then please note that they are able to spawn in maintenance if the barbershop room spawns.
Also please remove them from /obj/effect/landmark/start/randommaint/barber and just make them /obj/effect/landmark/start/barber, since the /randommaint/ adds extra slots ontop of the total and spawn _positions.
*/
/datum/job/barber

	title = JOB_NAME_BARBER
	description = "Give the crew haircuts using the variety of tools at your disposal, and provide less professional and cosmetic surgeries."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#d4ebf2"

	outfit = /datum/outfit/job/barber

	base_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	extra_access = list()

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_ASSISTANT)

	display_order = JOB_DISPLAY_ORDER_BARBER
	rpg_title = "Scissorhands"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman //there is no suit for you either, sorry.
	)
	minimal_lightup_areas = list(/area/medical/morgue)

// Barber will be off until we either get a better system for cutting hair, or we make the need to get getto surgery more prevlant.
/datum/job/barber/config_check()
	return CONFIG_GET(flag/allow_barber)

/datum/outfit/job/barber
	name = JOB_NAME_BARBER
	jobtype = /datum/job/barber
	id = /obj/item/card/id/job/barber
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/suit/sl
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor
	can_be_admin_equipped = TRUE
