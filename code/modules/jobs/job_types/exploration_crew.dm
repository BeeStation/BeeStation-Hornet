/datum/job/exploration_crew
	title = "Exploration Crew"
	flag = EXPLORATIONTEAM
	department_head = list("Expansion Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the expansion director and research director"
	selection_color = "#C8FDF4"
	chat_color = "#AC71FA"
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/exploration_crew/leader

	access = list(ACCESS_RESEARCH, ACCESS_EVA, ACCESS_EXPLORATION)
	minimal_access = list(ACCESS_RESEARCH, ACCESS_EVA, ACCESS_EXPLORATION)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_EXP

	display_order = JOB_DISPLAY_ORDER_EXPLORATION_TEAM

/datum/job/exploration_crew/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin, datum/outfit/outfit_override, client/preference_source)
	//Choose a role for the member to be
	var/static/amount_equipped = 0
	switch(amount_equipped % 3)
		if(0)
			outfit = /datum/outfit/job/exploration_crew/leader
		if(1)
			outfit = /datum/outfit/job/exploration_crew/scientist
		if(2)
			outfit = /datum/outfit/job/exploration_crew/engineer
	. = ..()

/datum/outfit/job/exploration_crew
	name = "Exploration Crew"
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/sci
	l_pocket = /obj/item/pinpointer/exploration
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/energy/e_gun/mini	//This is a bad idea, but we can get a replacement soon

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	pda_slot = SLOT_L_STORE

/datum/outfit/job/exploration_crew/leader
	name = "Exploration Crew Leader"
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/exploration_crew/captain
	l_pocket = /obj/item/pinpointer/exploration
	ears = /obj/item/radio/headset/headset_exp
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/energy/e_gun/mini	//This is a bad idea, but we can get a replacement soon

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	pda_slot = SLOT_L_STORE

/datum/outfit/job/exploration_crew/scientist
	name = "Exploration Crew Scientist"
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/exploration_crew/scientist
	l_pocket = /obj/item/pinpointer/exploration
	ears = /obj/item/radio/headset/headset_exp
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/energy/e_gun/mini	//This is a bad idea, but we can get a replacement soon

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	pda_slot = SLOT_L_STORE

/datum/outfit/job/exploration_crew/engineer
	name = "Exploration Crew Engineer"
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/exploration_crew/engineer
	l_pocket = /obj/item/pinpointer/exploration
	ears = /obj/item/radio/headset/headset_exp
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/energy/e_gun/mini	//This is a bad idea, but we can get a replacement soon

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	pda_slot = SLOT_L_STORE
