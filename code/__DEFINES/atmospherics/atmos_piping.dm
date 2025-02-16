//PIPES
//Defines for pipe bitmasking
#define NORTH_FULLPIPE (1<<0) //also just NORTH
#define SOUTH_FULLPIPE (1<<1) //also just SOUTH
#define EAST_FULLPIPE (1<<2) //also just EAST
#define WEST_FULLPIPE (1<<3) //also just WEST
#define NORTH_SHORTPIPE (1<<4)
#define SOUTH_SHORTPIPE (1<<5)
#define EAST_SHORTPIPE (1<<6)
#define WEST_SHORTPIPE (1<<7)
// Helpers to convert cardinals to and from pipe bitfields
// Assumes X_FULLPIPE = X, X_SHORTPIPE >> 4 = X, X_PIPECAPS >> 8 = X as above
#define FULLPIPE_TO_CARDINALS(bitfield) ((bitfield) & ALL_CARDINALS)
#define SHORTPIPE_TO_CARDINALS(bitfield) (((bitfield) >> 4) & ALL_CARDINALS)
#define PIPECAPS_TO_CARDINALS(bitfield) (((bitfield) >> 8) & ALL_CARDINALS)
#define CARDINAL_TO_FULLPIPES(cardinals) (cardinals)
#define CARDINAL_TO_SHORTPIPES(cardinals) ((cardinals) << 4)
#define CARDINAL_TO_PIPECAPS(cardinals) ((cardinals) << 8)
// A pipe is a stub if it only has zero or one permitted direction. For a regular pipe this is nonsensical, and there are no pipe sprites for this, so it is not allowed.
#define ISSTUB(bits) !((bits) & ((bits) - 1))
#define ISNOTSTUB(bits) ((bits) & ((bits) - 1))
//Atmos pipe limits
/// (kPa) What pressure pumps and powered equipment max out at.
#define MAX_OUTPUT_PRESSURE 4500
/// (L/s) Maximum speed powered equipment can work at.
#define MAX_TRANSFER_RATE 200
/// (kPa) Minimum pressure volume pumps can move.
#define VOLUME_PUMP_MINIMUM_OUTPUT_PRESSURE 0.01
/// (kPa) What pressure volume pumps max out at.
#define VOLUME_PUMP_MAX_OUTPUT_PRESSURE 9000
/// (kPa) Allowed pressure difference between input and output pipenets for overclocked volume pump.
#define VOLUME_PUMP_OVERPRESSURE_ALLOWANCE 1000
/// How many percent of the contents that an overclocked volume pumps leak into the air.
#define VOLUME_PUMP_LEAK_AMOUNT 0.1
//used for device_type vars
#define UNARY 1
#define BINARY 2
#define TRINARY 3
#define QUATERNARY 4

// The volume per direction of atmos pipes.
#define UNARY_PIPE_VOLUME 35

//TANKS
/// The volume of the standard handheld gas tanks on the station.
#define TANK_STANDARD_VOLUME 70
/// The minimum pressure an gas tanks release valve can be set to.
#define TANK_MIN_RELEASE_PRESSURE 0
/// The maximum pressure an gas tanks release valve can be set to.
#define TANK_MAX_RELEASE_PRESSURE (ONE_ATMOSPHERE*3)
/// The default initial value gas tanks release valves are set to. (At least the ones containing pure plasma/oxygen.)
#define TANK_DEFAULT_RELEASE_PRESSURE 16
/// temperature in kelvins at which a tank will start to melt
#define TANK_MELT_TEMPERATURE 1000000
/// Tank starts leaking
#define TANK_LEAK_PRESSURE (30.*ONE_ATMOSPHERE)
/// Tank spills all contents into atmosphere
#define TANK_RUPTURE_PRESSURE (35.*ONE_ATMOSPHERE)
/// Boom 3x3 base explosion
#define TANK_FRAGMENT_PRESSURE (40.*ONE_ATMOSPHERE)
/// +1 for each SCALE kPa aboe threshold
#define TANK_FRAGMENT_SCALE (6.*ONE_ATMOSPHERE)
/// Denotes that our tank is overpressurized simply from gas merging.
#define TANK_MERGE_OVERPRESSURE "tank_overpressure"
// Indices for the reaction_results returned by explosion_information()
/// Reactions that have happened in the tank.
#define TANK_RESULTS_REACTION 1
/// Additional information of the tank.
#define TANK_RESULTS_MISC 2

//MULTIPIPES
//IF YOU EVER CHANGE THESE CHANGE SPRITES TO MATCH.
//layer = initial(layer) + piping_layer / 1000 in atmospherics/update_icon() to determine order of pipe overlap
#define PIPING_LAYER_MIN 1
#define PIPING_LAYER_2 2
#define PIPING_LAYER_DEFAULT 3
#define PIPING_LAYER_4 4
#define PIPING_LAYER_MAX 5
#define PIPING_LAYER_P_X 5
#define PIPING_LAYER_P_Y 5
#define PIPING_LAYER_LCHANGE 0.005

/// intended to connect with all layers, check for all instead of just one.
#define PIPING_ALL_LAYER (1<<0)
/// can only be built if nothing else with this flag is on the tile already.
#define PIPING_ONE_PER_TURF (1<<1)
/// can only exist at PIPING_LAYER_DEFAULT
#define PIPING_DEFAULT_LAYER_ONLY (1<<2)
/// north/south east/west doesn't matter, auto normalize on build.
#define PIPING_CARDINAL_AUTONORMALIZE (1<<3)
/// intended to connect with everything, both layers and colors
#define PIPING_ALL_COLORS (1<<4)
/// can bridge over pipenets
#define PIPING_BRIDGE (1<<5)
/// intended to connect with layers 2 and 4 only
#define PIPING_DISTRO_AND_WASTE_LAYERS (1<<6)

// Ventcrawling bitflags, handled in var/vent_movement
///Allows for ventcrawling to occur. All atmospheric machines have this flag on by default. Cryo is the exception
#define VENTCRAWL_ALLOWED	(1<<0)
///Allows mobs to enter or leave from atmospheric machines. On for passive, unary, and scrubber vents.
#define VENTCRAWL_ENTRANCE_ALLOWED (1<<1)
///Used to check if a machinery is visible. Called by update_pipe_vision(). On by default for all except cryo.
#define VENTCRAWL_CAN_SEE	(1<<2)

