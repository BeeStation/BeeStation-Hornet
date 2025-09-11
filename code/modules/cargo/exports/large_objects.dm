/datum/export/large/reagent_dispenser
	cost = 100 // +0-400 depending on amount of reagents left
	var/contents_cost = 400

/datum/export/large/reagent_dispenser/get_cost(obj/O)
	var/obj/structure/reagent_dispensers/D = O
	var/ratio = D.reagents.total_volume / D.reagents.maximum_volume

	return ..() + round(contents_cost * ratio)

/datum/export/large/reagent_dispenser/water
	unit_name = "watertank"
	export_types = list(/obj/structure/reagent_dispensers/watertank)
	contents_cost = 200

/datum/export/large/reagent_dispenser/fuel
	unit_name = "fueltank"
	export_types = list(/obj/structure/reagent_dispensers/fueltank)

/datum/export/large/reagent_dispenser/beer
	unit_name = "beer keg"
	contents_cost = 700
	export_types = list(/obj/structure/reagent_dispensers/beerkeg)

/**
 * Gas canister exports.
 * I'm going to put a quick aside here as this has been a pain to balance for several years now, and I'd like to at least break how to keep gas exports tame.
 * So: Gasses are sold in canisters below, which have a variable amount of maximum pressure before they start to break. The largest of which is 9.2e13 kPa.
 * This means we can determine a theoretical maximum value for gas sale prices using the ideal gas laws, as we know we have a minimum gas temperature of 2.7 kelvin.
 *
 * Additional note on base value. Gasses are soft capped to limit how much they're worth at large quantities, and time and time again players will find new ways to break your gasses.
 * so please, *PLEASE* try not to go too much further past 10.

 * * AUTHORS NOTE: This means the theoretical, insane madman number of moles of a single gas in a can sits at a horrifying 4,098,150,709.4 moles.
 * * Use this as you will, and when someone makes a quinquadrillion credits using gas exports, use these metrics as a way to balance the bejesus out of them.
 * * For more information, see code\modules\atmospherics\machinery\portable\canister.dm.
 */
/datum/export/large/gas_canister
	cost = 10 //Base cost of canister. You get more for nice gases inside.
	unit_name = "Gas Canister"
	export_types = list(/obj/machinery/portable_atmospherics/canister)

/datum/export/large/gas_canister/get_cost(obj/O)
	var/obj/machinery/portable_atmospherics/canister/C = O
	var/worth = cost
	var/datum/gas_mixture/canister_mix = C.return_air()
	var/canister_gas = canister_mix.gases
	var/list/gases_to_check = list(
		/datum/gas/bz,
		/datum/gas/nitrium,
		/datum/gas/hypernoblium,
		/datum/gas/tritium,
		/datum/gas/pluoxium,
		/datum/gas/water_vapor,
	)

	for(var/gasID in gases_to_check)
		canister_mix.assert_gas(gasID)
		if(canister_gas[gasID][MOLES] > 0)
			worth += get_gas_value(gasID, canister_gas[gasID][MOLES])

	canister_mix.garbage_collect()
	return worth

/datum/export/large/gas_canister/proc/get_gas_value(datum/gas/gasType, moles)
	var/baseValue = initial(gasType.base_value)
	return round((baseValue/k_elasticity) * (1 - NUM_E**(-1 * k_elasticity * moles)))
