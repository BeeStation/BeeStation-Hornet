//Defines used in atmos gas reactions. Used to be located in ..\modules\atmospherics\gasmixtures\reactions.dm, but were moved here because fusion added so fucking many.

// Atmos reaction priorities:
/// The prority used to indicate that a reaction should run immediately at the start of a reaction cycle. Currently used by a jumble of decomposition reactions and purgative reactions.
#define PRIORITY_PRE_FORMATION 1
/// The priority used for reactions that produce a useful or more advanced product. Goes after purgative reactions so that the purgers can be slightly more useful.
#define PRIORITY_FORMATION 2
/// The priority used for indicate that a reactions should run immediately before most forms of combustion. Used by two decomposition reactions and steam condensation.
#define PRIORITY_POST_FORMATION 3
/// The priority used to indicate that a reactions should run after all other types of reactions. Exclusively used for combustion reactions that produce fire or are freon.
#define PRIORITY_FIRE 4

/// An exponent used to make large volume gas mixtures significantly less likely to release rads. Used to prevent tritfires in distro from irradiating literally the entire station with no warning.
#define ATMOS_RADIATION_VOLUME_EXP 3

/// Maximum range a radiation pulse is allowed to be from a gas reaction.
#define GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE 20

// Water Vapor:
/// The temperature required for water vapor to condense.
#define WATER_VAPOR_CONDENSATION_POINT (T20C + 10)
/// The temperature required for water vapor to condense as ice instead of water.
#define WATER_VAPOR_DEPOSITION_POINT 200

#define OXYGEN_BURN_RATE_BASE				1.4
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2

// Fire:

// - General:
/// Amount of heat released per mole of burnt carbon into the tile
#define FIRE_CARBON_ENERGY_RELEASED 1e5

// - Plasma:
/// Minimum temperature to burn plasma
#define PLASMA_MINIMUM_BURN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST
/// Upper temperature ceiling for plasmafire reaction calculations for fuel consumption
#define PLASMA_UPPER_TEMPERATURE (PLASMA_MINIMUM_BURN_TEMPERATURE + 1270)
/// The maximum and default amount of plasma consumed as oxydizer per mole of plasma burnt.
#define OXYGEN_BURN_RATIO_BASE 1.4
/// Multiplier for plasmafire with O2 moles * PLASMA_OXYGEN_FULLBURN for the maximum fuel consumption
#define PLASMA_OXYGEN_FULLBURN 10
/// The minimum ratio of oxygen to plasma necessary to start producing tritium.
#define SUPER_SATURATION_THRESHOLD 96
/// The divisor for the maximum plasma burn rate. (1/9 of the plasma can burn in one reaction tick.)
#define PLASMA_BURN_RATE_DELTA 9
/// Amount of heat released per mole of burnt plasma into the tile
#define FIRE_PLASMA_ENERGY_RELEASED 3e6

// - Tritium:
/// The minimum temperature tritium combusts at.
#define TRITIUM_MINIMUM_BURN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST
#define TRITIUM_BURN_OXY_FACTOR 100
#define TRITIUM_OXYGEN_FULLBURN 10
//The neutrons gotta go somewhere. Completely arbitrary number.
#define TRITIUM_BURN_RADIOACTIVITY_FACTOR 50000
/// The minimum number of moles of trit that must be burnt for a tritium fire reaction to produce a radiation pulse. (0.01 moles trit or 10 moles oxygen to start producing rads.)
#define TRITIUM_RADIATION_MINIMUM_MOLES 0.1
//This is calculated to help prevent singlecap bombs(Overpowered tritium/oxygen single tank bombs)
#define MINIMUM_TRIT_OXYBURN_ENERGY 2000000
/// The amount of energy released by burning one mole of tritium.
#define FIRE_TRITIUM_ENERGY_RELEASED 280000

// N2O:
/// The minimum temperature N2O can form from nitrogen and oxygen in the presence of BZ at.
#define N2O_FORMATION_MIN_TEMPERATURE 200
/// The maximum temperature N2O can form from nitrogen and oxygen in the presence of BZ at.
#define N2O_FORMATION_MAX_TEMPERATURE 250
/// The amount of energy released when a mole of N2O forms from nitrogen and oxygen in the presence of BZ.
#define N2O_FORMATION_ENERGY 10000

/// The minimum temperature N2O can decompose at.
#define N2O_DECOMPOSITION_MIN_TEMPERATURE 1400
/// The maximum temperature N2O can decompose at.
#define N2O_DECOMPOSITION_MAX_TEMPERATURE 100000
/// The maximum portion of the N2O that can decompose each reaction tick. (50%)
#define N2O_DECOMPOSITION_RATE_DIVISOR 2
/// One root of the parabola used to scale N2O decomposition rates.
#define N2O_DECOMPOSITION_MIN_SCALE_TEMP 0
/// The other root of the parabola used to scale N2O decomposition rates.
#define N2O_DECOMPOSITION_MAX_SCALE_TEMP 100000
/// The divisor used to normalize the N2O decomp scaling parabola. Basically the value of the apex/nadir of (x - [N2O_DECOMPOSITION_MIN_SCALE_TEMP]) * (x - [N2O_DECOMPOSITION_MAX_SCALE_TEMP]).
#define N2O_DECOMPOSITION_SCALE_DIVISOR ((-1/4) * ((N2O_DECOMPOSITION_MAX_SCALE_TEMP - N2O_DECOMPOSITION_MIN_SCALE_TEMP)**2))
/// The amount of energy released when one mole of N2O decomposes into nitrogen and oxygen.
#define N2O_DECOMPOSITION_ENERGY 200000

// BZ:
/// The maximum temperature BZ can form at. Deliberately set lower than the minimum burn temperature for most combustible gases in an attempt to prevent long fuse singlecaps.
#define BZ_FORMATION_MAX_TEMPERATURE (FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 60) // Yes, someone used this as a bomb timer. I hate players.
/// The amount of energy 1 mole of BZ forming from N2O and plasma releases.
#define BZ_FORMATION_ENERGY 80000

// Pluoxium:
/// The minimum temperature pluoxium can form from carbon dioxide, oxygen, and tritium at.
#define PLUOXIUM_FORMATION_MIN_TEMP 50
/// The maximum temperature pluoxium can form from carbon dioxide, oxygen, and tritium at.
#define PLUOXIUM_FORMATION_MAX_TEMP T0C
/// The maximum amount of pluoxium that can form from carbon dioxide, oxygen, and tritium per reaction tick.
#define PLUOXIUM_FORMATION_MAX_RATE 5
/// The amount of energy one mole of pluoxium forming from carbon dioxide, oxygen, and tritium releases.
#define PLUOXIUM_FORMATION_ENERGY 250

// Nitrium:
/// The minimum temperature necessary for nitrium to form from tritium, nitrogen, and BZ.
#define NITRIUM_FORMATION_MIN_TEMP 1500
/// A scaling divisor for the rate of nitrium formation relative to mix temperature.
#define NITRIUM_FORMATION_TEMP_DIVISOR (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8)
/// The amount of thermal energy consumed when a mole of nitrium is formed from tritium, nitrogen, and BZ.
#define NITRIUM_FORMATION_ENERGY 100000

/// The maximum temperature nitrium can decompose into nitrogen and hydrogen at.
#define NITRIUM_DECOMPOSITION_MAX_TEMP (T0C + 70) //Pretty warm, explicitly not fire temps. Time bombs are cool, but not that cool. If it makes you feel any better it's close.
/// A scaling divisor for the rate of nitrium decomposition relative to mix temperature.
#define NITRIUM_DECOMPOSITION_TEMP_DIVISOR (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8)
/// The amount of energy released when a mole of nitrium decomposes into nitrogen and hydrogen.
#define NITRIUM_DECOMPOSITION_ENERGY 30000

// H-Nob:
/// The maximum temperature hyper-noblium can form from tritium and nitrogen at.
#define NOBLIUM_FORMATION_MIN_TEMP TCMB
/// The maximum temperature hyper-noblium can form from tritium and nitrogen at.
#define NOBLIUM_FORMATION_MAX_TEMP 15
/// The amount of energy a single mole of hyper-noblium forming from tritium and nitrogen releases.
#define NOBLIUM_FORMATION_ENERGY 2e7

/// The number of moles of hyper-noblium required to prevent reactions.
#define REACTION_OPPRESSION_THRESHOLD 5

#define STIM_BALL_GAS_AMOUNT				5
#define PLUOXIUM_TEMP_CAP 200
//Plasma fusion properties
#define FUSION_ENERGY_THRESHOLD				3e9 	//! Amount of energy it takes to start a fusion reaction
#define FUSION_MOLE_THRESHOLD				250 	//! Mole count required (tritium/plasma) to start a fusion reaction
#define FUSION_TRITIUM_CONVERSION_COEFFICIENT 0.002
#define INSTABILITY_GAS_POWER_FACTOR 		3
#define FUSION_TRITIUM_MOLES_USED  			1
#define PLASMA_BINDING_ENERGY  				20000000
#define TOROID_CALCULATED_THRESHOLD			5.96	//! changing it by 0.1 generally doubles or halves fusion temps
#define FUSION_TEMPERATURE_THRESHOLD	    10000
#define PARTICLE_CHANCE_CONSTANT 			(-20000000)
#define FUSION_INSTABILITY_ENDOTHERMALITY   2
#define FUSION_SCALE_DIVISOR				10		//! Used to be Pi
#define FUSION_MINIMAL_SCALE				50
#define FUSION_SLOPE_DIVISOR				1250	//! This number is probably the safest number to change
#define FUSION_ENERGY_TRANSLATION_EXPONENT	1.25	//! This number is probably the most dangerous number to change
#define FUSION_BASE_TEMPSCALE				6       //! This number is responsible for orchestrating fusion temperatures
#define FUSION_RAD_MIDPOINT					15		//! If you decrease this by one, the fusion rads will *triple* and vice versa
#define FUSION_MIDDLE_ENERGY_REFERENCE		1e6		//! This number is deceptively dangerous; sort of tied to TOROID_CALCULATED_THRESHOLD
#define FUSION_BUFFER_DIVISOR				1		//! Increase this to cull unrobust fusions faster
