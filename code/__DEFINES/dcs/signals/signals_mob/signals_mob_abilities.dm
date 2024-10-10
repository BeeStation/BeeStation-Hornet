// Mob ability signals

/// from base of /datum/action/cooldown/proc/PreActivate(): (datum/action/cooldown/activated)
#define COMSIG_ABILITY_STARTED "mob_ability_base_started"
	#define COMPONENT_BLOCK_ABILITY_START (1<<0)
/// from base of /datum/action/cooldown/proc/PreActivate(): (datum/action/cooldown/finished)
#define COMSIG_ABILITY_FINISHED "mob_ability_base_finished"
