//TODO: make failure more interesting
//TODO: make it produce power directly
//TODO: make instructions sheet

/obj/machinery/atmospherics/components/unary/cdr
	name = "Condensate Decay Reactor"
	desc = "A sphere of ultra-stable metallic gases, which generate magnetic flux by decaying into more stable gases. Use a multitool to deactivate."
	icon = 'icons/obj/machines/cdr.dmi'
	icon_state = "cdr"
	density = TRUE
	layer = BELOW_OBJ_LAYER
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
	var/base_instability
	/// How much instabiliy are components giving?
	var/component_instability_factor = 0
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
	///The internal gas_mixture
	var/datum/gas_mixture/core_composition
	/// For admin logging
	var/last_user = null
	/// Our internal radio
	var/obj/item/radio/radio
	/// The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng

	var/obj/effect/abstract/particle_holder/collapse

	COOLDOWN_DECLARE(radio_cooldown)
	COOLDOWN_DECLARE(alert_cooldown)

/obj/machinery/atmospherics/components/unary/cdr/Initialize(mapload)
	. = ..()
	new /obj/item/paper/fluff/cdr(get_turf(src))
	core_composition = new()
	cdr_gas_factors = init_condensate_gas()
	cdr_uid = gl_cdr_uid++
	soundloop = new(src)
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/machinery/atmospherics/components/unary/cdr/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(radio)
	QDEL_NULL(collapse)
	return ..()

/obj/machinery/atmospherics/components/unary/cdr/process(delta_time)
	if(!activated)
		return
	if(flux > CDR_FLUX_MIN_PARTICLE)
		fire_graviton()

/obj/machinery/atmospherics/components/unary/cdr/process_atmos()
	update_parents() //needs to process constantly for gases to not get stuck
	if(!activated)
		return
	process_diffusion()
	decay_gases()
	process_toroid()
	process_stability()
	update_appearance(UPDATE_OVERLAYS)
	if (core_health <= 0)
		collapse = new(loc, /particles/cdr_collapse)
		collapse.pixel_y = 20
		collapse.vis_flags = NONE
		collapse.plane = ABOVE_LIGHTING_PLANE
		collapse.blend_mode = BLEND_ADD
		collapse.add_filter("cdr_orb_glow", 1, list(type = "bloom", size = 1, threshold = rgb(156, 156, 156)))
		addtimer(CALLBACK(src, PROC_REF(fail)), 3 SECONDS)
		playsound(src, 'sound/machines/cdr-collapse.ogg', 200, FALSE, 40, falloff_distance = 25, ignore_walls = TRUE, pressure_affected = FALSE)
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
	. += mutable_appearance(icon, overlay_state, layer = GASFIRE_LAYER)
	. += emissive_appearance(icon, overlay_state, layer = GASFIRE_LAYER)

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
	for(var/gastype in core_composition.moles)
		core_composition_named[GLOB.meta_gas_info[META_GAS_NAME][gastype]] = core_composition.moles[gastype]

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
	data["base_instability"] = base_instability
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

	for(var/gastype in core_composition.moles) //I loop over this a lot, it would possibly be better to only loop it once but that would make the code really messy
		var/datum/condensate_gas/cdr_gas = cdr_gas_factors[gastype]
		stability_value += core_composition.moles[gastype] * cdr_gas?.stability_val
	return stability_value * get_temp_stab_factor()

/obj/machinery/atmospherics/components/unary/cdr/proc/get_temp_stab_factor()
	var/n2o_mols = core_composition.moles[/datum/gas/nitrous_oxide]
	var/maximum_temp_factor = n2o_mols ? max(100 - n2o_mols * 0.1, 10) : 100 //when n2o mols > 1000 temp_factor = 10
	var/temp_slope = 0.01
	return max(-core_composition.temperature * temp_slope + maximum_temp_factor, 1)

/obj/machinery/atmospherics/components/unary/cdr/proc/decay_gases()
	var/datum/gas_mixture/turf_mix = src.loc.return_air()
	var/total_energy_consumed = 0
	var/total_flux_produced = 0
	for(var/gastype in core_composition.moles)
		var/datum/condensate_gas/cdr_gas = cdr_gas_factors[gastype]
		var/gas_moles = core_composition.moles[gastype]
		if(!cdr_gas.decays_into)
			continue
		if(!gas_moles)
			continue
		if(gas_moles < cdr_gas.threshold)
			continue

		var/decayed_gas = max((gas_moles - cdr_gas.threshold) * cdr_gas.decay_rate, 0)
		total_energy_consumed += decayed_gas * CDR_HEAT_CONSUMED_PER_MOL * cdr_gas.decay_flux_mult

		total_flux_produced += cdr_gas.decay_flux_mult * gas_moles
		core_composition.convert_gas(gastype, cdr_gas.decays_into, decayed_gas)

	set_flux(total_flux_produced * get_mass_multiplier())

	var/core_capacity = core_composition.heat_capacity()
	var/core_thermal_heat = core_composition.thermal_energy() - total_energy_consumed
	var/mix_capacity = turf_mix.heat_capacity()
	var/new_temperature = max(((turf_mix.temperature * mix_capacity) + core_thermal_heat) / (core_capacity + mix_capacity), TCMB)
	core_composition.temperature = new_temperature
	turf_mix.temperature = new_temperature

/obj/machinery/atmospherics/components/unary/cdr/proc/get_mass_multiplier()
	return max(core_composition.total_moles() / CDR_CORE_MASS_DIV, 1)

/obj/machinery/atmospherics/components/unary/cdr/RefreshParts()
	. = ..()
	var/total_rating = 0
	var/total_parts = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		total_rating += bin.rating
		total_parts += 1
	component_instability_factor = total_parts ? CDR_BASE_INSTABILITY * (total_rating / total_parts) : CDR_BASE_INSTABILITY

/obj/machinery/atmospherics/components/unary/cdr/proc/process_stability()
	var/datum/condensate_gas/bz_gas = cdr_gas_factors[/datum/gas/bz]
	var/bz_mols = core_composition.moles[/datum/gas/bz]
	core_stability = get_core_stability()
	base_instability = (bz_mols * bz_gas.threshold) + component_instability_factor
	core_instability = (max(core_composition.temperature >= 100000 ? 50000 * (log(10, core_composition.temperature) - 4) + base_instability : 0.5 * core_composition.temperature, 0) + base_instability) //I could make this a define, but really, whos going to change it? :clueless: IF YOU DO TOUCH IT, make sure to recalculate the entire function
	var/delta_stability = core_instability - core_stability
	adjust_health(delta_stability > 0 ? max(log(10, abs(delta_stability)) / CDR_HEALTH_DELTA_DIVISOR, 0) : min(-log(10, abs(delta_stability)) / CDR_HEALTH_DELTA_DIVISOR, 0))

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
	if(COOLDOWN_FINISHED(src, radio_cooldown) && core_health < CDR_MAX_CORE_HEALTH * 0.6)
		radio.talk_into(src, "Core health is [decreasing ? "decreasing" : "increasing"] to [round(core_health)]!", core_health < CDR_MAX_CORE_HEALTH * 0.25 ? null : RADIO_CHANNEL_ENGINEERING)
		COOLDOWN_START(src, radio_cooldown, CDR_RADIO_COOLDOWN)
	if(COOLDOWN_FINISHED(src, alert_cooldown) && core_health < CDR_MAX_CORE_HEALTH * 0.4)
		playsound(get_turf(src), 'sound/misc/alert.ogg', 100, TRUE, 5, pressure_affected = FALSE)
		COOLDOWN_START(src, alert_cooldown, CDR_ALERT_COOLDOWN + rand(-5, 5))

/obj/machinery/atmospherics/components/unary/cdr/proc/fail()
	investigate_log("failed. The last person to use it was [last_user]", INVESTIGATE_ENGINES)
	for(var/turf/nearby_turf in orange(CDR_DET_RADIUS, src))
		for(var/obj/object in nearby_turf.contents)
			SSexplosions.high_mov_atom += object
		SSexplosions.highturf += nearby_turf
	qdel(src)

/obj/machinery/atmospherics/components/unary/cdr/proc/process_toroid()
	toroid_spin = toroid_spin - toroid_spin * metallization_ratio

	toroid_spin = round(toroid_spin, 0.001) // prevent it from reaching absurdly small numbers

	var/datum/gas_mixture/toroid_mix = new()
	airs[1].pump_gas_volume(toroid_mix, input_volume)

	if(toroid_mix)
		toroid_spin += (length(toroid_mix.moles) ? toroid_mix.heat_capacity() / length(toroid_mix.moles) : 0) * (1 / parabolic_setting ** 2) * CDR_MOL_TO_SPIN

	parabolic_upper_limit = get_mass_multiplier()
	parabolic_ratio = toroid_spin / 10000

	toroid_flux_mult = round(max(parabolic_ratio * (-1 * (parabolic_ratio - sqrt(parabolic_upper_limit))**2 + (parabolic_upper_limit)), 0), (parabolic_upper_limit * parabolic_setting) / CDR_PARABOLIC_ACCURACY) //hopefully this rounding removes some issues

/obj/machinery/atmospherics/components/unary/cdr/proc/process_diffusion()
	var/datum/gas_mixture/turf_mix = src.loc.return_air()
	for(var/turf_gas in (turf_mix.moles | core_composition.moles))
		var/turf_mix_mols = turf_mix.moles[turf_gas]
		var/core_comp_mols = core_composition.moles[turf_gas]
		var/total_gas = core_comp_mols + turf_mix_mols

		if(!total_gas)
			continue

		var/ratio = total_gas * (1 - metallization_ratio)
		var/diffusion_difference = ratio - turf_mix_mols
		var/gas_diffused = ((diffusion_difference / total_gas) ** 3) * total_gas

		gas_diffused = clamp(gas_diffused, gas_diffused > 0 ? 0 : -turf_mix_mols, gas_diffused < 0 ? 0 : core_comp_mols)

		if(gas_diffused > 0)
			core_composition.adjust_gas(turf_gas, -gas_diffused)
			turf_mix.adjust_gas(turf_gas, gas_diffused)
		else
			core_composition.adjust_gas(turf_gas, -gas_diffused)
			turf_mix.adjust_gas(turf_gas, gas_diffused)

		src.air_update_turf(FALSE, FALSE)
		core_composition.garbage_collect()
		turf_mix.garbage_collect()

/obj/machinery/atmospherics/components/unary/cdr/proc/set_flux(flux_to_add)
	flux += flux_to_add * toroid_flux_mult

/obj/machinery/atmospherics/components/unary/cdr/proc/fire_graviton()
	var/obj/projectile/energy/graviton_particle/particle = new /obj/projectile/energy/graviton_particle(src)
	particle.carried_energy = flux * CDR_FLUX_TO_POWER
	particle.damage = min(300, round(log(2, flux)))
	flux = 0
	playsound(get_turf(src), 'sound/weapons/graviton.ogg', 100, TRUE)
	particle.fire(rand(0, 360))


/obj/machinery/power/energy_accumulator/graviton_target
	name = "graviton wave disperser"
	desc = "This can absorb graviton particles and convert them to electrical power. Steam turbines are king no longer!"
	icon = 'icons/obj/machines/power/graviton_target.dmi'
	icon_state = "target"

/obj/machinery/power/energy_accumulator/graviton_target/bullet_act(obj/projectile/projectile)
	if(!istype(projectile, /obj/projectile/energy/graviton_particle))
		return ..()
	var/obj/projectile/energy/graviton_particle/grav = projectile
	stored_energy += grav.carried_energy
	add_emitter(/obj/emitter/electrified, "electrified", 10, 10)
	playsound(src, 'sound/weapons/graviton_impact.ogg', 65, TRUE)
	return BULLET_ACT_BLOCK

/obj/machinery/power/energy_accumulator/graviton_target/attackby(obj/item/attacking_item, mob/user, params)
	if(default_unfasten_wrench(user, attacking_item))
		return
	return ..()

/obj/item/paper/fluff/cdr
	default_raw_text = "<p>This paper will guide you through how to operate the <strong>Condensate Decay Reactor</strong>. (henceforth referred to as the CDR)</p><p>The CDR has four components: the core, stability, the toroid, and graviton targets.</p><h3 id=\"the-core-\">The Core:</h3><hr><p>Gases will either deposit on the core, or diffuse off of it, to hit the set ratio of core-to-environment gases (called the metallization ratio) There, once they hit their decay threshold, will decay into other gases slowly. There is a decay chain, IE, one gases decays into another which decays into another. As gases decay, they release flux and cool the core, with each gas releasing a different amount of flux. Generally, more stable gases generate more flux, but also contribute to stability more.</p><br><h3 id=\"stability-\">Stability:</h3><hr><p>As gases collect on the core, they will cause the Reactor to become more stable. Stability is not optimal, and can lead to core collapse.  You can decrease stability by increasing the core temperature, or by adding BZ gas. Stability is massively increased by low temperatures, though by how much can be reduced by adding N2O.</p><br><h3 id=\"toroid-\">Toroid:</h3><hr><p>The toroid is quite simple, it will increase the amount of flux produced based on a parabolic function. As gases are input they increase toroid spin. (higher specific heats generate more spin) Toroid spin is the X-value of the parabolic function- you need to hit the sweet spot to get the most flux output. The upper limit is increased by core mass. There is also the parabolic setting variable, which makes it easier increase the X-value of the function, but the upper limit is also reduced.</p><br><h3 id=\"graviton-targets-\">Graviton Targets:</h3><hr><p>These convert graviton particles ejected from the CDR into power.</p>"
	name = "CDR Technical Sheet"
