/datum/config_entry/keyed_list/policy
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_TEXT

/datum/config_entry/number/damage_multiplier
	config_entry_value = 1
	integer = FALSE

/datum/config_entry/flag/assistants_have_maint_access

/datum/config_entry/flag/security_has_maint_access

/datum/config_entry/flag/everyone_has_maint_access

/datum/config_entry/flag/sec_start_brig	//makes sec start in brig instead of dept sec posts

/datum/config_entry/flag/force_random_names

/datum/config_entry/flag/humans_need_surnames

/datum/config_entry/flag/allow_ai	// allow ai job

/datum/config_entry/flag/allow_ai_multicam	// allow ai multicamera mode

/datum/config_entry/flag/disable_human_mood

/datum/config_entry/flag/disable_guardianborg	// disallow secborg model to be chosen.

/datum/config_entry/flag/disable_peaceborg

/datum/config_entry/flag/donator_items 	// do you need to be a donator to use donator items

/datum/config_entry/flag/combat_indicator //Whether we show combat indicators when combat mode is enabled
/datum/config_entry/number/traitor_objectives_amount
	config_entry_value = 2
	min_val = 0

/datum/config_entry/number/brother_objectives_amount
	config_entry_value = 2
	min_val = 0

/datum/config_entry/flag/reactionary_explosions	//If we use reactionary explosions, explosions that react to walls and doors

/datum/config_entry/flag/protect_roles_from_antagonist	//If security and such can be traitor/cult/other

/datum/config_entry/flag/protect_assistant_from_antagonist	//If assistants can be traitor/cult/other

/datum/config_entry/flag/protect_heads_from_antagonist	//If heads can be traitor/cult/other

/datum/config_entry/flag/enforce_human_authority	//If non-human species are barred from joining as a head of staff

/datum/config_entry/flag/allow_latejoin_antagonists	// If late-joining players can be traitor/changeling

/datum/config_entry/flag/use_antag_rep // see game_options.txt for details

/datum/config_entry/number/antag_rep_maximum
	config_entry_value = 200
	integer = FALSE
	min_val = 0

/datum/config_entry/number/default_antag_tickets
	config_entry_value = 100
	integer = FALSE
	min_val = 0

/datum/config_entry/number/max_tickets_per_roll
	config_entry_value = 100
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/equal_job_weight

/datum/config_entry/number/default_rep_value
	config_entry_value = 5
	integer = FALSE
	min_val = 0

/datum/config_entry/number/midround_antag_time_check	// How late (in minutes you want the midround antag system to stay on, setting this to 0 will disable the system)
	config_entry_value = 60
	integer = FALSE
	min_val = 0

/datum/config_entry/number/midround_antag_life_check	// A ratio of how many people need to be alive in order for the round not to immediately end in midround antagonist
	config_entry_value = 0.7
	integer = FALSE
	min_val = 0
	max_val = 1

/datum/config_entry/number/shuttle_refuel_delay
	config_entry_value = 12000
	integer = FALSE
	min_val = 0

/datum/config_entry/string/fallback_default_species
	config_entry_value = SPECIES_HUMAN

/datum/config_entry/keyed_list/roundstart_races	//races you can play as from the get go.
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/keyed_list/paywall_races	//races you have to be a subscriber to play as
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/keyed_list/roundstart_no_hard_check // Species contained in this list will not cause existing characters with no-longer-roundstart species set to be resetted to the human race.
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/flag/join_with_mutant_humans	//players can pick mutant bodyparts for humans before joining the game

/datum/config_entry/flag/no_summon_guns	//No

/datum/config_entry/flag/no_summon_magic	//Fun

/datum/config_entry/flag/no_summon_events	//Allowed

/datum/config_entry/flag/intercept_report	//Whether or not to send a communications intercept report roundstart. This may be overridden by gamemodes.
	config_entry_value = TRUE

/datum/config_entry/number/arrivals_shuttle_dock_window	//Time from when a player late joins on the arrivals shuttle to when the shuttle docks on the station
	config_entry_value = 55
	integer = FALSE
	min_val = 30

/datum/config_entry/flag/arrivals_shuttle_require_undocked	//Require the arrivals shuttle to be undocked before latejoiners can join

/datum/config_entry/flag/arrivals_shuttle_require_safe_latejoin	//Require the arrivals shuttle to be operational in order for latejoiners to join

/datum/config_entry/string/alert_green
	config_entry_value = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."

/datum/config_entry/string/alert_blue_upto
	config_entry_value = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."

/datum/config_entry/string/alert_blue_downto
	config_entry_value = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."

/datum/config_entry/string/alert_engineering
	config_entry_value = "The security alert level has been changed to yellow (Engineering). There is currently a critical engineering issue on the station. All crewmembers are instructed to obey all instructions given by the Chief Engineer for the duration of this alert."

/datum/config_entry/string/alert_medical
	config_entry_value = "The security alert level has been changed to yellow (Medical). There is an ongoing C-B-R-N threat to the station. Crewmembers are advised to don protective gear, and personal oxygen systems. All crew are instructed to obey all instructions given by the Chief Medical Officer for the duration of this alert."

/datum/config_entry/string/alert_red_upto
	config_entry_value = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."

/datum/config_entry/string/alert_red_downto
	config_entry_value = "There is still an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."

/datum/config_entry/string/alert_gamma
	config_entry_value = "Central Command has ordered the Gamma security level on the station. This station is now under direct central command control. Central command personnel are to be listened to in favor of heads of staff."

/datum/config_entry/string/alert_black
	config_entry_value = "Central Command has detected multiple syndicate infiltrator ships incoming. All crew are to prepare for hostile boarding. Any violations of orders from security personnel are punishable by death. This is not a drill, evacuate the station immediately."

/datum/config_entry/string/alert_lambda
	config_entry_value = "Central Command has detected a large spike of dimensional energy, consistent with the summoning of \[REDACTED\] entities. Any violations of orders from Heads of Staff and security can be punished by death. All crew are recommended to evacuate if possible."

/datum/config_entry/string/alert_delta
	config_entry_value = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

/datum/config_entry/string/alert_epsilon
	config_entry_value = "Central Command has ordered the Epsilon security level on the station. Consider your contracts terminated."

/datum/config_entry/number/station_goal_budget
	config_entry_value = 1
	min_val = 0

/datum/config_entry/flag/diona_ghost_spawn

/datum/config_entry/flag/revival_cloning

/datum/config_entry/flag/post_revival_message

/datum/config_entry/number/revival_brain_life
	config_entry_value = -1
	integer = FALSE
	min_val = -1

/datum/config_entry/flag/ooc_during_round

/datum/config_entry/flag/looc_enabled

/datum/config_entry/flag/emojis

/datum/config_entry/flag/badges

/datum/config_entry/keyed_list/multiplicative_movespeed
	key_mode = KEY_MODE_TYPE
	value_mode = VALUE_MODE_NUM
	config_entry_value = list(			//DEFAULTS
	/mob/living/simple_animal = 1,
	/mob/living/silicon/pai = 1,
	/mob/living/carbon/alien/humanoid/hunter = -0.5,
	/mob/living/carbon/alien/humanoid/royal/praetorian = 1,
	/mob/living/carbon/alien/humanoid/royal/queen = 3
	)

/datum/config_entry/keyed_list/multiplicative_movespeed/ValidateAndSet()
	. = ..()
	if(.)
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/keyed_list/multiplicative_movespeed/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/number/movedelay	//Used for modifying movement speed for mobs.
	abstract_type = /datum/config_entry/number/movedelay

/datum/config_entry/number/movedelay/ValidateAndSet()
	. = ..()
	if(.)
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/run_delay
	integer = FALSE

/datum/config_entry/number/movedelay/run_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/run)
	M.sync()

/datum/config_entry/number/movedelay/walk_delay
	integer = FALSE

/datum/config_entry/number/movedelay/walk_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/walk)
	M.sync()

/////////////////////////////////////////////////

/datum/config_entry/flag/virtual_reality	//Will virtual reality be loaded

/datum/config_entry/flag/roundstart_away	//Will random away mission be loaded.

/datum/config_entry/number/gateway_delay	//How long the gateway takes before it activates. Default is half an hour. Only matters if roundstart_away is enabled.
	config_entry_value = 18000
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/ghost_interaction

/datum/config_entry/flag/near_death_experience //If carbons can hear ghosts when unconscious and very close to death

/datum/config_entry/flag/silent_ai
/datum/config_entry/flag/silent_borg

/datum/config_entry/flag/sandbox_autoclose	// close the sandbox panel after spawning an item, potentially reducing griff

/datum/config_entry/number/default_laws //Controls what laws the AI spawns with.
	config_entry_value = 0
	min_val = 0
	max_val = 4

/datum/config_entry/number/silicon_max_law_amount
	config_entry_value = 12
	min_val = 0

/datum/config_entry/keyed_list/specified_laws
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG

/datum/config_entry/keyed_list/random_laws
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	splitter = ","

/datum/config_entry/keyed_list/law_weight
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	splitter = ","

/datum/config_entry/number/max_law_len
	config_entry_value = 1024

/datum/config_entry/number/overflow_cap
	config_entry_value = -1
	min_val = -1

/datum/config_entry/string/overflow_job
	config_entry_value = JOB_NAME_ASSISTANT

/datum/config_entry/flag/grey_assistants

/datum/config_entry/number/lavaland_budget
	config_entry_value = 60
	integer = FALSE
	min_val = 0

/datum/config_entry/number/space_budget
	config_entry_value = 40
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/allow_random_events	// Enables random events mid-round when set

/datum/config_entry/number/events_min_time_mul	// Multipliers for random events minimal starting time and minimal players amounts
	config_entry_value = 1
	min_val = 0
	integer = FALSE

/datum/config_entry/number/events_min_players_mul
	config_entry_value = 1
	min_val = 0
	integer = FALSE

/datum/config_entry/number/mice_roundstart
	config_entry_value = 10
	min_val = 0

/datum/config_entry/number/bombcap
	config_entry_value = 14
	min_val = 4

/datum/config_entry/number/bombcap/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.MAX_EX_DEVESTATION_RANGE = round(config_entry_value / 4)
		GLOB.MAX_EX_HEAVY_RANGE = round(config_entry_value / 2)
		GLOB.MAX_EX_LIGHT_RANGE = config_entry_value
		GLOB.MAX_EX_FLASH_RANGE = config_entry_value
		GLOB.MAX_EX_FLAME_RANGE = config_entry_value

/datum/config_entry/number/emergency_shuttle_autocall_threshold
	min_val = 0
	max_val = 1
	integer = FALSE

/datum/config_entry/flag/ic_printing

/datum/config_entry/flag/roundstart_traits

/datum/config_entry/flag/enable_night_shifts

/datum/config_entry/flag/randomize_shift_time

/datum/config_entry/flag/shift_time_realtime

/datum/config_entry/keyed_list/antag_rep
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/flag/allow_crew_objectives

//Mob spam prevention
/datum/config_entry/number/max_cube_monkeys
	config_entry_value = 100
/datum/config_entry/number/ratcap
	config_entry_value = 64
	min_val = 0
/datum/config_entry/number/max_chickens
	config_entry_value = 100
/datum/config_entry/number/max_slimes
	config_entry_value = 100
/datum/config_entry/number/max_slimeperson_bodies
	config_entry_value = 10


//Shuttle size limiter
/datum/config_entry/number/max_shuttle_count
	config_entry_value = 6

/datum/config_entry/number/max_shuttle_size
	config_entry_value = 250

/datum/config_entry/flag/restricted_suicide

/datum/config_entry/flag/dynamic_config_enabled

/datum/config_entry/flag/spare_enforce_coc

/datum/config_entry/flag/station_traits

/datum/config_entry/keyed_list/positive_station_traits
	config_entry_value = list("0" = 8, "1" = 4, "2" = 2, "3" = 1)
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/negative_station_traits
	config_entry_value = list("0" = 8, "1" = 4, "2" = 2, "3" = 1)
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/neutral_station_traits
	config_entry_value = list("0" = 10, "1" = 10, "2" = 3, "2.5" = 1)
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/flag/dark_unstaffed_departments

/datum/config_entry/flag/allow_virologist

/datum/config_entry/flag/chemviro_allowed

/datum/config_entry/flag/isolation_allowed

/datum/config_entry/flag/neuter_allowed

/datum/config_entry/flag/mixvirus_allowed

/datum/config_entry/flag/seeded_symptoms

/datum/config_entry/flag/biohazards_allowed

/datum/config_entry/flag/process_dead_allowed

/datum/config_entry/flag/unconditional_virus_spreading

/datum/config_entry/flag/unconditional_symptom_thresholds

/datum/config_entry/flag/event_symptom_thresholds

/datum/config_entry/flag/special_symptom_thresholds

/datum/config_entry/number/virus_thinning_cap
	config_entry_value = 4

/**
 * A config that skews with the random spawners weights
 * If the value is lower than 1, it'll tend to even out the odds
 * If higher than 1, it'll lean toward common spawns even more.
 */
/datum/config_entry/number/random_loot_weight_modifier
	integer = FALSE
	default = 1
	min_val = 0.05
