// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///Called from /datum/species/proc/help : (mob/living/carbon/human/helper, datum/martial_art/helper_style)
#define COMSIG_CARBON_PRE_HELP "carbon_pre_help"
	/// Stops the rest of the help
	#define COMPONENT_BLOCK_HELP_ACT (1<<0)

///Called from /mob/living/carbon/help_shake_act, before any hugs have ocurred. (mob/living/helper)
#define COMSIG_CARBON_PRE_MISC_HELP "carbon_pre_misc_help"
	/// Stops the rest of help act (hugging, etc) from occuring
	#define COMPONENT_BLOCK_MISC_HELP (1<<0)

///Called from /mob/living/carbon/help_shake_act on the person being helped, after any hugs have ocurred. (mob/living/helper)
#define COMSIG_CARBON_HELP_ACT "carbon_help"
///Called from /mob/living/carbon/help_shake_act on the helper, after any hugs have ocurred. (mob/living/helped)
#define COMSIG_CARBON_HELPED "carbon_helped_someone"

///Called when a carbon attempts to breath, before the breath has actually occured
#define COMSIG_CARBON_ATTEMPT_BREATHE "carbon_attempt_breathe"
	// Prevents the breath
	#define COMSIG_CARBON_BLOCK_BREATH (1 << 0)
///Called when a carbon breathes, before the breath has actually occured
#define COMSIG_CARBON_PRE_BREATHE "carbon_pre_breathe"

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit" //! Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_ATTACKED "carbon_attacked" //hit by something that checks shields.

// Mob transformation signals
///Called when a human turns into a monkey, from /mob/living/carbon/proc/finish_monkeyize()
#define COMSIG_HUMAN_MONKEYIZE "human_monkeyize"
///Called when a monkey turns into a human, from /mob/living/carbon/proc/finish_humanize(species)
#define COMSIG_MONKEY_HUMANIZE "monkey_humanize"

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
