//update_state
//Shifts 0/1/2 are used by UPSTATE_OPENED1 and UPSTATE_OPENED2 with a base shift of 0 (see _DEFINES/apc.dm)
#define UPSTATE_MAINT		(1<<3)
#define UPSTATE_BROKE		(1<<4)
#define UPSTATE_BLUESCREEN	(1<<5)
#define UPSTATE_WIREEXP		(1<<6)
#define UPSTATE_ALLGOOD		(1<<7)
#define UPSTATE_CELL_IN		(1<<8)

#define APC_RESET_EMP "emp"

//update_overlay
#define APC_UPOVERLAY_CHARGEING0	(1<<0)
#define APC_UPOVERLAY_CHARGEING1	(1<<1)
#define APC_UPOVERLAY_CHARGEING2	(1<<2)
#define APC_UPOVERLAY_EQUIPMENT0	(1<<3)
#define APC_UPOVERLAY_EQUIPMENT1	(1<<4)
#define APC_UPOVERLAY_EQUIPMENT2	(1<<5)
#define APC_UPOVERLAY_LIGHTING0		(1<<6)
#define APC_UPOVERLAY_LIGHTING1		(1<<7)
#define APC_UPOVERLAY_LIGHTING2		(1<<8)
#define APC_UPOVERLAY_ENVIRON0		(1<<9)
#define APC_UPOVERLAY_ENVIRON1		(1<<10)
#define APC_UPOVERLAY_ENVIRON2		(1<<11)
#define APC_UPOVERLAY_LOCKED		(1<<12)
#define APC_UPOVERLAY_OPERATING		(1<<13)

#define APC_ELECTRONICS_MISSING 0 // None
#define APC_ELECTRONICS_INSTALLED 1 // Installed but not secured
#define APC_ELECTRONICS_SECURED 2 // Installed and secured

#define APC_COVER_CLOSED 0
/// The APCs cover is open.
#define APC_COVER_OPENED 1
/// The APCs cover is missing.
#define APC_COVER_REMOVED 2
// APC charging status:
/// The APC is not charging.
#define APC_NOT_CHARGING 0
/// The APC is charging.
#define APC_CHARGING 1
/// The APC is fully charged.
#define APC_FULLY_CHARGED 2
