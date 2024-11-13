// ATMOSIA GAS MONITOR SUITE TAGS
// Things that use these include atmos control monitors, sensors, inputs, and outlets.
// They last three adds _sensor, _in, and _out respectively to the id_tag variable.
// Dont put underscores here, we use them as delimiters.

#define ATMOS_GAS_MONITOR_O2 GAS_O2
#define ATMOS_GAS_MONITOR_PLAS GAS_PLASMA
#define ATMOS_GAS_MONITOR_AIR GAS_AIR
#define ATMOS_GAS_MONITOR_MIX "mix"
#define ATMOS_GAS_MONITOR_N2O GAS_N2O
#define ATMOS_GAS_MONITOR_N2 GAS_N2
#define ATMOS_GAS_MONITOR_CO2 GAS_CO2
#define ATMOS_GAS_MONITOR_BZ GAS_BZ
#define ATMOS_GAS_MONITOR_H2 GAS_HYDROGEN
#define ATMOS_GAS_MONITOR_HYPERNOBLIUM GAS_HYPER_NOBLIUM
#define ATMOS_GAS_MONITOR_NITRYL GAS_NITRYL
#define ATMOS_GAS_MONITOR_PLUOXIUM GAS_PLUOXIUM
#define ATMOS_GAS_MONITOR_TRITIUM GAS_TRITIUM
#define ATMOS_GAS_MONITOR_H2O GAS_WATER_VAPOR
#define ATMOS_GAS_MONITOR_INCINERATOR "incinerator"
#define ATMOS_GAS_MONITOR_TOXINS_BURN "toxinsburn"
#define ATMOS_GAS_MONITOR_TOXINS_FREEZER "toxinsfreezer"
#define ATMOS_GAS_MONITOR_DISTRO "distro"
#define ATMOS_GAS_MONITOR_WASTE "waste"
#define ATMOS_GAS_MONITOR_ENGINE "engine"


///maps a chamber id to its air sensor
#define CHAMBER_SENSOR_FROM_ID(chamber_id) ((chamber_id) + "_sensor")
///maps an air sensor's chamber id to its input valve[ i.e. outlet_injector] id
#define CHAMBER_INPUT_FROM_ID(chamber_id) ((chamber_id) + "_in")
///maps an air sensor's chamber id to its output valve[i.e. vent pump] id
#define CHAMBER_OUTPUT_FROM_ID(chamber_id) ((chamber_id) + "_out")

///list of all air sensor's created round start
GLOBAL_LIST_EMPTY(map_loaded_sensors)

// Human-readble names of these funny tags.
GLOBAL_LIST_INIT(station_gas_chambers, list(
	ATMOS_GAS_MONITOR_O2 = "Oxygen Supply",
	ATMOS_GAS_MONITOR_PLAS = "Plasma Supply",
	ATMOS_GAS_MONITOR_AIR = "Mixed Air Supply",
	ATMOS_GAS_MONITOR_N2O = "Nitrous Oxide Supply",
	ATMOS_GAS_MONITOR_N2 = "Nitrogen Supply",
	ATMOS_GAS_MONITOR_CO2 = "Carbon Dioxide Supply",
	ATMOS_GAS_MONITOR_BZ = "BZ Supply",
	ATMOS_GAS_MONITOR_HYPERNOBLIUM = "Hypernoblium Supply",
	ATMOS_GAS_MONITOR_NITRYL = "Nitryl Supply",
	ATMOS_GAS_MONITOR_PLUOXIUM = "Pluoxium Supply",
	ATMOS_GAS_MONITOR_TRITIUM = "Tritium Supply",
	ATMOS_GAS_MONITOR_H2O = "Water Vapor Supply",
	ATMOS_GAS_MONITOR_MIX = "Mix Chamber",
	ATMOS_GAS_MONITOR_INCINERATOR = "Incinerator Chamber",
	ATMOS_GAS_MONITOR_TOXINS_LAB = "Toxins Chamber",
	ATMOS_GAS_MONITOR_DISTRO = "Distribution Loop",
	ATMOS_GAS_MONITOR_WASTE = "Waste Loop",
	ATMOS_GAS_MONITOR_ENGINE = "Supermatter Engine Chamber",
))
