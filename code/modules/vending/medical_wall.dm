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
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = 25
	extra_price = 100
	payment_department = ACCOUNT_MED
	tiltable = FALSE

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/machinery/vending/wallmed/pubby
	products = list(/obj/item/reagent_containers/syringe = 3,
					/obj/item/reagent_containers/pill/patch/styptic = 1,
					/obj/item/reagent_containers/pill/patch/silver_sulf = 1,
					/obj/item/reagent_containers/medspray/sterilizine = 1)
