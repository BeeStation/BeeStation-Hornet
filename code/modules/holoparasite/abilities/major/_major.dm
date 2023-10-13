/**
 * A major holoparasite ability.
 * Holoparasites may only have one major ability.
 */
/datum/holoparasite_ability/major
	/// If this ability forces a weapon, then this is a typepath to said weapon.
	var/forced_weapon

/datum/holoparasite_ability/major/Destroy()
	if(master_stats?.ability == src)
		master_stats.ability = null
	return ..()
