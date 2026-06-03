/// Returns the summary data of a variable. This is meant to use override.
/datum/proc/get_vv_summary_data()
	return

/// Wraps the vv summary data
/datum/proc/_get_vv_summary(summary_title)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/output = get_vv_summary_data()
	if(output)
		if(summary_title)
			return "<li>[summary_title]</li><ul class='data-column'>[output]</ul>"
		return "<ul class='data-column'>[output]</ul>"
	return null

// Note: Rather than putting these in individual files, I decided to contain them all here.

// Base of /mob
/mob/get_vv_summary_data()
	var/turf/my_loc = get_turf(src)
	var/area/my_area = get_area(my_loc)
	return {"
	<li>Name : [name]</li>
	<li>Mind : [mind?.name || "(no mind)"]
	<li>Loc : x[my_loc.x] | y[my_loc.y] | z[my_loc.z] (area: [my_area.name])
	<li>Client : [client?.key || "(no client)"]</li>
	"}

/mob/living/carbon/get_vv_summary_data()
	var/list/result = list()
	for(var/obj/item/organ/each_organ as anything in internal_organs)
		result += "[each_organ.name] [each_organ.damage]/[each_organ.maxHealth][each_organ.organ_flags & ORGAN_FAILING ? " <b>(FAILED)</b>" : ""]"
	var/list/chem_result = list()
	if(reagents)
		for(var/datum/reagent/each_chem as anything in reagents.reagent_list)
			chem_result += "[each_chem.name]([each_chem.volume]u)"

	return {"[..()]
	<li>Species : [dna?.species?.name || "(UNKNOWN)"]</li>
	<li>Damages : BRUTE [getBruteLoss()] | BURN [getFireLoss()] | TOX [getToxLoss()] | OXY [getOxyLoss()] | CLONE [getCloneLoss()] | STAM [getStaminaLoss()]</li>
	[length(result)		 ? "<li>Organs : [result.Join(" | ")]</li>" : ""]
	[length(chem_result) ? "<li>Chems : [chem_result.Join(" | ")]</li>" : ""]
	"}

/mob/living/simple_animal/revenant/get_vv_summary_data()
	return {"[..()]
	<li>Essence : [essence] (+[essence_regen_amount]/per tick, Max: [essence_regen_cap])</li>
	<li>Stolen Essnce: [essence_accumulated]</li>
	<li>Unused stolen essence: [essence_excess]</li>
	<li>Stolen perfect souls: [perfectsouls]</li>"}


// Atmos related stuff
/datum/gas_mixture/get_vv_summary_data()
	var/total_moles = total_moles()
	var/list/result = list()
	for(var/each_gas_id as anything in gases)
		var/gas_concentration = gases[each_gas_id][MOLES]/total_moles
		result += "[gases[each_gas_id][GAS_META][META_GAS_NAME]]: [round(gases[each_gas_id][MOLES], 0.01)] mol ([round(gas_concentration*100, 0.01)] %)"
	return {"
	<li>Total Moles : [total_moles]</li>
	<li>Gases: [result.Join(" | ")]</li>
	<li>Temp: [temperature]K</li>
	<li>Volume: [return_volume()]</li>
	<li>Pressure: [return_pressure()]</li>
	<li>Thermal Energy: [thermal_energy()]</li>
	"}

/obj/machinery/portable_atmospherics/get_vv_summary_data()
	if(air_contents)
		return air_contents.get_vv_summary_data()
	return null

/obj/machinery/atmospherics/components/get_vv_summary_data()
	var/list/result = list()
	var/count = 1
	for(var/datum/gas_mixture/each_mix as anything in airs)
		result += each_mix._get_vv_summary("Gas group [count++]")
	return result.Join()

// Reagent & Chem stuff
/datum/reagents/get_vv_summary_data()
	var/list/result = list()
	for(var/datum/reagent/each_chem as anything in reagent_list)
		result += "[each_chem.name]([each_chem.volume]u)"

	return {"
	<li>Volume : [total_volume]u / [maximum_volume]u</li>
	<li>Temp : [chem_temp]K</li>
	<li>Chems: [result.Join(" / ") || "(none)"]</li>"}

/obj/item/reagent_containers/get_vv_summary_data()
	return reagents?.get_vv_summary_data()

// Base of /obj
/obj/machinery/get_vv_summary_data()
	var/list/comp_result
	if(length(component_parts))
		comp_result = list()
		for(var/obj/item/each_part in component_parts)
			comp_result += "[each_part.name]"

	var/beaker_result_text
	var/obj/item/reagent_containers/beaker = hasvar(src, "beaker") && src.vars["beaker"]  // I don't like this, but there are a few hardcoded machines. Note: NAMEOF_STATIC(thing, beaker) makes this damn long. I just used raw string.
	if(istype(beaker, /obj/item/reagent_containers))
		beaker_result_text = beaker.reagents._get_vv_summary(summary_title = "Beaker")

	var/chem_result_text
	if(reagents)
		chem_result_text = reagents._get_vv_summary(summary_title = "Internal reagent container")

	return "[length(comp_result) ? "<li>Parts : [comp_result.Join(" | ")]</li>" : ""][beaker_result_text][chem_result_text]"

/obj/machinery/sleeper/get_vv_summary_data()
	var/list/result = list()
	for(var/obj/item/reagent_containers/each_vial as anything in inserted_vials)
		result += each_vial._get_vv_summary(each_vial.name)
	return "[..()][result.Join()]"

/obj/machinery/power/smes/get_vv_summary_data()
	return {"[..()]
	<li>Power Status : [charge] / [capacity]</li>
	<li>Input([inputting ? "ON" : "OFF"]): [input_level] / [input_level_max]</li>
	<li>Output([outputting ? "ON" : "OFF"]): [output_level] / [output_level_max]</li>
	"}

/obj/item/stock_parts/cell/get_vv_summary_data()
	return "<li>Power : [charge]/[maxcharge] ([round(src.percent())]%)</li>"

/obj/item/stock_parts/get_vv_summary_data()
	return "<li>Rating : [rating]</li>"

/obj/item/encryptionkey/get_vv_summary_data()
	return "<li>Channels: [channels.Join(" | ")]</li>"

/obj/item/radio/get_vv_summary_data()
	return "<li>Freq: [frequency]</li><li>Channels:[channels.Join(" | ")]</li>[keyslot?._get_vv_summary("Keyslot1")]"

/obj/item/radio/headset/get_vv_summary_data()
	return "[..()][keyslot2?._get_vv_summary("Keyslot2")]"
