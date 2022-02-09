/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	chat_color = "#B2CEB3"
	exp_type_department = EXP_TYPE_SERVICE // This is so the jobs menu can work properly

	outfit = /datum/outfit/job/bartender

	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	minimal_access = list(ACCESS_BAR, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BARTENDER
	departments = DEPARTMENT_SERVICE
	rpg_title = "Tavernkeeper"

	mail_goodies = list(
		/obj/item/storage/box/rubbershot = 30,
		/obj/item/reagent_containers/glass/bottle/clownstears = 10,
		/obj/item/stack/sheet/mineral/plasma = 5,
		/obj/item/stack/sheet/mineral/uranium = 5,
		/obj/item/reagent_containers/food/drinks/bottle/fernet = 3,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 3,
		/obj/item/reagent_containers/food/drinks/bottle/trappist = 3
	)

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/bar
	)
/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender

	id = /obj/item/card/id/job/serv
	glasses = /obj/item/clothing/glasses/sunglasses/advanced/reagent
	belt = /obj/item/pda/bar
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	backpack_contents = list(/obj/item/storage/box/beanbag=1)
	shoes = /obj/item/clothing/shoes/laceup

