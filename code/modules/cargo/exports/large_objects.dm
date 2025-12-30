/datum/export/large/reagent_dispenser
	cost = 100 // +0-400 depending on amount of reagents left
	var/contents_cost = 400

/datum/export/large/reagent_dispenser/get_cost(obj/O)
	var/obj/structure/reagent_dispensers/D = O
	var/ratio = D.reagents.total_volume / D.reagents.maximum_volume

	return ..() + round(contents_cost * ratio)

/datum/export/large/reagent_dispenser/water
	unit_name = "watertank"
	export_types = list(
		/obj/structure/reagent_dispensers/watertank = TRUE,
	)
	contents_cost = 200

/datum/export/large/reagent_dispenser/fuel
	unit_name = "fueltank"
	export_types = list(
		/obj/structure/reagent_dispensers/fueltank = TRUE,
	)

/datum/export/large/reagent_dispenser/beer
	unit_name = "beer keg"
	contents_cost = 700
	export_types = list(
		/obj/structure/reagent_dispensers/beerkeg = TRUE,
	)

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
	unit_name = "Gas Canister"
	export_types = list(
		/obj/machinery/portable_atmospherics/canister = TRUE,
	)

/datum/export/large/gas_canister/get_cost(obj/O)
	var/obj/machinery/portable_atmospherics/canister/C = O
	var/worth = C.item_price
	var/datum/gas_mixture/canister_mix = C.return_air()
	var/canister_gas = canister_mix.gases

	for(var/id in canister_gas)
		var/datum/gas/path = gas_id2path(id)
		var/moles = canister_gas[id][MOLES]
		if(moles > 0)
			worth += SSdemand.get_gas_value(path, moles)

	canister_mix.garbage_collect()
	return worth

/datum/export/large/gas_canister/get_amount(obj/O)
	var/obj/machinery/portable_atmospherics/canister/C = O
	var/datum/gas_mixture/canister_mix = C.return_air()
	var/canister_gas = canister_mix.gases

	var/dominant_id = null
	var/dominant_moles = 0
	var/total_moles = 0

	for(var/id in canister_gas)
		var/moles = canister_gas[id][MOLES]
		if(moles > 0)
			total_moles += moles
			if(moles > dominant_moles)
				dominant_moles = moles
				dominant_id = id

	if(total_moles <= 0)
		return 0

	if(dominant_id)
		var/gas_name = canister_gas[dominant_id][GAS_META][META_GAS_NAME]
		unit_name = "Mole - Gas Canister: [gas_name]"
	else
		unit_name = "Mole - Mixed Gases Canister"

	return total_moles

/datum/export/large/gas_canister/sell_object(obj/O, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO)
	var/obj/machinery/portable_atmospherics/canister/C = O
	var/datum/gas_mixture/canister_mix = C.return_air()
	var/canister_gas = canister_mix.gases

	// Total value & amount already calculated by existing procs
	var/total_value = get_cost(O)
	var/total_moles = get_amount(O)

	report.total_value[src] += total_value
	report.total_amount[src] += total_moles

	// Reduce demand for each gas sold
	for(var/id in canister_gas)
		var/datum/gas/path = gas_id2path(id)
		var/moles = canister_gas[id][MOLES]
		if(moles <= 0)
			return
		if(!dry_run)
			var/datum/demand_state/state = SSdemand.get_demand_state(path)
			state.current_demand = max(0, state.current_demand - moles)
			SSblackbox.record_feedback("nested tally", "export_sold_cost", 1, list("[O.type]", "[total_value]"))

	return TRUE
