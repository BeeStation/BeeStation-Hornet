/// The minimum for glide_size to be clamped to.
#define MIN_GLIDE_SIZE 1
/// The maximum for glide_size to be clamped to.
/// This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

/// Compensating for time dilation
GLOBAL_VAR_INIT(glide_size_multiplier, 1.0)

///Broken down, here's what this does:
/// divides the world icon_size (32) by delay divided by ticklag to get the number of pixels something should be moving each tick.
/// The division result is given a min value of 1 to prevent obscenely slow glide sizes from being set
/// Then that's multiplied by the global glide size multiplier. 1.25 by default feels pretty close to spot on. This is just to try to get byond to behave.
/// The whole result is then clamped to within the range above.
/// Not very readable but it works
#define DELAY_TO_GLIDE_SIZE(delay) (clamp(((world.icon_size / max((delay) / world.tick_lag, 1)) * GLOB.glide_size_multiplier), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE))

///Similar to DELAY_TO_GLIDE_SIZE, except without the clamping, and it supports piping in an unrelated scalar
#define MOVEMENT_ADJUSTED_GLIDE_SIZE(delay, movement_disparity) (world.icon_size / ((delay) / world.tick_lag) * movement_disparity * GLOB.glide_size_multiplier)

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
///Should we override the loop's glide?
#define MOVEMENT_LOOP_IGNORE_GLIDE (1<<2)
///Should we not update our movables dir on move?
#define MOVEMENT_LOOP_NO_DIR_UPDATE (1<<3)

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
/// /// Snowflakey gateway teleportation from Stargate... Gateway...? (idk) it uses old technology
#define TELEPORT_CHANNEL_GATEWAY "gateway"
/// Quantum-based teleportation, requires both sender and receiver, but is free from normal disruption
#define TELEPORT_CHANNEL_QUANTUM "quantum"
/// Wormhole teleportation, is not disrupted by bluespace fluctuations but tends to be very random or unsafe
#define TELEPORT_CHANNEL_WORMHOLE "wormhole"
/// Magic teleportation, does whatever it wants (unless there's antimagic)
#define TELEPORT_CHANNEL_MAGIC "magic"
/// Magic teleportation cast by the user
#define TELEPORT_CHANNEL_MAGIC_SELF "magic_self"
/// Cult teleportation, does whatever it wants (unless there's holiness)
#define TELEPORT_CHANNEL_CULT "cult"
/// Teleportation with only a sender, but not disrupted by the BOH
#define TELEPORT_CHANNEL_BLINK "blink"
/// Anything else
#define TELEPORT_CHANNEL_FREE "free"

///Return values for moveloop Move()
#define MOVELOOP_FAILURE 0
#define MOVELOOP_SUCCESS 1
#define MOVELOOP_NOT_READY 2

//Teleport restriction modes (For areas)
/// No restrictions
#define TELEPORT_ALLOW_ALL 0
/// Everyone is restricted
#define TELEPORT_ALLOW_NONE 1
/// Everyone but clockwork is restricted
#define TELEPORT_ALLOW_CLOCKWORK 2
/// Everyone but abductors is restricted
#define TELEPORT_ALLOW_ABDUCTORS 3
/// Everyone but wizards is restricted
#define TELEPORT_ALLOW_WIZARD 4

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
		user.add_or_update_variable_movespeed_modifier(movespeed_id, multiplicative_slowdown=speed * __proportion);\
	} else {\
		user.remove_movespeed_modifier(movespeed_id);\
	}

/// Generic position of user offset for /datum/component/riding
#define RIDING_OFFSET_ALL "ALL"
