#define WATT *1
#define KILOWATT *1000
#define MEGAWATT KILOWATT *1000
#define GIGAWATT MEGAWATT *1000

/// This define is used to create some loss of power so that some power transfers aren't exactly 1:1. At 15% loss currently
#define POWER_TRANSFER_LOSS 0.85

GLOBAL_LIST_EMPTY(powernets)

#define SOLAR_TRACK_OFF 0
#define SOLAR_TRACK_TIMED 1
#define SOLAR_TRACK_AUTO 2
