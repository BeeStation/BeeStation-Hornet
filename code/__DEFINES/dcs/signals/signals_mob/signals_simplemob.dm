// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/simple_animal/hostile signals
#define COMSIG_HOSTILE_ATTACKINGTARGET "hostile_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK (1 << 0)

#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"

/// called when a simplemob is given sentience from a sentience potion (target = person who sentienced)
#define COMSIG_SIMPLEMOB_SENTIENCEPOTION "simplemob_sentiencepotion"
