/datum/movespeed_modifier/strained_muscles
	multiplicative_slowdown = -0.5
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/pai_spacewalk
	multiplicative_slowdown = 2
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/bodypart
	movetypes = ~FLYING
	variable = TRUE

/datum/movespeed_modifier/dna_vault_speedup
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.5

/datum/movespeed_modifier/rift_empowerment
	multiplicative_slowdown = -0.5
