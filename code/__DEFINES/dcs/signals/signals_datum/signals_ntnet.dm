// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

//NTnet
#define COMSIG_COMPONENT_NTNET_RECEIVE "ntnet_receive"			/// called on an object by its NTNET connection component on receive. (data(datum/netdata))
#define COMSIG_COMPONENT_NTNET_PORT_UPDATE "ntnet_port_update"	/// called on an object by its NTNET connection component on a port update (hardware_id, port))
#define COMSIG_COMPONENT_NTNET_ACK "ntnet_ack"					/// called when packet was accepted by the target (datum/netdata, error_code)
#define COMSIG_COMPONENT_NTNET_NAK "ntnet_nack"					/// called when packet was not acknoledged by the target (datum/netdata, error_code)

// Some internal NTnet signals used on ports
#define COMSIG_COMPONENT_NTNET_PORT_DESTROYED "ntnet_port_destroyed"	/// called on an object by its NTNET connection component on a port distruction (port, list/data))
#define COMSIG_COMPONENT_NTNET_PORT_UPDATED "ntnet_port_updated"		/// called on an object by its NTNET connection component on a port distruction (port, list/data))
