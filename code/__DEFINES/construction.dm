/*ALL DEFINES RELATED TO CONSTRUCTION, CONSTRUCTING THINGS, OR CONSTRUCTED OBJECTS GO HERE*/

//Defines for construction states

// girder construction states
#define GIRDER_NORMAL 0
#define GIRDER_REINF_STRUTS 1
#define GIRDER_REINF 2
#define GIRDER_DISPLACED 3
#define GIRDER_DISASSEMBLED 4

// rwall construction states
#define INTACT 0
#define SUPPORT_LINES 1
#define COVER 2
#define CUT_COVER 3
#define ANCHOR_BOLTS 4
#define SUPPORT_RODS 5
#define SHEATH 6

// cwall construction states
#define COG_COVER 1
#define COG_EXPOSED 3

// window construction states
#define WINDOW_OUT_OF_FRAME 0
#define WINDOW_IN_FRAME 1
#define WINDOW_SCREWED_TO_FRAME 2

// airlock assembly construction states
#define AIRLOCK_ASSEMBLY_NEEDS_WIRES 0
#define AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS 1
#define AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER 2

///The blast door is missing wires, first step of construction.
#define BLASTDOOR_NEEDS_WIRES 0
///The blast door needs electronics, second step of construction.
#define BLASTDOOR_NEEDS_ELECTRONICS 1
///The blast door is fully constructed.
#define BLASTDOOR_FINISHED 2

// default_unfasten_wrench() return defines
#define CANT_UNFASTEN 0
#define FAILED_UNFASTEN 1
#define SUCCESSFUL_UNFASTEN 2

// ai core defines
#define EMPTY_CORE 0
#define CIRCUIT_CORE 1
#define SCREWED_CORE 2
#define CABLED_CORE 3
#define GLASS_CORE 4
#define AI_READY_CORE 5

// Construction defines for the pinion airlock
#define GEAR_SECURE 1
#define GEAR_LOOSE 2

// floodlights because apparently we use defines now
#define FLOODLIGHT_NEEDS_WIRES 0
#define FLOODLIGHT_NEEDS_LIGHTS 1
#define FLOODLIGHT_NEEDS_SECURING 2
#define FLOODLIGHT_NEEDS_WRENCHING 3

// turnstile state
#define TURNSTILE_SECURED 0
#define TURNSTILE_CIRCUIT_EXPOSED 1
#define TURNSTILE_SHELL 2

//! ## other construction-related things

/// windows affected by Nar'Sie turn this color.
#define NARSIE_WINDOW_COLOUR "#7D1919"

/// The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MINERAL_MATERIAL_AMOUNT 2000
/// The maximum size of a stack object.
#define MAX_STACK_SIZE 50
/// maximum amount of cable in a coil
#define MAXCOIL 30

// rcd buildtype defines
// these aren't even used as bitflags so who even knows why they are treated like them
#define RCD_FLOORWALL (1<<0)
#define RCD_AIRLOCK (1<<1)
#define RCD_DECONSTRUCT (1<<2)
#define RCD_WINDOWGRILLE (1<<3)
#define RCD_MACHINE (1<<4)
#define RCD_COMPUTER (1<<5)
#define RCD_FURNISHING (1<<6)
#define RCD_LADDER (1<<7)

#define RCD_UPGRADE_FRAMES (1<<0)
#define RCD_UPGRADE_SIMPLE_CIRCUITS	(1<<1)
#define RCD_UPGRADE_SILO_LINK (1<<2)
#define RCD_UPGRADE_FURNISHING (1<<3)

#define RPD_UPGRADE_UNWRENCH (1<<0)

#define RCD_WINDOW_FULLTILE "full tile"
#define RCD_WINDOW_DIRECTIONAL "directional"
#define RCD_WINDOW_NORMAL "glass"
#define RCD_WINDOW_REINFORCED "reinforced glass"

#define RCD_MEMORY_WALL 1
#define RCD_MEMORY_WINDOWGRILLE 2

// How much faster to use the RCD when on a tile with memory
#define RCD_MEMORY_SPEED_BUFF 5

/// How much less resources the RCD uses when reconstructing
#define RCD_MEMORY_COST_BUFF 8

// Frame (de/con)struction states
/// Frame is empty, no wires no board
#define FRAME_STATE_EMPTY 0
/// Frame has been wired
#define FRAME_STATE_WIRED 1
/// Frame has a board installed, it is safe to assume if in this state then circuit is non-null (but you never know)
#define FRAME_STATE_BOARD_INSTALLED 2
/// Frame now has a board installed, it is safe to assume beyond this state, circuit is non-null (but you never know)
#define FRAME_COMPUTER_STATE_BOARD_INSTALLED 1
/// Board has been secured
#define FRAME_COMPUTER_STATE_BOARD_SECURED 2
/// Frame has been wired
#define FRAME_COMPUTER_STATE_WIRED 3
/// Frame has had glass applied to it
#define FRAME_COMPUTER_STATE_GLASSED 4
