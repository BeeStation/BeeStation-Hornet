/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_head = list("Head of Personnel", "Research Director")
	department_flag = CIVSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/botanist

	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM, ACCESS_RESEARCH)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI
	display_order = JOB_DISPLAY_ORDER_BOTANIST
	departments = DEPARTMENT_SCIENCE
	rpg_title = "Druid"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/botany
	)

/datum/outfit/job/botanist
	name = "Botanist"
	jobtype = /datum/job/hydro

	id = /obj/item/card/id/job/botanist
	belt = /obj/item/pda/toxins
	ears = /obj/item/radio/headset/headset_srvsci
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	suit = /obj/item/clothing/suit/apron
	gloves = /obj/item/clothing/gloves/botanic_leather
	suit_store = /obj/item/plant_analyzer
	r_pocket = /obj/item/discovery_scanner
	l_pocket = /obj/item/paper/botany_temp

	backpack = /obj/item/storage/backpack/botany
	satchel = /obj/item/storage/backpack/satchel/hyd

/obj/item/paper/botany_temp
	name = "Botany notification paper"
	info = "Botany has been reworked. Please follow these procedure to do hydroponics<br>1.Buy a seed<br>2.Plant a seed on it<br>3.wait<br>4.harvest them<br>5.Scan them with your discovery scanner<br>6.Make the plant as seeds<br>7.Put the seed into the plant gene manipulating machine<br>8.Adjust its gene as you wish<br>- Add/Remove trait or chemical<br>- Mutate it into another plant<br><br>Remember you need to scan every plant if you want more traits and more chemicals.<br>Note: Strange plant now has a cycle. Scan them and mutate them for cycling.<br>Note2: Most plant chemicals are not working anymore.<br><br>This is Alpha experimentation - there's no plant stat change for the period of alpha experimentation shifts."
