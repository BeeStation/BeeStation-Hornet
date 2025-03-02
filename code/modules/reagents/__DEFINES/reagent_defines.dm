#define REM REAGENTS_EFFECT_MULTIPLIER
#define METABOLITE_RATE     0.5 // How much of a reagent is converted metabolites if one is defined
#define MAX_METABOLITES		15  // The maximum amount of a given metabolite someone can have at a time
#define METABOLITE_PENALTY(path) clamp(M.reagents.get_reagent_amount(path)/2.5, 1, 5) //Ranges from 1 to 5 depending on level of metabolites.

#define ALCOHOL_THRESHOLD_MODIFIER 1 //Greater numbers mean that less alcohol has greater intoxication potential
#define ALCOHOL_RATE 0.005 //The rate at which alcohol affects you
#define ALCOHOL_EXPONENT 1.6 //The exponent applied to boozepwr to make higher volume alcohol at least a little bit damaging to the liver

#define REACTION_HINT_EXPLOSION_OTHER "explosion"
/// A radius table showing the radius at 10, 50 and 100, 200 and 500 units of the reaction
#define REACTION_HINT_RADIUS_TABLE "explosion_radius"
#define REACTION_HINT_SAFETY "safety"
