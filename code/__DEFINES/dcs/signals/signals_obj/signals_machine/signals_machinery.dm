// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/machinery signals

/// Sent from /obj/machinery/open_machine(): (drop)
#define COMSIG_MACHINE_OPEN "machine_open"
/// Sent from /obj/machinery/close_machine(): (atom/movable/target)
#define COMSIG_MACHINE_CLOSE "machine_close"
//from /obj/machinery/atom_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"
///from /obj/machinery/set_occupant(atom/movable/O): (new_occupant)
#define COMSIG_MACHINERY_SET_OCCUPANT "machinery_set_occupant"
///from /obj/machinery/proc/use_power(): (power_used)
#define COMSIG_MACHINERY_POWER_USED "machinery_power_used"
///from /obj/machinery/default_change_direction_wrench: (mob/user, obj/item/wrench)
#define COMSIG_MACHINERY_DEFAULT_ROTATE_WRENCH "machinery_default_rotate_wrench"

///from /obj/machinery/can_interact(mob/user): Called on user when attempting to interact with a machine (obj/machinery/machine)
#define COMSIG_TRY_USE_MACHINE "try_use_machine"
	/// Can't interact with the machine
	#define COMPONENT_CANT_USE_MACHINE_INTERACT (1<<0)
	/// Can't use tools on the machine
	#define COMPONENT_CANT_USE_MACHINE_TOOLS (1<<1)

// /obj/machinery/cryo_cell signals

/// from /obj/machinery/cryo_cell/set_on(bool): (on)
#define COMSIG_CRYO_SET_ON "cryo_set_on"

///from /datum/controller/subsystem/air/proc/start_processing_machine: ()
#define COMSIG_MACHINERY_START_PROCESSING_AIR "start_processing_air"
///from /datum/controller/subsystem/air/proc/stop_processing_machine: ()
#define COMSIG_MACHINERY_STOP_PROCESSING_AIR "stop_processing_air"
