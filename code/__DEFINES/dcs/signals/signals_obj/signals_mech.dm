// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/vehicle/sealed/mecha signals

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_TRIGGER "mecha_action_activate"

///sent from clicking while you have no equipment selected. Sent before cooldown and adjacency checks, so you can use this for infinite range things if you want.
#define COMSIG_MECHA_MELEE_CLICK "mecha_action_melee_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_MELEE_CLICK (1<<0)
///sent from clicking while you have equipment selected.
#define COMSIG_MECHA_EQUIPMENT_CLICK "mecha_action_equipment_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_EQUIPMENT_CLICK (1<<0)

///From /datum/action/vehicle/sealed/mecha/mech_toggle_safeties/proc/update_action_icon(): ()
#define COMSIG_MECH_SAFETIES_TOGGLE "mech_safeties_toggle"
