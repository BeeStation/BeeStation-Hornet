#define GAS_DECAY_LIST list( \
	/datum/gas/nitrium = /datum/gas/tritium, \
	/datum/gas/tritium = /datum/gas/plasma, \
	/datum/gas/plasma = /datum/gas/bz, \
	/datum/gas/bz = /datum/gas/nitrous_oxide, \
	/datum/gas/nitrous_oxide = /datum/gas/oxygen, \
	/datum/gas/oxygen = /datum/gas/water_vapor, \
	/datum/gas/water_vapor = /datum/gas/carbon_dioxide, \
	/datum/gas/carbon_dioxide = /datum/gas/nitrogen, \
	/datum/gas/nitrogen = /datum/gas/pluoxium, \
	/datum/gas/pluoxium = /datum/gas/hypernoblium \
)
#define GAS_DECAY_RATE 1
#define GAS_DECAY_THRESHOLD 2
#define GAS_DECAY_FLUX_MULT 3
#define GAS_STABILITY_VAL 4
#define MDR_GAS_VARS list( \
	/datum/gas/nitrium = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 10, GAS_DECAY_FLUX_MULT = 10, GAS_STABILITY_VAL = 0.1), \
	/datum/gas/tritium = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 20, GAS_DECAY_FLUX_MULT = 5, GAS_STABILITY_VAL = 0.2), \
	/datum/gas/plasma = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 100, GAS_DECAY_FLUX_MULT = 2, GAS_STABILITY_VAL = 0.5), \
	/datum/gas/bz = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 200, GAS_DECAY_FLUX_MULT = 1, GAS_STABILITY_VAL = 0.75), \
	/datum/gas/nitrous_oxide = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 400, GAS_DECAY_FLUX_MULT = 1, GAS_STABILITY_VAL = 0.9), \
	/datum/gas/oxygen = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 1000, GAS_DECAY_FLUX_MULT = 1, GAS_STABILITY_VAL = 1), \
	/datum/gas/water_vapor = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 600, GAS_DECAY_FLUX_MULT = 5, GAS_STABILITY_VAL = 2), \
	/datum/gas/carbon_dioxide = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 100, GAS_DECAY_FLUX_MULT = 10, GAS_STABILITY_VAL = 5), \
	/datum/gas/nitrogen = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 50, GAS_DECAY_FLUX_MULT = 20, GAS_STABILITY_VAL = 8), \
	/datum/gas/pluoxium = list(GAS_DECAY_RATE = 0.1, GAS_DECAY_THRESHOLD = 10, GAS_DECAY_FLUX_MULT = 100, GAS_STABILITY_VAL = 10), \
	/datum/gas/hypernoblium = list(GAS_DECAY_RATE = 0, GAS_DECAY_THRESHOLD = 0, GAS_DECAY_FLUX_MULT = 0, GAS_STABILITY_VAL = 100))
//oxygen decreases the increase in stability from low temperatures
//BZ increases base_instability

#define MDR_MOL_TO_SPIN 1000
#define MDR_SPIN_INSTABILITY_MULT 1e3

#define MDR_BASE_INSTABILITY 100

#define MDR_HEAT_CONSUMED_PER_MOL 1 MEGAWATT
#define MDR_FLUX_TO_POWER 1 KILOWATT

#define MDR_MAX_CORE_HEALTH 250

#define MDR_CORE_MASS_DIV 1000

#define MDR_RADIO_COOLDOWN 8 SECONDS

/obj/machinery/atmospherics/components/unary/mdr
	name = "Metallic Decay Reactor"
	desc = "A sphere of ultra-stable metallic gases, which generate magnetic flux by decaying into more stable gases."
	icon = 'icons/obj/machines/mdr.dmi'
	icon_state = "mdr"
	density = TRUE
	layer = MOB_LAYER
	var/activated = FALSE

	var/metallization_ratio = 0.2
	var/core_stability = 0
	var/core_instability = 0
	var/base_instability = MDR_BASE_INSTABILITY

	var/core_health = MDR_MAX_CORE_HEALTH
	var/temp_stability_factor = 0
	var/core_temperature = T20C

	var/flux = 0

	var/toroid_spin = 0
	var/toroid_flux_mult = 0

	var/parabolic_setting = 1
	var/parabolic_upper_limit = 1
	var/parabolic_ratio = 0

	var/input_volume = 200

	var/last_user = null //for admin logging

	var/mdr_uid = 1 //id of the MDR
	var/static/gl_mdr_uid = 1 //number of MDRs that have been made (this solution is from supermatter.dm as of 2026, yell at them if you think its dumb)

	var/datum/looping_sound/mdr/soundloop

	var/list/obj/machinery/power/flux_harvester/linked_harvesters = list()
	var/list/core_composition = list()

	/// Our internal radio
	var/obj/item/radio/radio
	/// The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng

	COOLDOWN_DECLARE(radio_cooldown)

/obj/machinery/atmospherics/components/unary/mdr/Initialize(mapload)
	. = ..()
	mdr_uid = gl_mdr_uid++
	soundloop = new(src)
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/machinery/atmospherics/components/unary/mdr/Destroy()
	for(var/obj/machinery/power/flux_harvester/harvester in linked_harvesters)
		harvester.parent = null
	var/total_core_mols = 0
	for(var/gastype in core_composition)
		total_core_mols += core_composition[gastype]
	if(total_core_mols > 1000)
		investigate_log("was destroyed and spawned a temporary singularity. The last person to use it was [last_user]", INVESTIGATE_ENGINES)
		new /obj/anomaly/singularity/temporary(get_turf(src), 500)
	qdel(soundloop)
	qdel(radio)
	. = ..()


/obj/machinery/atmospherics/components/unary/mdr/process(delta_time)
	update_parents() //needs to process constantly for gases to not get stuck
	if(!activated)
		return
	process_diffusion()
	decay_gases(get_decay_factor())
	process_toroid()
	process_harvesters()
	process_stability()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/atmospherics/components/unary/mdr/screwdriver_act(mob/living/user, obj/item/tool)
	if(activated)
		balloon_alert(user, "deactivate first!")
		return TRUE

	if(default_deconstruction_screwdriver(user, "mdr", "mdr", tool))
		update_appearance()
		return TRUE

/obj/machinery/atmospherics/components/unary/mdr/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/atmospherics/components/unary/mdr/multitool_act(mob/living/user, obj/item/tool)
	deactivate()
	return TRUE

/obj/machinery/atmospherics/components/unary/mdr/update_overlays()
	. = ..()
	var/core_mass = 0
	for(var/gastype in core_composition)
		core_mass += core_composition[gastype]
	if(!activated)
		return
	switch(core_mass)
		if(0 to 500)
			. += mutable_appearance(initial(icon), "sphere_1")
			. += emissive_appearance(initial(icon), "sphere_1", layer)
		if(500 to 5000) //todo, figure out if this is inclusive or exclusive, and how to handle a switch better
			. += mutable_appearance(initial(icon), "sphere_2")
			. += emissive_appearance(initial(icon), "sphere_2", layer)
		else
			. += mutable_appearance(initial(icon), "sphere_3")
			. += emissive_appearance(initial(icon), "sphere_3", layer)

/obj/machinery/atmospherics/components/unary/mdr/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosMdr")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/atmospherics/components/unary/mdr/ui_state()
	return GLOB.default_state

/obj/machinery/atmospherics/components/unary/mdr/ui_static_data(mob/user)
	. = ..()
	.["uid"] = mdr_uid
	.["area"] = AREACOORD(src)
	.["max_core_health"] = MDR_MAX_CORE_HEALTH

/obj/machinery/atmospherics/components/unary/mdr/ui_data(mob/user)
	. = ..()

	var/list/core_composition_named = list()
	for(var/gastype in core_composition)
		core_composition_named[GLOB.meta_gas_info[gastype]?[META_GAS_NAME]] = core_composition[gastype]

	.["toroid_spin"] = toroid_spin
	.["parabolic_setting"] = parabolic_setting
	.["input_volume"] = input_volume
	.["toroid_flux_mult"] = toroid_flux_mult
	.["core_temperature"] = core_temperature
	.["core_composition"] = core_composition_named
	.["can_activate"] = can_activate()
	.["activated"] = activated
	.["metallization_ratio"] = metallization_ratio
	.["parabolic_setting"] = parabolic_setting
	.["parabolic_upper_limit"] = parabolic_upper_limit
	.["parabolic_ratio"] = parabolic_ratio
	.["core_stability"] = core_stability
	.["core_instability"] = core_instability
	.["core_health"] = core_health

/obj/machinery/atmospherics/components/unary/mdr/ui_act(action, params)
	var/mob/user = usr
	if(ismob(user) && user.ckey)
		last_user = user.ckey
	. = ..()
	switch(action)
		if("change_input")
			input_volume = clamp(text2num(params["change_input"]), 0, 200)
		if("activate")
			activate()
		if("change_metal_ratio")
			metallization_ratio = clamp(text2num(params["change_metal_ratio"]), 0.1, 1)
		if("change_parabolic_setting")
			parabolic_setting = clamp(text2num(params["change_parabolic_setting"]), 0.1, 1)
		if("reconnect")
			link_harvesters()

/obj/machinery/atmospherics/components/unary/mdr/proc/can_activate()
	return !(activated || (!is_operational))

/obj/machinery/atmospherics/components/unary/mdr/proc/can_deactivate()
	for(var/gastype in core_composition)
		if(core_composition[gastype])
			return FALSE
	return TRUE

/obj/machinery/atmospherics/components/unary/mdr/proc/activate()
	if(!can_activate())
		balloon_alert_to_viewers("can not activate now!")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		return
	soundloop.start()
	update_appearance()
	activated = TRUE

/obj/machinery/atmospherics/components/unary/mdr/proc/deactivate()
	if(!can_deactivate())
		balloon_alert_to_viewers("can not deactivate now!")
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		return
	soundloop.stop()
	update_appearance()
	activated = FALSE

/obj/machinery/atmospherics/components/unary/mdr/proc/get_core_heat_capacity()
	var/total_capacity
	for(var/gastype in core_composition)
		total_capacity += GLOB.meta_gas_info[gastype]?[META_GAS_SPECIFIC_HEAT] * core_composition[gastype]
	return total_capacity

/obj/machinery/atmospherics/components/unary/mdr/proc/get_core_stability()
	var/stability_value = 0
	for(var/gastype in core_composition) //I loop over this a lot, it would possibly be better to only loop it once but that would make the code really messy
		stability_value += core_composition[gastype] * MDR_GAS_VARS[gastype]?[GAS_STABILITY_VAL]
	return stability_value * get_temp_stab_factor()

/obj/machinery/atmospherics/components/unary/mdr/proc/link_harvesters()
	for(var/obj/machinery/power/flux_harvester/harvester in linked_harvesters)
		harvester.unlink_harvester()
		linked_harvesters -= harvester
	for(var/obj/machinery/power/flux_harvester/harvester in orange(5, src))
		if(!(harvester in linked_harvesters))
			linked_harvesters += harvester
			harvester.link_harvester(src)
			START_PROCESSING(SSmachines, harvester)

/obj/machinery/atmospherics/components/unary/mdr/proc/get_decay_factor()
	return 1 //todo remove this proc or add to it

/obj/machinery/atmospherics/components/unary/mdr/proc/get_temp_stab_factor()
	var/n2o_mols = core_composition[/datum/gas/oxygen]
	var/maximum_temp_factor = n2o_mols ? max(100 - n2o_mols * 0.1, 10) : 100 //when n2o mols > 1000 temp_factor = 10
	var/temp_slope = 0.01
	return max(-(core_temperature * temp_slope) + maximum_temp_factor, 1)

/obj/machinery/atmospherics/components/unary/mdr/proc/decay_gases(decay_factor)
	var/datum/gas_mixture/turf_mix = src.loc.return_air()
	var/total_energy_consumed = 0
	for(var/gastype in core_composition)
		if(!MDR_GAS_VARS[gastype]) //sanity check, the MDR_GAS defines SHOULD cover all gases, but on the off chance they dont? this should stop it
			continue
		if(!GAS_DECAY_LIST[gastype]) //same as above, except decaying should always skip the last gas on the decay chain
			continue
		if(!core_composition[gastype])
			continue
		if(core_composition[gastype] < MDR_GAS_VARS[gastype][GAS_DECAY_THRESHOLD])
			continue

		var/true_decay_factor = decay_factor * MDR_GAS_VARS[gastype][GAS_DECAY_RATE]
		var/decayed_gas = max((core_composition[gastype] - MDR_GAS_VARS[gastype][GAS_DECAY_THRESHOLD]) * true_decay_factor, 0)
		total_energy_consumed += decayed_gas * MDR_HEAT_CONSUMED_PER_MOL * MDR_GAS_VARS[gastype][GAS_DECAY_FLUX_MULT]

		add_flux(MDR_GAS_VARS[gastype][GAS_DECAY_FLUX_MULT] * core_composition[gastype] * get_mass_multiplier())
		remove_gas_from_core(gastype, decayed_gas)
		add_gas_to_core(GAS_DECAY_LIST[gastype], decayed_gas)

	var/core_capacity = get_core_heat_capacity() //todo make this heat transfer not instant
	var/core_thermal_heat = (core_temperature * core_capacity) - total_energy_consumed
	var/mix_capacity = turf_mix.heat_capacity()
	var/new_temperature = max(((turf_mix.temperature * mix_capacity) + core_thermal_heat) / (core_capacity + mix_capacity), TCMB)
	core_temperature = new_temperature
	turf_mix.temperature = new_temperature

/obj/machinery/atmospherics/components/unary/mdr/proc/get_mass_multiplier()
	var/core_mass = 0
	for(var/gastype in core_composition)
		core_mass += core_composition[gastype]
	return max(core_mass / MDR_CORE_MASS_DIV, 1)

/obj/machinery/atmospherics/components/unary/mdr/proc/process_stability()
	var/bz_mols = core_composition[/datum/gas/bz]
	core_stability = get_core_stability()
	base_instability = max(bz_mols ? bz_mols * MDR_GAS_VARS[/datum/gas/bz][GAS_DECAY_THRESHOLD] : 0, MDR_BASE_INSTABILITY)
	core_instability = (max(core_temperature >= 100000 ? 50000 * (log(10, core_temperature) - 4) : 0.5 * core_temperature, 0) + base_instability) //I could make this a define, but really, whos going to change it? :clueless: IF YOU DO TOUCH IT, make sure to recalculate the entire function
	var/delta_stability = core_instability - core_stability
	adjust_health(delta_stability > 0 ? max(log(10, abs(delta_stability)), 0) : min(-log(10, abs(delta_stability)), 0))

/obj/machinery/atmospherics/components/unary/mdr/proc/adjust_health(delta)
	var/health_delta = clamp(core_health + delta, 0, MDR_MAX_CORE_HEALTH)
	if(health_delta > core_health)
		alert_radio(FALSE)
	if(health_delta < core_health)
		alert_radio(TRUE)
	core_health = health_delta
	if (core_health <= 0)
		fail()

/obj/machinery/atmospherics/components/unary/mdr/proc/alert_radio(decreasing)
	if(!(COOLDOWN_FINISHED(src, radio_cooldown)) || core_health > MDR_MAX_CORE_HEALTH * 0.6)
		return
	var/message = "Core health is [decreasing ? "decreasing" : "increasing"] to [round(core_health)]!"
	core_health < MDR_MAX_CORE_HEALTH * 0.25 ? radio.talk_into(src, message, null) : radio.talk_into(src, message, RADIO_CHANNEL_ENGINEERING)
	COOLDOWN_START(src, radio_cooldown, MDR_RADIO_COOLDOWN)

/obj/machinery/atmospherics/components/unary/mdr/proc/fail()
	qdel(src)

/obj/machinery/atmospherics/components/unary/mdr/proc/process_toroid()
	toroid_spin = toroid_spin - toroid_spin * metallization_ratio

	if(toroid_spin < 0.001) //prevent it from reaching absurdly small numbers
		toroid_spin = 0

	var/datum/gas_mixture/toroid_mix = new
	airs[1].pump_gas_volume(toroid_mix, input_volume)

	if(toroid_mix)
		toroid_spin += toroid_mix.total_moles() * MDR_MOL_TO_SPIN //todo make this respect specific heat

	parabolic_upper_limit = get_mass_multiplier()
	parabolic_ratio = toroid_spin / 10000

	toroid_flux_mult = max(-1 * (parabolic_ratio - sqrt(parabolic_upper_limit * parabolic_setting))**2 + (parabolic_upper_limit * parabolic_setting), 0)

/obj/machinery/atmospherics/components/unary/mdr/proc/process_diffusion()
	var/datum/gas_mixture/turf_mix = src.loc.return_air()
	for(var/turf_gas in (turf_mix.gases | core_composition))
		var/turf_mix_mols = turf_mix.gases[turf_gas]?[MOLES]
		var/core_comp_mols = core_composition[turf_gas]
		if(!turf_mix_mols)
			turf_mix_mols = 0
		if(!core_comp_mols)
			core_comp_mols = 0
		var/total_gas = core_comp_mols + turf_mix_mols

		if(!total_gas)
			continue

		var/ratio = total_gas * (1 - metallization_ratio)
		var/diffusion_difference = ratio - turf_mix_mols
		var/gas_diffused = (((diffusion_difference / total_gas) / 1) ** 3) * total_gas

		gas_diffused = clamp(gas_diffused, gas_diffused > 0 ? 0 : -turf_mix_mols, gas_diffused < 0 ? 0 : core_comp_mols) //todo, make this avoid instant diffusion (when metallization is 0 all gas is diffused instantly)
		if(gas_diffused > 0)
			remove_gas_from_core(turf_gas, gas_diffused)
			ADD_MOLES(turf_gas, turf_mix, gas_diffused)
			src.air_update_turf(FALSE, FALSE)
			garbage_collect()
		if(gas_diffused < 0)
			add_gas_to_core(turf_gas, -gas_diffused)
			REMOVE_MOLES(turf_gas, turf_mix, -gas_diffused)
			src.air_update_turf(FALSE, FALSE)
			garbage_collect()

/obj/machinery/atmospherics/components/unary/mdr/proc/process_harvesters()
	var/power_left = flux * MDR_FLUX_TO_POWER
	for (var/obj/machinery/power/flux_harvester/harvester in linked_harvesters)
		power_left -= harvester.add_power(power_left)

/obj/machinery/atmospherics/components/unary/mdr/proc/garbage_collect()
	for(var/gastype in core_composition)
		if(QUANTIZE(core_composition[gastype]) <= 0)
			core_composition -= gastype


/obj/machinery/atmospherics/components/unary/mdr/proc/add_flux(flux_to_add)
	flux = flux_to_add * toroid_flux_mult

/obj/machinery/atmospherics/components/unary/mdr/proc/add_gas_to_core(datum/gas/to_add, mols_to_add)
	core_composition[to_add] += mols_to_add

/obj/machinery/atmospherics/components/unary/mdr/proc/remove_gas_from_core(datum/gas/to_add, mols_to_remove)
	core_composition[to_add] = max(core_composition[to_add] - mols_to_remove, 0)

/obj/machinery/power/flux_harvester
	name = "Magnetic Flux Harvester"
	desc = "Uses advanced wire coils to harvest magnetic flux efficiently"
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger"
	var/output_this_tick = 0
	var/max_harvested = 100 GIGAWATT
	var/obj/machinery/atmospherics/components/unary/mdr/parent = null

/obj/machinery/power/flux_harvester/Destroy()
	. = ..()
	parent?.linked_harvesters -= src

/obj/machinery/power/flux_harvester/process(delta_time)
	if(!parent)
		..()
	add_avail(output_this_tick)
	output_this_tick = 0

/obj/machinery/power/flux_harvester/proc/add_power(power)
	var/excess = max(power - max_harvested, 0)
	output_this_tick = min(power, max_harvested)
	return excess

/obj/machinery/power/flux_harvester/proc/link_harvester(obj/machinery/atmospherics/components/unary/mdr/reactor)
	parent = reactor

/obj/machinery/power/flux_harvester/proc/unlink_harvester()
	parent = null

#undef GAS_DECAY_LIST
#undef GAS_DECAY_RATE
#undef GAS_DECAY_THRESHOLD
#undef MDR_BASE_INSTABILITY
#undef GAS_DECAY_FLUX_MULT
#undef GAS_STABILITY_VAL
#undef MDR_GAS_VARS
#undef MDR_MOL_TO_SPIN
#undef MDR_SPIN_INSTABILITY_MULT
#undef MDR_HEAT_CONSUMED_PER_MOL
#undef MDR_FLUX_TO_POWER
#undef MDR_MAX_CORE_HEALTH
#undef MDR_CORE_MASS_DIV
#undef MDR_RADIO_COOLDOWN
