/datum/auxgm/proc/add_supermatter_properties(datum/gas/gas)
	var/g = gas.id
	var/list/props = src.supermatter
	if(gas.powermix || gas.heat_penalty || gas.transmit_modifier || gas.radioactivity_modifier || gas.heat_resistance || gas.powerloss_inhibition)
		props[HEAT_PENALTY][g] = gas.heat_penalty
		props[TRANSMIT_MODIFIER][g] = gas.transmit_modifier
		props[RADIOACTIVITY_MODIFIER][g] = gas.radioactivity_modifier
		props[HEAT_RESISTANCE][g] = gas.heat_resistance
		props[POWERLOSS_INHIBITION][g] = gas.powerloss_inhibition
		props[POWER_MIX][g] = gas.powermix
		props[ALL_SUPERMATTER_GASES] += g

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20         //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20        //Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.        //Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

#define MOLE_PENALTY_THRESHOLD 1800           //Above this value we can get lord singulo and independent mol damage, below it we can heal damage
#define MOLE_HEAT_PENALTY 350                 //Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
//Along with damage_penalty_point, makes flux anomalies.
#define POWER_PENALTY_THRESHOLD 5000          //The cutoff on power properly doing damage, pulling shit around, and delamming into a tesla. Low chance of pyro anomalies, +2 bolts of electricity
#define SEVERE_POWER_PENALTY_THRESHOLD 7000   //+1 bolt of electricity, allows for gravitational anomalies, and higher chances of pyro anomalies
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000 //+1 bolt of electricity.
#define HEAT_PENALTY_THRESHOLD 40             //Higher == Crystal safe operational temperature is higher.
#define DAMAGE_HARDCAP 0.002
#define DAMAGE_INCREASE_MULTIPLIER 0.25


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
#define CRITICAL_TEMPERATURE 10000

#define SUPERMATTER_COUNTDOWN_TIME 30 SECONDS

///to prevent accent sounds from layering
#define SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN 2 SECONDS
