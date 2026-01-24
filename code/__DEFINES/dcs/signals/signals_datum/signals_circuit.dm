// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// Component signals
/// From /datum/port/output/set_output: (output_value)
#define COMSIG_PORT_SET_OUTPUT "port_set_output"
/// From /datum/port/input/set_input: (input_value)
#define COMSIG_PORT_SET_INPUT "port_set_input"
/// Sent when a port calls disconnect(). From /datum/port/disconnect: ()
#define COMSIG_PORT_DISCONNECT "port_disconnect"
/// Sent on the output port when an input port registers on it: (datum/port/input/registered_port)
#define COMSIG_PORT_OUTPUT_CONNECT "port_output_connect"

/// Sent when a [/obj/item/circuit_component] is added to a circuit.
#define COMSIG_CIRCUIT_ADD_COMPONENT "circuit_add_component"
	/// Cancels adding the component to the circuit.
	#define COMPONENT_CANCEL_ADD_COMPONENT (1<<0)

/// Sent when a [/obj/item/circuit_component] is added to a circuit manually, by putting the item inside directly.
/// Accepts COMPONENT_CANCEL_ADD_COMPONENT.
#define COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY "circuit_add_component_manually"

/// Sent when a circuit is removed from its shell
#define COMSIG_CIRCUIT_SHELL_REMOVED "circuit_shell_removed"

/// Sent to [/obj/item/circuit_component] when it is removed from a circuit. (/obj/item/integrated_circuit)
#define COMSIG_CIRCUIT_COMPONENT_REMOVED "circuit_component_removed"

/// Sent to an atom when a [/obj/item/usb_cable] attempts to connect to something. (/obj/item/usb_cable/usb_cable, /mob/user)
#define COMSIG_ATOM_USB_CABLE_TRY_ATTACH "usb_cable_try_attach"
/// Attaches the USB cable to the atom. If the USB cables moves away, it will disconnect.
#define COMSIG_USB_CABLE_ATTACHED (1<<0)

/// Attaches the USB cable to a circuit. Producers of this are expected to set the usb_cable's
/// `attached_circuit` variable.
#define COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT (1<<1)

/// Cancels the attack chain, but without performing any other action.
#define COMSIG_CANCEL_USB_CABLE_ATTACK (1<<2)

/// Called when the circuit component is saved.
#define COMSIG_CIRCUIT_COMPONENT_SAVE "circuit_component_save"

/// Called when an external object is loaded.
#define COMSIG_MOVABLE_CIRCUIT_LOADED "movable_circuit_loaded"

/// Called when the integrated circuit's cell is set.
#define COMSIG_CIRCUIT_SET_CELL "circuit_set_cell"

/// Called when the integrated circuit is turned on or off.
#define COMSIG_CIRCUIT_SET_ON "circuit_set_on"

/// Called when the integrated circuit's shell is set.
#define COMSIG_CIRCUIT_SET_SHELL "circuit_set_shell"

/// Called when the integrated circuit's is locked.
#define COMSIG_CIRCUIT_SET_LOCKED "circuit_set_locked"

/// Called before power is used in an integrated circuit (power_to_use)
#define COMSIG_CIRCUIT_PRE_POWER_USAGE "circuit_pre_power_usage"
	#define COMPONENT_OVERRIDE_POWER_USAGE (1<<0)

/// Called when somebody passes through a scanner gate and it triggers
#define COMSIG_SCANGATE_PASS_TRIGGER "scangate_pass_trigger"

/// Called when somebody passes through a scanner gate and it does not trigger
#define COMSIG_SCANGATE_PASS_NO_TRIGGER "scangate_pass_no_trigger"

/// Called when something passes through a scanner gate shell
#define COMSIG_SCANGATE_SHELL_PASS "scangate_shell_pass"

/// Sent when the value of a port is set.
#define COMSIG_PORT_SET_VALUE "port_set_value"
/// Sent when the type of a port is set.
#define COMSIG_PORT_SET_TYPE "port_set_type"

///Called when an Ntnet sender is sending Ntnet data
#define COMSIG_GLOB_CIRCUIT_NTNET_DATA_SENT "!circuit_ntnet_data_sent"
