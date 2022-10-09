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
