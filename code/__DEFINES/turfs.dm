#define CHANGETURF_DEFER_CHANGE		1
#define CHANGETURF_IGNORE_AIR		2 //! This flag prevents changeturf from gathering air from nearby turfs to fill the new turf with an approximation of local air
#define CHANGETURF_FORCEOP			4
#define CHANGETURF_SKIP				8 //! A flag for PlaceOnTop to just instance the new turf instead of calling ChangeTurf. Used for uninitialized turfs NOTHING ELSE
#define CHANGETURF_INHERIT_AIR 16 //! Inherit air from previous turf. Implies CHANGETURF_IGNORE_AIR
#define CHANGETURF_RECALC_ADJACENT 32 //! Immediately recalc adjacent atmos turfs instead of queuing.

//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
///Returns a list of turf in a square
#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(RADIUS),1),          max(CENTER.y-(RADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
  )

#define RANGE_TURFS_XY(XRADIUS, YRADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(XRADIUS),1),          max(CENTER.y-(YRADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(XRADIUS),world.maxx), min(CENTER.y+(YRADIUS),world.maxy), CENTER.z) \
  )

///Returns all turfs in a zlevel
#define Z_TURFS(ZLEVEL) block(locate(1,1,ZLEVEL), locate(world.maxx, world.maxy, ZLEVEL))

#define TURF_FROM_COORDS_LIST(List) (locate(List[1], List[2], List[3]))

//Wet floor type flags. Stronger ones should be higher in number.
/// Turf is dry and mobs won't slip
#define TURF_DRY (0)
/// Turf has water on the floor and mobs will slip unless walking or using galoshes
#define TURF_WET_WATER (1<<0)
/// Turf has a thick layer of ice on the floor and mobs will slip in the direction until they bump into something
#define TURF_WET_PERMAFROST (1<<1)
/// Turf has a thin layer of ice on the floor and mobs will slip
#define TURF_WET_ICE (1<<2)
/// Turf has lube on the floor and mobs will slip
#define TURF_WET_LUBE (1<<3)
/// Turf has superlube on the floor and mobs will slip even if they are crawling
#define TURF_WET_SUPERLUBE (1<<4)

/// Maximum amount of time, (in deciseconds) a tile can be wet for.
#define MAXIMUM_WET_TIME 5 MINUTES

/**
 * Get the turf that `A` resides in, regardless of any containers.
 *
 * Use in favor of `A.loc` or `src.loc` so that things work correctly when
 * stored inside an inventory, locker, or other container.
 */
#define get_turf(A) (get_step(A, 0))

/**
 * Get the ultimate area of `A`, similarly to [get_turf].
 *
 * Use instead of `A.loc.loc`.
 */
#define get_area(A) (isarea(A) ? A : get_step(A, 0)?.loc)
