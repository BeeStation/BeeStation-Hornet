/// Returns the summary data of a variable. This is meant to use override.
/datum/proc/get_vv_summary()
	return


// Note: Rather than putting these in individual files, I decided contain them all here.

// Base of /mob
/mob/get_vv_summary()
	var/turf/my_loc = get_turf(src)
	var/area/my_area = get_area(my_loc)
	return {"<ul class='data-column'>
	<li>Name : [name]</li>
	<li>Mind : [mind?.name || "(no mind)"]
	<li>Loc : x[my_loc.x] | y[my_loc.y] | z[my_loc.z] (area: [my_area.name])
	<li>Client : [client.key]</li>
	</ul>"}

/mob/living/carbon/get_vv_summary()
	var/turf/my_loc = get_turf(src)
	var/area/my_area = get_area(my_loc)

	var/list/result = list()
	for(var/obj/item/organ/each_organ as anything in internal_organs)
		result += "[each_organ.name] [each_organ.damage]/[each_organ.maxHealth][each_organ.organ_flags & ORGAN_FAILING ? " <b>(FAILED)</b>" : ""]"
	var/list/chem_result = list()
	if(reagents)
		for(var/datum/reagent/each_chem as anything in reagents.reagent_list)
			chem_result += "[each_chem.name]([each_chem.volume]u)"

	return {"<ul class='data-column'>
	<li>Name : [name]</li>
	<li>Mind : [mind?.name || "(no mind)"]
	<li>Loc : x[my_loc.x] | y[my_loc.y] | z[my_loc.z] (area: [my_area.name])
	<li>Client : [client?.key || "(no client)"]</li>
	<li>Species : [dna?.species?.name || "(UNKNOWN)"]</li>
	<li>Damages : BRUTE [getBruteLoss()] | BURN [getFireLoss()] | TOX [getToxLoss()] | OXY [getOxyLoss()] | CLONE [getCloneLoss()] | STAM [getStaminaLoss()]</li>
	[length(result)		 && "<li>Organs : [result.Join(" | ")]</li>"]
	[length(chem_result) && "<li>Chems : [chem_result.Join(" | ")]</li>"]
	</ul>"}

/mob/living/simple_animal/revenant/get_vv_summary()
	var/turf/my_loc = get_turf(src)
	var/area/my_area = get_area(my_loc)

	return {"<ul class='data-column'>
	<li>Name : [name]</li>
	<li>Mind : [mind?.name || "(no mind)"]
	<li>Loc : x[my_loc.x] | y[my_loc.y] | z[my_loc.z] (area: [my_area.name])
	<li>Client : [client?.key || "(no client)"]</li>
	<li>Essence : [essence] (+[essence_regen_amount]/per tick, Max: [essence_regen_cap])</li>
	<li>Stolen Essnce: [essence_accumulated]</li>
	<li>Unused stolen essence: [essence_excess]</li>
	<li>Stolen perfect souls: [perfectsouls]</li>
	</ul>"}

// Base of /obj
/obj/machinery/get_vv_summary()
	var/list/comp_result
	if(length(component_parts))
		comp_result = list()
		for(var/obj/item/each_part in component_parts)
			comp_result += "[each_part.name]"

	var/list/chem_result
	var/beaker_result_text
	var/obj/item/reagent_containers/beaker = hasvar(src, "beaker") && src.vars["beaker"]  // I don't like this, but there are a few hardcoded machines
	if(istype(beaker, /obj/item/reagent_containers))
		chem_result = list()
		for(var/datum/reagent/each_chem as anything in beaker.reagents.reagent_list)
			chem_result += "[each_chem.name]([each_chem.volume]u)"
		beaker_result_text = {"<li>Beaker</li><ul><li>Volume : [beaker.reagents.total_volume]u / [beaker.reagents.maximum_volume]u</li>
		<li>Temp : [beaker.reagents.chem_temp]K</li>
		<li>Chems: [chem_result.Join(" / ") || "(none)"]</li></ul>"}

	var/chem_result_text
	if(reagents)
		chem_result = list()
		for(var/datum/reagent/each_chem as anything in reagents.reagent_list)
			chem_result += "[each_chem.name]([each_chem.volume]u)"
		chem_result_text = {"<li>Internal reagent container</li><ul><li>Volume : [reagents.total_volume]u / [reagents.maximum_volume]u</li>
		<li>Temp : [reagents.chem_temp]K</li>
		<li>Chems: [chem_result.Join(" / ") || "(none)"]</li></ul>"}

	var/output = "[length(comp_result) ? "<li>Parts : [comp_result.Join(" | ")]</li>" : ""][beaker_result_text][chem_result_text]"
	if(!output || !length(output))
		return
	return "<ul class='data-column'>[output]</ul>"

/obj/item/stock_parts/cell/get_vv_summary()
	return {"<ul class='data-column'>
	<li>Power : [charge]/[maxcharge] ([round(src.percent())]%)</li>
	</ul>"}

/obj/item/stock_parts/get_vv_summary()
	return  {"<ul class='data-column'>
	<li>Rating : [rating]</li>
	</ul>"}

/obj/item/reagent_containers/get_vv_summary()
	var/list/result = list()
	for(var/datum/reagent/each_chem as anything in reagents.reagent_list)
		result += "[each_chem.name]([each_chem.volume]u)"

	return {"<ul class='data-column'>
	<li>Volume : [reagents.total_volume]u / [volume]u</li>
	<li>Temp : [reagents.chem_temp]K</li>
	<li>Chems: [result.Join(" / ") || "(none)"]</li>
	</ul>"}
