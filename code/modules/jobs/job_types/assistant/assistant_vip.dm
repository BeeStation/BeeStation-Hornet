/datum/job/assistant/vip
	g_jkey = JOB_KEY_VIP
	g_jtitle = JOB_TITLE_VIP
	job_bitflags = JOB_BITFLAG_GIMMICK | JOB_BITFLAG_MANAGE_LOCKED
	department_head = list()
	antag_rep = 3 // you're having fun with shitton of money already
	total_positions = 0
	spawn_positions = 0

	outfit = /datum/outfit/job/vip

	access = list(ACCESS_MAINT_TUNNELS) //Assistants with shitloads of money, what could go wrong?
	minimal_access = list(ACCESS_MAINT_TUNNELS)

	departments = DEPT_BITFLAG_VIP
	bank_account_department = ACCOUNT_VIP_BITFLAG
	payment_per_department = list(ACCOUNT_VIP_ID = PAYCHECK_VIP)  //our power is being fucking rich

	rpg_title = "Master of Patronage"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/vip
	)

/datum/job/assistant/vip/notify_your_supervisor()
	return "yourself"

/datum/outfit/job/vip
	name = JOB_KEY_VIP
	jobtype = /datum/job/assistant/vip
	id = /obj/item/card/id/gold/vip
	belt = /obj/item/modular_computer/tablet/pda/vip
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset/heads //VIP can talk loud for no reason
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	can_be_admin_equipped = TRUE
