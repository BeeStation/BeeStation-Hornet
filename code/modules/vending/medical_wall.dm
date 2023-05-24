/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = FALSE
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/reagent_containers/syringe = 3,
					/obj/item/stack/medical/gauze = 4,
					/obj/item/reagent_containers/hypospray/medipen = 3,
					/obj/item/reagent_containers/hypospray/medipen/dexalin = 3,
					/obj/item/reagent_containers/glass/bottle/epinephrine = 2,
					/obj/item/reagent_containers/glass/bottle/charcoal = 2,
					/obj/item/reagent_containers/medspray/sterilizine = 3)
	contraband = list(/obj/item/reagent_containers/glass/bottle/toxin = 1,
	                  /obj/item/reagent_containers/glass/bottle/morphine = 1)
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50, STAMINA = 0)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = 25
	extra_price = 100
	dept_req_for_free = ACCOUNT_MED_BITFLAG
	tiltable = FALSE

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/machinery/vending/wallmed/pubby
	products = list(/obj/item/reagent_containers/syringe = 3,
					/obj/item/reagent_containers/pill/patch/styptic = 1,
					/obj/item/reagent_containers/pill/patch/silver_sulf = 1,
					/obj/item/reagent_containers/medspray/sterilizine = 1)
