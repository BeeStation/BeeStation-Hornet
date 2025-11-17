// Action signals

///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	// Return to block the trigger from occuring
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
/// From /datum/action/Grant(): (mob/grant_to)
#define COMSIG_ACTION_GRANTED "action_grant"
/// From /datum/action/Remove(): (mob/removed_from)
#define COMSIG_ACTION_REMOVED "action_removed"
/// From /datum/action/apply_button_overlay()
#define COMSIG_ACTION_OVERLAY_APPLY "action_overlay_applied"
// Cooldown action signals

/// From base of /datum/action/proc/pre_activate(), sent to the action owner: (datum/action/cooldown/activated)
#define COMSIG_MOB_ABILITY_STARTED "mob_ability_base_started"
	/// Return to block the ability from starting / activating
	#define COMPONENT_BLOCK_ABILITY_START (1<<0)
/// From base of /datum/action/proc/pre_activate(), sent to the action owner: (datum/action/cooldown/finished)
#define COMSIG_MOB_ABILITY_FINISHED "mob_ability_base_finished"

// Specific cooldown action signals

/// From base of /datum/action/mob_cooldown/blood_warp/proc/blood_warp(): ()
#define COMSIG_BLOOD_WARP "mob_ability_blood_warp"
/// From base of /datum/action/mob_cooldown/charge/proc/do_charge(): ()
#define COMSIG_STARTED_CHARGE "mob_ability_charge_started"
/// From base of /datum/action/mob_cooldown/charge/proc/do_charge(): ()
#define COMSIG_FINISHED_CHARGE "mob_ability_charge_finished"
/// From base of /datum/action/mob_cooldown/lava_swoop/proc/swoop_attack(): ()
#define COMSIG_SWOOP_INVULNERABILITY_STARTED "mob_swoop_invulnerability_started"
/// From base of /datum/action/mob_cooldown/lava_swoop/proc/swoop_attack(): ()
#define COMSIG_LAVA_ARENA_FAILED "mob_lava_arena_failed"

/// From /datum/action/cooldown/manual_heart/Activate(): ()
#define COMSIG_HEART_MANUAL_PULSE "heart_manual_pulse"
