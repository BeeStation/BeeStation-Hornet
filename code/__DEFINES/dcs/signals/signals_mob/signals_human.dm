// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"	//! Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_ATTACKED "carbon_attacked"					//hit by something that checks shields.

///From mob/living/carbon/human/suicide()
#define COMSIG_HUMAN_SUICIDE_ACT "human_suicide_act"

///from base of /mob/living/carbon/regenerate_limbs(): (excluded_limbs)
#define COMSIG_CARBON_REGENERATE_LIMBS "living_regen_limbs"

///called from /obj/effect/proc_holder/spell/cast_check (src)
#define COMSIG_MOB_PRE_CAST_SPELL "mob_cast_spell"
	/// Return to cancel the cast from beginning.
	#define COMPONENT_CANCEL_SPELL (1<<0)

//from /mob/living/carbon/human/proc/check_shields(): (atom/hit_by, damage, attack_text, attack_type, armour_penetration)
#define COMSIG_HUMAN_CHECK_SHIELDS "human_check_shields"
	#define SHIELD_BLOCK (1<<0)

/// from /mob/living/carbon/human/on_fire_stack. Called when the human is set on fire and burning clothes and stuff
#define COMSIG_HUMAN_BURNING "human_burning"
