// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/machinery/power/supermatter_crystal signals

/// from /obj/machinery/power/supermatter_crystal/process_atmos(); when the SM sounds an audible alarm
#define COMSIG_SUPERMATTER_DELAM_ALARM "sm_delam_alarm"

/// from /datum/component/supermatter_crystal/proc/consume()
/// called on the thing consumed, passes the thing which consumed it
#define COMSIG_SUPERMATTER_CONSUMED "sm_consumed_this"
