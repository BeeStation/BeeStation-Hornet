///Defines for anomaly types (for supermatter spawning)
#define ANOMALY_BIOSCRAMBLER "bioscrambler_anomaly"
#define ANOMALY_FLUX "flux_anomaly"
#define ANOMALY_GRAVITATIONAL "gravitational_anomaly"
#define ANOMALY_HALLUCINATION "hallucination_anomaly"
#define ANOMALY_EXO "exothermic_anomaly"
#define ANOMALY_VORTEX "vortex_anomaly"
#define ANOMALY_ENDO "endothermic_anomaly"
#define ANOMALY_TRAP "beartrap_anomaly"
#define ANOMALY_CLOWN "clown_anomaly"
#define ANOMALY_MIME "mime_anomaly"
#define ANOMALY_BABEL "babel_anomaly"
#define ANOMALY_MONKEY "monkey_anomaly"
#define ANOMALY_CARP "carp_anomaly"
#define ANOMALY_NUCLEAR "nuclear_anomaly"
#define ANOMALY_GLITCH "glitch_anomaly"


///Defines for area allowances
#define ANOMALY_AREA_BLACKLIST list(/area/ai_monitored/turret_protected/ai,/area/ai_monitored/turret_protected/ai_upload,/area/engine,/area/solar,/area/holodeck,/area/shuttle)
#define ANOMALY_AREA_SUBTYPE_WHITELIST list(/area/engine/break_room)

///Defines for weighted anomaly chances
#define ANOMALY_WEIGHTS list(ANOMALY_GRAVITATIONAL = 55, ANOMALY_HALLUCINATION = 45, ANOMALY_TRAP = 40, ANOMALY_CLOWN = 40, ANOMALY_MIME = 40, ANOMALY_BABEL = 40, ANOMALY_MONKEY = 40, ANOMALY_CARP = 40, ANOMALY_BIOSCRAMBLER = 35, ANOMALY_NUCLEAR = 30, ANOMALY_FLUX = 25,  ANOMALY_EXO = 5, ANOMALY_ENDO = 5, ANOMALY_VORTEX = 1, ANOMALY_GLITCH = 1)

///Defines for the different types of explosion a flux anomaly can have
#define ANOMALY_FLUX_NO_EXPLOSION 0
#define ANOMALY_FLUX_EXPLOSIVE 1
#define ANOMALY_FLUX_LOW_EXPLOSIVE 2

/// Chance of anomalies moving every process tick
#define ANOMALY_MOVECHANCE 45
