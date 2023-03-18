// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from [/datum/move_loop/start_loop] ():
#define COMSIG_MOVELOOP_START "moveloop_start"
///from [/datum/move_loop/stop_loop] ():
#define COMSIG_MOVELOOP_STOP "moveloop_stop"
///from [/datum/move_loop/process] ():
#define COMSIG_MOVELOOP_PREPROCESS_CHECK "moveloop_preprocess_check"
	#define MOVELOOP_SKIP_STEP (1<<0)
///from [/datum/move_loop/process] (succeeded, visual_delay):
#define COMSIG_MOVELOOP_POSTPROCESS "moveloop_postprocess"
//from [/datum/move_loop/has_target/jps/recalculate_path] ():
#define COMSIG_MOVELOOP_JPS_REPATH "moveloop_jps_repath"

// Exploration related signals
/// Called when a message is sent to an orbital body: (message)
#define COMSIG_ORBITAL_BODY_MESSAGE "orbital_body_message"
/// Called on SSorbits when an orbital body is created on an orbital map: (datum/orbital_object/body, datum/orbital_map/map)
#define COMSIG_ORBITAL_BODY_CREATED "orbital_body_created"
/// Called on a space level when generation is complete
#define COMSIG_SPACE_LEVEL_GENERATED "space_level_generated"

// Shuttle Machinery Signals
/// Called when a shuttle engine updates its status: (is_active)
#define COMSIG_SHUTTLE_ENGINE_STATUS_CHANGE "shuttle_engine_status"
/// Called when a shield generator changes its health amount: (old_amount, new_amount)
#define COMSIG_SHUTTLE_SHIELD_HEALTH_CHANGE "shuttle_shield_health_change"
