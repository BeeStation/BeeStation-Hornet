// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj access signals

#define COMSIG_OBJ_ALLOWED "door_try_to_activate"
	#define COMPONENT_OBJ_ALLOW (1<<0)

// /obj/machinery/door/airlock signals

//from /obj/machinery/door/airlock/open(): (forced)
#define COMSIG_AIRLOCK_OPEN "airlock_open"
//from /obj/machinery/door/airlock/close(): (forced)
#define COMSIG_AIRLOCK_CLOSE "airlock_close"
///from /obj/machinery/door/airlock/set_bolt():
#define COMSIG_AIRLOCK_SET_BOLT "airlock_set_bolt"
///Sent from /obj/machinery/door/airlock when its touched. (mob/user)
#define COMSIG_AIRLOCK_TOUCHED "airlock_touched"
	#define COMPONENT_PREVENT_OPEN 1
