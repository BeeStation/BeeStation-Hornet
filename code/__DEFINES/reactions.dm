//Defines used in atmos gas reactions. Used to be located in ..\modules\atmospherics\gasmixtures\reactions.dm, but were moved here because fusion added so fucking many.

//Plasma fire properties
#define OXYGEN_BURN_RATE_BASE				1.4
#define PLASMA_BURN_RATE_DELTA				9
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define FIRE_CARBON_ENERGY_RELEASED			100000	//! Amount of heat released per mole of burnt carbon into the tile
#define FIRE_HYDROGEN_ENERGY_RELEASED		280000  //! Amount of heat released per mole of burnt hydrogen and/or tritium(hydrogen isotope)
#define FIRE_PLASMA_ENERGY_RELEASED			3000000	//! Amount of heat released per mole of burnt plasma into the tile

// Water Vapor:
/// The temperature required for water vapor to condense.
#define WATER_VAPOR_CONDENSATION_POINT (T20C + 10)
/// The temperature required for water vapor to condense as ice instead of water.
#define WATER_VAPOR_DEPOSITION_POINT 200

#define N2O_DECOMPOSITION_MIN_ENERGY		1400
#define N2O_DECOMPOSITION_ENERGY_RELEASED	200000

#define NITRYL_FORMATION_ENERGY				100000
#define TRITIUM_BURN_OXY_FACTOR				100
#define TRITIUM_BURN_TRIT_FACTOR			10
#define TRITIUM_BURN_RADIOACTIVITY_FACTOR	50000 	//! The neutrons gotta go somewhere. Completely arbitrary number.
#define TRITIUM_MINIMUM_RADIATION_ENERGY	0.1  	//! minimum 0.01 moles trit or 10 moles oxygen to start producing rads
#define MINIMUM_TRIT_OXYBURN_ENERGY 		2000000	//! This is calculated to help prevent singlecap bombs(Overpowered tritium/oxygen single tank bombs)
#define SUPER_SATURATION_THRESHOLD			96
#define STIMULUM_HEAT_SCALE					100000
#define STIMULUM_FIRST_RISE					0.65
#define STIMULUM_FIRST_DROP					0.065
#define STIMULUM_SECOND_RISE				0.0009
#define STIMULUM_ABSOLUTE_DROP				0.00000335
#define REACTION_OPPRESSION_THRESHOLD		5
#define NOBLIUM_FORMATION_ENERGY			2e9 	//! 1 Mole of Noblium takes the planck energy to condense.
#define STIM_BALL_GAS_AMOUNT				5
//Research point amounts
#define NOBLIUM_RESEARCH_AMOUNT				1000
#define BZ_RESEARCH_SCALE					4
#define BZ_RESEARCH_MAX_AMOUNT				400
#define STIMULUM_RESEARCH_AMOUNT			50
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
