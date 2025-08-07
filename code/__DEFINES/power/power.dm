#define W *1
#define KW *1000
#define MW KW *1000
#define GW MW *1000

/// This define is used to create some loss of power so that some power transfers aren't exactly 1:1. At 15% loss currently
#define POWER_TRANSFER_LOSS * 0.85

GLOBAL_LIST_EMPTY(powernets)
