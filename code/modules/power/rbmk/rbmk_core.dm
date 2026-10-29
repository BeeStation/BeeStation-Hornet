/*
	This section contains the RBMK's core with all the variables and the Initialize() and Destroy() procs

//Reference: Heaters go up to 500K.
//Hot plasmaburn: 14164.95 C.

Moderators list (Not gonna keep this accurate forever):
Fuel Type:
Oxygen: Power production multiplier. Allows you to run a low plasma, high oxy mix, and still get a lot of power.
Plasma: Power production gas. More plasma -> more power, but it enriches your fuel and makes the reactor much, much harder to control.
Tritium: Extremely efficient power production gas. Will cause chernobyl if used improperly.

Moderation Type:
N2: Helps you regain control of the reaction by increasing control rod effectiveness, will massively boost the rad production of the reactor.
CO2: Super effective shutdown gas for runaway reactions. MASSIVE RADIATION PENALTY!
Pluoxium: Same as N2, but no cancer-rads!

Permeability Type:
BZ: Increases your reactor's ability to transfer its heat to the coolant, thus letting you cool it down faster (but your output will get hotter)
Water Vapour: More efficient permeability modifier
Hyper Noblium: Extremely efficient permeability increase. (10x as efficient as bz)

Depletion type:
Nitrium: When you need weapons grade plutonium yesterday. Causes your fuel to deplete much, much faster. Not a huge amount of use outside of sabotage.

Sabotage:

Meltdown:
Flood reactor moderator with plasma, they won't be able to mitigate the reaction with control rods.
Shut off coolant entirely. Raise control rods.
Swap all fuel out with spent fuel, as it's way stronger.

Blowout:
Shut off exit valve for quick overpressure.
Cause a pipefire in the coolant line (LETHAL).
Tack heater onto coolant line (can also cause straight meltdown)

Tips:
Be careful to not exhaust your plasma supply. I recommend you DON'T max out the moderator input when youre running plasma + o2, or you're at a tangible risk of running out of those gasses from atmos.
The reactor CHEWS through moderator. It does not do this slowly. Be very careful with that!

Remember kids. If the reactor itself is not physically powered by an APC, it cannot shove coolant in!
*/

/obj/machinery/atmospherics/components/unary/rbmk/core
	name = "\improper Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'icons/obj/machines/power/rbmk/rbmk_reactor.dmi'
	icon_state = "reactor"
	base_icon_state = "reactor"
	use_power = IDLE_POWER_USE
	layer = NUCLEAR_REACTOR_LAYER
	// This is to offset the entire reactor by one tile down and left, so it actually looks right.
	pixel_x = -32
	pixel_y = -32

	//Processing checks

	/// If the reactor is active or not
	var/active = FALSE

	// RBMK internal gasmix

	/// Stores the information for the control rods computer
	var/obj/machinery/computer/reactor_control_rods/linked_interface
	/// Stores the information of the moderator input
	var/obj/machinery/atmospherics/components/unary/rbmk/moderator_input/linked_moderator
	/// Stores the information of the fuel input
	var/obj/machinery/atmospherics/components/unary/rbmk/coolant_input/linked_input
	/// Stores the information of the waste output
	var/obj/machinery/atmospherics/components/unary/rbmk/waste_output/linked_output

	// Variables essential to operation

	/// Lose control of this -> Meltdown
	var/temperature = 0
	/// Lose control of this -> Blowout
	var/pressure = 0
	// Rate of reaction.
	var/rate_of_reaction = 0
	var/desired_reate_of_reaction = 0
	/// Starts off with a lot of control over rate_of_reaction.
	/// If you flood this thing with plasma, you lose your ability to control rate_of_reaction as easily.
	var/control_rod_effectiveness = 0.5
	/// 0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power = 0
	/// The fuel rods in this reactor
	var/list/fuel_rods = list()
	var/gas_absorption_effectiveness = 0.5
	var/gas_absorption_constant = 0.5 //We refer to this one as it's set on init, randomized.
	var/minimum_coolant_level = 5

	/// Our internal radio
	var/obj/item/radio/radio
	/// The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng
	/// The engineering channel
	var/engineering_channel = RADIO_CHANNEL_ENGINEERING
	/// The common channel
	var/common_channel = null

	/// Our soundloop for the alarm
	var/datum/looping_sound/rbmk/alarmloop
	var/alarm = FALSE //Is the alarm playing already?

	/// Soundloop for ambience
	var/datum/looping_sound/rbmk_ambience/soundloop

	/// Console statistics
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	/// For administrative cheating only. Knowing the delta lets you know EXACTLY what to set rate_of_reaction at.
	var/last_heat_delta = 0
	/// How many times in succession did we not have enough coolant? Decays twice as fast as it accumulates.
	var/no_coolant_ticks = 0

	/// Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0
	/// Boolean used for logging if we've passed the emergency point
	var/has_reached_emergency = FALSE

	/// Integrity of the machine, if reaches 900 the machine will explode. 1 so it doesnt stunlock itself and never change for damage calculations
	var/critical_threshold_proximity = 0
	/// Store the integrity for calculations
	var/critical_threshold_proximity_archived = 0
	/// Our "Shit is no longer fucked" message. We send it when critical_threshold_proximity is less then critical_threshold_proximity_archived
	var/safe_alert = "RBMK reactor returning to safe operating parameters."
	/// The point at which we should start sending messeges about the critical_threshold_proximity to the engi channels.
	var/warning_point = 50
	/// The point at which we start sending messages to the common channel
	var/emergency_point = 700
	/// The alert we send when we've reached emergency_point
	var/emergency_alert = "NUCLEAR REACTOR MELTDOWN IMMINENT."
	/// The point at which we melt
	var/melting_point = 900
	/// Light flicker timer
	var/next_flicker = 0
	/// For logging purposes
	var/last_power_produced = 0
	/// Var used in the meltdown phase
	var/final_countdown = FALSE

	/// Flags used in the alert proc to select what messages to show when the reactor is delaminating (RBMK_PRESSURE_DAMAGE | RBMK_TEMPERATURE_DAMAGE)
	var/warning_damage_flags = NONE

	/// Counter for number of reactors on a server
	var/static/reactorcount = 0

	/// Grilling.
	var/grill_time = 0
	var/datum/looping_sound/grill/grill_loop
	var/obj/item/food/grilled_item

	/// Used to create a graph on the reactor UI
	var/list/logged_pressure = list()
	var/list/logged_power = list()
	var/list/logged_coolant_input_temp = list()
	var/list/logged_coolant_output_temp = list()
	/// How often we update the logged data
	var/stat_update_delay = 1 SECONDS
	COOLDOWN_DECLARE(next_stat_interval)

/obj/machinery/atmospherics/components/unary/rbmk/core/Initialize(mapload)
	. = ..()
	grill_loop = new(src)
	soundloop = new(src)
	alarmloop = new(src)

	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/point_of_interest)

	// All reactors are slightly different. This will result in you having to figure out what the balance is for rate_of_reaction.
	gas_absorption_effectiveness = RANDOM_DECIMAL(0.5, 0.6)
	// And set this up for the rest of the round.
	gas_absorption_constant = gas_absorption_effectiveness

	investigate_log("has been created.", INVESTIGATE_ENGINES)
	check_part_connectivity()
	set_init_directions()
	connect_nodes()
	update_appearance()
	update_pipenets()

	reactorcount++
	name += " ([reactorcount])"

	uid = gl_uid
	gl_uid++

/obj/machinery/atmospherics/components/unary/rbmk/core/Destroy()
	unregister_signals(only_signals = TRUE)
	if(linked_input)
		QDEL_NULL(linked_input)
	if(linked_output)
		QDEL_NULL(linked_output)
	if(linked_moderator)
		QDEL_NULL(linked_moderator)
	if(linked_interface)
		linked_interface.reactor = null
		linked_interface = null
	grilled_item = null
	QDEL_NULL(grill_loop)
	QDEL_NULL(radio)
	QDEL_NULL(soundloop)
	QDEL_NULL(alarmloop)

	SSair.atmos_machinery -= src
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/atmospherics/components/unary/rbmk/core/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
	else if(!active && !power)
		icon_state = base_icon_state
	else if(active && power < 20)
		icon_state = "[base_icon_state]_startup"
	else
		icon_state = "[base_icon_state]_active"

/obj/machinery/atmospherics/components/unary/rbmk/core/update_overlays()
	. = ..()
	if(ISINRANGE(length(fuel_rods), 0, 5))
		. += mutable_appearance('icons/obj/machines/power/rbmk/rbmk_reactor.dmi', "reactor_top_[length(fuel_rods)]")

/obj/machinery/atmospherics/components/unary/rbmk/core/examine(mob/user)
	. = ..()
	switch(get_integrity_percent())
		if(0 to 10)
			. += span_boldwarning("[src]'s seals are dangerously warped and you can see cracks all over the reactor vessel! ")
		if(10 to 40)
			. += span_boldwarning("[src]'s seals are heavily warped and cracked! ")
		if(40 to 60)
			. += span_warning("[src]'s seals are holding, but barely. You can see some micro-fractures forming in the reactor vessel.")
		if(60 to 80)
			. += span_warning("[src]'s seals are intact, but slightly worn. There are no visible cracks in the reactor vessel.")
		if(80 to 90)
			. += span_notice("[src]'s seals are in good shape, and there are no visible cracks in the reactor vessel.")
		if(95 to 100)
			. += span_notice("[src]'s seals look factory new, and the reactor's in excellent shape.")
		else
			. += span_warning("The reactor looks operational.")

// Nuclear reactor UI for ghosts only. Inherited attack_ghost will call this.
/obj/machinery/atmospherics/components/unary/rbmk/core/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user))
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Rbmk")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/atmospherics/components/unary/rbmk/core/ui_data()
	var/list/data = list()
	data["rbmk_data"] = list(rbmk_ui_data())
	return data

/**
 * Log the last 100 seconds of data for the RBMK reactor.
 * This is used to create graphs in the UI.
 */
/obj/machinery/atmospherics/components/unary/rbmk/core/proc/update_logged_data()
	COOLDOWN_START(src, next_stat_interval, stat_update_delay)

	// Pressure
	logged_pressure += pressure
	if(length(logged_pressure) > 100)
		logged_pressure.Cut(1, 2)

	// Power
	logged_power += power * 10
	if(length(logged_power) > 100)
		logged_power.Cut(1, 2)

	// Input coolant temp
	logged_coolant_input_temp += last_coolant_temperature
	if(length(logged_coolant_input_temp) > 100)
		logged_coolant_input_temp.Cut(1, 2)

	// Output coolant temp
	logged_coolant_output_temp += last_output_temperature
	if(length(logged_coolant_output_temp) > 100)
		logged_coolant_output_temp.Cut(1, 2)

/obj/machinery/atmospherics/components/unary/rbmk/core/proc/rbmk_ui_data()
	var/list/data = list()
	data["uid"] = uid
	data["area_name"] = get_area_name(src)

	// Immediate values
	data["integrity"] = get_integrity_percent()
	data["coolant_input_temp"] = last_coolant_temperature
	data["coolant_output_temp"] = last_output_temperature
	data["power"] = power
	data["pressure"] = pressure

	// Graph stuff
	data["logged_pressure"] = logged_pressure
	data["logged_power"] = logged_power
	data["logged_coolant_input_temp"] = logged_coolant_input_temp
	data["logged_coolant_output_temp"] = logged_coolant_output_temp

	return data
