// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/machinery/atmospherics/components/binary/valve signals

/// from /obj/machinery/atmospherics/components/binary/valve/toggle(): (on)
#define COMSIG_VALVE_SET_OPEN "valve_toggled"


/// from /obj/machinery/atmospherics/components/binary/pump/set_on(active): (on)
#define COMSIG_PUMP_SET_ON "pump_set_on"
