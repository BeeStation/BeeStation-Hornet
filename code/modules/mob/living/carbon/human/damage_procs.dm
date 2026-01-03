

/mob/living/carbon/human/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, spread_damage = FALSE)
	// depending on the species, it will run the corresponding apply_damage code there
	if(stat != DEAD && (damagetype==BRUTE || damagetype==BURN) && damage>10 && prob(10+damage/2))
		INVOKE_ASYNC(src, PROC_REF(emote), "scream")
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, forced, spread_damage)
