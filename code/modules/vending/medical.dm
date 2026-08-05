/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(ACCESS_MEDICAL)
	products = list(/obj/item/reagent_containers/syringe = 12,
					/obj/item/reagent_containers/dropper = 3,
					/obj/item/reagent_containers/medspray = 6,
					/obj/item/storage/pill_bottle = 6,
					/obj/item/reagent_containers/cup/bottle = 10,
					/obj/item/reagent_containers/spray/cleaner = 1,
					/obj/item/stack/medical/gauze = 8,
					/obj/item/reagent_containers/hypospray/medipen = 8,
					/obj/item/reagent_containers/hypospray/medipen/dexalin = 8,
					/obj/item/reagent_containers/cup/bottle/epinephrine = 4,
					/obj/item/reagent_containers/cup/bottle/charcoal = 4,
					/obj/item/reagent_containers/cup/bottle/salglu_solution = 4,
					/obj/item/reagent_containers/cup/bottle/tricordrazine = 1,
					/obj/item/reagent_containers/cup/bottle/spaceacillin = 1,
					/obj/item/reagent_containers/cup/bottle/morphine = 2,
					/obj/item/reagent_containers/cup/bottle/toxin = 4,
					/obj/item/reagent_containers/medspray/sterilizine = 4)
	contraband = list(/obj/item/reagent_containers/cup/bottle/chloralhydrate = 1,
						/obj/item/storage/box/hug/medical = 1,
						/obj/item/reagent_containers/cup/bottle/random_virus = 1)
	premium = list(
		/obj/item/storage/firstaid/regular = 3,
		/obj/item/storage/belt/medical = 3,
		/obj/item/sensor_device = 2,
		/obj/item/pinpointer/crew = 2,
		/obj/item/healthanalyzer = 2,
		/obj/item/wrench/medical = 1
		)
	armor_type = /datum/armor/vending_medical
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/medical
	default_price = 25
	extra_price = 100
	light_mask = "med-light-mask"

/datum/armor/vending_medical
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50

/obj/item/vending_refill/medical
	machine_name = "NanoMed Plus"
	icon_state = "refill_medical"

/obj/machinery/vending/medical/syndicate_access
	name = "\improper SyndiMed Plus"
	req_access = list(ACCESS_SYNDICATE)
	initial_language_holder = /datum/language_holder/syndicate
