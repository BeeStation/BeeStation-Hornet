/// Advanced Gas Rig defines

#define GASRIG_MAX_SHIELD_STRENGTH 10000
#define GASRIG_NATURAL_SHIELD_RECOVERY 500

#define GASRIG_RETRACTOR_SPEED 10

#define GASRIG_MAX_DEPTH 2000
#define GASRIG_DEPTH_CHANGE_SPEED 5
#define GASRIG_DEPTH_SHIELD_DAMAGE_MULTIPLIER 1
#define GASRIG_SHIELD_MOL_LOG_MULTIPLER 1

#define GASRIG_MODE_NORMAL 1
#define GASRIG_MODE_REPAIR 2

#define GASRIG_DEPTH_TEMP_MULTIPLER 1
#define GASRIG_FRACKING_PRESSURE_MULTIPLER 1
#define GASRIG_DEFAULT_OUTPUT_PRESSURE 4500

#define GASRIG_MAX_HEALTH 100



/// Gas depths
/// Defines are ordered as (gas starting depth, gas ending depth, maximium production multipler)
#define GASRIG_O2 list(10, 250, 75)
#define GASRIG_N2 list(115, 400, 25)
#define GASRIG_PLAS list(300, 1750, 100)
#define GASRIG_CO2 list(330, 500, 15)
#define GASRIG_N2O list(700, 950, 5)
#define GASRIG_BZ list(950, 2000, 25)
#define GASRIG_PLOX list(1555, 1875, 30)
#define GASRIG_NOB list(1925, 2000, 25)
#define GASRIG_TRIT list(1300, 1675, 15)
