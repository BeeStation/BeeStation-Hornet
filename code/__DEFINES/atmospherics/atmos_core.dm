//LISTMOS
//indices of values in gas lists.
///Amount of total moles in said gas mixture
#define MOLES 1
///Archived version of MOLES
#define ARCHIVE 2
///All gas related variables
#define GAS_META 3
///Gas specific heat per mole
#define META_GAS_SPECIFIC_HEAT 1
///Name of the gas
#define META_GAS_NAME 2
///Amount of moles required of the gas to be visible
#define META_GAS_MOLES_VISIBLE 3
///Overlay path of the gas, also setup the alpha based on the amount
#define META_GAS_OVERLAY 4
///Let the air alarm know if the gas is dangerous
#define META_GAS_DANGER 5
///Id of the gas for quick access
#define META_GAS_ID 6
///Short description of the gas.
#define META_GAS_DESC 7
///Power of the gas when used in the current iteration of fusion
#define META_GAS_FUSION_POWER 8
///Defines the alert that should jump out if the quantity of a gas affects to a point it's too much or not enough
#define META_GAS_BREATH_ALERT_INFO 9
///Defines the reagents applied on breathing the gas
#define META_GAS_BREATH_REAGENT 10
///Defines the gas to which this gas is a result of breathing
#define META_GAS_BREATH_RESULTS 11
///Reagents applied when the gas passes its dangerous threshold
#define META_GAS_BREATH_REAGENT_DANGEROUS 12
///Gas advanced gas rig shielding power
#define META_GAS_RIG_SHIELDING_POWER 13
///Gas advanced gas rig shielding modifier
#define META_GAS_RIG_SHIELDING_MODIFIER 14

//ATMOS
//stuff you should probably leave well alone!
/// kPa*L/(K*mol)
#define R_IDEAL_GAS_EQUATION 8.31
/// kPa
#define ONE_ATMOSPHERE 101.325
/// -270.3degC
#define TCMB 2.7
/// -48.15degC
#define TCRYO 225
/// 0degC
#define T0C 273.15
/// 20degC
#define T20C 293.15
/// -14C - Temperature used for kitchen cold room, medical freezer, etc.
#define COLD_ROOM_TEMP 259.15

/**
 *I feel the need to document what happens here. Basically this is used
 *catch rounding errors, and make gas go away in small portions.
 *People have raised it to higher levels in the past, do not do this. Consider this number a soft limit
 *If you're making gasmixtures that have unexpected behavior related to this value, you're doing something wrong.
 *
 *On an unrelated note this may cause a bug that creates negative gas, related to round(). When it has a second arg it will round up.
 *So for instance round(0.5, 1) == 1. I've hardcoded a fix for this into share, by forcing the garbage collect.
 *Any other attempts to fix it just killed atmos. I leave this to a greater man then I
 */
/// The minimum heat capacity of a gas
#define MINIMUM_HEAT_CAPACITY 0.0003
/// Minimum mole count of a gas
#define MINIMUM_MOLE_COUNT 0.01
/// Molar accuracy to round to
#define MOLAR_ACCURACY  1E-4
/// Types of gases (based on gaslist_cache)
#define GAS_TYPE_COUNT GLOB.gaslist_cache.len
/// Maximum error caused by QUANTIZE when removing gas (roughly, in reality around 2 * MOLAR_ACCURACY less)
#define MAXIMUM_ERROR_GAS_REMOVAL (MOLAR_ACCURACY * GAS_TYPE_COUNT)

/// Moles in a standard cell after which gases are visible
#define MOLES_GAS_VISIBLE 0.25

/// moles_visible * FACTOR_GAS_VISIBLE_MAX = Moles after which gas is at maximum visibility
#define FACTOR_GAS_VISIBLE_MAX 20
/// Mole step for alpha updates. This means alpha can update at 0.25, 0.5, 0.75 and so on
#define MOLES_GAS_VISIBLE_STEP 0.25
/// The total visible states
#define TOTAL_VISIBLE_STATES (FACTOR_GAS_VISIBLE_MAX * (1 / MOLES_GAS_VISIBLE_STEP))

//REACTIONS
//return values for reactions (bitflags)
///The gas mixture is not reacting
#define NO_REACTION 0
///The gas mixture is reacting
#define REACTING 1
///The gas mixture is able to stop all reactions
#define STOP_REACTIONS 2


//EXCITED GROUPS
/**
 * Some further context on breakdown. Unlike dismantle, the breakdown ticker doesn't reset itself when a tile is added
 * This is because we cannot expect maps to have small spaces, so we need to even ourselves out often
 * We do this to avoid equalizing a large space in one tick, with some significant amount of say heat diff
 * This way large areas don't suddenly all become cold at once, it acts more like a wave
 *
 * Because of this and the behavior of share(), the breakdown cycles value can be tweaked directly to effect how fast we want gas to move
 */
/// number of FULL air controller ticks before an excited group breaks down (averages gas contents across turfs)
#define EXCITED_GROUP_BREAKDOWN_CYCLES 4
/// number of FULL air controller ticks before an excited group dismantles and removes its turfs from active
#define EXCITED_GROUP_DISMANTLE_CYCLES (EXCITED_GROUP_BREAKDOWN_CYCLES * 2) + 1 //Reset after 2 breakdowns
/// Ratio of air that must move to/from a tile to reset group processing
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.1
/// Minimum ratio of air that must move to/from a tile
#define MINIMUM_AIR_RATIO_TO_MOVE 0.001
/// Minimum amount of air that has to move before a group processing can be suspended (Round about 10)
#define MINIMUM_AIR_TO_SUSPEND (MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND)
/// Either this must be active (round about 0.1) //Might need to raise this a tad to better support space leaks. we'll see
#define MINIMUM_MOLES_DELTA_TO_MOVE (MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_MOVE)
/// or this (or both, obviously)
#define MINIMUM_TEMPERATURE_TO_MOVE (T20C+100)
/// Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4
/// Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5
///Minimum temperature to continue superconduction once started
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION (T20C+80)
///Minimum temperature to start doing superconduction calculations
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION (T20C+400)

//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Should not exceed 0.4 else strange heat flow occur
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
/// a hack for now
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.1
/// a hack to help make vacuums "cold", sacrificing realism for gameplay
/// Setting this value too high results in space having so much thermal energy
/// that heat is immediately sucked out of every room progressively.
#define HEAT_CAPACITY_VACUUM 800

//FIRE
///Minimum temperature for fire to move to the next turf (150 °C or 433 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD (150+T0C)
///Minimum temperature for fire to exist on a turf (100 °C or 373 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST (100+T0C)
///Multiplier for the temperature shared to other turfs
#define FIRE_SPREAD_RADIOSITY_SCALE 0.85
///Helper for small fires to grow
#define FIRE_GROWTH_RATE 40000

///moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC (103 or so)
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))
#define M_CELL_WITH_RATIO (MOLES_CELLSTANDARD * 0.005)
/// percentage of oxygen in a normal mixture of air
#define O2STANDARD 0.21
/// same but for nitrogen
#define N2STANDARD 0.79
/// O2 standard value (21%)
#define MOLES_O2STANDARD (MOLES_CELLSTANDARD*O2STANDARD)
/// N2 standard value (79%)
#define MOLES_N2STANDARD (MOLES_CELLSTANDARD*N2STANDARD)
/// liters in a cell
#define CELL_VOLUME 2500

//CANATMOSPASS
#define ATMOS_PASS_YES 1
#define ATMOS_PASS_NO 0
/// ask can_atmos_pass()
#define ATMOS_PASS_PROC -1
/// just check density
#define ATMOS_PASS_DENSITY -2

//Adjacent turf related defines, they dictate what to do with a turf once it's been recalculated
//Used as "state" in CALCULATE_ADJACENT_TURFS
///Normal non-active turf
#define NORMAL_TURF 1
///Set the turf to be activated on the next calculation
#define MAKE_ACTIVE 2
///Disable excited group
#define KILL_EXCITED 3

/// How many maximum iterations do we allow the Newton-Raphson approximation for gas pressure to do.
#define ATMOS_PRESSURE_APPROXIMATION_ITERATIONS 20
/// We deal with big numbers and a lot of math, things are bound to get imprecise. Take this traveller.
#define ATMOS_PRESSURE_ERROR_TOLERANCE 0.01

/// Used when an atmos machine has "external" selected.
/// Found in `pressure_checks` of vents and air alarms.
#define ATMOS_EXTERNAL_BOUND (1 << 0)

/// Used when an atmos machine has "internal" selected.
/// Found in `pressure_checks` of vents and air alarms.
#define ATMOS_INTERNAL_BOUND (1 << 1)

/// The maximum bound of an atmos machine.
/// Found in `pressure_checks` of vents and air alarms.
#define ATMOS_BOUND_MAX (ATMOS_EXTERNAL_BOUND | ATMOS_INTERNAL_BOUND)

/// Used when an atmos machine is siphoning out air.
/// Found in air alarms, vents, and scrubbers.
#define ATMOS_DIRECTION_SIPHONING 0

/// Used when a vent is releasing air.
/// Found in air alarms, vents, and scrubbers.
#define ATMOS_DIRECTION_RELEASING 1

/// Used when a scrubber is scrubbing air.
/// Found in air alarms, vents, and scrubbers.
#define ATMOS_DIRECTION_SCRUBBING 1

/// The max pressure of pumps.
#define ATMOS_PUMP_MAX_PRESSURE (ONE_ATMOSPHERE * 50)
/// Max external target temperature of pumps
#define ATMOS_PUMP_MAX_TEMPERATURE 500

// Value of [/obj/machinery/airalarm/var/danger_level] and retvals of [/datum/tlv/proc/check_value]
/// No TLV exceeded.
#define AIR_ALARM_ALERT_NONE 0
/// TLV warning exceeded but not hazardous.
#define AIR_ALARM_ALERT_WARNING 1
/// TLV hazard exceeded or someone pulled the switch.
#define AIR_ALARM_ALERT_HAZARD 2

// Air alarm buildstage [/obj/machinery/airalarm/buildstage]
/// Air alarm missing circuit
#define AIR_ALARM_BUILD_NO_CIRCUIT 0
/// Air alarm has circuit but is missing wires
#define AIR_ALARM_BUILD_NO_WIRES 1
/// Air alarm has all components but isn't completed
#define AIR_ALARM_BUILD_COMPLETE 2

// Fire alarm buildstage [/obj/machinery/firealarm/buildstage]
/// Fire alarm missing circuit
#define FIRE_ALARM_BUILD_NO_CIRCUIT 0
/// Fire alarm has circuit but is missing wires
#define FIRE_ALARM_BUILD_NO_WIRES 1
/// Fire alarm has all components but isn't completed
#define FIRE_ALARM_BUILD_SECURED 2

// Fault levels for air alarm display
/// Area faults clear
#define AREA_FAULT_NONE 0
/// Fault triggered by manual intervention (ie: fire alarm pull)
#define AREA_FAULT_MANUAL 1
/// Fault triggered automatically (ie: firedoor detection)
#define AREA_FAULT_AUTOMATIC 2

// threshold_type values for [/datum/tlv/proc/set_value]  and [/datum/tlv/proc/reset_value]
/// [/datum/tlv/var/warning_min]
#define TLV_VAR_WARNING_MIN (1 << 0)
/// [/datum/tlv/var/hazard_min]
#define TLV_VAR_HAZARD_MIN (1 << 1)
/// [/datum/tlv/var/warning_max]
#define TLV_VAR_WARNING_MAX (1 << 2)
/// [/datum/tlv/var/hazard_max]
#define TLV_VAR_HAZARD_MAX (1 << 3)
/// All the vars in [/datum/tlv]
#define TLV_VAR_ALL (TLV_VAR_WARNING_MIN | TLV_VAR_HAZARD_MIN | TLV_VAR_WARNING_MAX | TLV_VAR_HAZARD_MAX)

/// TLV datums will ignore variables set to this.
#define TLV_VALUE_IGNORE -1

#define CIRCULATOR_HOT 0
#define CIRCULATOR_COLD 1

///Default pressure, used in the UI to reset the settings
#define PUMP_DEFAULT_PRESSURE (ONE_ATMOSPHERE)
///Maximum settable pressure
#define PUMP_MAX_PRESSURE (PUMP_DEFAULT_PRESSURE * 25)
///Minimum settable pressure
#define PUMP_MIN_PRESSURE (PUMP_DEFAULT_PRESSURE / 10)
///The machine pumps from the turf to the internal tank
#define PUMP_IN TRUE
///The machine pumps from the internal source to the turf
#define PUMP_OUT FALSE

///Max allowed pressure for canisters to release air per tick
#define CAN_MAX_RELEASE_PRESSURE (ONE_ATMOSPHERE * 25)
///Min allowed pressure for canisters to release air per tick
#define CAN_MIN_RELEASE_PRESSURE (ONE_ATMOSPHERE * 0.1)
