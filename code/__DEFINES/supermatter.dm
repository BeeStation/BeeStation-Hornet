#define SUPERMATTER_MAXIMUM_ENERGY 1e6

#define PLASMA_HEAT_PENALTY 15     // Higher == Bigger heat and waste penalty from having the crystal surrounded by this gas. Negative numbers reduce penalty.
#define OXYGEN_HEAT_PENALTY 1
#define CO2_HEAT_PENALTY 0.1
#define NITROGEN_HEAT_PENALTY -1.5
#define BZ_HEAT_PENALTY 5
#define PLUOXIUM_HEAT_PENALTY -1
#define TRITIUM_HEAT_PENALTY 10

#define OXYGEN_TRANSMIT_MODIFIER 1.5   //Higher == Bigger bonus to power generation.
#define PLASMA_TRANSMIT_MODIFIER 4

#define N2O_HEAT_RESISTANCE 6          //Higher == Gas makes the crystal more resistant against heat damage.

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20         //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20        //Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.        //Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

//Higher == Shard can absorb more moles before triggering the high mole penalties.
#define MOLE_PENALTY_THRESHOLD 1800
//Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
#define MOLE_HEAT_PENALTY 350
//The cutoff on power properly doing damage, pulling shit around, and delamming into a tesla. Low chance of pyro anomalies, +2 bolts of electricity
#define POWER_PENALTY_THRESHOLD 5000
//+1 bolt of electricity, allows for gravitational anomalies, and higher chances of pyro anomalies
#define SEVERE_POWER_PENALTY_THRESHOLD 7000
//+1 bolt of electricity, threshold for tesla delamination
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000
//Higher == Crystal safe operational temperature is higher.
#define HEAT_PENALTY_THRESHOLD 40

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
#define DETONATION_HALLUCINATION 600


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
