#define SDQL2_STATE_ERROR 0
#define SDQL2_STATE_IDLE 1
#define SDQL2_STATE_PRESEARCH 2
#define SDQL2_STATE_SEARCHING 3
#define SDQL2_STATE_EXECUTING 4
#define SDQL2_STATE_SWITCHING 5
#define SDQL2_STATE_HALTING 6

#define SDQL2_VALID_OPTION_TYPES list("proccall", "select", "priority", "autogc" , "sequential")
#define SDQL2_VALID_OPTION_VALUES list("async", "blocking", "force_nulls", "skip_nulls", "high", "normal", "keep_alive" , "true")

#define SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS			(1<<0)
#define SDQL2_OPTION_BLOCKING_CALLS						(1<<1)
#define SDQL2_OPTION_HIGH_PRIORITY						(1<<2)		//High priority SDQL query, allow using almost all of the tick.
#define SDQL2_OPTION_DO_NOT_AUTOGC						(1<<3)

#define SDQL2_OPTIONS_DEFAULT		(SDQL2_OPTION_SELECT_OUTPUT_SKIP_NULLS)

#define SDQL2_IS_RUNNING (state == SDQL2_STATE_EXECUTING || state == SDQL2_STATE_SEARCHING || state == SDQL2_STATE_SWITCHING || state == SDQL2_STATE_PRESEARCH)
#define SDQL2_HALT_CHECK if(!SDQL2_IS_RUNNING) {state = SDQL2_STATE_HALTING; return FALSE;};

#define SDQL2_TICK_CHECK ((options & SDQL2_OPTION_HIGH_PRIORITY)? CHECK_TICK_HIGH_PRIORITY : CHECK_TICK)

#define SDQL2_STAGE_SWITCH_CHECK if(state != SDQL2_STATE_SWITCHING){\
		if(state == SDQL2_STATE_HALTING){\
			state = SDQL2_STATE_IDLE;\
			return FALSE}\
		state = SDQL2_STATE_ERROR;\
		CRASH("SDQL2 fatal error");};
