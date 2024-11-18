#define KILOWATT *1000
#define MEGAWATT KILOWATT *1000
#define GIGAWATT MEGAWATT *1000

///The watt is the standard unit of power for this codebase. Do not change this.
#define WATT 1
///The joule is the standard unit of energy for this codebase. Do not change this.
#define JOULE 1
///The watt is the standard unit of power for this codebase. You can use this with other defines to clarify that it will be multiplied by time.
#define WATTS * WATT
///The joule is the standard unit of energy for this codebase. You can use this with other defines to clarify that it will not be multiplied by time.
#define JOULES * JOULE

///The capacity of a standard power cell
#define STANDARD_CELL_VALUE (10 KILO)
	///The amount of energy, in joules, a standard powercell has.
	#define STANDARD_CELL_CHARGE (STANDARD_CELL_VALUE JOULES) // 10 KJ.
	///The amount of power, in watts, a standard powercell can give.
	#define STANDARD_CELL_RATE (STANDARD_CELL_VALUE WATTS) // 10 KW.

/// Capacity of a standard battery
#define STANDARD_BATTERY_VALUE (STANDARD_CELL_VALUE * 100)
	/// The amount of energy, in joules, a standard battery has.
	#define STANDARD_BATTERY_CHARGE (STANDARD_BATTERY_VALUE JOULES) // 1 MJ
	/// The amount of energy, in watts, a standard battery can give.
	#define STANDARD_BATTERY_RATE (STANDARD_BATTERY_VALUE WATTS) // 1 MW

GLOBAL_VAR_INIT(CELLRATE, 0.002)  //! conversion ratio between a watt-tick and kilojoule
GLOBAL_VAR_INIT(CHARGELEVEL, 0.001) // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

GLOBAL_LIST_EMPTY(powernets)
