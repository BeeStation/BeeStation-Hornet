/// Random event is trying to roll. (/datum/round_event_control/random_event)
/// Called by (/datum/round_event_control/preRunEvent).
#define COMSIG_GLOB_PRE_RANDOM_EVENT "!pre_random_event"
	/// Do not allow this random event to continue.
	#define CANCEL_PRE_RANDOM_EVENT (1<<0)
/// Called by (/datum/round_event_control/run_event).
#define COMSIG_GLOB_RANDOM_EVENT "!random_event"
	/// Do not allow this random event to continue.
	#define CANCEL_RANDOM_EVENT (1<<0)

/// Signal sent by round event controls when they create round event datums before calling setup() on them: (datum/round_event_control/source_event_control, datum/round_event/created_event)
#define COMSIG_CREATED_ROUND_EVENT "creating_round_event"

/// Sent when the Grey Tide event begins affecting the station.
/// (list/area/greytide_areas)
#define COMSIG_GLOB_GREY_TIDE "grey_tide"

/// A different signal, used specifically for flickering the lights during the event
#define COMSIG_GLOB_GREY_TIDE_LIGHT "grey_tide_light"
