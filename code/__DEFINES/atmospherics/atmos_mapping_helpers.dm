///Used to define the temperature of a tile, arg is the temperature it should be at. Should always be put at the end of the atmos list.
///This is solely to be used after compile-time.
#define TURF_TEMPERATURE(temperature) "TEMP=[temperature]"

//OPEN TURF ATMOS
/// the default air mix that open turfs spawn
#define OPENTURF_DEFAULT_ATMOS GAS_O2 + "=22;" + GAS_N2 + "=82;TEMP=293.15"
/// the default low-pressure air mix used mostly for mining areas.
#define OPENTURF_LOW_PRESSURE GAS_O2 + "=14;" + GAS_N2 + "=30;TEMP=293.15"
/// -193,15°C telecommunications. also used for xenobiology slime killrooms
#define TCOMMS_ATMOS GAS_N2 + "=100;TEMP=80"
/// space
#define AIRLESS_ATMOS "TEMP=2.7"
/// -93.15°C snow and ice turfs
#define FROZEN_ATMOS GAS_O2 + "=22;" + GAS_N2 + "=82;TEMP=180"
/// -14°C kitchen coldroom, just might loss your tail; higher amount of mol to reach about 101.3 kpA
#define KITCHEN_COLDROOM_ATMOS GAS_O2 + "=26;" + GAS_N2 + "=97;TEMP=259.15"
/// used in the holodeck burn test program
#define BURNMIX_ATMOS GAS_O2 + "=2500;" + GAS_PLASMA + "=5000;TEMP=370"
///-153.15°C plasma air, used for burning people.
#define BURNING_COLD GAS_N2 + "=82;" + GAS_PLASMA + "=24;TEMP=120"
///Space temperature hyper nob
#define SPACE_TEMP_NOBLIUM GAS_HYPER_NOBLIUM + "=7500;TEMP=2.7"


//ATMOSPHERICS DEPARTMENT GAS TANK TURFS
#define ATMOS_TANK_N2O GAS_N2O + "=6000;TEMP=293.15"
#define ATMOS_TANK_CO2 GAS_CO2 + "=50000;TEMP=293.15"
#define ATMOS_TANK_PLASMA GAS_PLASMA + "=70000;TEMP=293.15"
#define ATMOS_TANK_O2 GAS_O2 + "=100000;TEMP=293.15"
#define ATMOS_TANK_N2 GAS_N2 + "=100000;TEMP=293.15"
#define ATMOS_TANK_BZ GAS_BZ + "=100000;TEMP=293.15"
#define ATMOS_TANK_HYPERNOBLIUM GAS_HYPER_NOBLIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_NITRYL GAS_NITRYL + "=100000;TEMP=293.15"
#define ATMOS_TANK_PLUOXIUM GAS_PLUOXIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_TRITIUM GAS_TRITIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_H2O GAS_WATER_VAPOR + "=100000;TEMP=293.15"
#define ATMOS_TANK_AIRMIX GAS_O2 + "=2644;" + GAS_N2 + "=10580;TEMP=293.15"

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
