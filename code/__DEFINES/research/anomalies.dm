///Defines for anomaly types
#define ANOMALY_FLUX "flux_anomaly"
#define ANOMALY_GRAVITATIONAL "gravitational_anomaly"
#define ANOMALY_PYRO "pyro_anomaly"
#define ANOMALY_VORTEX "vortex_anomaly"

///Defines for area allowances
#define ANOMALY_AREA_BLACKLIST list(/area/ai_monitored/turret_protected/ai,/area/ai_monitored/turret_protected/ai_upload,/area/engine,/area/solar,/area/holodeck,/area/shuttle)
#define ANOMALY_AREA_SUBTYPE_WHITELIST list(/area/engine/break_room)

///Defines for weighted anomaly chances
#define ANOMALY_WEIGHTS list(ANOMALY_FLUX = 75, ANOMALY_GRAVITATIONAL = 25, ANOMALY_PYRO = 5)

///Defines for the different types of explosion a flux anomaly can have
#define FLUX_NO_EXPLOSION 0
#define FLUX_EXPLOSIVE 1
#define FLUX_LOW_EXPLOSIVE 2
