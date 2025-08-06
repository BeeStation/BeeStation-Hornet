/**

Point consciousness: No Crit.

When the consciousness value goes below 0, rather than entering a crit
or unconscious state, we simply die.

The consciousness value is tied directly to the amount of damage that we
have recieved.

This is primarily for simple creatures which have no blood model, and thus
cannot die from fluid loss or brain damage.

*/

/datum/consciousness/point/nocrit

/datum/consciousness/point/nocrit/register_signals(mob/living/owner)
	return

/datum/consciousness/point/nocrit/update_consciousness(consciousness_value)
	if (owner.status_flags & GODMODE)
		return
	if (owner.stat != DEAD)
		if (consciousness_value <= 0)
			owner.death()
		else
			owner.set_stat(CONSCIOUS)
