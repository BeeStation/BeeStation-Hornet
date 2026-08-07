// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/expose_reagents():
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"
	/// Prevents the atom from being exposed to reagents if returned on [COMPONENT_ATOM_EXPOSE_REAGENTS]
	#define COMPONENT_NO_EXPOSE_REAGENTS (1<<0)
///from base of [/datum/reagent/proc/expose_atom]: (/datum/reagent, reac_volume)
#define COMSIG_ATOM_EXPOSE_REAGENT "atom_expose_reagent"
