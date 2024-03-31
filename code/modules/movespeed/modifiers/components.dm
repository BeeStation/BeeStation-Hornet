/datum/movespeed_modifier/shrink_ray
	movetypes = GROUND
	multiplicative_slowdown = 4
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/snail_crawl
	multiplicative_slowdown = -7
	movetypes = GROUND

/datum/movespeed_modifier/sanity
	id = MOVESPEED_ID_SANITY
	movetypes = (~FLYING)

/datum/movespeed_modifier/sanity/insane
	multiplicative_slowdown = 0.6

/datum/movespeed_modifier/sanity/crazy
	multiplicative_slowdown = 0.3

/datum/movespeed_modifier/sanity/disturbed
	multiplicative_slowdown = 0.15
