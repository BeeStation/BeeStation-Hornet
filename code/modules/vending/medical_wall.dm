/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = FALSE
	products = list(/obj/item/reagent_containers/syringe = 3,
					/obj/item/stack/medical/gauze = 4,
					/obj/item/reagent_containers/hypospray/medipen = 3,
					/obj/item/reagent_containers/hypospray/medipen/dexalin = 3,
					/obj/item/reagent_containers/cup/bottle/epinephrine = 2,
					/obj/item/reagent_containers/cup/bottle/charcoal = 2,
					/obj/item/reagent_containers/medspray/sterilizine = 3)
	contraband = list(/obj/item/reagent_containers/cup/bottle/toxin = 1,
						/obj/item/reagent_containers/cup/bottle/morphine = 1)
	armor_type = /datum/armor/vending_wallmed
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = 25
	extra_price = 100
	tiltable = FALSE
	light_mask = "wallmed-light-mask"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/vending/wallmed, 32)

/datum/armor/vending_wallmed
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"

/obj/machinery/vending/wallmed/lite
	name = "\improper NanoMed Lite"
	desc = "Wall-mounted Medical Equipment dispenser with less items than usual."
	products = list(/obj/item/reagent_containers/syringe = 3,
					/obj/item/reagent_containers/pill/patch/styptic = 1,
					/obj/item/reagent_containers/pill/patch/silver_sulf = 1,
					/obj/item/reagent_containers/medspray/sterilizine = 1)
