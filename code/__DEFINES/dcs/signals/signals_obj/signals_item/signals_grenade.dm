// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/item/grenade signals
#define COMSIG_GRENADE_PRIME "grenade_prime"					//called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"					//called in /obj/item/gun/process_fire (user, target, params, zone_override)
