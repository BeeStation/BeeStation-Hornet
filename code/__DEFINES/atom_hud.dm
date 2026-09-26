// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists

/// dead, alive, sick, health status
#define HEALTH_HUD "1"
/// a simple line rounding the mob's number health
#define STATUS_HUD "2"
/// the job asigned to your ID
#define ID_HUD "3"
/// wanted, released, parroled, security status
#define WANTED_HUD "4"
/// loyality implant
#define IMPLOYAL_HUD "5"
/// chemical implant
#define IMPCHEM_HUD "6"
/// tracking implant
#define IMPTRACK_HUD "7"
/// Silicon/Mech/Circuit Status
#define DIAG_STAT_HUD "8"
/// Silicon health bar
#define DIAG_HUD "9"
/// Borg/Mech/Circutry power meter
#define DIAG_BATT_HUD "10"
/// Mech health bar
#define DIAG_MECH_HUD "11"
/// Bot HUDs
#define DIAG_BOT_HUD "12"
/// Mech/Silicon tracking beacon, Circutry long range icon
#define DIAG_TRACK_HUD "13"
/// Airlock shock overlay
#define DIAG_AIRLOCK_HUD "14"
/// Bot path indicators
#define DIAG_PATH_HUD "15"
/// Gland indicators for abductors
#define GLAND_HUD "16"
/// AI detector
#define AI_DETECT_HUD "17"
/// HUD element when a nanite user has the monitoring program
#define NANITE_HUD "18"
/// Nanite fullness hud
#define DIAG_NANITE_FULL_HUD "19"
/// Displays launchpads' targeting reticle
#define DIAG_LAUNCHPAD_HUD "20"
/// Bluespace Wakes
#define BLUESPACE_WAKE_HUD "21"
/// Gives permanent visibility of hacked APCs
#define HACKED_APC_HUD "22"

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

//data HUD (medhud, sechud) defines
//Don't forget to update human/New() if you change these!
#define DATA_HUD_SECURITY_BASIC 1
#define DATA_HUD_SECURITY_ADVANCED 2
#define DATA_HUD_MEDICAL_BASIC 3
#define DATA_HUD_MEDICAL_ADVANCED 4
#define DATA_HUD_DIAGNOSTIC 5
#define DATA_HUD_BOT_PATH 6
#define DATA_HUD_ABDUCTOR 7
#define DATA_HUD_AI_DETECT 8
#define DATA_HUD_HACKED_APC 9

// Notification action types
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_ORBIT "orbit"

/// cooldown for being shown the images for any particular data hud
#define ADD_HUD_TO_COOLDOWN 20
