#define CELSIUS_TO_KELVIN(T_K)	((T_K) + T0C)

#define OPTIMAL_TEMP_K_PLA_BURN_SCALE(PRESSURE_P,PRESSURE_O,TEMP_O)	(((PRESSURE_P) * GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_SPECIFIC_HEAT]) / (((PRESSURE_P) * GLOB.meta_gas_info[/datum/gas/plasma][META_GAS_SPECIFIC_HEAT] + (PRESSURE_O) * GLOB.meta_gas_info[/datum/gas/oxygen][META_GAS_SPECIFIC_HEAT]) / PLASMA_UPPER_TEMPERATURE - (PRESSURE_O) * GLOB.meta_gas_info[/datum/gas/oxygen][META_GAS_SPECIFIC_HEAT] / CELSIUS_TO_KELVIN(TEMP_O)))
#define OPTIMAL_TEMP_K_PLA_BURN_RATIO(PRESSURE_P,PRESSURE_O,TEMP_O)	(CELSIUS_TO_KELVIN(TEMP_O) * PLASMA_OXYGEN_FULLBURN * (PRESSURE_P) / (PRESSURE_O))

/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	var/temp_p = 1500
	var/temp_o = 1000	// tank temperatures
	var/pressure_p = 10 * ONE_ATMOSPHERE
	var/pressure_o = 10 * ONE_ATMOSPHERE	//tank pressures
	var/assembly_type

/obj/effect/spawner/newbomb/Initialize(mapload)
	. = ..()
	var/obj/item/transfer_valve/V = new(src.loc)
	var/obj/item/tank/internals/plasma/plasma_tank = new(V)
	var/obj/item/tank/internals/oxygen/oxygen_tank = new(V)

	var/datum/gas_mixture/plasma_mix = plasma_tank.return_air()
	var/datum/gas_mixture/oxygen_mix = oxygen_tank.return_air()

	plasma_mix.assert_gas(/datum/gas/plasma)
	plasma_mix.gases[/datum/gas/plasma][MOLES] = pressure_p*plasma_mix.volume/(R_IDEAL_GAS_EQUATION*CELSIUS_TO_KELVIN(temp_p))
	plasma_mix.temperature = CELSIUS_TO_KELVIN(temp_p)

	oxygen_mix.assert_gas(/datum/gas/oxygen)
	oxygen_mix.gases[/datum/gas/oxygen][MOLES] = pressure_o*oxygen_mix.volume/(R_IDEAL_GAS_EQUATION*CELSIUS_TO_KELVIN(temp_o))
	oxygen_mix.temperature = CELSIUS_TO_KELVIN(temp_o)

	V.tank_one = PT
	V.tank_two = OT
	PT.master = V
	OT.master = V

	if(assembly_type)
		var/obj/item/assembly/A = new assembly_type(V)
		V.attached_device = A
		A.holder = V

	V.update_icon()

/obj/effect/spawner/newbomb/timer/syndicate/Initialize(mapload)
	temp_p = (OPTIMAL_TEMP_K_PLA_BURN_SCALE(pressure_p, pressure_o, temp_o)/2 + OPTIMAL_TEMP_K_PLA_BURN_RATIO(pressure_p, pressure_o, temp_o)/2) - T0C
	. = ..()

/obj/effect/spawner/newbomb/timer
	assembly_type = /obj/item/assembly/timer

/obj/effect/spawner/newbomb/timer/syndicate
	pressure_o = TANK_LEAK_PRESSURE - 1
	temp_o = 20

	pressure_p = TANK_LEAK_PRESSURE - 1

/obj/effect/spawner/newbomb/proximity
	assembly_type = /obj/item/assembly/prox_sensor

/obj/effect/spawner/newbomb/radio
	assembly_type = /obj/item/assembly/signaler


#undef CELSIUS_TO_KELVIN

#undef OPTIMAL_TEMP_K_PLA_BURN_SCALE
#undef OPTIMAL_TEMP_K_PLA_BURN_RATIO
