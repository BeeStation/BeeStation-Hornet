//Monkey defines, placed here so they can be read by other things!

/// below this health value the monkey starts to flee from enemies
#define MONKEY_FLEE_HEALTH 					25
/// how close an enemy must be to trigger aggression
#define MONKEY_ENEMY_VISION 				10
/// how close an enemy must be before it triggers flee
#define MONKEY_FLEE_VISION					2
/// How long does it take the item to be taken from a mobs hand
#define MONKEY_ITEM_SNATCH_DELAY 			15
/// Probability monkey will aggro when cuffed
#define MONKEY_CUFF_RETALIATION_PROB		50
/// Probability monkey will aggro when syringed
#define MONKEY_SYRINGE_RETALIATION_PROB		50

// Probability per Life tick that the monkey will:

/// probability that monkey resist out of restraints
#define MONKEY_RESIST_PROB 					75
///  probability that monkey aggro against the mob pulling it
#define MONKEY_PULL_AGGRO_PROB 				10
/// probability that monkey will get into mischief, i.e. finding/stealing items
#define MONKEY_SHENANIGAN_PROB 				75
/// probability that monkey will disarm an armed attacker
#define MONKEY_ATTACK_DISARM_PROB 			50
/// probability that monkey will get recruited when friend is attacked
#define MONKEY_RECRUIT_PROB 				100


/// probability for the monkey to aggro when attacked
#define MONKEY_RETALIATE_PROB 90

/// probability for the monkey to aggro when attacked with harm intent
#define MONKEY_RETALIATE_HARM_PROB 			100
/// probability for the monkey to aggro when attacked with disarm intent
#define MONKEY_RETALIATE_DISARM_PROB 		75

/// amount of aggro to add to an enemy when they attack user
#define MONKEY_HATRED_AMOUNT 				30
/// amount of aggro to add to an enemy when a monkey is recruited
#define MONKEY_RECRUIT_HATED_AMOUNT 		30
/// probability of reducing aggro by one when the monkey attacks
#define MONKEY_HATRED_REDUCTION_PROB 		1

///Monkey recruit cooldown
#define MONKEY_RECRUIT_COOLDOWN 10 SECONDS
