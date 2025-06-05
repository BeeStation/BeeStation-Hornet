/datum/job/vip

	title = JOB_NAME_VIP
	description = "Be the 1%, use your capital to get even richer, flaunt around your wealth, organize posh parties and other high life activities with your near-bottomless budget."
	department_for_prefs = DEPT_NAME_CIVILIAN
	supervisors = "Capital"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/vip

	base_access = list(ACCESS_MAINT_TUNNELS) //Assistants with shitloads of money, what could go wrong?
	extra_access = list()

	departments = DEPT_BITFLAG_VIP
	bank_account_department = ACCOUNT_VIP_BITFLAG
	payment_per_department = list(ACCOUNT_VIP_ID = PAYCHECK_VIP)  //our power is being fucking rich

	display_order = JOB_DISPLAY_ORDER_VIP
	rpg_title = "Master of Patronage"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/vip
	)

/datum/outfit/job/vip
	name = JOB_NAME_VIP
	jobtype = /datum/job/vip
	id = /obj/item/card/id/gold/vip
	belt = /obj/item/modular_computer/tablet/pda/vip
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset/heads //VIP can talk loud for no reason
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	can_be_admin_equipped = TRUE
