/obj/machinery/atmospherics/components/unary/cdr
	name = "Condensate Decay Reactor"
	desc = "A sphere of ultra-stable metallic gases, which generate magnetic flux by decaying into more stable gases."
	icon = 'icons/obj/machines/cdr.dmi'
	icon_state = "cdr"
	density = TRUE
	layer = MOB_LAYER
	circuit = /obj/item/circuitboard/machine/cdr

	/// The list of CDR-specific gas attributes
	var/list/cdr_gas_factors
	/// Is the CDR activated or not?
	var/activated = FALSE
	/// What is the ratio of gases of core_compostion and the CDR's turf mix
	var/metallization_ratio = 0.2
	/// How stable the core is
	var/core_stability = 0
	/// How unstable the core is
	var/core_instability = 0
	/// How unstable the core is naturally
	var/base_instability = CDR_BASE_INSTABILITY
	/// How much health the core has, reaching zero causes the fail state
	var/core_health = CDR_MAX_CORE_HEALTH
	/// Does the core take damage?
	var/no_core_damage = FALSE
	/// How much power is the CDR making?
	var/flux = 0
	/// The spin of the toroid, influenced by gases added to the CDRs node
	var/toroid_spin = 0
	/// Multiplier for flux based on toroid_spin
	var/toroid_flux_mult = 0
	/// How steep the toroid parabola is
	var/parabolic_setting = 1
	/// The upper limit on the toroid parabola
	var/parabolic_upper_limit = 1
	/// Where on the toroid parabolic curve the CDR is at
	var/parabolic_ratio = 0
	/// Volume to pump into its internal buffer per cycle
	var/input_volume = 200
	/// Id of the CDR
	var/cdr_uid = 1
	/// The number of CDRs that have been made
	var/static/gl_cdr_uid = 1
	/// The soundloop to play while active
	var/datum/looping_sound/cdr/soundloop
	/// Currently linked flux_harvesters
	var/list/obj/machinery/power/energy_accumulator/flux_harvester/linked_harvesters = list()
	///The internal gas_mixture
	var/datum/gas_mixture/core_composition
	/// For admin logging
	var/last_user = null
	/// Our internal radio
	var/obj/item/radio/radio
	/// The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng

	COOLDOWN_DECLARE(radio_cooldown)

/obj/machinery/atmospherics/components/unary/cdr/Initialize(mapload)
	. = ..()
	core_composition = new()
	cdr_gas_factors = init_condensate_gas()
	cdr_uid = gl_cdr_uid++
	soundloop = new(src)
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/machinery/atmospherics/components/unary/cdr/Destroy()
	for(var/obj/machinery/power/energy_accumulator/flux_harvester/harvester in linked_harvesters)
		harvester.parent = null
	QDEL_NULL(soundloop)
	QDEL_NULL(radio)
	return ..()

/obj/machinery/atmospherics/components/unary/cdr/process_atmos()
	update_parents() //needs to process constantly for gases to not get stuck
	if(!activated)
		return
	process_diffusion()
	decay_gases()
	process_toroid()
	process_harvesters()
	process_stability()
	update_appearance(UPDATE_OVERLAYS)
	if (core_health <= 0)
		addtimer(CALLBACK(src, PROC_REF(fail)), 3 SECONDS)
		playsound(src, 'sound/machines/cdr-collapse.ogg', 200, FALSE, 40, falloff_distance = 25, ignore_walls = TRUE)
		return PROCESS_KILL

/obj/machinery/atmospherics/components/unary/cdr/screwdriver_act(mob/living/user, obj/item/tool)
	if(activated)
		balloon_alert(user, "deactivate first!")
		return FALSE

	return default_deconstruction_screwdriver(user, "cdr", "cdr", tool)

/obj/machinery/atmospherics/components/unary/cdr/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/atmospherics/components/unary/cdr/multitool_act(mob/living/user, obj/item/tool)
	return deactivate(user)

/obj/machinery/atmospherics/components/unary/cdr/crowbar_act(mob/living/user, obj/item/tool)
	return crowbar_deconstruction_act(user, tool)

/obj/machinery/atmospherics/components/unary/cdr/update_overlays()
	. = ..()
	if(!activated)
		return
	var/overlay_state = "sphere_3"
	switch(core_composition.total_moles())
		if(0 to 500)
			overlay_state = "sphere_1"
		if(500 to 5000)
			overlay_state = "sphere_2"
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, overlay_state, layer)

/obj/machinery/atmospherics/components/unary/cdr/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosCdr")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/components/unary/cdr/ui_static_data(mob/user)
	var/list/data = list()
	data["uid"] = cdr_uid
	data["area"] = AREACOORD(src)
	data["max_core_health"] = CDR_MAX_CORE_HEALTH
	return data

/obj/machinery/atmospherics/components/unary/cdr/ui_data(mob/user)
	var/list/data = list()

	var/list/core_composition_named = list()
	for(var/gastype in core_composition.gases)
		core_composition_named[GLOB.meta_gas_info[gastype]?[META_GAS_NAME]] = GET_MOLES(gastype, core_composition)

	data["toroid_spin"] = toroid_spin
	data["parabolic_setting"] = parabolic_setting
	data["input_volume"] = input_volume
	data["toroid_flux_mult"] = toroid_flux_mult
	data["core_temperature"] = core_composition.temperature
	data["core_composition"] = core_composition_named
	data["can_activate"] = !activated && is_operational
	data["activated"] = activated
	data["metallization_ratio"] = metallization_ratio
	data["parabolic_setting"] = parabolic_setting
	data["parabolic_upper_limit"] = parabolic_upper_limit
	data["parabolic_ratio"] = parabolic_ratio
	data["core_stability"] = core_stability
	data["core_instability"] = core_instability
	data["core_health"] = core_health
	data["power_output"] = display_power_persec(flux * CDR_FLUX_TO_POWER)
	return data

/obj/machinery/atmospherics/components/unary/cdr/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(usr.ckey)
		last_user = usr.ckey
	switch(action)
		if("change_input")
			input_volume = clamp(text2num(params["change_input"]), 0, 200)
			return TRUE
		if("activate")
			activate()
			return TRUE
		if("change_metal_ratio")
			metallization_ratio = clamp(text2num(params["change_metal_ratio"]), 0.1, 1)
			return TRUE
		if("change_parabolic_setting")
			parabolic_setting = clamp(text2num(params["change_parabolic_setting"]), 0.1, 1)
			return TRUE
		if("reconnect")
			link_harvesters()
			return TRUE

/obj/machinery/atmospherics/components/unary/cdr/proc/activate()
	if(activated || !is_operational)
		return
	soundloop.start()
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF //you cannot destroy it while its on... because of its quantum-flux-field!
	activated = TRUE
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/components/unary/cdr/proc/deactivate(mob/user)
	if(!activated)
		return FALSE
	if(core_composition.total_moles())
		balloon_alert(user, "can't deactivate!")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		return FALSE
	soundloop.stop()
	resistance_flags = FREEZE_PROOF
	activated = FALSE
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/atmospherics/components/unary/cdr/proc/get_core_stability()
	var/stability_value = 0

	for(var/gastype in core_composition.gases) //I loop over this a lot, it would possibly be better to only loop it once but that would make the code really messy
		var/datum/condensate_gas/cdr_gas = cdr_gas_factors[gastype]
		stability_value += GET_MOLES(gastype, core_composition) * cdr_gas?.stability_val
	return stability_value * get_temp_stab_factor()

/obj/machinery/atmospherics/components/unary/cdr/proc/link_harvesters()
	for(var/obj/machinery/power/energy_accumulator/flux_harvester/harvester in linked_harvesters)
		harvester.parent = null
		linked_harvesters -= harvester
	for(var/obj/machinery/power/energy_accumulator/flux_harvester/harvester in orange(5, src))
		linked_harvesters += harvester
		harvester.parent = src

/obj/machinery/atmospherics/components/unary/cdr/proc/get_temp_stab_factor()
	var/n2o_mols = GET_MOLES(/datum/gas/oxygen, core_composition)
	var/maximum_temp_factor = n2o_mols ? max(100 - n2o_mols * 0.1, 10) : 100 //when n2o mols > 1000 temp_factor = 10
	var/temp_slope = 0.01
	return max(-core_composition.temperature * temp_slope + maximum_temp_factor, 1)

/obj/machinery/atmospherics/components/unary/cdr/proc/decay_gases()
	var/datum/gas_mixture/turf_mix = src.loc.return_air()
	var/total_energy_consumed = 0
	var/total_flux_produced = 0
	for(var/gastype in core_composition.gases)
		var/datum/condensate_gas/cdr_gas = cdr_gas_factors[gastype]
		var/gas_moles = GET_MOLES(gastype, core_composition)
		if(!cdr_gas.decays_into)
			continue
		if(!gas_moles)
			continue
		if(gas_moles < cdr_gas.threshold)
			continue

		var/decayed_gas = max((gas_moles - cdr_gas.threshold) * cdr_gas.decay_rate, 0)
		total_energy_consumed += decayed_gas * CDR_HEAT_CONSUMED_PER_MOL * cdr_gas.decay_flux_mult

		total_flux_produced += cdr_gas.decay_flux_mult * gas_moles
		REMOVE_MOLES(gastype, core_composition, decayed_gas)
		ADD_MOLES(cdr_gas.decays_into, core_composition, decayed_gas)

	set_flux(total_flux_produced * get_mass_multiplier())

	var/core_capacity = core_composition.heat_capacity()
	var/core_thermal_heat = core_composition.thermal_energy() - total_energy_consumed
	var/mix_capacity = turf_mix.heat_capacity()
	var/new_temperature = max(((turf_mix.temperature * mix_capacity) + core_thermal_heat) / (core_capacity + mix_capacity), TCMB)
	core_composition.temperature = new_temperature
	turf_mix.temperature = new_temperature

/obj/machinery/atmospherics/components/unary/cdr/proc/get_mass_multiplier()
	return max(core_composition.total_moles() / CDR_CORE_MASS_DIV, 1)

/obj/machinery/atmospherics/components/unary/cdr/proc/process_stability()
	var/datum/condensate_gas/bz_gas = cdr_gas_factors[/datum/gas/bz]
	var/bz_mols = GET_MOLES(/datum/gas/bz, core_composition)
	core_stability = get_core_stability()
	base_instability = max(bz_mols ? bz_mols * bz_gas.threshold : 0, CDR_BASE_INSTABILITY)
	core_instability = (max(core_composition.temperature >= 100000 ? 50000 * (log(10, core_composition.temperature) - 4) : 0.5 * core_composition.temperature, 0) + base_instability) //I could make this a define, but really, whos going to change it? :clueless: IF YOU DO TOUCH IT, make sure to recalculate the entire function
	var/delta_stability = core_instability - core_stability
	adjust_health(delta_stability > 0 ? max(log(10, abs(delta_stability)), 0) : min(-log(10, abs(delta_stability)), 0))

/obj/machinery/atmospherics/components/unary/cdr/proc/adjust_health(delta)
	if(no_core_damage)
		return
	var/health_delta = clamp(core_health + delta, 0, CDR_MAX_CORE_HEALTH)
	if(health_delta > core_health)
		alert_radio(FALSE)
	if(health_delta < core_health)
		alert_radio(TRUE)
	core_health = health_delta

/obj/machinery/atmospherics/components/unary/cdr/proc/alert_radio(decreasing)
	if(!COOLDOWN_FINISHED(src, radio_cooldown) || core_health > CDR_MAX_CORE_HEALTH * 0.6)
		return
	radio.talk_into(src, "Core health is [decreasing ? "decreasing" : "increasing"] to [round(core_health)]!", core_health < CDR_MAX_CORE_HEALTH * 0.25 ? RADIO_CHANNEL_ENGINEERING : null)
	COOLDOWN_START(src, radio_cooldown, CDR_RADIO_COOLDOWN)

/obj/machinery/atmospherics/components/unary/cdr/proc/fail()
	investigate_log("failed and spawned a temporary singularity. The last person to use it was [last_user]", INVESTIGATE_ENGINES)
	new /obj/anomaly/singularity/temporary(get_turf(src), 500)
	qdel(src)

/obj/machinery/atmospherics/components/unary/cdr/proc/process_toroid()
	toroid_spin = toroid_spin - toroid_spin * metallization_ratio

	toroid_spin = round(toroid_spin, 0.001) // prevent it from reaching absurdly small numbers

	var/datum/gas_mixture/toroid_mix = new()
	airs[1].pump_gas_volume(toroid_mix, input_volume)

	if(toroid_mix)
		var/total_heat_capacity = 0
		var/gas_count = 0
		toroid_mix.heat_capacity()
		for (var/datum/gas/gas_id as anything in toroid_mix.gases)
			total_heat_capacity += initial(gas_id.specific_heat) * toroid_mix.gases[gas_id][MOLES]
			gas_count++
		if(gas_count)
			toroid_spin += (total_heat_capacity / gas_count) * CDR_MOL_TO_SPIN

	parabolic_upper_limit = get_mass_multiplier()
	parabolic_ratio = toroid_spin / 10000

	toroid_flux_mult = round(max(-1 * (parabolic_ratio - sqrt(parabolic_upper_limit * parabolic_setting))**2 + (parabolic_upper_limit * parabolic_setting), 0), (parabolic_upper_limit * parabolic_setting) / CDR_PARABOLIC_ACCURACY) //hopefully this rounding removes some issues

/obj/machinery/atmospherics/components/unary/cdr/proc/process_diffusion()
	var/datum/gas_mixture/turf_mix = src.loc.return_air()
	for(var/turf_gas in (turf_mix.gases | core_composition.gases))
		var/turf_mix_mols = GET_MOLES(turf_gas, turf_mix)
		var/core_comp_mols = GET_MOLES(turf_gas, core_composition)
		var/total_gas = core_comp_mols + turf_mix_mols

		if(!total_gas)
			continue

		var/ratio = total_gas * (1 - metallization_ratio)
		var/diffusion_difference = ratio - turf_mix_mols
		var/gas_diffused = ((diffusion_difference / total_gas) ** 3) * total_gas

		gas_diffused = clamp(gas_diffused, gas_diffused > 0 ? 0 : -turf_mix_mols, gas_diffused < 0 ? 0 : core_comp_mols)

		if(gas_diffused > 0)
			REMOVE_MOLES(turf_gas, core_composition, gas_diffused)
			ADD_MOLES(turf_gas, turf_mix, gas_diffused)
		else
			ADD_MOLES(turf_gas, core_composition, -gas_diffused)
			REMOVE_MOLES(turf_gas, turf_mix, -gas_diffused)

		src.air_update_turf(FALSE, FALSE)
		core_composition.garbage_collect()
		turf_mix.garbage_collect()

/obj/machinery/atmospherics/components/unary/cdr/proc/process_harvesters()
	var/power_left = flux * CDR_FLUX_TO_POWER
	for (var/obj/machinery/power/energy_accumulator/flux_harvester/harvester in linked_harvesters)
		power_left -= harvester.add_power(power_left)

/obj/machinery/atmospherics/components/unary/cdr/proc/set_flux(flux_to_add)
	flux = flux_to_add * toroid_flux_mult

/obj/machinery/power/energy_accumulator/flux_harvester
	name = "magnetic flux harvester"
	desc = "Uses advanced wire coils to harvest magnetic flux efficiently."
	icon = 'icons/obj/power.dmi'
	icon_state = "flux_harvester"
	circuit = /obj/item/circuitboard/machine/flux_harvester
	var/max_harvested = 1 GIGAWATT
	var/obj/machinery/atmospherics/components/unary/cdr/parent = null

/obj/machinery/power/energy_accumulator/flux_harvester/Destroy()
	. = ..()
	parent?.linked_harvesters -= src

/obj/machinery/power/energy_accumulator/flux_harvester/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "flux_harvester-o", "flux_harvester", tool)

/obj/machinery/power/energy_accumulator/flux_harvester/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/power/energy_accumulator/flux_harvester/proc/add_power(power)
	var/excess = max(power - max_harvested, 0)
	stored_energy += min(power, max_harvested)
	return excess
