// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/machinery/power/supermatter_crystal signals
/// from /obj/machinery/power/supermatter_crystal/process_atmos(); when the SM delam reaches the point of sounding alarms
#define COMSIG_SUPERMATTER_DELAM_START_ALARM "sm_delam_start_alarm"
/// from /obj/machinery/power/supermatter_crystal/process_atmos(); when the SM sounds an audible alarm
#define COMSIG_SUPERMATTER_DELAM_ALARM "sm_delam_alarm"
