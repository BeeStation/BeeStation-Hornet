//This is where all syndicate circuits unlocked after the syndicate upgrade goes
//by nuclearmayhem

/obj/item/integrated_circuit/syndicate
	category_text = "Illegal"
	power_draw_per_use = 5

/obj/item/integrated_circuit/syndicate/teleporter
	name = "teleportation circuit"
	desc = "lets you teleport."
	extended_desc = "lets you teleport."
	icon_state = "speaker"
	cooldown_per_use = 100
	complexity = 12
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

	do_teleport(teleportee,target,0)