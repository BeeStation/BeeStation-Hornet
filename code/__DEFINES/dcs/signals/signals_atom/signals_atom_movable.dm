// Atom movable signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /atom/movable signals
/// from base of atom/movable/Moved(): (/atom)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE (1<<0)
/// from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_MOVED "movable_moved"
/// from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_CROSS "movable_cross"
/// from base of atom/movable/Bump(): (/atom)
#define COMSIG_MOVABLE_BUMP "movable_bump"
/// from base of atom/movable/throw_impact(): (/atom/hit_atom, /datum/thrownthing/throwingdatum)
#define COMSIG_MOVABLE_IMPACT "movable_impact"
/// from base of mob/living/hitby(): (mob/living/target, hit_zone)
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"
/// from base of atom/movable/buckle_mob(): (mob, force)
#define COMSIG_MOVABLE_BUCKLE "buckle"
/// from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
/// from base of atom/movable/throw_at(): (list/args)
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"
	#define COMPONENT_CANCEL_THROW 1
/// from base of atom/movable/throw_at(): (datum/thrownthing, spin)
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"
/// from base of datum/thrownthing/finalize(): (obj/thrown_object, datum/thrownthing) used for when a throw is finished
#define COMSIG_MOVABLE_THROW_LANDED "movable_throw_landed"
/// from base of atom/movable/onTransitZ(): (old_z, new_z)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit"
/// called when the movable is placed in an unaccessible area, used for stationloving: ()
#define COMSIG_MOVABLE_SECLUDED_LOCATION "movable_secluded"
/// from base of atom/movable/Hear(): (message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
#define COMSIG_MOVABLE_HEAR "movable_hear"
	#define HEARING_MESSAGE 1
	#define HEARING_SPEAKER 2
//	#define HEARING_LANGUAGE 3
	#define HEARING_RAW_MESSAGE 4
	/* #define HEARING_RADIO_FREQ 5
	#define HEARING_SPANS 6
	#define HEARING_MESSAGE_MODE 7 */

/// called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"

//from base of atom/movable/on_enter_storage(): (datum/component/storage/concrete/master_storage)
#define COMSIG_STORAGE_ENTERED "storage_entered"
//from base of atom/movable/on_exit_storage(): (datum/component/storage/concrete/master_storage)
#define COMSIG_STORAGE_EXITED "storage_exited"
