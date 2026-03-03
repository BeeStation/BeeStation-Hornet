//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "portable generator"
	desc = "A portable generator for emergency backup power."
	icon = 'icons/obj/machines/power/portgen.dmi'
	icon_state = "portgen0"
	base_icon_state = "portgen0"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE

	var/active = FALSE
	var/power_gen = 5 KILOWATT
	var/power_output = 1
	var/consumption = 0
	var/datum/looping_sound/portable_generator/soundloop

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

/obj/machinery/power/port_gen/Initialize(mapload)
	. = ..()
	soundloop = new(src, active)

/obj/machinery/power/port_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/port_gen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return TRUE

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/proc/TogglePower()
	if(active)
		active = FALSE
		update_appearance(UPDATE_ICON)
		soundloop.stop()
	else if(HasFuel())
		active = TRUE
		START_PROCESSING(SSmachines, src)
		update_appearance(UPDATE_ICON)
		update_sound_volume()
		soundloop.start()

/obj/machinery/power/port_gen/update_icon_state()
	icon_state = "[base_icon_state][active ? "on" : ""]"
	return ..()

/obj/machinery/power/port_gen/proc/update_sound_volume()
	if(!soundloop)
		return
	// Scale volume based on power output
	var/new_volume = 10 + (15 * power_output)
	if(soundloop.volume != new_volume)
		soundloop.volume = new_volume

/obj/machinery/power/port_gen/process()
	if(active)
		if(!HasFuel() || !anchored)
			TogglePower()
			return
		if(powernet)
			add_avail(power_gen * power_output)
		UseFuel()
	else
		handleInactive()

/obj/machinery/power/port_gen/examine(mob/user)
	. = ..()
	. += "It is[!active?"n't":""] running."

/////////////////
// P.A.C.M.A.N //
/////////////////
/obj/machinery/power/port_gen/pacman
	name = "\improper P.A.C.M.A.N.-type portable generator"
	circuit = /obj/item/circuitboard/machine/pacman
	var/sheets = 0
	var/max_sheets = 100
	var/sheet_name = ""
	var/sheet_path = /obj/item/stack/sheet/mineral/plasma
	var/sheet_left = 0 // How much is left of the sheet
	var/time_per_sheet = 260
	/// Current operating temperature in Kelvin
	var/operating_temperature = T20C
	/// Maximum safe operating temperature before overheating begins (in Kelvin)
	var/max_temperature = T0C + 300
	/// Temperature gain per power level (equilibrium calculation)
	var/temperature_gain = 55
	/// Heat capacity of the generator (J/K) - affects how quickly temperature changes
	var/heat_capacity = 5000
	/// Overheat counter - explodes when this exceeds max_overheat
	var/overheating = 0
	/// Maximum overheat counter before explosion
	var/max_overheat = 150
	/// Current smoke/steam state (for visual effects)
	var/smoke_state = 0

/obj/machinery/power/port_gen/pacman/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()

	var/obj/S = sheet_path
	sheet_name = initial(S.name)

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	return ..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	var/temp_rating = 0
	var/matter_bin_rating = 0
	var/consumption_coeff = 0

	for(var/obj/item/stock_parts/part in component_parts)
		if(istype(part, /obj/item/stock_parts/micro_laser))
			temp_rating += part.rating
		else if(istype(part, /obj/item/stock_parts/capacitor))
			temp_rating += part.rating
		else if(istype(part, /obj/item/stock_parts/matter_bin))
			matter_bin_rating += part.rating
		else
			consumption_coeff += part.rating

	max_sheets = 50 * clamp(matter_bin_rating, 0, 5) ** 2
	power_gen = round(initial(power_gen) * clamp(temp_rating, 0, 20) / 2)
	consumption = max(consumption_coeff, 1) // Ensure minimum consumption of 1
	..()

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	. = ..()
	. += span_notice("The generator has [sheets] units of [sheet_name] fuel left, producing [display_power(power_gen)] per cycle.")
	if(anchored)
		. += span_notice("It is anchored to the ground.")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Fuel efficiency increased by <b>[(consumption*100)-100]%</b>.")
		if(active)
			. += span_notice("Operating temperature: <b>[round(operating_temperature - T0C, 0.1)]°C</b> (max safe: [round(max_temperature - T0C)]°C)")
			if(overheating > 0)
				var/percent = round((overheating / max_overheat) * 100, 1)
				. += span_warning("OVERHEATING: [percent]%")

/obj/machinery/power/port_gen/pacman/HasFuel()
	if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
		return TRUE
	return FALSE

/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		new sheet_path(drop_location(), sheets)
		sheets = 0

/obj/machinery/power/port_gen/pacman/UseFuel()
	var/needed_sheets = 1 / (time_per_sheet * consumption / power_output)
	var/temp = min(needed_sheets, sheet_left)
	needed_sheets -= temp
	sheet_left -= temp
	sheets -= round(needed_sheets)
	needed_sheets -= round(needed_sheets)
	if (sheet_left <= 0 && sheets > 0)
		sheet_left = 1 - needed_sheets
		sheets--

	// Thermal equilibrium system
	var/datum/gas_mixture/environment = loc.return_air()
	var/ambient_temp = environment ? environment.return_temperature() : T20C
	var/pressure_ratio = environment ? min(environment.return_pressure() / ONE_ATMOSPHERE, 1) : 1

	// target temperature range based on power output (in Kelvin)
	var/lower_limit = T0C + 56 + (power_output * temperature_gain)
	var/upper_limit = T0C + 76 + (power_output * temperature_gain)

	// ambient temperature deviation from 20C
	var/ambient_deviation = ambient_temp - T20C
	lower_limit += ambient_deviation * pressure_ratio
	upper_limit += ambient_deviation * pressure_ratio

	// equilibrium and temperature drift
	var/target_temp = (lower_limit + upper_limit) / 2
	var/temp_diff = target_temp - operating_temperature
	var/bias = clamp(round(temp_diff / 40), -20, 20)

	//temperature change random variation
	operating_temperature += bias + rand(-7, 7)
	operating_temperature = max(operating_temperature, TCMB) // Can't go below cosmic background temperature

	// Thermal runaway - when running hot, chance for temperature spikes
	if(operating_temperature > max_temperature * 0.9)
		if(prob(power_output * 10))
			operating_temperature += rand(5, 15)

	// Heat transfer to environment
	if(environment)
		// Calculate outer temperature
		var/outer_temp = 0.1 * (operating_temperature - T0C) + T0C
		if(outer_temp > environment.temperature)
			var/environment_heat_capacity = environment.heat_capacity()
			if(environment_heat_capacity > 0)
				// Energy needed to heat environment to outer_temp
				var/heat_transfer = environment_heat_capacity * (outer_temp - environment.temperature)
				if(heat_transfer > 1)
					// Cap by heating power (10% of power output)
					var/heating_power = 0.1 * power_gen * power_output
					heat_transfer = min(heat_transfer, heating_power)
					// Apply thermal energy to environment
					environment.temperature = max(environment.temperature + heat_transfer / environment_heat_capacity, TCMB)

	// Overheat mechanics
	if(operating_temperature > max_temperature)
		overheating++
		// Add smoke effects when overheating
		var/new_smoke = 0
		if(overheating > max_overheat * 0.8)
			new_smoke = 3
		else if(overheating > max_overheat * 0.5)
			new_smoke = 2
		else if(overheating > 0)
			new_smoke = 1
		set_smoke_state(new_smoke)

		if(overheating > max_overheat)
			overheat()
			qdel(src)
	else if(overheating > 0)
		overheating--
		if(overheating == 0)
			set_smoke_state(0) // Clear smoke when no longer overheating

/obj/machinery/power/port_gen/pacman/handleInactive()
	// Environmental cooling when inactive
	var/datum/gas_mixture/environment = loc.return_air()
	var/ambient_temp = environment ? environment.return_temperature() : T20C
	var/pressure_ratio = environment ? min(environment.return_pressure() / ONE_ATMOSPHERE, 1) : 1

	// Cool toward ambient temperature (in Kelvin)
	var/cooling_target = T20C + ((ambient_temp - T20C) * pressure_ratio)
	var/temp_loss = clamp((operating_temperature - cooling_target) / 40, 2, 20)
	operating_temperature -= temp_loss
	operating_temperature = max(operating_temperature, TCMB)

	// Reduce overheat counter while cooling
	if(overheating > 0)
		overheating--

	// Stop processing when fully cooled
	if(operating_temperature <= cooling_target + 5 && overheating == 0)
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/power/port_gen/pacman/proc/overheat()
	explosion(src.loc, 2, 5, 2, -1)

/obj/machinery/power/port_gen/pacman/proc/set_smoke_state(new_state)
	if(new_state == smoke_state)
		return
	smoke_state = new_state

	QDEL_NULL(particles)
	switch(smoke_state)
		if(3) // Heavy smoke - critically overheating
			particles = new /particles/smoke()
		if(2) // Medium smoke - moderately overheating
			particles = new /particles/smoke/steam()
		if(1) // Light steam - starting to overheat
			particles = new /particles/smoke/steam/mild

/obj/machinery/power/port_gen/pacman/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(anchorvalue)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/port_gen/pacman/attackby(obj/item/O, mob/user, params)
	if(istype(O, sheet_path))
		var/obj/item/stack/addstack = O
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, span_notice("The [src.name] is full!"))
			return
		to_chat(user, span_notice("You add [amount] sheets to the [src.name]."))
		sheets += amount
		addstack.use(amount)
		return
	else if(!active)
		if(O.tool_behaviour == TOOL_WRENCH)
			if(!anchored && !isinspace())
				set_anchored(TRUE)
				to_chat(user, span_notice("You secure the generator to the floor."))
			else if(anchored)
				set_anchored(FALSE)
				to_chat(user, span_notice("You unsecure the generator from the floor."))

			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return
		else if(O.tool_behaviour == TOOL_SCREWDRIVER)
			panel_open = !panel_open
			O.play_tool_sound(src)
			if(panel_open)
				to_chat(user, span_notice("You open the access panel."))
			else
				to_chat(user, span_notice("You close the access panel."))
			return
		else if(default_deconstruction_crowbar(O))
			return
	return ..()

/obj/machinery/power/port_gen/pacman/on_emag(mob/user)
	..()
	balloon_alert(user, "maximum power output unlocked")
	emp_act(EMP_HEAVY)

/obj/machinery/power/port_gen/pacman/attack_silicon(mob/user)
	interact(user)

/obj/machinery/power/port_gen/pacman/attack_paw(mob/user)
	interact(user)

/obj/machinery/power/port_gen/pacman/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableGenerator")
		ui.open()
		ui.set_autoupdate(TRUE) // Fuel left, power generated, power in powernet, current heat(?)

/obj/machinery/power/port_gen/pacman/ui_data()
	var/data = list()

	data["active"] = active
	data["sheet_name"] = capitalize(sheet_name)
	data["sheets"] = sheets
	data["stack_percent"] = round(sheet_left * 100, 0.1)

	data["anchored"] = anchored
	data["connected"] = (powernet == null ? 0 : 1)
	data["ready_to_boot"] = anchored && HasFuel()
	data["power_generated"] = display_power_persec(power_gen)
	data["power_output"] = display_power_persec(power_gen * power_output)
	data["power_available"] = (powernet == null ? 0 : display_power_persec(avail()))
	data["current_heat"] = round(operating_temperature - T0C, 0.1) // Display in Celsius
	data["max_temperature"] = round(max_temperature - T0C) // ditto
	data["overheat_percent"] = round((overheating / max_overheat) * 100, 0.1)
	. =  data

/obj/machinery/power/port_gen/pacman/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_power")
			TogglePower()
			. = TRUE

		if("eject")
			if(!active)
				DropFuel()
				. = TRUE

		if("lower_power")
			if (power_output > 1)
				power_output--
				update_sound_volume()
				update_appearance(UPDATE_ICON)
				. = TRUE

		if("higher_power")
			if (power_output < 4 || (obj_flags & EMAGGED))
				power_output++
				update_sound_volume()
				update_appearance(UPDATE_ICON)
				. = TRUE

/obj/machinery/power/port_gen/pacman/super
	name = "\improper S.U.P.E.R.P.A.C.M.A.N.-type portable generator"
	desc = "A power generator that utilizes uranium sheets as fuel. Can run for much longer than the standard PACMAN type generators."
	icon_state = "portgen1"
	base_icon_state = "portgen1"
	circuit = /obj/item/circuitboard/machine/pacman/super
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	power_gen = 15 KILOWATT
	time_per_sheet = 85
	// Thermal characteristics same as standard PACMAN
	max_temperature = T0C + 300
	temperature_gain = 50
	/// Radiation output multiplier
	var/rad_power = 4
	/// Power output level considered safe (radiation glow appears above this)
	var/max_safe_output = 3
	/// Maximum power output level for alpha scaling
	var/max_power_output = 4

/obj/machinery/power/port_gen/pacman/super/UseFuel()
	// Produces a tiny amount of radiation when in use
	if(prob(rad_power * power_output))
		radiation_pulse(src, 2 * rad_power)
	..()

/obj/machinery/power/port_gen/pacman/super/update_overlays()
	. = ..()
	if(!active)
		set_light(0)
		return
	// Radiation glow at high power output
	if(power_output >= max_safe_output)
		var/glow_alpha = round(255 * power_output / max_power_output)
		var/icon_state_rad = "[base_icon_state]rad"

		// Add visible glow overlay
		var/mutable_appearance/rad_overlay = mutable_appearance(icon, icon_state_rad, layer)
		rad_overlay.blend_mode = BLEND_ADD
		rad_overlay.alpha = glow_alpha
		. += rad_overlay

		// Add emissive overlay
		. += emissive_appearance(icon, icon_state_rad, layer, glow_alpha)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

		set_light(rad_power + power_output - max_safe_output, 0.7, "#3b97ca")
	else
		set_light(0)

/obj/machinery/power/port_gen/pacman/super/overheat()
	// A nice burst of radiation
	var/rads = rad_power * 25 + (sheets + sheet_left) * 1.5
	radiation_pulse(src, max(40, rads))
	explosion(src.loc, 3, 3, 3, -1)

/obj/machinery/power/port_gen/pacman/mrs
	name = "\improper M.R.S.P.A.C.M.A.N.-type portable generator"
	icon_state = "portgen2"
	base_icon_state = "portgen2"
	circuit = /obj/item/circuitboard/machine/pacman/mrs
	sheet_path = /obj/item/stack/sheet/mineral/diamond
	power_gen = 40 KILOWATT
	time_per_sheet = 80
	// MRS has much higher thermal tolerance but generates more heat per level
	max_temperature = T0C + 800
	temperature_gain = 90

/obj/machinery/power/port_gen/pacman/mrs/overheat()
	explosion(src.loc, 4, 4, 4, -1)
