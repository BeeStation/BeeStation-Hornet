/datum/job/shaft_miner
	title = JOB_NAME_SHAFTMINER
	description = "Collect resources for the station, redeem them for points, and purchase gear to collect even more ores."
	department_for_prefs = DEPT_NAME_CARGO
	department_head_for_prefs = JOB_NAME_QUARTERMASTER
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the quartermaster and the head of personnel"
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/miner

	base_access = list(ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE, ACCESS_GATEWAY)
	extra_access = list(ACCESS_QM, ACCESS_CARGO, ACCESS_MAINT_TUNNELS)

	departments = DEPT_BITFLAG_CAR
	bank_account_department = ACCOUNT_CAR_BITFLAG
	payment_per_department = list(ACCOUNT_CAR_ID = PAYCHECK_HARD)

	display_order = JOB_DISPLAY_ORDER_SHAFT_MINER
	rpg_title = "Adventurer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/shaft_miner
	)

	minimal_lightup_areas = list(/area/construction/mining/aux_base)

/datum/outfit/job/miner
	name = JOB_NAME_SHAFTMINER
	jobtype = /datum/job/shaft_miner

	id = /obj/item/card/id/job/shaft_miner
	belt = /obj/item/modular_computer/tablet/pda/shaft_miner
	ears = /obj/item/radio/headset/headset_cargo/shaft_miner
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/storage/bag/ore	//causes issues if spawned in backpack
	backpack_contents = list(
		/obj/item/flashlight/seclite=1,\
		/obj/item/knife/combat/survival=1,\
		/obj/item/mining_voucher=1,\
		/obj/item/stack/marker_beacon/ten=1,\
		/obj/item/discovery_scanner=1)

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag
	box = /obj/item/storage/box/survival/mining

	chameleon_extras = /obj/item/gun/energy/recharge/kinetic_accelerator

/datum/outfit/job/miner/equipped
	name = "Shaft Miner (Equipment)"
	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	backpack_contents = list(
		/obj/item/flashlight/seclite=1,
		/obj/item/knife/combat/survival=1,
		/obj/item/mining_voucher=1,
		/obj/item/t_scanner/adv_mining_scanner/lesser=1,
		)

	l_hand = /obj/item/gun/energy/recharge/kinetic_accelerator

/datum/outfit/job/miner/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	if(istype(H.wear_suit, /obj/item/clothing/suit/hooded))
		var/obj/item/clothing/suit/hooded/S = H.wear_suit
		S.ToggleHood()

/datum/outfit/job/miner/equipped/hardsuit
	name = "Shaft Miner (Equipment + Hardsuit)"
	suit = /obj/item/clothing/suit/space/hardsuit/mining
	mask = /obj/item/clothing/mask/breath

