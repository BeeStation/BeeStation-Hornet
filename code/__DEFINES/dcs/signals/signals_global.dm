// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
/// sent after world.maxx and/or world.maxy are expanded: (has_exapnded_world_maxx, has_expanded_world_maxy)
#define COMSIG_GLOB_EXPANDED_WORLD_BOUNDS "!expanded_world_bounds"
#define COMSIG_GLOB_VAR_EDIT "!var_edit"						//! called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_EXPLOSION "!explosion"						//! called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"					//! mob was created somewhere : (mob)
/// mob died somewhere : (mob/living, gibbed)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"			//! global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_CARBON_THROW_THING	"!throw_thing"			//! a person somewhere has thrown something : (mob/living/carbon/carbon_thrower, target)
#define COMSIG_GLOB_SOUND_PLAYED "!sound_played"				//! a sound was played : (sound_player, sound_file)
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
/// Called when a cargo resupply is triggered
#define COMSIG_GLOB_RESUPPLY "!resupply"
/// research has been researched
#define COMSIG_GLOB_NEW_RESEARCH "!remote_research_changed"
/// Called after the round has fully setup and all jobs have been spawned
#define COMSIG_GLOB_POST_START "!post_start"
/// Called when the parallax background changes colour. (new_colour, transition_time)
#define COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE "!starlight_colour_change"
/// Called whenever the crew manifest is updated
#define COMSIG_GLOB_CREW_MANIFEST_UPDATE "!crew_manifest_update"
/// Called whenever something is sold through exports
#define COMSIG_GLOB_ATOM_SOLD "!atom_sold"
/// Call this to update the dynamic panel's data
#define COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA "!update_dynamicpanel_data"
/// Call this to update the dynamic panel's static data
#define COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA_STATIC "!update_dynamicpanel_data_static"
