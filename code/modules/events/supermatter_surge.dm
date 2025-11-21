#define SURGE_DURATION_MIN 240 SECONDS
#define SURGE_DURATION_MAX 270 SECONDS
#define SURGE_SEVERITY_MIN 1
#define SURGE_SEVERITY_MAX 4
#define SURGE_SEVERITY_RANDOM 5
/// The amount of bullet energy we add for the duration of the SM surge
#define SURGE_BULLET_ENERGY_ADDITION 5
/// The amount of powerloss inhibition (energy retention) we add for the duration of the SM surge
#define SURGE_BASE_POWERLOSS_INHIBITION 0.55
/// The powerloss inhibition scaling based on surge severity
#define SURGE_POWERLOSS_INHIBITION_MODIFIER 0.175
/// The power generation scaling based on surge severity
#define SURGE_POWER_GENERATION_MODIFIER 0.075
/// The heat modifier scaling based on surge severity
#define SURGE_HEAT_MODIFIER 0.25

/**
 * Supermatter Surge
 *
 * An engineering challenge event where the properties of the SM changes to be in a 'surge' of power.
 * For the duration of the event a powerloss inhibition is added to nitrogen, causing the crystal to retain more of its internal energy.
 * Heat modifier is lowered to generate some heat but not a high temp burn.
 * Bullet energy from emitters is raised slightly to raise meV while turned on.
 */

/datum/round_event_control/supermatter_surge
	name = "Supermatter Surge"
	typepath = /datum/round_event/supermatter_surge
	weight = 15
	max_occurrences = 1
	earliest_start = 60 MINUTES

/datum/round_event_control/supermatter_surge/canSpawnEvent(players_amt)
	. = ..()
	if(!.)
		return FALSE

	if(isnull(GLOB.main_supermatter_engine))
		return FALSE
	if(GLOB.main_supermatter_engine.get_status() == SUPERMATTER_INACTIVE)
		return FALSE

/datum/round_event/supermatter_surge
	announceWhen = 4
	endWhen = 5

	/// How powerful is the supermatter surge going to be?
	var/surge_class = SURGE_SEVERITY_RANDOM
	/// Typecasted reference to the supermatter chosen at event start
	var/obj/machinery/power/supermatter_crystal/engine
	/// Typecasted reference to the nitrogen properies in the SM chamber
	var/datum/sm_gas/nitrogen/sm_gas

/datum/round_event/supermatter_surge/setup()
	engine = GLOB.main_supermatter_engine
	if(isnull(engine))
		stack_trace("SM surge event failed to find a supermatter engine!")
		return

	sm_gas = LAZYACCESS(engine.current_gas_behavior, /datum/gas/nitrogen)
	if(isnull(sm_gas))
		stack_trace("SM surge event failed to find gas properties for [engine].")
		return

	if(surge_class == SURGE_SEVERITY_RANDOM)
		var/severity_weight = rand(1, 100)
		switch(severity_weight)
			if(1 to 14)
				surge_class = 1
			if(15 to 34)
				surge_class = 2
			if(35 to 69)
				surge_class = 3
			if(70 to 100)
				surge_class = 4

	addtimer(CALLBACK(src, PROC_REF(actually_end)), rand(SURGE_DURATION_MIN, SURGE_DURATION_MAX), TIMER_OVERRIDE|TIMER_UNIQUE)

/datum/round_event/supermatter_surge/announce(fake)
	var/class_to_announce = fake ? pick(1, 2, 3, 4) : surge_class
	priority_announce(
		"The Crystal Integrity Monitoring System has detected unusual atmospheric properties in the supermatter chamber, \
		energy output from the supermatter crystal has increased significantly. \
		Engineering intervention is required to stabilize the engine.",
		"Class [class_to_announce] Supermatter Surge Alert",
		'sound/machines/engine_alert3.ogg'
	)

/datum/round_event/supermatter_surge/start()
	engine.bullet_energy = surge_class + SURGE_BULLET_ENERGY_ADDITION
	sm_gas.powerloss_inhibition = (surge_class * SURGE_POWERLOSS_INHIBITION_MODIFIER) + SURGE_BASE_POWERLOSS_INHIBITION
	sm_gas.heat_power_generation = (surge_class * SURGE_POWER_GENERATION_MODIFIER) - 1
	sm_gas.heat_modifier = (surge_class * SURGE_HEAT_MODIFIER) - 1

/// I HATE EVENT CODE SO MUCH, BUT THIS IS THE WAY IT HAS TO BE DONE, AGH!
/datum/round_event/supermatter_surge/proc/actually_end()
	if(!QDELETED(engine))
		engine.bullet_energy = initial(engine.bullet_energy)
		priority_announce("The supermatter surge has dissipated, crystal output readings have normalized.", "Anomaly Cleared")

	sm_gas.powerloss_inhibition = initial(sm_gas.powerloss_inhibition)
	sm_gas.heat_power_generation = initial(sm_gas.heat_power_generation)
	sm_gas.heat_modifier = initial(sm_gas.heat_modifier)
	engine = null
	sm_gas = null

/datum/round_event_control/supermatter_surge/poly
	name = "Supermatter Surge: Poly's Revenge"
	typepath = /datum/round_event/supermatter_surge/poly
	weight = 0
	max_occurrences = 4
	earliest_start = 0

/datum/round_event/supermatter_surge/poly
	announceWhen = 4
	surge_class =  4
	fakeable = FALSE

/datum/round_event/supermatter_surge/poly/announce(fake)
	priority_announce(
		"The Crystal Integrity Monitoring System has detected unusual parrot type resonance in the supermatter chamber, energy output from the supermatter crystal has increased significantly. Engineering intervention is required to stabilize the engine.",
		"Class P Supermatter Surge Alert",
		'sound/machines/engine_alert3.ogg'
	)

#undef SURGE_DURATION_MIN
#undef SURGE_DURATION_MAX
#undef SURGE_SEVERITY_MIN
#undef SURGE_SEVERITY_MAX
#undef SURGE_SEVERITY_RANDOM
#undef SURGE_BULLET_ENERGY_ADDITION
#undef SURGE_BASE_POWERLOSS_INHIBITION
#undef SURGE_POWERLOSS_INHIBITION_MODIFIER
#undef SURGE_POWER_GENERATION_MODIFIER
#undef SURGE_HEAT_MODIFIER
