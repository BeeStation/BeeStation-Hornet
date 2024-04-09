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
Nitryl: When you need weapons grade plutonium yesterday. Causes your fuel to deplete much, much faster. Not a huge amount of use outside of sabotage.

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

TO DO:

sprites
make it orderable
replace PSI with kpa on status monitor
check if it can explode
fix grilling
test things with aramix

*/

/obj/machinery/atmospherics/components/unary/rbmk/core
	name = "\improper Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'icons/obj/machines/rbmk.dmi'
	icon_state = "reactor_closed"
	use_power = IDLE_POWER_USE
	idle_power_usage = IDLE_POWER_USE

	///Vars for the state of the icon of the object (open, closed, fuel rod counts (1>5))
	icon_state_open = "reactor_open"
	icon_state_off = "reactor_closed"

	//Processing checks

	///Checks if the user has started the machine
	var/start_power = FALSE
	///Checks for the cooling to start
	var/start_cooling = FALSE
	///Checks for the moderators to be injected
	var/start_moderator = FALSE

	// RBMK internal gasmix

	//Stores the information for the control rods computer
	var/obj/machinery/computer/reactor/control_rods/linked_interface
	//Stores the information of the moderator input
	var/obj/machinery/atmospherics/components/unary/rbmk/moderator_input/linked_moderator
	///Stores the information of the fuel input
	var/obj/machinery/atmospherics/components/unary/rbmk/coolant_input/linked_input
	///Stores the information of the waste output
	var/obj/machinery/atmospherics/components/unary/rbmk/waste_output/linked_output
	///Stores the information of the corners of the machine
	var/list/corners = list()
	///Stores the three inputs/outputs of the RBMK
	var/list/machine_parts = list()

	//Variables essential to operation
	var/temperature =  0//Lose control of this -> Meltdown
	var/pressure = 0 //Lose control of this -> Blowout
	var/K = 0 //Rate of reaction.
	var/desired_k = 0
	var/control_rod_effectiveness = 0.65 //Starts off with a lot of control over K. If you flood this thing with plasma, you lose your ability to control K as easily.
	var/power = 0 //0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power_modifier = 1 //Upgrade me with parts, science! Flat out increase to physical power output when loaded with plasma.
	var/list/fuel_rods = list()
	var/gas_absorption_effectiveness = 0.5
	var/gas_absorption_constant = 0.5 //We refer to this one as it's set on init, randomized.
	var/minimum_coolant_level = 5

	///Our internal radio
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng
	///The engineering channel
	var/engineering_channel = "Engineering"
	///The common channel
	var/common_channel = null

	//Our soundloop for the alaarm
	var/datum/looping_sound/rbmk/soundloop

	//Console statistics
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	var/last_heat_delta = 0 //For administrative cheating only. Knowing the delta lets you know EXACTLY what to set K at.
	var/no_coolant_ticks = 0	//How many times in succession did we not have enough coolant? Decays twice as fast as it accumulates.

	///Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0
	///Boolean used for logging if we've passed the emergency point
	var/has_reached_emergency = FALSE

	///Integrity of the machine, if reaches 900 the machine will explode
	var/critical_threshold_proximity = 0
	///Store the integrity for calculations
	var/critical_threshold_proximity_archived = 0
	///Our "Shit is no longer fucked" message. We send it when critical_threshold_proximity is less then critical_threshold_proximity_archived
	var/safe_alert = "RBMK reactor returning to safe operating parameters."
	///The point at which we should start sending messeges about the critical_threshold_proximity to the engi channels.
	var/warning_point = 50
	///The alert we send when we've reached warning_point
	var/warning_alert = "Danger! RBMK reactor faltering!"
	///The point at which we start sending messages to the common channel
	var/emergency_point = 700
	///The alert we send when we've reached emergency_point
	var/emergency_alert = "NUCLEAR REACTOR MELTDOWN IMMINENT."
	///The point at which we melt
	var/melting_point = 900
	//Light flicker timer
	var/next_flicker = 0
	//For logging purposes
	var/last_power_produced = 0
	//Power modifier for producing power.
	var/base_power_modifier = RBMK_POWER_FLAVOURISER
	///Var used in the meltdown phase
	var/final_countdown = FALSE


	///Flags used in the alert proc to select what messages to show when the reactor is delaminating (RBMK_PRESSURE_DAMAGE | RBMK_TEMPERATURE_DAMAGE)
	var/warning_damage_flags = NONE

	//Counter for number of reactors on a server
	var/static/reactorcount = 0

/obj/machinery/atmospherics/components/unary/rbmk/core/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/point_of_interest)
	investigate_log("has been created.", INVESTIGATE_ENGINES)

	reactorcount++
	src.name = name + " ([reactorcount])"
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.
	gas_absorption_constant = gas_absorption_effectiveness //And set this up for the rest of the round.
	check_part_connectivity()

/obj/machinery/atmospherics/components/unary/rbmk/core/Destroy()
	unregister_signals(TRUE)
	if(linked_input)
		QDEL_NULL(linked_input)
	if(linked_output)
		QDEL_NULL(linked_output)
	if(linked_moderator)
		QDEL_NULL(linked_moderator)
	if(linked_interface)
		QDEL_NULL(linked_interface)
	QDEL_NULL(radio)
	QDEL_NULL(soundloop)
	machine_parts = null
	return ..()

/obj/machinery/atmospherics/components/unary/rbmk/core/examine(mob/user)
	. = ..()
	if(Adjacent(src, user))
		if(do_after(user, 1 SECONDS, target=src))
			var/slope = -100 / 900
			var/intercept = 100
			var/percent = slope * critical_threshold_proximity + intercept
			var/msg = "<span class='warning'>The reactor looks operational.</span>"
			switch(percent)
				if(0 to 10)
					msg = "<span class='boldwarning'>[src]'s seals are dangerously warped and you can see cracks all over the reactor vessel! </span>"
				if(10 to 40)
					msg = "<span class='boldwarning'>[src]'s seals are heavily warped and cracked! </span>"
				if(40 to 60)
					msg = "<span class='warning'>[src]'s seals are holding, but barely. You can see some micro-fractures forming in the reactor vessel.</span>"
				if(60 to 80)
					msg = "<span class='warning'>[src]'s seals are in-tact, but slightly worn. There are no visible cracks in the reactor vessel.</span>"
				if(80 to 90)
					msg = "<span class='notice'>[src]'s seals are in good shape, and there are no visible cracks in the reactor vessel.</span>"
				if(95 to 100)
					msg = "<span class='notice'>[src]'s seals look factory new, and the reactor's in excellent shape.</span>"
			. += msg
