#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8

//fugitive end results
#define FUGITIVE_RESULT_BADASS_HUNTER 0
#define FUGITIVE_RESULT_POSTMORTEM_HUNTER 1
#define FUGITIVE_RESULT_MAJOR_HUNTER 2
#define FUGITIVE_RESULT_HUNTER_VICTORY 3
#define FUGITIVE_RESULT_MINOR_HUNTER 4
#define FUGITIVE_RESULT_STALEMATE 5
#define FUGITIVE_RESULT_MINOR_FUGITIVE 6
#define FUGITIVE_RESULT_FUGITIVE_VICTORY 7
#define FUGITIVE_RESULT_MAJOR_FUGITIVE 8

#define APPRENTICE_DESTRUCTION "destruction"
#define APPRENTICE_BLUESPACE "bluespace"
#define APPRENTICE_ROBELESS "robeless"
#define APPRENTICE_HEALING "healing"


//Blob
#define BLOB_REROLL_TIME 2400 //blob gets a free reroll every X time
#define BLOB_SPREAD_COST 4
#define BLOB_ATTACK_REFUND 2 //blob refunds this much if it attacks and doesn't spread
#define BLOB_REFLECTOR_COST 15
#define BLOB_STRAIN_COLOR_LIST list("#BE5532", "#7D6EB4", "#EC8383", "#00E5B1", "#00668B", "#FFF68", "#BBBBAA", "#CD7794", "#57787B", "#3C6EC8", "#AD6570", "#823ABB")

//Shuttle hijacking
#define HIJACK_NEUTRAL 0 //Does not stop hijacking but itself won't hijack
#define HIJACK_HIJACKER 1 //Needs to be present for shuttle to be hijacked
#define HIJACK_PREVENT 2 //Prevents hijacking same way as non-antags

//Overthrow time to update heads obj
#define OBJECTIVE_UPDATING_TIME 300

//Assimilation
#define TRACKER_DEFAULT_TIME 900
#define TRACKER_MINDSHIELD_TIME 1200
#define TRACKER_AWAKENED_TIME	3000
#define TRACKER_BONUS_LARGE 300
#define TRACKER_BONUS_SMALL 100

//gang dominators
#define NOT_DOMINATING			-1
#define MAX_LEADERS_GANG		3
#define INITIAL_DOM_ATTEMPTS	3

//yoinked from hippie (infiltrators):
#define ANTAG_DATUM_INFILTRATOR	/datum/antagonist/infiltrator
#define ANTAG_DATUM_HIJACKEDAI	/datum/antagonist/hijacked_ai

//Syndicate Contracts
#define CONTRACT_STATUS_INACTIVE 1
#define CONTRACT_STATUS_ACTIVE 2
#define CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE 3
#define CONTRACT_STATUS_EXTRACTING 4
#define CONTRACT_STATUS_COMPLETE 5
#define CONTRACT_STATUS_ABORTED 6

#define CONTRACT_PAYOUT_LARGE 1
#define CONTRACT_PAYOUT_MEDIUM 2
#define CONTRACT_PAYOUT_SMALL 3

#define CONTRACT_UPLINK_PAGE_CONTRACTS "CONTRACTS"
#define CONTRACT_UPLINK_PAGE_HUB "HUB"

//Special Antagonists
#define SPAWNTYPE_ROUNDSTART "roundstart"
#define SPAWNTYPE_MIDROUND "midround"
#define SPAWNTYPE_EITHER "either"
