/datum/job/deputy
	title = "Deputy"
	flag = DEPUTY
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/deputy

	access = list(ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DEPUTY  //see code/__DEFINES/jobs.dm

/datum/outfit/job/deputy
	name = "Deputy"
	jobtype = /datum/job/deputy

	belt = /obj/item/storage/belt/security/deputy
	ears = /obj/item/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/rank/security/officer/mallcop/deputy
	accessory = /obj/item/clothing/accessory/armband/deputy
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/hud/security/deputy
	head = /obj/item/clothing/head/soft/sec
	l_pocket = /obj/item/pda/security

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival
	
/obj/item/card/deputy_access_card
	name = "deputy assignment card"
	desc = "A small card, that when used on any ID, will grant basic security access and the role of Deputy."
	icon_state = "data_1"

/obj/item/card/deputy_access_card/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(istype(AM, /obj/item/card/id) && proximity)
		var/obj/item/card/id/I = AM
		I.assignment = "Deputy"
		I.access |=	ACCESS_SEC_DOORS
		I.access |= ACCESS_MAINT_TUNNELS
		I.access |= ACCESS_COURT
		I.access |= ACCESS_BRIG
		I.access |= ACCESS_WEAPONS
		to_chat(user, "You have been assigned as deputy.")
		log_id("[key_name(user)] added basic security access to '[I]' using [src] at [AREACOORD(user)].")
		qdel(src)
