// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /datum signals
#define COMSIG_COMPONENT_ADDED "component_added"				//! when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//! before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"			//! before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_QDELETING "parent_qdeleting"				//! just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_TOPIC "handle_topic"                             //! generic topic handler (usr, href_list)

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

/// Sent when the amount of materials in material_container changes
#define COMSIG_MATERIAL_CONTAINER_CHANGED "material_container_changed"

// /datum/species signals
#define COMSIG_SPECIES_GAIN "species_gain"						//! from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_LOSS "species_loss"						//! from datum/species/on_species_loss(): (datum/species/lost_species)

// /datum/song signals
/// Sent to the instrument when a song starts playing
#define COMSIG_SONG_START 	"song_start"
#define COMSIG_SONG_END		"song_end"

/*******Component Specific Signals*******/
//Janitor
#define COMSIG_TURF_IS_WET "check_turf_wet"							//! (): Returns bitflags of wet values.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"						//! (max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"					//! called on an object to clean it of cleanables. Usualy with soap: (num/strength)

//Creamed
#define COMSIG_COMPONENT_CLEAN_FACE_ACT "clean_face_act"		//! called when you wash your face at a sink: (num/strength)

//Food

///from base of obj/item/reagent_containers/food/snacks/attack() & Edible component: (mob/living/eater, mob/feeder)
#define COMSIG_FOOD_EATEN "food_eaten"

///from base of Component/edible/On_Consume: (mob/living/eater, mob/living/feeder)
#define COMSIG_FOOD_CONSUMED "food_consumed"

#define COMSIG_ITEM_FRIED "item_fried"
	#define COMSIG_FRYING_HANDLED (1<<0)

//Gibs

#define COMSIG_GIBS_STREAK "gibs_streak"						//! from base of /obj/effect/decal/cleanable/blood/gibs/streak(): (list/directions, list/diseases)

//Diseases

#define COMSIG_DISEASE_END "disease_end" 						//from the base of /datum/disease/advance/Destroy(): (GetDiseaseID)

//Mood

#define COMSIG_ADD_MOOD_EVENT "add_mood" //! Called when you send a mood event from anywhere in the code.
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood" //! Called when you clear a mood event from anywhere in the code.

/// Called in /obj/structure/moneybot/add_money(). (to_add)
#define COMSIG_MONEYBOT_ADD_MONEY "moneybot_add_money"

// Sent when a mob with a mind enters cryo storage
#define COMSIG_MIND_CRYOED "mind_cryoed"

#define COMSIG_GREYSCALE_CONFIG_REFRESHED "greyscale_config_refreshed"


// /datum/component/two_handed signals
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"              //from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
      #define COMPONENT_TWOHANDED_BLOCK_WIELD 1
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"          //from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)

// /datum/action signals
#define COMSIG_ACTION_TRIGGER "action_trigger"						//! from base of datum/action/proc/Trigger(): (datum/action)
	#define COMPONENT_ACTION_BLOCK_TRIGGER 1

// /datum/mind signals
#define COMSIG_MIND_TRANSFER_TO	"mind_transfer_to"					// (mob/old, mob/new)

// /datum/component/clockwork_trap signals
#define COMSIG_CLOCKWORK_SIGNAL_RECEIVED "clock_received"			//! When anything the trap is attatched to is triggered

///Subsystem signals
///From base of datum/controller/subsystem/Initialize: (start_timeofday)
#define COMSIG_SUBSYSTEM_POST_INITIALIZE "subsystem_post_initialize"

/// a weather event of some kind occured
#define COMSIG_WEATHER_TELEGRAPH(event_type) "!weather_telegraph [event_type]"
#define COMSIG_WEATHER_START(event_type) "!weather_start [event_type]"
#define COMSIG_WEATHER_WINDDOWN(event_type) "!weather_winddown [event_type]"
#define COMSIG_WEATHER_END(event_type) "!weather_end [event_type]"
/// An alarm of some form was sent (datum/alarm_handler/source, alarm_type, area/source_area)
#define COMSIG_ALARM_FIRE(alarm_type) "!alarm_fire [alarm_type]"
/// An alarm of some form was cleared (datum/alarm_handler/source, alarm_type, area/source_area)
#define COMSIG_ALARM_CLEAR(alarm_type) "!alarm_clear [alarm_type]"

/// signals from globally accessible objects

// Alarm listener datum signals
///Sent when an alarm is fired (alarm, area/source_area)
#define COMSIG_ALARM_TRIGGERED "comsig_alarm_triggered"
///Send when an alarm source is cleared (alarm_type, area/source_area)
#define COMSIG_ALARM_CLEARED "comsig_alarm_clear"

// Radio jammer signals
/// Calls something to toggle its jamming ability. (mob/user, silent = FALSE)
#define COMSIG_TOGGLE_JAMMER "toggle_jammer"

///Called to all children when a parent moves, as long as it has the moved relay component.
#define COMSIG_PARENT_MOVED_RELAY "parent_moved_relay"

/// Called when a buffer tries to send some stored data to something (datum/source, mob/user, datum/buffer, obj/item/buffer_parent) (buffer item may be null)
#define COMSIG_PARENT_RECIEVE_BUFFER "recieve_buffer"
	#define COMPONENT_BUFFER_RECIEVED (1 << 0)
