/datum/job/cook
	title = JOB_NAME_COOK
	description = "Whip up meals for the crew, get creative and cook different meals, request ingredients from Botany and Cargo. Make sure everyone stays well fed and happy."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 2
	selection_color = "#bbe291"
	var/cooks = 0 //Counts cooks amount

	outfit = /datum/outfit/job/cook

	base_access = list(
		ACCESS_KITCHEN,
		ACCESS_MORGUE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SERVICE,
	)
	extra_access = list(
		ACCESS_HYDROPONICS,
		ACCESS_BAR,
	)

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_ASSISTANT)


	display_order = JOB_DISPLAY_ORDER_COOK
	rpg_title = "Tavern Chef"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/chef
	)

	minimal_lightup_areas = list(/area/crew_quarters/kitchen, /area/medical/morgue)
	lightup_areas = list(/area/hydroponics)

/datum/outfit/job/cook
	name = JOB_NAME_COOK
	jobtype = /datum/job/cook

	id = /obj/item/card/id/job/cook
	belt = /obj/item/modular_computer/tablet/pda/preset/cook
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/toggle/chef
	head = /obj/item/clothing/head/utility/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian
	backpack_contents = list(/obj/item/sharpener = 1)

/datum/outfit/job/cook/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/datum/job/cook/J = SSjob.GetJobType(jobtype)
	if(J) // Fix for runtime caused by invalid job being passed
		if(J.cooks>0)//Cooks
			suit = /obj/item/clothing/suit/apron/chef
			head = /obj/item/clothing/head/soft
		if(!visualsOnly)
			J.cooks++

/datum/outfit/job/cook/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	var/list/possible_boxes = subtypesof(/obj/item/storage/box/ingredients)
	var/chosen_box = pick(possible_boxes)
	var/obj/item/storage/box/I = new chosen_box(src)
	H.equip_to_slot_or_del(I,ITEM_SLOT_BACKPACK)
	var/datum/martial_art/cqc/under_siege/justacook = new
	justacook.teach(H)

/datum/outfit/job/cook/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/suit/apron/chef
	. += /obj/item/clothing/head/soft
