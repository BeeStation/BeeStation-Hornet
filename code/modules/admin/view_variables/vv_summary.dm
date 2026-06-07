/datum/proc/get_vv_grand_summary()
	SHOULD_NOT_OVERRIDE(TRUE)
	var/output_first = get_vv_summary_table()
	output_first = output_first ? "<b>Summary:</b>[output_first]" : ""
	var/output_second = get_vv_summary_table_fingerprint()
	output_second = output_second ? "<b>Fingerprints:</b><ul class='data-column'>[output_second]</ul>" : ""

	var/bar = length(output_first) && length(output_second) ? "<hr>" : ""

	var/output = "[output_first][bar][output_second]"
	return output ? "<hr><div>[output]</div>" : ""
//-------------------------------
/// Wraps the vv summary data
/datum/proc/get_vv_summary_table(summary_title = null)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/output = get_vv_summary_data()
	if(output)
		if(summary_title)
			return "<li>[summary_title]</li><ul>[output]</ul>"
		return "<ul class='data-column'>[output]</ul>"
	return null

//-------------------------------
// a little bit snowflake
/datum/proc/get_vv_summary_table_fingerprint()
	return

/atom/get_vv_summary_table_fingerprint()
	if(isnull(forensics) && isnull(fingerprintslast))
		return

	var/list/result = list()
	for(var/each_ckey, each_value in forensics.hiddenprints)
		result += "<li>[each_ckey]</br>[replacetext(each_value, ascii2text(10), "</br>")]</li>"

	if(!length(result) && isnull(fingerprintslast))
		return
	return {"
	<li>Last Fingerprint : [fingerprintslast || "(No one)"]</li>
	[length(result) ? "<hr><b>Hidden Prints</b>[result.Join()]" : ""]
	"}

/mob/living/get_vv_summary_table_fingerprint()
	if(timeofdeath)
		return "[..()]<li>Time of Death: [gameTimestamp(wtime = world.time - timeofdeath)] ([DisplayTimeText(timeofdeath - world.time)])</li>"
	return ..()

//-------------------------------
// Note: Rather than putting these in individual files, I decided to contain them all here.
/// Returns the summary data of a variable. This is meant to use override.
/datum/proc/get_vv_summary_data()
	return

// Base of /datum/status_effect
/datum/status_effect/get_vv_summary_data()
	return "<li>[id][alert_type ? "([alert_type::name])" : ""] / [duration == STATUS_EFFECT_PERMANENT ? "Duration: Permanent" : "Time Left: [DisplayTimeText(duration - world.time)]"][get_vv_summary_subdata()]</li>"

/datum/status_effect/inebriated/get_vv_summary_data()
	return "<li>[id] / drunk_value: [drunk_value] </li>"

/datum/status_effect/proc/get_vv_summary_subdata()
	return

/datum/status_effect/food/get_vv_summary_subdata()
	return "/ strength: [strength]"

/datum/status_effect/stacking/get_vv_summary_subdata()
	return "/ stacks: [stacks]"

/datum/status_effect/limited_buff/get_vv_summary_subdata()
	return "/ stacks: ([stacks]/[max_stacks])"

/datum/status_effect/in_love/get_vv_summary_subdata()
	return "/ Lover: [date]"

/datum/status_effect/offering/get_vv_summary_subdata()
	return "/ Offering [offered_item] to [possible_takers[1]][length(possible_takers) > 1 ? "(total [length(possible_takers)] people)" : ""]"



/datum/controller/subsystem/get_vv_summary_data()
	return {"
	<li>[name] ([type])</li>
	[length(dependencies) ? "<li>Dependencies:</li><ul><li>[dependencies.Join("</li><li>")]</li></ul>" : ""]
	[length(dependents) ? "<li>Dependents:</li><ul><li>[dependents.Join("</li><li>")]</li></ul>" : ""]
	<li>wait: [wait]</li>
	<li>init_order: [init_order]</li>
	<li>priority: [priority]</li>
	<li>can_fire: [can_fire]</li>
	<li>state: [state]</li>
	<li>queue:</li>
	<ul><li>Before: [queue_prev ? "[queue_prev.name] ([queue_prev.type])" : "null"]</li>
	<li>This: [name] ([type])</li>
	<li>Next: [queue_next ? "[queue_next.name] ([queue_next.type])" : "null"]</li>
	"}

/atom/get_vv_summary_data()
	return {"
	<li>atom_integrity: [atom_integrity]/[max_integrity]</li>
	"}

// Base of /mob
/mob/get_vv_summary_data()
	var/turf/my_loc = get_turf(src)
	var/area/my_area = get_area(my_loc)
	return {"
	<li>Name : [name]</li>
	<li>Mind : [mind?.name || "(no mind)"]
	<li>Loc : x[my_loc?.x] | y[my_loc?.y] | z[my_loc?.z] (area: [my_area?.name])
	<li>Client : [client?.key || "(no client)"]</li>
	"}

/mob/living/get_vv_summary_data()
	var/list/status_effects_result = list()
	for(var/datum/status_effect/each_effect in status_effects)
		status_effects_result += each_effect.get_vv_summary_data()
	status_effects_result = length(status_effects_result) ? "<li>Status Effects:</li><ul>[status_effects_result.Join()]</ul>" : ""

	var/list/component_result = list()
	for(var/datum/component/each_component in datum_components[/datum/component])
		var/result_text = each_component.get_vv_summary_data()
		if(!result_text) // There are a few components that we really do not care
			continue
		component_result += result_text
	component_result = length(component_result) ? "<li>Important Components:</li><ul>[component_result.Join()]</ul>" : ""

	var/list/status_traits_result = status_traits.Join(" | ")
	if(length(status_traits_result))
		status_traits_result = "<li>Status Traits: [status_traits_result]</li>"

	return "[..()]<hr>[status_effects_result][component_result][status_traits_result]"

/datum/component/irradiated/get_vv_summary_data()
	return "<li>Irradiated / intensity: [intensity] / trying_to_burn: [trying_to_burn ? "TRUE" : "FALSE"]</li>"

/mob/living/carbon/get_vv_summary_data()
	var/list/result = list()
	for(var/obj/item/organ/each_organ as anything in internal_organs)
		result += "[each_organ.name] [each_organ.damage]/[each_organ.maxHealth][each_organ.organ_flags & ORGAN_FAILING ? " <b>(FAILED)</b>" : ""]"
	var/list/chem_result = list()
	if(reagents)
		for(var/datum/reagent/each_chem as anything in reagents.reagent_list)
			chem_result += "[each_chem.name]([each_chem.volume]u)"

	var/dna_summary = dna?.get_vv_summary_data()
	return {"[..()]
	<li>Damages : BRUTE [getBruteLoss()] | BURN [getFireLoss()] | TOX [getToxLoss()] | OXY [getOxyLoss()] | CLONE [getCloneLoss()] | STAM [getStaminaLoss()]</li>
	[dna_summary]
	[length(result)		 ? "<li>Organs : [result.Join(" | ")]</li>" : ""]
	[length(chem_result) ? "<li>Chems : [chem_result.Join(" | ")]</li>" : ""]
	"}

/datum/dna/get_vv_summary_data()
	var/list/result = list()
	for(var/datum/mutation/each_mutation as anything in mutations)
		result += "[each_mutation.name]"
	return {"
	<li>Species: [species?.name || "(UNKNOWN)"]  |  Bloodtype: [blood_type]</li>
	<li>Active Mutations (Remaining stability: [stability])</li>
	[length(result) ? "<ul><li>[result.Join(" | ")]</ul></li>" : ""]
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
		result += "<li>[gases[each_gas_id][GAS_META][META_GAS_NAME]]: [round(gases[each_gas_id][MOLES], 0.01)] mol ([round(gas_concentration*100, 0.01)] %)</li>"

	var/list/reaction_result = list()
	for(var/each_reaction_type, each_value in reaction_results)
		var/datum/gas_reaction/reaction_datum = each_reaction_type
		reaction_result += "<li>[reaction_datum::name] : [each_value]</li>"

	var/temperature = return_temperature()
	return {"
	<li>Total Moles: [total_moles]</li>
	[length(result) ? "<ul>[result.Join()]</ul>" : ""]
	<li>Temperature: [round(temperature - T0C, 0.01)] Celcius ([round(temperature, 0.01)] K)</li>
	<li>Volume: [return_volume()]</li>
	<li>Pressure: [return_pressure()]</li>
	[length(reaction_result) ? "<li>reaction_results:</li><ul>[reaction_result.Join()]</ul>" : ""]
	"}

/obj/machinery/portable_atmospherics/get_vv_summary_data()
	if(air_contents)
		return air_contents.get_vv_summary_data()
	return null

/obj/machinery/atmospherics/components/get_vv_summary_data()
	var/list/result = list()
	var/count = 1
	for(var/datum/gas_mixture/each_mix as anything in airs)
		result += each_mix.get_vv_summary_table("Gas group [count++]")
	return result.Join()

/turf/open/get_vv_summary_data()
	return "[..()][air.get_vv_summary_table("Turf Atmos:")]"

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
		beaker_result_text = beaker.reagents.get_vv_summary_table(summary_title = "Beaker")

	var/chem_result_text
	if(reagents)
		chem_result_text = reagents.get_vv_summary_table(summary_title = "Internal reagent container")

	return "[length(comp_result) ? "<li>Parts : [comp_result.Join(" | ")]</li>" : ""][beaker_result_text][chem_result_text]"

/obj/machinery/sleeper/get_vv_summary_data()
	var/list/result = list()
	for(var/obj/item/reagent_containers/each_vial as anything in inserted_vials)
		result += each_vial.get_vv_summary_table(each_vial.name)
	return "[..()][result.Join()]"

/obj/machinery/power/smes/get_vv_summary_data()
	return {"[..()]
	<li>Power Status : [display_power(charge)]([charge]) / [display_power(capacity)]([capacity])</li>
	<li>Input([inputting ? "ON" : "OFF"]): [input_level] / [input_level_max]</li>
	<li>Output([outputting ? "ON" : "OFF"]): [output_level] / [output_level_max]</li>
	"}

/obj/machinery/power/apc/get_vv_summary_data()
	return cell ? cell.get_vv_summary_data() : ""

/obj/item/stock_parts/cell/get_vv_summary_data()
	return "<li>Power : [display_power(charge)]([charge])/[display_power(maxcharge)]([maxcharge]) ([round(src.percent())]%)</li>"

/obj/item/stock_parts/get_vv_summary_data()
	return "<li>Rating : [rating]</li>"

/obj/item/encryptionkey/get_vv_summary_data()
	return "<li>[name] / Channels: [channels.Join(" | ")]</li>"

/obj/item/radio/get_vv_summary_data()
	return "<li>Freq: [frequency] / Channels: [channels.Join(" | ")]</li>[keyslot?.get_vv_summary_table("Keyslot1")]"

/obj/item/radio/headset/get_vv_summary_data()
	return "[..()][keyslot2?.get_vv_summary_table("Keyslot2")]"
