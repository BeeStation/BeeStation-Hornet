/**
 * Security levels
 *
 * These are used by the security level subsystem. Each one of these represents a security level that a player can set.
 *
 * Base type is abstract
 */

/datum/security_level
	/// The name of this security level.
	var/name = "not set"
	/// The color of our announcement divider.
	var/announcement_color = "default"
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The sound that we will play when this security level is set
	var/sound
	/// The looping sound that will be played while the security level is set
	var/looping_sound
	/// The looping sound interval
	var/looping_sound_interval
	/// The shuttle call time modification of this security level
	var/shuttle_call_time_mod = 0
	/// Our announcement when lowering to this level
	var/lowering_to_announcement
	/// Our announcement when elevating to this level
	var/elevating_to_announcement
	/// Our configuration key for lowering to text, if set, will override the default lowering to announcement.
	var/lowering_to_configuration_key
	/// Our configuration key for elevating to text, if set, will override the default elevating to announcement.
	var/elevating_to_configuration_key

/datum/security_level/New()
	. = ..()
	if(lowering_to_configuration_key) // I'm not sure about you, but isn't there an easier way to do this?
		lowering_to_announcement = global.config.Get(lowering_to_configuration_key)
	if(elevating_to_configuration_key)
		elevating_to_announcement = global.config.Get(elevating_to_configuration_key)

/**
 * GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = "green"
	announcement_color = "green"
	sound = 'sound/misc/notice2.ogg' // Friendly beep
	number_level = SEC_LEVEL_GREEN
	lowering_to_configuration_key = /datum/config_entry/string/alert_green
	shuttle_call_time_mod = ALERT_COEFF_GREEN

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	announcement_color = "blue"
	sound = 'sound/misc/notice1.ogg' // Angry alarm
	number_level = SEC_LEVEL_BLUE
	lowering_to_configuration_key = /datum/config_entry/string/alert_blue_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_blue_upto
	shuttle_call_time_mod = ALERT_COEFF_BLUE

/**
 * YELLOW
 *
 * The station is sawed in half.
 */
/datum/security_level/yellow
	name = "yellow (Engineering)"
	announcement_color = "yellow"
	sound = 'sound/misc/yellowalert.ogg'
	number_level = SEC_LEVEL_YELLOW
	lowering_to_configuration_key = /datum/config_entry/string/alert_engineering
	elevating_to_configuration_key = /datum/config_entry/string/alert_engineering
	shuttle_call_time_mod = ALERT_COEFF_BLUE

/**
 * CYAN
 *
 * The station is undergoing stupid virologist syndrome
 * Blame bacon for this not being called cyan alert.
 */
/datum/security_level/cyan
	name = "yellow (Medical)"
	announcement_color = "cyan"
	sound = 'sound/misc/cyanalert.ogg'
	number_level = SEC_LEVEL_CYAN
	lowering_to_configuration_key = /datum/config_entry/string/alert_medical
	elevating_to_configuration_key = /datum/config_entry/string/alert_medical
	shuttle_call_time_mod = ALERT_COEFF_BLUE

/**
 * RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = "red"
	announcement_color = "red"
	sound = 'sound/misc/notice3.ogg' // More angry alarm
	number_level = SEC_LEVEL_RED
	lowering_to_configuration_key = /datum/config_entry/string/alert_red_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_red_upto
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * GAMMA
 *
 * ERT enroute, station is in a critical situation
 */
/datum/security_level/gamma
	name = "gamma"
	announcement_color = "darkred"
	sound = 'sound/misc/gamma.ogg'
	number_level = SEC_LEVEL_EPSILON
	lowering_to_configuration_key = /datum/config_entry/string/alert_gamma
	elevating_to_configuration_key = /datum/config_entry/string/alert_gamma
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * BLACK
 *
 * We are under fucking attack.
 */
/datum/security_level/black
	name = "black"
	announcement_color = "black"
	sound = 'sound/misc/black.ogg'
	number_level = SEC_LEVEL_BLACK
	lowering_to_configuration_key = /datum/config_entry/string/alert_black
	elevating_to_configuration_key = /datum/config_entry/string/alert_black
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * EPSILON
 *
 * You done fucked up, now centcom's angry. Deathsquad incoming.
 */
/datum/security_level/epsilon
	name = "epsilon"
	announcement_color = "purple"
	sound = 'sound/misc/epsilon.ogg'
	number_level = SEC_LEVEL_EPSILON
	elevating_to_configuration_key = /datum/config_entry/string/alert_epsilon
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * LAMBDA
 *
 * heretic ascension, cult win, magic shit won
 */
/datum/security_level/lambda
	name = "lambda"
	announcement_color = "purple"
	sound = 'sound/misc/lambda.ogg'
	number_level = SEC_LEVEL_LAMBDA
	lowering_to_configuration_key = /datum/config_entry/string/alert_lambda
	elevating_to_configuration_key = /datum/config_entry/string/alert_lambda
	shuttle_call_time_mod = ALERT_COEFF_DELTA

/**
 * DELTA
 *
 * Station destruction is imminent
 */
/datum/security_level/delta
	name = "delta"
	announcement_color = "purple"
	sound = 'sound/misc/airraid.ogg' // Air alarm to signify importance
	number_level = SEC_LEVEL_DELTA
	lowering_to_configuration_key = /datum/config_entry/string/alert_delta
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
	shuttle_call_time_mod = ALERT_COEFF_DELTA
