// Helpers for checking whether a z-level conforms to a specific requirement

// Basic levels
#define is_centcom_level(z) SSmapping.level_trait(z, ZTRAIT_CENTCOM)

GLOBAL_LIST_EMPTY(station_levels_cache)

// Used to prevent z from being re-evaluated
GLOBAL_VAR(station_level_z_scratch)

// Called a lot, somewhat slow, so has its own cache
#define is_station_level(z) \
	( !z ? 0 : ( \
		( \
			/* The right hand side of this guarantees that we'll have the space to fill later on, while also not failing the condition */ \
			(GLOB.station_levels_cache.len < (GLOB.station_level_z_scratch = z) && (GLOB.station_levels_cache.len = GLOB.station_level_z_scratch)) \
			|| isnull(GLOB.station_levels_cache[GLOB.station_level_z_scratch]) \
		) \
		? (GLOB.station_levels_cache[GLOB.station_level_z_scratch] = !!SSmapping.level_trait(z, ZTRAIT_STATION)) \
		: GLOB.station_levels_cache[GLOB.station_level_z_scratch] \
	) )

#define is_mining_level(z) SSmapping.level_trait(z, ZTRAIT_MINING)

#define is_empty_level(z) SSmapping.level_trait(z, ZTRAIT_EMPTY)

#define is_reserved_level(z) SSmapping.level_trait(z, ZTRAIT_RESERVED)

#define is_away_level(z) SSmapping.level_trait(z, ZTRAIT_AWAY)

/**
 * A more complicated form of layer_a > layer_b, taking into account topdown layers
 *
 * - If both layers are topdown, checks if layer_a is greater than layer_b
 * - If neither layer is topdown, checks if layer_a is greater than layer_b
 * - If layer_a is topdown and layer_b is not, returns FALSE
 * - If layer_b is topdown and layer_a is not, returns TRUE
 */
#define COMPARE_LAYERS(layer_a, layer_b) \
	((layer_a) >= TOPDOWN_LAYER \
		? ((layer_b) >= TOPDOWN_LAYER \
			? ((layer_a) > (layer_b)) \
			: FALSE \
		) \
		: ((layer_b) >= TOPDOWN_LAYER \
			? TRUE \
			: ((layer_a) > (layer_b)) \
		) \
	)
