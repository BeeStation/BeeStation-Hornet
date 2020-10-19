//This is where all syndicate circuits unlocked after the syndicate upgrade goes
//by nuclearmayhem

/obj/item/integrated_circuit/syndicate
	category_text = "Illegal"
	power_draw_per_use = 5

/obj/item/integrated_circuit/syndicate/teleporter
	name = "teleportation circuit"
	desc = "lets you teleport."
	extended_desc = "teleports the selected ref to the absolute x,y coordinates on the same z level."
	icon_state = "syndicate_teleporter"
	cooldown_per_use = 100
	complexity = 20
	inputs = list("X" = IC_PINTYPE_NUMBER,"Y" = IC_PINTYPE_NUMBER, "REF to teleport" = IC_PINTYPE_REF)
	outputs = list()
	activators = list("Teleport" = IC_PINTYPE_PULSE_IN)
	power_draw_per_use = 14000000
	spawn_flags = IC_SPAWN_SYNDICATE

/obj/item/integrated_circuit/syndicate/teleporter/do_work()
	var/teleportee = get_pin_data_as_type(IC_INPUT, 3, /atom)
	var/x = CLAMP(get_pin_data(IC_INPUT, 1), 0, world.maxx)
	var/y = CLAMP(get_pin_data(IC_INPUT, 2), 0, world.maxy)
	var/turf/t = get_turf(teleportee)
	var/turf/target = locate(x, y, t.z)
	playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, TRUE)
	do_teleport(teleportee,target,0)

/obj/item/integrated_circuit/syndicate/ammo_printer
	name = "ammo printer"
	desc = "lets you print ammo."
	extended_desc = "lets you print ammo by its name the names are 10mm, 10mmap, 10mmhp, 10mmfire, 9mm, 9mmap, 9mminc."
	icon_state = "syndicate_teleporter"
	cooldown_per_use = 10
	complexity = 15
	inputs = list("Ammostring" = IC_PINTYPE_STRING)
	outputs = list()
	activators = list("print" = IC_PINTYPE_PULSE_IN)
	power_draw_per_use = 270000
	spawn_flags = IC_SPAWN_SYNDICATE
	//if you whant to have it spawn more types of ammo add the path and name like this
	var/valid_ammo = list(
		"10mm"			=	/obj/item/ammo_casing/c10mm,
		"10mmap"		=	/obj/item/ammo_casing/c10mm/ap,
		"10mmhp"		=	/obj/item/ammo_casing/c10mm/hp,
		"10mmfire"		=	/obj/item/ammo_casing/c10mm/fire,
		"9mm"			=	/obj/item/ammo_casing/c9mm,
		"9mmap"			=	/obj/item/ammo_casing/c9mm/ap,
		"9mminc"		=	/obj/item/ammo_casing/c9mm/inc,
	)

/obj/item/integrated_circuit/syndicate/ammo_printer/do_work()
	var/obj/ammotype = valid_ammo[get_pin_data(IC_INPUT,1)]
	if(ammotype == null)
		return
	spawn_atom_to_turf(ammotype, src.loc, 1, FALSE)

/obj/item/integrated_circuit/syndicate/electronics_detonator
	name = "electronics detonator"
	desc = "detonates machinery."
	extended_desc = "detonates selected machinery."
	icon_state = "syndicate_teleporter"
	cooldown_per_use = 10
	complexity = 20
	inputs = list("ref of machine to detonate" = IC_PINTYPE_REF)
	outputs = list()
	activators = list("detonate" = IC_PINTYPE_PULSE_IN)
	power_draw_per_use = 5000000
	spawn_flags = IC_SPAWN_SYNDICATE


/obj/item/integrated_circuit/syndicate/electronics_detonator/do_work()
	var/obj/machine = get_pin_data_as_type(IC_INPUT, 1, /atom)
	if(istype(machine, /obj/machinery))
		if(!istype(machine,/obj/machinery/nuclearbomb) && !istype(machine,/obj/machinery/door) && !istype(machine,/obj/machinery/atmospherics) && !istype(machine,/obj/machinery/porta_turret)&& !istype(machine,/obj/machinery/porta_turret_cover)&& !istype(machine,/obj/machinery/portable_atmospherics)&& !istype(machine,/obj/machinery/power)&& !istype(machine,/obj/machinery/keycard_auth)&& !istype(machine,/obj/machinery/button)&& !istype(machine,/obj/machinery/gateway)&& !istype(machine,/obj/machinery/shieldwallgen)&& !istype(machine,/obj/machinery/door_timer)&& !istype(machine,/obj/machinery/airalarm/engine)&& !istype(machine,/obj/machinery/keycard_auth)&& !istype(machine,/obj/machinery/turretid))
			playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25)
			explosion(machine,0,0,0,3,TRUE,FALSE,1,FALSE)
			machine.deconstruct()