/// Physical statuses
#define PHYSICAL_ACTIVE "Active"
#define PHYSICAL_DEBILITATED "Debilitated"
#define PHYSICAL_UNCONSCIOUS "Unconscious"
#define PHYSICAL_DECEASED "Deceased"

/// List of available physical statuses
#define PHYSICAL_STATUSES(...) list(\
	PHYSICAL_ACTIVE, \
	PHYSICAL_DEBILITATED, \
	PHYSICAL_UNCONSCIOUS, \
	PHYSICAL_DECEASED, \
)

/// Mental statuses
#define MENTAL_STABLE "Stable"
#define MENTAL_WATCH "Watch"
#define MENTAL_UNSTABLE "Unstable"
#define MENTAL_INSANE "Insane"

/// List of available mental statuses
#define MENTAL_STATUSES(...) list(\
	MENTAL_STABLE, \
	MENTAL_WATCH, \
	MENTAL_UNSTABLE, \
	MENTAL_INSANE, \
)

/// Possible application results
#define MEDICAL_ITEM_NO_INTERCEPT 0
#define MEDICAL_ITEM_APPLIED 1
#define MEDICAL_ITEM_FAILED 2
#define MEDICAL_ITEM_VALID 3
