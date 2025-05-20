// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/machinery/atmospherics/components/binary/valve signals

/// from /obj/machinery/atmospherics/components/binary/valve/toggle(): (on)
#define COMSIG_VALVE_SET_OPEN "valve_toggled"

/// from /obj/machinery/atmospherics/set_on(active): (on)
#define COMSIG_ATMOS_MACHINE_SET_ON "atmos_machine_set_on"

/// from /obj/machinery/fire_alarm/reset(), /obj/machinery/fire_alarm/alarm(): (status)
#define COMSIG_FIREALARM_ON_TRIGGER "firealarm_trigger"
#define COMSIG_FIREALARM_ON_RESET "firealarm_reset"
