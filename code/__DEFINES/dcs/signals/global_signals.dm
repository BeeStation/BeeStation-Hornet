// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice
#define COMSIG_GLOB_NEW_Z "!new_z"								//! from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"						//! called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_EXPLOSION "!explosion"						//! called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"					//! mob was created somewhere : (mob)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"						//! mob died somewhere : (mob , gibbed)
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"			//! global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_CARBON_THROW_THING	"!throw_thing"			//! a person somewhere has thrown something : (mob/living/carbon/carbon_thrower, target)
#define COMSIG_GLOB_SECURITY_ALERT_CHANGE "!alert_change"		//! security level was changed : (new_alert)
/// called by datum/cinematic/play() : (datum/cinematic/new_cinematic)
#define COMSIG_GLOB_PLAY_CINEMATIC "!play_cinematic"
	#define COMPONENT_GLOB_BLOCK_CINEMATIC 1
/// Random event is trying to roll. (/datum/round_event_control/random_event)
/// Called by (/datum/round_event_control/preRunEvent).
#define COMSIG_GLOB_PRE_RANDOM_EVENT "!pre_random_event"
	/// Do not allow this random event to continue.
	#define CANCEL_PRE_RANDOM_EVENT (1<<0)
///global mob logged in signal! (/mob/added_player)
#define COMSIG_GLOB_MOB_LOGGED_IN "!mob_logged_in"
/// crewmember joined the game (mob/living, rank)
#define COMSIG_GLOB_CREWMEMBER_JOINED "!crewmember_joined"
/// job subsystem has spawned and equipped a new mob
#define COMSIG_GLOB_JOB_AFTER_SPAWN "!job_after_spawn"

/// research has been researched
#define COMSIG_GLOB_NEW_RESEARCH "!remote_research_changed"
