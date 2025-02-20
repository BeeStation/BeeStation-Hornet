
///Action button checks if hands are unusable
#define AB_CHECK_HANDS_BLOCKED (1<<0)
///Action button checks if user is immobile
#define AB_CHECK_IMMOBILE (1<<1)
///Action button checks if user is resting
#define AB_CHECK_LYING (1<<2)
///Action button checks if user is conscious
#define AB_CHECK_CONSCIOUS (1<<3)
///Action button checks if user is incapacitated
#define AB_CHECK_INCAPACITATED (1<<4)
///Action button checks if user is jaunting
#define AB_CHECK_PHASED (1<<5)
/// Action button works when unconcious, but not when dead
#define AB_CHECK_DEAD (1<<6)

//Bitfield is in /_DEFINES/_globablvars/bitfields.dm for reasons

///Action button triggered with right click
#define TRIGGER_SECONDARY_ACTION (1<<0)
///Action triggered to ignore any availability checks
#define TRIGGER_FORCE_AVAILABLE (1<<1)

/// The status shown in the stat panel.
/// Can be stuff like "ready", "on cooldown", "active", "charges", "charge cost", etc.
#define STAT_STATUS "Status"

#define ACTION_BUTTON_DEFAULT_BACKGROUND "_use_ui_default_background"

#define UPDATE_BUTTON_NAME (1<<0)
#define UPDATE_BUTTON_ICON (1<<1)
#define UPDATE_BUTTON_BACKGROUND (1<<2)
#define UPDATE_BUTTON_OVERLAY (1<<3)
#define UPDATE_BUTTON_STATUS (1<<4)

/// Takes in a typepath of a `/datum/action` and adds it to `src`.
/// Only useful if you want to add the action and never desire to reference it again ever.
#define GRANT_ACTION(typepath) do {\
	var/datum/action/_ability = new typepath(src);\
	_ability.Grant(src);\
} while (FALSE)

#define GRANT_ACTION_MOB(typepath, mob) do {\
	var/datum/action/_ability = new typepath(mob);\
	_ability.Grant(mob);\
} while (FALSE)
