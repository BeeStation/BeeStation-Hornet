//Ghost orbit types:
/// Ghosts will orbit objects in a circle
#define GHOST_ORBIT_CIRCLE "circle"
/// Ghosts will orbit objects in a triangle
#define GHOST_ORBIT_TRIANGLE "triangle"
/// Ghosts will orbit objects in a hexagon
#define GHOST_ORBIT_HEXAGON "hexagon"
/// Ghosts will orbit objects in a square
#define GHOST_ORBIT_SQUARE "square"
/// Ghosts will orbit objects in a pentagon
#define GHOST_ORBIT_PENTAGON "pentagon"

// DEADCHAT MESSAGE TYPES //
/// Deadchat notification for important round events (RED_ALERT, shuttle EVAC, communication announcements, etc.)
#define DEADCHAT_ANNOUNCEMENT "announcement"
/// Deadchat notification for new players who join the round at arrivals
#define DEADCHAT_ARRIVALRATTLE "arrivalrattle"
/// Deadchat notification for players who die during the round
#define DEADCHAT_DEATHRATTLE "deathrattle"
/// Deadchat notification for when there is an AI law change
#define DEADCHAT_LAWCHANGE "lawchange"
/// Deadchat regular ghost chat
#define DEADCHAT_REGULAR "regular-deadchat"

/// Maximum view range by-default for ghosts
#define GHOST_MAX_VIEW_RANGE_DEFAULT 10
/// Maximum view range by-default for BYOND members
#define GHOST_MAX_VIEW_RANGE_MEMBER 14

/// Pictures taken by a camera will not display ghosts
#define CAMERA_NO_GHOSTS 0
/// Pictures taken by a camera will display ghosts in the photo
#define CAMERA_SEE_GHOSTS_BASIC 1
/// Pictures taken by a camera will display ghosts and their orbits
#define CAMERA_SEE_GHOSTS_ORBIT 2 // this doesn't do anything right now as of Mar 2023
