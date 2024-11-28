
/// Wanted statuses
#define WANTED_ARREST "Arrest"
#define WANTED_DISCHARGED "Discharged"
#define WANTED_NONE "None"
#define WANTED_PAROLE "Parole"
#define WANTED_PRISONER "Incarcerated"
#define WANTED_SUSPECT "Suspected"

/// List of available wanted statuses
#define WANTED_STATUSES(...) list(\
	WANTED_NONE, \
	WANTED_SUSPECT, \
	WANTED_ARREST, \
	WANTED_PRISONER, \
	WANTED_PAROLE, \
	WANTED_DISCHARGED, \
)
