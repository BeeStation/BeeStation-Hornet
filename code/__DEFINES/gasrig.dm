/// Advanced Gas Rig defines

// All of these comments are AI generated because sunshine was lazy and didn't add any. Take them with a grain of salt.
/// Maximum shield strength value the gas rig can have
#define GASRIG_MAX_SHIELD_STRENGTH 10000
/// Passive shield recovery amount added each process tick
#define GASRIG_NATURAL_SHIELD_RECOVERY 500

/// Maximum depth the gas rig nozzle can be extended from the station
#define GASRIG_MAX_EXTENSION 10000
/// Speed at which the nozzle extends or retracts per delta_time
#define GASRIG_DEPTH_CHANGE_SPEED 20
/// Multiplier for shield damage based on current depth
#define GASRIG_DEPTH_SHIELD_DAMAGE_MULTIPLIER 1
/// Multiplier for shield strength calculation based on mole count
#define GASRIG_SHIELD_MOL_LOG_MULTIPLER 1

/// Normal operating mode - gas rig is harvesting gases
#define GASRIG_MODE_NORMAL 1
/// Repair mode - gas rig is damaged and needs repairs
#define GASRIG_MODE_REPAIR 2

/// Multiplier for gas temperature based on depth when producing gases
#define GASRIG_DEPTH_TEMP_MULTIPLER 1
/// Multiplier for calculating output pressure based on fracking efficiency
#define GASRIG_FRACKING_PRESSURE_MULTIPLER 1
/// Minimum/default output pressure for the gas rig
#define GASRIG_DEFAULT_OUTPUT_PRESSURE 4500

/// Maximum health value of the gas rig before it needs repairs
#define GASRIG_MAX_HEALTH 100

/// Gas depths
/// Defines are ordered as (gas low depth, gas high depth, maximium production multipler)
#define GASRIG_N2O list(93000, 100000, 5)
#define GASRIG_BZ list(86000, 93000, 25)
#define GASRIG_PLOX list(80000, 86000, 30)

#define GASRIG_N2 list(83000, 100000, 25)
#define GASRIG_TRIT list(81000, 83000, 15)
#define GASRIG_NOB list(80000, 81000, 25)

#define GASRIG_O2 list(94000, 100000, 75)
#define GASRIG_PLAS list(92000, 94000, 100)
#define GASRIG_CO2 list(80000, 92000, 15)
