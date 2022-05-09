#define STATION_TRAIT_POSITIVE 1
#define STATION_TRAIT_NEUTRAL 2
#define STATION_TRAIT_NEGATIVE 3


#define STATION_TRAIT_ABSTRACT (1<<0)

//TODO Move to a pref //Move to a config instead of a define
#define STATION_GOAL_BUDGET  1

#define PR_ANNOUNCEMENTS_PER_ROUND 5 //The number of unique PR announcements allowed per round
									//This makes sure that a single person can only spam 3 reopens and 3 closes before being ignored
