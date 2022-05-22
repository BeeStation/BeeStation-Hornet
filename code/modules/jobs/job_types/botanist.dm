/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_head = list("Head of Personnel", "Research Director")
	department_flag = CIVSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel and research director"
	selection_color = "#bbe291"
	chat_color = "#95DE85"

	outfit = /datum/outfit/job/botanist

	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM, ACCESS_RESEARCH)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BOTANIST
	departments = DEPARTMENT_SERVICE
	rpg_title = "Gardener"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/botany
	)
/datum/outfit/job/botanist
	name = "Botanist"
	jobtype = /datum/job/hydro

	id = /obj/item/card/id/job/serv
	belt = /obj/item/pda/botanist
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/botanic_leather
	suit_store = /obj/item/plant_analyzer
	r_pocket = /obj/item/discovery_scanner

	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel/hyd


