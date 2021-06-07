/datum/job/exploration
	title = "Exploration Crew"
	flag = EXPLORATION_CREW
	department_head = list("Head of Personnel", "Research Director")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster, head of personnel and research director"
	selection_color = "#dcba97"
	chat_color = "#85d8b8"

	outfit = /datum/outfit/job/exploration

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_RESEARCH, ACCESS_EXPLORATION)
	minimal_access = list(ACCESS_MAILSORTING, ACCESS_EXPLORATION)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_EXPLORATION
	departments = DEPARTMENT_CARGO

/datum/outfit/job/exploration
	name = "Exploration Crew"
	jobtype = /datum/job/exploration

	id = /obj/item/card/id/job/exploration
	belt = /obj/item/pda/exploration
	ears = /obj/item/radio/headset/headset_exploration
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/rank/cargo/exploration
	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/stack/marker_beacon/thirty=1)
	l_pocket = /obj/item/gps/mining/exploration
	r_pocket = /obj/item/gun/energy/e_gun/mini/exploration

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag

	chameleon_extras = /obj/item/gun/energy/e_gun/mini/exploration

/datum/outfit/job/exploration/hardsuit
	name = "Exploration Crew (Hardsuit)"
	suit = /obj/item/clothing/suit/space/hardsuit/exploration
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/breath
