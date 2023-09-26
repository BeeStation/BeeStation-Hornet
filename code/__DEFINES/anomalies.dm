///Defines for anomaly types
#define ANOMALY_BIOSCRAMBLER "bioscrambler_anomaly"
#define ANOMALY_FLUX "flux_anomaly"
#define ANOMALY_GRAVITATIONAL "gravitational_anomaly"
#define ANOMALY_HALLUCINATION "hallucination_anomaly"
#define ANOMALY_PYRO "pyro_anomaly"
#define ANOMALY_VORTEX "vortex_anomaly"

///Defines for area allowances
#define ANOMALY_AREA_BLACKLIST list(/area/ai_monitored/turret_protected/ai,/area/ai_monitored/turret_protected/ai_upload,/area/engine,/area/solar,/area/holodeck,/area/shuttle)
#define ANOMALY_AREA_SUBTYPE_WHITELIST list(/area/engine/break_room)

///Defines for weighted anomaly chances
#define ANOMALY_WEIGHTS list(ANOMALY_GRAVITATIONAL = 55, ANOMALY_HALLUCINATION = 45, ANOMALY_BIOSCRAMBLER = 35, ANOMALY_FLUX = 25, ANOMALY_PYRO = 5, ANOMALY_VORTEX = 1)

///Defines for the different types of explosion a flux anomaly can have
#define ANOMALY_FLUX_NO_EXPLOSION 0
#define ANOMALY_FLUX_EXPLOSIVE 1
#define ANOMALY_FLUX_LOW_EXPLOSIVE 2
