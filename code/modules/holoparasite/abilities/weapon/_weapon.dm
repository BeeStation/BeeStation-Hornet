/**
 * A holoparasite weapon.
 * This determines 'how' the holoparasite attacks.
 * Holoparasites may only have one weapon.
 */
/datum/holoparasite_ability/weapon
	/// The cooldown time between attacks.
	var/click_cooldown = CLICK_CD_MELEE

/datum/holoparasite_ability/weapon/Destroy()
	if(master_stats?.weapon == src)
		master_stats.weapon = null
	return ..()

/**
 * An "after-attack" effect to be dealt to a target mob, after a successful attack.
 *
 * Arguments
 * * target: The target that was attacked.
 * * successful: TRUE if the attack was successful, FALSE otherwise.
 */
/datum/holoparasite_ability/weapon/proc/attack_effect(atom/movable/target, successful)
	SHOULD_CALL_PARENT(TRUE)
	owner.changeNext_move(click_cooldown)
