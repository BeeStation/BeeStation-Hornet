/datum/job/away_team
	title = "Away Team"
	flag = AWAY_TEAM
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 4
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	chat_color = "#C772C7"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/away_team

	access = list(ACCESS_RESEARCH, ACCESS_MAINT_TUNNELS, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM, ACCESS_GATEWAY, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_TECH_STORAGE, ACCESS_GENETICS)
	minimal_access = list(ACCESS_RESEARCH, ACCESS_MAINT_TUNNELS, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM, ACCESS_GATEWAY)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_AWAY_TEAM

/datum/outfit/job/away_team
	name = "Away Team"
	jobtype = /datum/job/away_team
	id = /obj/item/card/id/job/sci
	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/rnd/awayteam
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/light
	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox
	l_pocket = /obj/item/pinpointer/pinpointer_gateway
	r_pocket = /obj/item/pda/toxins
	backpack_contents = list(
		/obj/item/gun/ballistic/revolver/detective = 1, // Placeholder for now
		/obj/item/choice_beacon/away_team = 1,
		)