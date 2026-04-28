/**
 * Often times, we want functionality to be available to both AIs and Cyborgs.
 *
 * returns TRUE if action has been done
 */
/atom/proc/attack_silicon(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_SILICON, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	return FALSE
