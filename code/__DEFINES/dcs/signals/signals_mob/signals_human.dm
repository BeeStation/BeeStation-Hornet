// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"	//! Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_ATTACKED "carbon_attacked"					//hit by something that checks shields.

//Heretics stuff
/// Default behavior is to use a charge, so return this to blocks the mansus fist from being consumed after use.
#define COMPONENT_BLOCK_CHARGE_USE (1<<0)

///called from /obj/effect/proc_holder/spell/cast_check (src)
#define COMSIG_MOB_PRE_CAST_SPELL "mob_cast_spell"
	/// Return to cancel the cast from beginning.
	#define COMPONENT_CANCEL_SPELL (1<<0)
