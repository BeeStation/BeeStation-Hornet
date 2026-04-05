/**
 * # Event Cargo Crates
 *
 * Crates used internally by events (shuttle loans, etc.) that aren't normally orderable.
 * These use special = TRUE so they don't appear in any cargo console UI.
 */

/datum/cargo_crate/event
	special = TRUE

/datum/cargo_crate/event/specialops
	name = "Special Ops Supplies"
	cost = 4000
	contains = list(
		/obj/item/storage/backpack/duffelbag/syndie/surgery,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m10mm,
	)

/datum/cargo_crate/event/party
	name = "Party Supplies"
	cost = 2000
	contains = list(
		/obj/item/reagent_containers/cup/glass/bottle/vodka,
		/obj/item/reagent_containers/cup/glass/bottle/vodka,
		/obj/item/reagent_containers/cup/glass/drinkingglass,
		/obj/item/reagent_containers/cup/glass/drinkingglass,
		/obj/item/reagent_containers/cup/glass/drinkingglass,
		/obj/item/reagent_containers/cup/glass/drinkingglass,
	)

/datum/cargo_crate/event/department_emergency
	name = "Emergency Equipment"
	contains = list(
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
	)

/datum/cargo_crate/event/department_security
	name = "Security Supplies"
	contains = list(
		/obj/item/restraints/handcuffs,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight/seclite,
		/obj/item/flashlight/seclite,
	)

/datum/cargo_crate/event/department_food
	name = "Food Supplies"
	contains = list(
		/obj/item/reagent_containers/condiment/flour,
		/obj/item/reagent_containers/condiment/flour,
		/obj/item/reagent_containers/condiment/rice,
		/obj/item/reagent_containers/condiment/sugar,
	)

/datum/cargo_crate/event/department_tools
	name = "Tool Supplies"
	contains = list(
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/mechanical,
	)

/datum/cargo_crate/event/department_medical
	name = "Medical Supplies"
	contains = list(
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/firstaid/regular,
		/obj/item/reagent_containers/cup/bottle/epinephrine,
		/obj/item/reagent_containers/cup/bottle/epinephrine,
	)

/datum/cargo_crate/event/beekeeping
	name = "Beekeeping Starter Kit"
	contains = list(
		/obj/structure/beebox/unwrenched,
		/obj/item/queen_bee/bought,
		/obj/item/honey_frame,
		/obj/item/honey_frame,
		/obj/item/honey_frame,
		/obj/item/clothing/suit/utility/beekeeper_suit,
		/obj/item/clothing/head/utility/beekeeper_head,
		/obj/item/melee/flyswatter,
	)
	crate_type = /obj/structure/closet/crate/hydroponics
