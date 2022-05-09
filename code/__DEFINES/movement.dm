//Diagonal movement is split into two cardinal moves
/// The first step of the diagnonal movement
#define FIRST_DIAG_STEP 1
/// The second step of the diagnonal movement
#define SECOND_DIAG_STEP 2

/// Classic bluespace teleportation, requires a sender but no receiver
#define TELEPORT_CHANNEL_BLUESPACE "bluespace"
/// Quantum-based teleportation, requires both sender and receiver, but is free from normal disruption
#define TELEPORT_CHANNEL_QUANTUM "quantum"
/// Wormhole teleportation, is not disrupted by bluespace fluctuations but tends to be very random or unsafe
#define TELEPORT_CHANNEL_WORMHOLE "wormhole"
/// Magic teleportation, does whatever it wants (unless there's antimagic)
#define TELEPORT_CHANNEL_MAGIC "magic"
/// Cult teleportation, does whatever it wants (unless there's holiness)
#define TELEPORT_CHANNEL_CULT "cult"
/// Anything else
#define TELEPORT_CHANNEL_FREE "free"

//Teleport restriction modes (For areas)
#define TELEPORT_ALLOW_ALL 0
#define TELEPORT_ALLOW_NONE 1
#define TELEPORT_ALLOW_CLOCKWORK 2
#define TELEPORT_ALLOW_ABDUCTORS 3

//Teleport modes
#define TELEPORT_MODE_DEFAULT 0
#define TELEPORT_MODE_CLOCKWORK 2
#define TELEPORT_MODE_ABDUCTORS 3

/// possible bitflag return values of [atom/proc/intercept_zImpact] calls
/// Stops the movable from falling further and crashing on the ground. Example: stairs.
#define FALL_INTERCEPTED (1<<0)
/// Suppresses the "[movable] falls through [old_turf]" message because it'd make little sense in certain contexts like climbing stairs.
#define FALL_NO_MESSAGE (1<<1)
/// Used when the whole intercept_zImpact forvar loop should be stopped. For example: when someone falls into the supermatter and becomes dust.
#define FALL_STOP_INTERCEPTING (1<<2)
