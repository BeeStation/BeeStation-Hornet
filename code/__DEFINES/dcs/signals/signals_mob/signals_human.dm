// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/carbon/human signals
///Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT "human_disarm_hit"
//hit by something that checks shields.
#define COMSIG_HUMAN_ATTACKED "carbon_attacked"
///from /datum/species/handle_fire. Called when the human is set on fire and burning clothes and stuff
#define COMSIG_HUMAN_BURNING "human_burning"

///From mob/living/carbon/human/suicide()
#define COMSIG_HUMAN_SUICIDE_ACT "human_suicide_act"

///called from /obj/effect/proc_holder/spell/cast_check (src)
#define COMSIG_MOB_PRE_CAST_SPELL "mob_cast_spell"
	/// Return to cancel the cast from beginning.
	#define COMPONENT_CANCEL_SPELL (1<<0)
