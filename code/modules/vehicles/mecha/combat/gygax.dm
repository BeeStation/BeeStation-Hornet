/obj/vehicle/sealed/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "\improper Gygax"
	icon_state = "gygax"
	base_icon_state = "gygax"
	allow_diagonal_movement = TRUE
	movedelay = 3
	dir_in = 1 //Facing North.
	max_integrity = 250
	deflect_chance = 5
	armor = list("melee" = 25, "bullet" = 20, "laser" = 30, "energy" = 15, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0)
	max_temperature = 25000
	leg_overload_coeff = 80
	force = 25
	wreckage = /obj/structure/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 3
	step_energy_drain = 3

/obj/vehicle/sealed/mecha/combat/gygax/dark
	desc = "A lightweight exosuit, painted in a dark scheme. This model appears to have some modifications."
	name = "\improper Dark Gygax"
	icon_state = "darkgygax"
	max_integrity = 300
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 40, "laser" = 50, "energy" = 35, "bomb" = 20, "bio" = 0, "rad" =20, "fire" = 100, "acid" = 100, "stamina" = 0)
	max_temperature = 35000
	leg_overload_coeff = 70
	operation_req_access = list(ACCESS_SYNDICATE)
	internals_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/gygax/dark
	max_equip = 5
	destruction_sleep_duration = 20

/obj/vehicle/sealed/mecha/combat/gygax/dark/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/thrusters/ion(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)

/obj/vehicle/sealed/mecha/combat/gygax/dark/add_cell(obj/item/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/hyper(src)


/obj/vehicle/sealed/mecha/combat/gygax/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_overload_mode)

/obj/vehicle/sealed/mecha/combat/gygax/dark/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_overload_mode)

