#define SUPERMATTER_MAXIMUM_ENERGY 1e6

#define PLASMA_HEAT_PENALTY 15     // Higher == Bigger heat and waste penalty from having the crystal surrounded by this gas. Negative numbers reduce penalty.
#define OXYGEN_HEAT_PENALTY 1
#define CO2_HEAT_PENALTY 2
#define NITROGEN_HEAT_PENALTY -1.5
#define BZ_HEAT_PENALTY 5
#define PLUOXIUM_HEAT_PENALTY  -0.5 //Better then co2, worse then n2
#define TRITIUM_HEAT_PENALTY 10

#define OXYGEN_TRANSMIT_MODIFIER 1.5   //Higher == Bigger bonus to power generation.
#define PLASMA_TRANSMIT_MODIFIER 4

#define N2O_HEAT_RESISTANCE 6          //Higher == Gas makes the crystal more resistant against heat damage.

/// The minimum portion of the CO2 in the air that will be consumed. Higher values mean more CO2 will be consumed be default.
#define CO2_CONSUMPTION_RATIO_MIN 0
/// The maximum portion of the CO2 in the air that will be consumed. Lower values mean the CO2 consumption rate caps earlier.
#define CO2_CONSUMPTION_RATIO_MAX 1
/// The minimum pressure for a pure CO2 atmosphere to begin being consumed. Higher values mean it takes more CO2 pressure to make CO2 be consumed. Should be >= 0
#define CO2_CONSUMPTION_PP (ONE_ATMOSPHERE*0.01)
/// How the amount of CO2 consumed per tick scales with partial pressure. Higher values decrease the rate CO2 consumption scales with partial pressure. Should be >0
#define CO2_PRESSURE_SCALING (ONE_ATMOSPHERE*0.25)
/// How much the amount of CO2 consumed per tick scales with gasmix power ratio. Higher values means gasmix has a greater effect on the CO2 consumed.
#define CO2_GASMIX_SCALING (0.1)

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20         //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20        //Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.        //Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

#define MOLE_PENALTY_THRESHOLD 1800           //Higher == Shard can absorb more moles before triggering the high mole penalties.
#define MOLE_HEAT_PENALTY 350                 //Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
#define POWER_PENALTY_THRESHOLD 5000          //Higher == Engine can generate more power before triggering the high power penalties.
#define SEVERE_POWER_PENALTY_THRESHOLD 7000   //Same as above, but causes more dangerous effects
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000 //Even more dangerous effects, threshold for tesla delamination
#define HEAT_PENALTY_THRESHOLD 40             //Higher == Crystal safe operational temperature is higher.
#define DAMAGE_HARDCAP 0.002
#define DAMAGE_INCREASE_MULTIPLIER 0.25
#define TRITIUM_RADIOACTIVITY_MODIFIER 3  //Higher == Crystal spews out more radiation
#define BZ_RADIOACTIVITY_MODIFIER 5
#define PLUOXIUM_RADIOACTIVITY_MODIFIER -2
#define PLUOXIUM_HEAT_RESISTANCE 1.5

#define THERMAL_RELEASE_MODIFIER 5         //Higher == less heat released during reaction, not to be confused with the above values
#define PLASMA_RELEASE_MODIFIER 750        //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 325        //Higher == less oxygen released at high temperature/power

#define REACTION_POWER_MODIFIER 0.55       //Higher == more overall power

#define MATTER_POWER_CONVERSION 10         //Crystal converts 1/this value of stored matter into energy.

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 20 MINUTES


#define WARNING_DELAY 60

#define HALLUCINATION_RANGE(P) (min(7, round(P ** 0.25)))



//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define SUPERMATTER_DELAM_PERCENT 5
#define SUPERMATTER_EMERGENCY_PERCENT 25
#define SUPERMATTER_DANGER_PERCENT 50
#define SUPERMATTER_WARNING_PERCENT 100

#define SUPERMATTER_COUNTDOWN_TIME 30 SECONDS

///to prevent accent sounds from layering
#define SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN 2 SECONDS
