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

// called when movable is expelled from a disposal pipe, bin or outlet on obj/pipe_eject: (direction)
#define COMSIG_MOVABLE_PIPE_EJECTING "movable_pipe_ejecting"

///from base of atom/movable/newtonian_move(): (inertia_direction)
#define COMSIG_MOVABLE_NEWTONIAN_MOVE "movable_newtonian_move"
	#define COMPONENT_MOVABLE_NEWTONIAN_BLOCK (1<<0)

/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_PRE_MOVE "mob_client_pre_move"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	/// From base of /client/Move()

	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE

///from base of atom/experience_pressure_difference(): (pressure_difference, direction, pressure_resistance_prob_delta)
#define COMSIG_ATOM_PRE_PRESSURE_PUSH "atom_pre_pressure_push"
	///prevents pressure movement
	#define COMSIG_ATOM_BLOCKS_PRESSURE (1<<0)

#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
