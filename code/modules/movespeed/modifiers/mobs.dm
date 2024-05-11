/datum/movespeed_modifier/obesity
	multiplicative_slowdown = 1.5

/datum/movespeed_modifier/monkey_reagent_speedmod
	variable = TRUE

/datum/movespeed_modifier/monkey_health_speedmod
	variable = TRUE

/datum/movespeed_modifier/monkey_temperature_speedmod
	variable = TRUE

/datum/movespeed_modifier/hunger
	variable = TRUE

/datum/movespeed_modifier/slaughter
	multiplicative_slowdown = -1

/datum/movespeed_modifier/damage_slowdown
	blacklisted_movetypes = FLOATING|FLYING
	variable = TRUE

/datum/movespeed_modifier/damage_slowdown_flying
	movetypes = FLYING
	variable = TRUE

/datum/movespeed_modifier/equipment_speedmod
	variable = TRUE
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/grab_slowdown
	id = MOVESPEED_ID_MOB_GRAB_STATE
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/grab_slowdown/aggressive
	multiplicative_slowdown = 3

/datum/movespeed_modifier/grab_slowdown/neck
	multiplicative_slowdown = 6

/datum/movespeed_modifier/grab_slowdown/kill
	multiplicative_slowdown = 9

/datum/movespeed_modifier/slime_reagentmod
	variable = TRUE

/datum/movespeed_modifier/slime_healthmod
	variable = TRUE

/datum/movespeed_modifier/config_walk_run
	multiplicative_slowdown = 1
	id = MOVESPEED_ID_MOB_WALK_RUN
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/config_walk_run/proc/sync()

/datum/movespeed_modifier/config_walk_run/walk/sync()
	var/mod = CONFIG_GET(number/movedelay/walk_delay)
	multiplicative_slowdown = isnum(mod)? mod : initial(multiplicative_slowdown)

/datum/movespeed_modifier/config_walk_run/run/sync()
	var/mod = CONFIG_GET(number/movedelay/run_delay)
	multiplicative_slowdown = isnum(mod)? mod : initial(multiplicative_slowdown)

/datum/movespeed_modifier/turf_slowdown
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)
	variable = TRUE

/datum/movespeed_modifier/bulky_drag
	variable = TRUE

/datum/movespeed_modifier/cold
	blacklisted_movetypes = FLOATING
	variable = TRUE

/datum/movespeed_modifier/shove
	multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH

/datum/movespeed_modifier/human_carry
	multiplicative_slowdown = HUMAN_CARRY_SLOWDOWN

/datum/movespeed_modifier/limbless
	variable = TRUE
	movetypes = GROUND
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/simplemob_varspeed
	variable = TRUE
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/basicmob_varspeed
	variable = TRUE
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/tarantula_web
	multiplicative_slowdown = 3

/datum/movespeed_modifier/gravity
	blacklisted_movetypes = FLOATING
	variable = TRUE
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/carbon_softcrit
	multiplicative_slowdown = SOFTCRIT_ADD_SLOWDOWN
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/slime_tempmod
	variable = TRUE

/datum/movespeed_modifier/carbon_crawling
	multiplicative_slowdown = CRAWLING_ADD_SLOWDOWN
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/mob_config_speedmod
	variable = TRUE
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/phobia
	multiplicative_slowdown = 1

/datum/movespeed_modifier/phobia/terrified
	multiplicative_slowdown = -0.4

/datum/movespeed_modifier/virus
	variable = TRUE

/datum/movespeed_modifier/virus/light_virus
	variable = TRUE

/datum/movespeed_modifier/virus/grub_virus
	variable = TRUE

/datum/movespeed_modifier/virus/necro_virus
	variable = FALSE
	multiplicative_slowdown = 1

/datum/movespeed_modifier/nopowercell
	multiplicative_slowdown = 1.5
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/visible_hunger
	id = MOVESPEED_ID_VISIBLE_HUNGER
	movetypes = (~FLYING)

/datum/movespeed_modifier/visible_hunger/starving
	multiplicative_slowdown = 0.6

/datum/movespeed_modifier/visible_hunger/hungry
	multiplicative_slowdown = 0.2
