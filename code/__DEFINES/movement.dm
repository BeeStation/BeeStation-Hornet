//Movement loop priority. Only one loop can run at a time, this dictates that
// Higher numbers beat lower numbers
///Standard, go lower then this if you want to override, higher otherwise
#define MOVEMENT_DEFAULT_PRIORITY 10
///Very few things should override this
#define MOVEMENT_SPACE_PRIORITY 100
///Higher then the heavens
#define MOVEMENT_ABOVE_SPACE_PRIORITY (MOVEMENT_SPACE_PRIORITY + 1)

//Movement loop flags
///Should the loop act immediately following its addition?
#define MOVEMENT_LOOP_START_FAST (1<<0)
///Do we not use the priority system?
#define MOVEMENT_LOOP_IGNORE_PRIORITY (1<<1)

//Index defines for movement bucket data packets
#define MOVEMENT_BUCKET_TIME 1
#define MOVEMENT_BUCKET_LIST 2

// possible bitflag return values of intercept_zImpact(atom/movable/AM, levels = 1) calls
/// Stops the movable from falling further and crashing on the ground
#define FALL_INTERCEPTED (1<<0)
/// Used to suppress the "[A] falls through [old_turf]" messages where it'd make little sense at all, like going downstairs.
#define FALL_NO_MESSAGE (1<<1)
/// Used in situations where halting the whole "intercept" loop would be better, like supermatter dusting (and thus deleting) the atom.
#define FALL_STOP_INTERCEPTING (1<<2)

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
/// Teleportation with only a sender, but not disrupted by the BOH
#define TELEPORT_CHANNEL_BLINK "blink"
/// Anything else
#define TELEPORT_CHANNEL_FREE "free"

//Teleport restriction modes (For areas)
/// No restrictions
#define TELEPORT_ALLOW_ALL 0
/// Everyone is restricted
#define TELEPORT_ALLOW_NONE 1
/// Everyone but clockwork is restricted
#define TELEPORT_ALLOW_CLOCKWORK 2
/// Everyone but abductors is restricted
#define TELEPORT_ALLOW_ABDUCTORS 3

//Teleport modes
/// Default teleport mode
#define TELEPORT_MODE_DEFAULT 0
/// A clockwork teleport
#define TELEPORT_MODE_CLOCKWORK 2
/// An abductor teleport
#define TELEPORT_MODE_ABDUCTORS 3

// Jetpack Thrust
/// Thrust needed with gravity
#define THRUST_REQUIREMENT_GRAVITY 0.2
/// Thrust needed without gravity (in space)
#define THRUST_REQUIREMENT_SPACEMOVE 0.01
/// small number because we don't actually care about the energy here, just balance
#define GRAVITY_JOULE_REQUIREMENT 100
/// Amount to increase consumption by
#define JETPACK_COMBUSTION_CONSUMPTION_ADJUSTMENT 500

// The pressure at which jetpacks begin to slowdown
#define JETPACK_FAST_PRESSURE_MIN 20
// The pressure at which jetpacks reach their min speed
#define JETPACK_FAST_PRESSURE_MAX 80

#define JETPACK_SPEED_CHECK(user, movespeed_id, speed, full_speed) \
	var/datum/gas_mixture/__env = loc.return_air();\
	if(full_speed && __env.return_pressure() < JETPACK_FAST_PRESSURE_MAX) {\
		var/__proportion = CLAMP01(1 - ((__env.return_pressure() - JETPACK_FAST_PRESSURE_MIN) / (JETPACK_FAST_PRESSURE_MAX - JETPACK_FAST_PRESSURE_MIN)));\
		user.add_movespeed_modifier(movespeed_id, priority=100, override = TRUE, multiplicative_slowdown=speed * __proportion, movetypes=FLOATING, conflict=MOVE_CONFLICT_JETPACK);\
	} else {\
		user.remove_movespeed_modifier(movespeed_id);\
	}

/// Generic position of user offset for /datum/component/riding
#define RIDING_OFFSET_ALL "ALL"
