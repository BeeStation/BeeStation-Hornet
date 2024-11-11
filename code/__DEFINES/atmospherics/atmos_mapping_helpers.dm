//OPEN TURF ATMOS
/// the default air mix that open turfs spawn
#define OPENTURF_DEFAULT_ATMOS "o2=22;n2=82;TEMP=293.15"
#define OPENTURF_LOW_PRESSURE "o2=14;n2=30;TEMP=293.15"
/// -193,15°C telecommunications. also used for xenobiology slime killrooms
#define TCOMMS_ATMOS "n2=100;TEMP=80"
/// space
#define AIRLESS_ATMOS "TEMP=2.7"
/// -93.15°C snow and ice turfs
#define FROZEN_ATMOS "o2=22;n2=82;TEMP=180"
/// -14°C kitchen coldroom, just might loss your tail; higher amount of mol to reach about 101.3 kpA
#define KITCHEN_COLDROOM_ATMOS "o2=26;n2=97;TEMP=[COLD_ROOM_TEMP]"
/// used in the holodeck burn test program
#define BURNMIX_ATMOS "o2=2500;plasma=5000;TEMP=370"

//ATMOSPHERICS DEPARTMENT GAS TANK TURFS
#define ATMOS_TANK_N2O				"n2o=6000;TEMP=293.15"
#define ATMOS_TANK_CO2				"co2=50000;TEMP=293.15"
#define ATMOS_TANK_PLASMA			"plasma=70000;TEMP=293.15"
#define ATMOS_TANK_O2				"o2=100000;TEMP=293.15"
#define ATMOS_TANK_N2				"n2=100000;TEMP=293.15"
#define ATMOS_TANK_BZ				"bz=100000;TEMP=293.15"
#define ATMOS_TANK_HYPERNOBLIUM		"nob=100000;TEMP=293.15"
#define ATMOS_TANK_NO2				"no2=100000;TEMP=293.15"
#define ATMOS_TANK_PLUOXIUM			"pluox=100000;TEMP=293.15"
#define ATMOS_TANK_STIMULUM			"stim=100000;TEMP=293.15"
#define ATMOS_TANK_TRITIUM			"tritium=100000;TEMP=293.15"
#define ATMOS_TANK_H2O				"water_vapor=100000;TEMP=293.15"
#define ATMOS_TANK_AIRMIX			"o2=2777;n2=10447;TEMP=293.15" // 21% oxygen, 79% nitrogen. Roughly.

//LAVALAND
/// what pressure you have to be under to increase the effect of equipment meant for lavaland
#define MAXIMUM_LAVALAND_EQUIPMENT_EFFECT_PRESSURE 90

//ATMOS MIX IDS
#define LAVALAND_DEFAULT_ATMOS "o2=14;n2=5;co2=13;TEMP=300"

//AIRLOCK CONTROLLER TAGS

//RnD ordnance burn chamber
#define INCINERATOR_TOXMIX_IGNITER "toxmix_igniter"
#define INCINERATOR_TOXMIX_VENT "toxmix_vent"
#define INCINERATOR_TOXMIX_DP_VENTPUMP "toxmix_airlock_pump"
#define INCINERATOR_TOXMIX_AIRLOCK_SENSOR "toxmix_airlock_sensor"
#define INCINERATOR_TOXMIX_AIRLOCK_CONTROLLER "toxmix_airlock_controller"
#define INCINERATOR_TOXMIX_AIRLOCK_INTERIOR "toxmix_airlock_interior"
#define INCINERATOR_TOXMIX_AIRLOCK_EXTERIOR "toxmix_airlock_exterior"

//Atmospherics/maintenance incinerator
#define INCINERATOR_ATMOS_IGNITER "atmos_incinerator_igniter"
#define INCINERATOR_ATMOS_MAINVENT "atmos_incinerator_mainvent"
#define INCINERATOR_ATMOS_AUXVENT "atmos_incinerator_auxvent"
#define INCINERATOR_ATMOS_DP_VENTPUMP "atmos_incinerator_airlock_pump"
#define INCINERATOR_ATMOS_AIRLOCK_SENSOR "atmos_incinerator_airlock_sensor"
#define INCINERATOR_ATMOS_AIRLOCK_CONTROLLER "atmos_incinerator_airlock_controller"
#define INCINERATOR_ATMOS_AIRLOCK_INTERIOR "atmos_incinerator_airlock_interior"
#define INCINERATOR_ATMOS_AIRLOCK_EXTERIOR "atmos_incinerator_airlock_exterior"
#define TEST_ROOM_ATMOS_MAINVENT_1 "atmos_test_room_mainvent_1"
#define TEST_ROOM_ATMOS_MAINVENT_2 "atmos_test_room_mainvent_2"

//Syndicate lavaland base incinerator (lavaland_surface_syndicate_base1.dmm)
#define INCINERATOR_SYNDICATELAVA_IGNITER "syndicatelava_igniter"
#define INCINERATOR_SYNDICATELAVA_MAINVENT "syndicatelava_mainvent"
#define INCINERATOR_SYNDICATELAVA_AUXVENT "syndicatelava_auxvent"
#define INCINERATOR_SYNDICATELAVA_DP_VENTPUMP "syndicatelava_airlock_pump"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_SENSOR "syndicatelava_airlock_sensor"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_CONTROLLER "syndicatelava_airlock_controller"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_INTERIOR "syndicatelava_airlock_interior"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_EXTERIOR "syndicatelava_airlock_exterior"
