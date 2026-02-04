#define DEPARTMENTAL_FLAG_SECURITY (1<<0)
#define DEPARTMENTAL_FLAG_MEDICAL (1<<1)
#define DEPARTMENTAL_FLAG_CARGO	(1<<2)
#define DEPARTMENTAL_FLAG_SCIENCE (1<<3)
#define DEPARTMENTAL_FLAG_ENGINEERING (1<<4)
#define DEPARTMENTAL_FLAG_SERVICE (1<<5)
#define DEPARTMENTAL_FLAG_ALL (1<<6) //NO THIS DOESN'T ALLOW YOU TO PRINT EVERYTHING, IT'S FOR ALL DEPARTMENTS!

#define DESIGN_ID_IGNORE "IGNORE_THIS_DESIGN"

/// When adding new types, update the list below!
#define TECHWEB_POINT_TYPE_GENERIC "General Research"
#define TECHWEB_POINT_TYPE_DISCOVERY "Discovery Research"
#define TECHWEB_POINT_TYPE_NANITES "Nanite Research"

/// Defined here so people don't forget to change this!
#define TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES list(\
	TECHWEB_POINT_TYPE_GENERIC = "Gen. Res.",\
	TECHWEB_POINT_TYPE_DISCOVERY = "Disc. Res.",\
	TECHWEB_POINT_TYPE_NANITES = "Nan. Res.",\
)

/// Amount of points required to unlock nodes of corresponding tiers.
/// Not actual tech tiers, just like how advanced mops take less research points than bluespace teleportation.
#define TECHWEB_TIER_1_POINTS 40
#define TECHWEB_TIER_2_POINTS 80
#define TECHWEB_TIER_3_POINTS 120
#define TECHWEB_TIER_4_POINTS 160
#define TECHWEB_TIER_5_POINTS 200

/// Adjust as needed; Stops toxins from nullifying RND progression mechanics.
#define TECHWEB_BOMB_POINTCAP TECHWEB_TIER_5_POINTS * 5
#define TECHWEB_BOMB_MONEYCAP 50000

#define EXPLORATION_TRACKING "exploration_tracking"

/// Connects the 'server_var' to a valid research server on your Z level.
/// Used for machines in LateInitialize, to ensure that RND servers are loaded first.
#define CONNECT_TO_RND_SERVER_ROUNDSTART(server_var, holder) do { \
	var/list/found_servers = SSresearch.get_available_servers(get_turf(holder)); \
	var/obj/machinery/rnd/server/selected_server = length(found_servers) ? found_servers[1] : null; \
	if (selected_server) { \
		server_var = selected_server.stored_research; \
	}; \
	else { \
		var/datum/techweb/station_fallback_web = locate(/datum/techweb/science) in SSresearch.techwebs; \
		server_var = station_fallback_web; \
	}; \
} while (FALSE)
