// ATMOSIA GAS MONITOR SUITE TAGS
// Things that use these include atmos control monitors, sensors, inputs, and outlets.
// They last three adds _sensor, _in, and _out respectively to the id_tag variable.
// Dont put underscores here, we use them as delimiters.

#define ATMOS_GAS_MONITOR_O2 "o2"
#define ATMOS_GAS_MONITOR_PLAS "plas"
#define ATMOS_GAS_MONITOR_AIR "air"
#define ATMOS_GAS_MONITOR_MIX "mix"
#define ATMOS_GAS_MONITOR_N2O "n2o"
#define ATMOS_GAS_MONITOR_N2 "n2"
#define ATMOS_GAS_MONITOR_CO2 "co2"
#define ATMOS_GAS_MONITOR_BZ "bz"
#define ATMOS_GAS_MONITOR_HYPERNOBLIUM "hypernoblium"
#define ATMOS_GAS_MONITOR_NITRYL "nitryl"
#define ATMOS_GAS_MONITOR_PLUOXIUM "pluoxium"
#define ATMOS_GAS_MONITOR_TRITIUM "tritium"
#define ATMOS_GAS_MONITOR_H2O "h2o"
#define ATMOS_GAS_MONITOR_INCINERATOR "incinerator"
#define ATMOS_GAS_MONITOR_ORDNANCE_LAB "ordnancelab"
#define ATMOS_GAS_MONITOR_DISTRO "distro"
#define ATMOS_GAS_MONITOR_WASTE "waste"

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
	ATMOS_GAS_MONITOR_ORDNANCE_LAB = "Ordnance Chamber",
	ATMOS_GAS_MONITOR_DISTRO = "Distribution Loop",
	ATMOS_GAS_MONITOR_WASTE = "Waste Loop",
))
